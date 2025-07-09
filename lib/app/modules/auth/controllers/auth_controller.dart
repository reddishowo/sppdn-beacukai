import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
    // Stream ini sekarang hanya untuk menangani status login saat aplikasi pertama kali dibuka atau saat sign out.
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setInitialScreen);
  }
  
  // Fungsi ini sekarang hanya menangani kondisi awal dan sign-out
  void _setInitialScreen(User? user) {
    if (user == null) {
      // Jika user sign out atau sesi berakhir, arahkan ke login.
      Get.offAllNamed('/login');
    } else {
      // Jika user sudah login saat aplikasi dibuka, arahkan ke home.
      // Cek untuk menghindari navigasi berulang jika sudah di home.
      if (Get.currentRoute != '/home') {
        Get.offAllNamed('/home');
      }
    }
  }

  // Fungsi ini sudah benar, tidak perlu diubah.
  Future<void> _saveUserProfile(User user, {String? name}) async {
    final userName = name ?? user.displayName ?? 'Unnamed User';
    print("--> 1. Saving user data to Firestore for $userName");
    await _firestore.collection('users').doc(user.uid).set({
      'name': userName, 'email': user.email, 'createdAt': FieldValue.serverTimestamp(), 'uid': user.uid,
    }, SetOptions(merge: true));
    print("--> SUCCESS: Firestore write complete.");

    print("--> 2. Updating Firebase Auth profile display name.");
    try {
      if (user.displayName == null || user.displayName != userName) {
        await user.updateDisplayName(userName);
        print("--> SUCCESS: updateDisplayName call successful.");
      }
    } catch (e) {
      if (e.toString().contains('Pigeon') || e.toString().contains('List<Object?>')) {
        print("--> Swallowed known bug during profile update. Continuing...");
      } else { rethrow; }
    }
    
    print("--> 3. Forcing user reload to sync state.");
    await _auth.currentUser?.reload();
    firebaseUser.value = _auth.currentUser;
    print("--> User state synced. Final displayName: ${firebaseUser.value?.displayName}");
  }

  // **PERUBAHAN KUNCI DI SINI**
  Future<void> register(String name, String email, String password) async {
    try {
      isLoading.value = true;
      final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;
      
      if (user != null) {
        // Tunggu sampai profil selesai disimpan dan di-reload
        await _saveUserProfile(user, name: name); 
        
        // Baru navigasi SETELAH semuanya selesai
        Get.offAllNamed('/home'); 
      } else {
        throw Exception("User is null after creation.");
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Registration Error', _getFirebaseErrorMessage(e), snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      if (!e.toString().contains('Pigeon')) {
         Get.snackbar('Error', 'An unknown error occurred.', snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading.value = false;
    }
  }
  
  // **PERUBAHAN KUNCI DI SINI**
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      
      // Navigasi secara eksplisit setelah login berhasil
      Get.offAllNamed('/home');
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Login Error', _getFirebaseErrorMessage(e), snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      if (e.toString().contains('Pigeon')) {
        print("--> Swallowed known bug during login. Navigating to home...");
        // Jika bug terjadi, user tetap berhasil login, jadi kita tetap navigasi
        Get.offAllNamed('/home');
      } else {
        Get.snackbar('Error', 'Something went wrong.', snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading.value = false;
    }
  }
  
  // **PERUBAHAN KUNCI DI SINI**
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) { isLoading.value = false; return; }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final docRef = _firestore.collection('users').doc(user.uid);
        final docSnap = await docRef.get();
        if (!docSnap.exists) {
           await _saveUserProfile(user);
        }
        // Navigasi setelah semua proses selesai
        Get.offAllNamed('/home');
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', _getFirebaseErrorMessage(e), snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      if (!e.toString().contains('Pigeon')) {
        Get.snackbar('Error', 'Google sign in failed.', snackPosition: SnackPosition.BOTTOM);
      } else {
        // Jika bug Pigeon terjadi, tetap navigasi
        Get.offAllNamed('/home');
      }
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> signOut() async {
    try {
      await Future.wait([_googleSignIn.signOut(), _auth.signOut()]);
      // Navigasi akan ditangani oleh listener `ever` karena user menjadi null
    } catch (e) {
      await _auth.signOut();
    }
  }
  
  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return 'No user found with this email.';
      case 'wrong-password': return 'Wrong password provided.';
      case 'email-already-in-use': return 'An account already exists with this email.';
      case 'weak-password': return 'Password is too weak.';
      case 'invalid-email': return 'Invalid email address.';
      case 'user-disabled': return 'This user account has been disabled.';
      case 'too-many-requests': return 'Too many requests. Try again later.';
      case 'operation-not-allowed': return 'Operation not allowed. Please contact support.';
      case 'invalid-credential': return 'Invalid credentials. Please try again.';
      default: return e.message ?? 'An error occurred during authentication.';
    }
  }
}