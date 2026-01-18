import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider {
  final AuthService authService = AuthService();

  // Auth state stream
  Stream<User?> get authStateStream => authService.authStateStream;

  // Current user getter
  User? get currentUser => authService.currentUser;

  // Register method
  Future<User?> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return await authService.registerUser(
      email: email,
      password: password,
      fullName: fullName,
    );
  }

  // Login method
  Future<User?> login({required String email, required String password}) async {
    return await authService.loginUser(email: email, password: password);
  }

  // Logout method
  Future<void> logout() async {
    return await authService.logoutUser();
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    return await authService.getUserProfile(uid);
  }
}
