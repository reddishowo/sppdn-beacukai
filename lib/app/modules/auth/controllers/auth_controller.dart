import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  Rxn<User> firebaseUser = Rxn<User>();
  RxBool isLoading = false.obs;
  
  @override
  void onReady() {
    super.onReady();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setInitialScreen);
  }
  
  void _setInitialScreen(User? user) {
    // Beri sedikit jeda untuk memastikan build-frame pertama selesai.
    // Ini adalah praktik yang aman untuk navigasi saat startup.
    Future.delayed(const Duration(milliseconds: 1), () {
      if (user == null) {
        // Hanya navigasi jika kita tidak sudah di halaman login
        if (Get.currentRoute != '/register') {
          Get.offAllNamed('/register');
        }
      } else {
        // Hanya navigasi jika kita tidak sudah di halaman home
        if (Get.currentRoute != '/home') {
          Get.offAllNamed('/home');
        }
      }
    });
  }

  
  // Register with email and password
  Future<void> register(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      Get.snackbar(
        'Success',
        'Account created successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Error',
        e.message ?? 'Registration failed',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Login with email and password
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
        e.message ?? 'Login failed',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Google Sign In - Improved version
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      
      // Check if Google Play Services are available
      await _googleSignIn.signOut(); // Clear any cached sign-in
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        isLoading.value = false;
        return; // User cancelled the sign-in
      }
      
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Check if we have the necessary tokens
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Failed to get Google authentication tokens');
      }
      
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in to Firebase with the Google credential
      await _auth.signInWithCredential(credential);
      
      Get.snackbar(
        'Success',
        'Logged in with Google successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Google Sign In Error: $e');
      Get.snackbar(
        'Error',
        'Google sign in failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      Get.snackbar(
        'Error',
        'Sign out failed',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}