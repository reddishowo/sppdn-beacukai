// lib/app/modules/auth/controllers/auth_controller.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sppdn/app/routes/app_pages.dart'; 

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final GoogleSignIn _googleSignIn;
  
  Rxn<User> firebaseUser = Rxn<User>();
  RxBool isLoading = false.obs;
  
  final Rxn<DocumentSnapshot> _firestoreUser = Rxn<DocumentSnapshot>();
  StreamSubscription? _firestoreUserStream;

  bool get isAdmin {
    if (_firestoreUser.value != null && _firestoreUser.value!.exists) {
      final data = _firestoreUser.value!.data() as Map<String, dynamic>;
      return data.containsKey('role') && data['role'] == 'admin';
    }
    return false;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeGoogleSignIn();
  }
  
  void _initializeGoogleSignIn() {
    _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
    );
  }
  
  @override
  void onReady() {
    super.onReady();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setInitialScreen);
  }
  
  void _setInitialScreen(User? user) {
    if (user == null) {
      _firestoreUserStream?.cancel();
      _firestoreUser.value = null;
      Get.offAllNamed(Routes.LOGIN);
    } else {
      _firestoreUserStream = _firestore.collection('users').doc(user.uid).snapshots().listen((doc) {
        _firestoreUser.value = doc;
        update();
      });
      Get.offAllNamed(Routes.HOME);
    }
  }

  Future<void> _saveUserProfile(User user, {String? name}) async {
    await user.reload();
    final freshUser = _auth.currentUser!;
    final userName = name ?? freshUser.displayName ?? freshUser.email?.split('@')[0] ?? 'Pengguna';
    
    if (freshUser.displayName == null || freshUser.displayName != userName) {
      await freshUser.updateDisplayName(userName);
      await freshUser.reload();
    }
    
    final userData = {
      'uid': freshUser.uid,
      'name': userName,
      'email': freshUser.email,
      'lastUpdated': FieldValue.serverTimestamp(),
    };

    final docRef = _firestore.collection('users').doc(freshUser.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      userData['createdAt'] = FieldValue.serverTimestamp();
      
      final List<String> adminEmails = [
        'admin@sppdn.com',
        'sbuki.blbc@gmail.com',
      ];

      if (adminEmails.contains(freshUser.email)) {
        userData['role'] = 'admin';
      } else {
        userData['role'] = 'user';
      }
    }
    
    await docRef.set(userData, SetOptions(merge: true));
    firebaseUser.value = _auth.currentUser;
  }

  // **PERUBAHAN: Fungsi `updateUserName` telah dihapus sepenuhnya.**

  // ... (sisa kode register, login, dll. tetap sama) ...
  Future<void> register(String name, String email, String password) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Semua kolom wajib diisi.');
      return;
    }
    
    try {
      isLoading.value = true;
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      final user = userCredential.user;
      if (user != null) {
        await _saveUserProfile(user, name: name);
        Get.snackbar(
          'Registrasi Berhasil', 
          'Akun Anda telah berhasil dibuat!',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw Exception("User null setelah pembuatan akun.");
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error Registrasi', _getFirebaseErrorMessage(e), snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      await signOut();
      Get.snackbar('Error', 'Terjadi kesalahan tak terduga: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error Login', _getFirebaseErrorMessage(e), snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      // ignore: body_might_complete_normally_catch_error
      await _googleSignIn.signOut().catchError((_) {});
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) { 
        isLoading.value = false; 
        return; 
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, 
        idToken: googleAuth.idToken
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        await _saveUserProfile(user);
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', _getFirebaseErrorMessage(e), snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Login Google gagal: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _googleSignIn.signOut(),
        _auth.signOut(),
      // ignore: body_might_complete_normally_catch_error
      ]).catchError((_) {});
    } catch (e) {
      Get.snackbar('Error', 'Gagal sign out: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
    }
  }
  
  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': 
        return 'Tidak ada pengguna yang ditemukan dengan email ini.';
      case 'wrong-password': 
        return 'Password yang dimasukkan salah.';
      case 'email-already-in-use': 
        return 'Akun dengan email ini sudah ada.';
      case 'weak-password': 
        return 'Password terlalu lemah.';
      case 'invalid-email': 
        return 'Alamat email tidak valid.';
      case 'user-disabled': 
        return 'Akun pengguna ini telah dinonaktifkan.';
      case 'too-many-requests': 
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'operation-not-allowed': 
        return 'Operasi tidak diizinkan. Silakan hubungi dukungan.';
      case 'invalid-credential': 
        return 'Kredensial tidak valid. Silakan coba lagi.';
      case 'network-request-failed':
        return 'Kesalahan jaringan. Periksa koneksi internet Anda.';
      case 'permission-denied':
        return 'Izin ditolak. Silakan hubungi dukungan.';
      default: 
        return e.message ?? 'Terjadi kesalahan saat otentikasi.';
    }
  }
}