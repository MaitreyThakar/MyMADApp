import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _userName = '';
  String _userEmail = '';
  String _userId = '';
  String _userRole = 'user';
  bool _isLoading = false;

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userId => _userId;
  String get userRole => _userRole;
  bool get isLoading => _isLoading;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLogin = prefs.getBool('isLoggedIn') ?? false;
    final currentUser = _auth.currentUser;

    if (savedLogin && currentUser != null) {
      _isLoggedIn = true;
      _userEmail = currentUser.email ?? '';
      // Fetch name from Firestore
      try {
        final doc =
            await _firestore.collection('users').doc(currentUser.uid).get();
        if (doc.exists) {
          _userName = doc.data()?['name'] ?? '';
          _userRole = doc.data()?['role'] ?? 'user';
          _userId = currentUser.uid;
        }
      } catch (_) {}
    } else {
      _isLoggedIn = false;
    }
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      _isLoggedIn = true;
      _userEmail = cred.user?.email ?? '';
      _userId = cred.user?.uid ?? '';

      // Fetch name and role from users collection
      try {
        final doc = await _firestore
            .collection('users')
            .doc(cred.user?.uid)
            .get();
        if (doc.exists) {
          _userName = doc.data()?['name'] ?? '';
          _userRole = doc.data()?['role'] ?? 'user'; // 'admin', 'provider', or 'user'
        }
      } catch (_) {}

      _isLoading = false;
      notifyListeners();
      return null; // success
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return _mapError(e.code);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'An unexpected error occurred.';
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    _isLoggedIn = false;
    _userName = '';
    _userEmail = '';
    notifyListeners();
  }

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'network-request-failed':
        return 'Check your internet connection.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return 'Login failed. Please try again.';
    }
  }
}
