import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
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
      // Remove clientId for now, let it auto-detect
    );
  }
  
  @override
  void onReady() {
    super.onReady();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setInitialScreen);
  }
  
  void _setInitialScreen(User? user) {
    Future.delayed(const Duration(milliseconds: 100), () {
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
  
  // Fixed Google Sign In - handles type casting error
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      
      // Sign out first to ensure clean state
      await _googleSignIn.signOut();
      
      print('Starting Google Sign-In...');
      
      // Trigger the authentication flow with proper error handling
      GoogleSignInAccount? googleUser;
      
      try {
        googleUser = await _googleSignIn.signIn();
      } catch (e) {
        print('Google Sign-In selection error: $e');
        // Handle the type casting error gracefully
        if (e.toString().contains('PigeonUserDetails')) {
          print('Type casting error detected, retrying...');
          await Future.delayed(const Duration(milliseconds: 500));
          googleUser = await _googleSignIn.signIn();
        } else {
          rethrow;
        }
      }
      
      if (googleUser == null) {
        print('User cancelled Google Sign-In');
        isLoading.value = false;
        return;
      }
      
      print('Google user obtained: ${googleUser.email}');
      
      // Obtain the auth details from the request
      GoogleSignInAuthentication googleAuth;
      
      try {
        googleAuth = await googleUser.authentication;
      } catch (e) {
        print('Authentication error: $e');
        // Retry authentication if there's an error
        await Future.delayed(const Duration(milliseconds: 500));
        googleAuth = await googleUser.authentication;
      }
      
      print('Access Token: ${googleAuth.accessToken != null ? "✓" : "✗"}');
      print('ID Token: ${googleAuth.idToken != null ? "✓" : "✗"}');
      
      // Check if we have the necessary tokens
      if (googleAuth.accessToken == null && googleAuth.idToken == null) {
        throw Exception('Failed to get Google authentication tokens');
      }
      
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      print('Signing in to Firebase...');
      
      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      print('Firebase sign-in successful: ${userCredential.user?.email}');
      
      // Only show success message, don't show the error
      Get.snackbar(
        'Success',
        'Logged in with Google successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
      
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      Get.snackbar(
        'Error',
        _getFirebaseErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Google Sign In Error: $e');
      // Don't show error if it's the type casting error and login was successful
      if (!e.toString().contains('PigeonUserDetails') && 
          !e.toString().contains('List<Object?>')) {
        Get.snackbar(
          'Error',
          'Google sign in failed. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
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
      print('Sign out error: $e');
      // Still sign out from Firebase even if Google sign out fails
      await _auth.signOut();
    }
  }
  
  // Helper method to get user-friendly error messages
  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'Operation not allowed. Please contact support.';
      case 'invalid-credential':
        return 'Invalid credentials. Please try again.';
      default:
        return e.message ?? 'An error occurred during authentication.';
    }
  }
}