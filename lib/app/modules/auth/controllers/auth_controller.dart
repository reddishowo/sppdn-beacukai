// ignore_for_file: body_might_complete_normally_catch_error

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // <-- Tambahkan import ini
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
      Get.offAllNamed(Routes.LOGIN);
    } else {
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
    }
    
    await docRef.set(userData, SetOptions(merge: true));
    firebaseUser.value = _auth.currentUser;
  }

  // **FUNGSI BARU UNTUK UPDATE NAMA**
  Future<void> updateUserName(String newName) async {
    final user = _auth.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'Tidak ada pengguna yang login.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (newName.trim().isEmpty) {
      Get.snackbar('Error', 'Nama tidak boleh kosong.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      // 1. Update Display Name di Firebase Auth
      await user.updateDisplayName(newName.trim());

      // 2. Update Nama di Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'name': newName.trim(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      // 3. Reload user data untuk memastikan semua sinkron
      await user.reload();
      firebaseUser.value = _auth.currentUser; // Update state reaktif

      Get.back(); // Tutup dialog edit profil
      Get.snackbar(
        'Sukses', 
        'Nama profil berhasil diperbarui.', 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui nama: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ... (sisa kode register, login, dll. tetap sama) ...
  // PERBAIKAN: Logika registrasi yang lebih aman.
  Future<void> register(String name, String email, String password) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Semua kolom wajib diisi.');
      return;
    }
    
    try {
      isLoading.value = true;
      
      // 1. Buat user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      final user = userCredential.user;
      
      if (user != null) {
        // 2. Simpan profil (nama, dll.) SEBELUM menganggap proses selesai.
        // Fungsi ini sekarang akan menangani update display name juga.
        await _saveUserProfile(user, name: name);
        
        // Pesan sukses. Navigasi akan dihandle oleh listener 'ever' secara otomatis.
        Get.snackbar(
          'Registrasi Berhasil', 
          'Akun Anda telah berhasil dibuat!',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // Ini jarang terjadi, tetapi sebagai pengaman.
        throw Exception("User null setelah pembuatan akun.");
      }
      
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error Registrasi', _getFirebaseErrorMessage(e), snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      // Jika terjadi error (misal, _saveUserProfile gagal), log out user
      // untuk mencegah state yang tidak konsisten (login tapi tanpa profil).
      await signOut();
      Get.snackbar('Error', 'Terjadi kesalahan tak terduga: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
  
  // PERBAIKAN: Logika Login yang lebih bersih.
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Navigasi akan dihandle oleh listener 'ever'.
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error Login', _getFirebaseErrorMessage(e), snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
  
  // PERBAIKAN: Logika Google Sign In yang lebih solid.
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      
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
        // Cek jika ini adalah login pertama kali, lalu simpan profilnya.
        // Firestore akan memberi tahu kita jika user baru.
        final docRef = _firestore.collection('users').doc(user.uid);
        final docSnap = await docRef.get();
        
        if (!docSnap.exists) {
          // User baru, simpan profilnya.
          await _saveUserProfile(user);
        } else {
          // User lama, cukup perbarui nama jika perlu (misal, nama di akun google berubah).
          await _saveUserProfile(user);
        }
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
      // PERBAIKAN: Hentikan stream sebelum logout untuk mencegah error PERMISSION_DENIED
      // Ini adalah contoh, idealnya stream subscription di-dispose di controller masing-masing.
      // Namun, logout global adalah cara paling pasti.
      await Future.wait([
        _googleSignIn.signOut(),
        _auth.signOut(),
      ]).catchError((_) {});
      // Navigasi akan dihandle oleh listener 'ever'.
    } catch (e) {
      Get.snackbar('Error', 'Gagal sign out: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
    }
  }
  
  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    // ... (Fungsi ini sudah bagus, tidak perlu diubah)
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