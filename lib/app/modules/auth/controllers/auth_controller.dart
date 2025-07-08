// File: /sppdn/lib/app/modules/auth/controllers/auth_controller.dart (Versi Final)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';

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
    // Beri sedikit jeda agar update profil (seperti displayName) sempat diterima oleh stream
    Future.delayed(const Duration(seconds: 1), () {
      if (user == null) {
        if (Get.currentRoute != '/login' && Get.currentRoute != '/register') {
          Get.offAllNamed('/login');
        }
      } else {
        if (Get.currentRoute != '/home') {
          Get.offAllNamed('/home');
        }
      }
    });
  }
  
  // Helper untuk menambah/memperbarui data pengguna di Firestore dan profil Auth
  Future<void> _addUserDataToFirestore(User user, {String? name}) async {
    final userName = name ?? user.displayName ?? 'Unnamed User';
    print("--> Preparing to add user data to Firestore. UID: ${user.uid}, Name: $userName");

    try {
      // 1. Tulis data ke Firestore
      final userDoc = _firestore.collection('users').doc(user.uid);
      await userDoc.set({
        'name': userName,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'uid': user.uid,
      }, SetOptions(merge: true)); // Gunakan merge:true untuk update, bukan menimpa
      print("--> SUCCESS: Firestore document created/updated for ${user.uid}");

      // 2. Update profil Firebase Auth jika display name masih kosong atau berbeda
      if (user.displayName == null || user.displayName!.isEmpty || user.displayName != userName) {
        await user.updateDisplayName(userName);
        await user.reload(); // Penting: Muat ulang data user agar stream mendeteksi perubahan
        firebaseUser.value = _auth.currentUser; // Update state GetX secara manual
        print("--> SUCCESS: Firebase Auth profile displayName updated to '$userName'");
      }
    } catch (e) {
      print("!!! FIRESTORE/PROFILE UPDATE FAILED: $e");
      Get.snackbar(
        'Database Error', 
        'Failed to save user data. Please try again later.', 
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> register(String name, String email, String password) async {
    print("--> Attempting to register user: $email with name: $name");
    User? user; // Kita hanya butuh objek User, bukan UserCredential

    try {
      isLoading.value = true;
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user; // Ambil objek User dari hasil
      print("--> Firebase Auth user created successfully. UID: ${user?.uid}");

    } on FirebaseAuthException catch (e) {
      print("!!! FIREBASE AUTH REGISTER FAILED: ${e.code} - ${e.message}");
      Get.snackbar('Error', _getFirebaseErrorMessage(e), snackPosition: SnackPosition.BOTTOM);
      isLoading.value = false;
      return;

    } catch (e) {
      print("!!! POTENTIAL SWALLOWED EXCEPTION: $e");
      // Cek jika errornya adalah bug type cast yang diketahui
      if (e.toString().contains("PigeonUserDetails") || e.toString().contains("List<Object?>")) {
        print("--> Swallowed exception detected. User likely created. Continuing process.");
        // Ambil user yang baru saja dibuat, karena prosesnya berhasil meskipun ada error
        user = _auth.currentUser; // Langsung ambil user yang sedang aktif
      } else {
        // Jika ini error lain yang tidak dikenal, tampilkan ke user
        print("!!! UNKNOWN REGISTER FAILED: $e");
        Get.snackbar('Error', 'An unknown error occurred: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
        isLoading.value = false;
        return;
      }
    }

    // Blok ini akan dieksekusi jika try berhasil ATAU jika bug type cast terjadi
    try {
      if (user != null) {
        await _addUserDataToFirestore(user, name: name);
        Get.snackbar(
          'Success',
          'Account created successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        print("!!! CRITICAL ERROR: User creation reported success but user is null.");
        Get.snackbar('Error', 'Failed to retrieve user after creation.', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
       print("!!! FIRESTORE/PROFILE UPDATE FAILED AFTER REGISTER: $e");
       Get.snackbar('Error', 'User created, but failed to save profile data.', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
  
  // Login dengan Email dan Password
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Get.snackbar(
        'Success',
        'Logged in successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Error',
        _getFirebaseErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Login atau Register dengan Google
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        isLoading.value = false;
        return;
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final docRef = _firestore.collection('users').doc(userCredential.user!.uid);
        final docSnap = await docRef.get();
        // Buat/update data di firestore jika user baru atau data belum ada
        if (!docSnap.exists) {
           print("--> New Google Sign-In user detected. Creating Firestore document.");
           await _addUserDataToFirestore(userCredential.user!);
        } else {
           print("--> Existing Google Sign-In user. No need to create document.");
        }
      }
      
      Get.snackbar(
        'Success',
        'Logged in with Google successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
      
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', _getFirebaseErrorMessage(e), snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      // Hindari menampilkan error dari bug 'PigeonUserDetails'
      if (!e.toString().contains('PigeonUserDetails') && !e.toString().contains('List<Object?>')) {
        print("!!! GOOGLE SIGN IN FAILED: $e");
        Get.snackbar('Error', 'Google sign in failed. Please try again.', snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading.value = false;
    }
  }
  
  // Sign Out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _googleSignIn.signOut(),
        _auth.signOut(),
      ]);
      Get.snackbar(
        'Success',
        'Signed out successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // Jika salah satu gagal, tetap pastikan sign out dari Firebase Auth
      await _auth.signOut();
    }
  }
  
  // Helper untuk pesan error Firebase yang lebih ramah
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