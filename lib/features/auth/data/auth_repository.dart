import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_env.dart';
import '../domain/user_profile.dart';

class AuthExceptionCustom implements Exception {
  final String message;
  const AuthExceptionCustom(this.message);

  @override
  String toString() => message;
}

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Get the current authenticated Supabase session
  Session? get currentSession => _supabase.auth.currentSession;

  /// Get current user ID
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// Stream of Auth State changes
  Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;

  /// Helper to convert technical exceptions into clean, user-friendly error messages
  AuthExceptionCustom _handleError(dynamic e) {
    if (e is AuthExceptionCustom) return e;
    final errStr = e.toString().toLowerCase();
    if (errStr.contains('socketexception') ||
        errStr.contains('failed host lookup') ||
        errStr.contains('clientexception') ||
        errStr.contains('connection refused') ||
        errStr.contains('network') ||
        errStr.contains('xmlhttprequest')) {
      return const AuthExceptionCustom('Network error. Please check your internet connection and try again.');
    }
    if (e is AuthException) {
      return AuthExceptionCustom(e.message);
    }
    return const AuthExceptionCustom('An unexpected error occurred. Please try again.');
  }

  /// Check whether an email exists in the system (via RPC or profiles table)
  Future<bool> checkEmailExists(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    try {
      final response = await _supabase.rpc<bool>(
        'check_email_exists',
        params: {'email_to_check': cleanEmail},
      );
      return response;
    } catch (_) {
      // Fallback: Query profiles table directly if RPC is not deployed yet
      try {
        final res = await _supabase
            .from('profiles')
            .select('id')
            .filter('email', 'ilike', cleanEmail)
            .maybeSingle();
        return res != null;
      } catch (_) {
        // If unauthenticated query to profiles is blocked by RLS and RPC is missing,
        // fallback to true so Supabase Auth API can perform the authoritative check
        return true;
      }
    }
  }

  /// Sign Up with Email, Password, and Full Name
  Future<UserProfile> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final cleanEmail = email.trim().toLowerCase();
      final response = await _supabase.auth.signUp(
        email: cleanEmail,
        password: password,
        data: {'full_name': fullName.trim()},
        emailRedirectTo: AppEnv.emailVerificationRedirectUrl,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthExceptionCustom('Failed to create account. Please try again.');
      }

      final profile = UserProfile(
        id: user.id,
        email: cleanEmail,
        fullName: fullName.trim(),
        createdAt: DateTime.now(),
      );

      // Save full name and email in public.profiles table (never passwords)
      try {
        await _supabase.from('profiles').upsert(profile.toJson());
      } catch (dbError) {
        debugPrint('Profiles table upsert warning: $dbError');
      }

      return profile;
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('already registered') || e.code == 'user_already_exists') {
        throw const AuthExceptionCustom('An account with this email already exists.');
      }
      throw _handleError(e);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Sign In with Email and Password
  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: cleanEmail,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthExceptionCustom('Sign in failed. Invalid credentials.');
      }

      // Fetch profile
      final profile = await getUserProfile(user.id);
      return profile ?? UserProfile(id: user.id, email: cleanEmail, fullName: '');
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();

      // Detect unverified account
      if (msg.contains('email not confirmed') || e.code == 'email_not_confirmed') {
        throw const AuthExceptionCustom('Please verify your email address before signing in.');
      }

      // Handle invalid credentials
      if (msg.contains('invalid login credentials') ||
          msg.contains('invalid credentials') ||
          e.code == 'invalid_credentials' ||
          e.code == 'invalid_grant') {
        final exists = await checkEmailExists(cleanEmail);
        if (!exists) {
          throw const AuthExceptionCustom('Incorrect email or password. If you do not have an account, please sign up.');
        } else {
          throw const AuthExceptionCustom('Incorrect password. Please try again.');
        }
      }
      throw _handleError(e);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Send Password Reset Link to Email
  Future<void> resetPasswordForEmail(String email) async {
    final cleanEmail = email.trim().toLowerCase();

    // Check if account exists via RPC or fallback
    final exists = await checkEmailExists(cleanEmail);
    if (!exists) {
      throw const AuthExceptionCustom('This email is not registered.');
    }

    try {
      await _supabase.auth.resetPasswordForEmail(
        cleanEmail,
        redirectTo: AppEnv.passwordResetRedirectUrl,
      );
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('user not found') || msg.contains('unable to find user')) {
        throw const AuthExceptionCustom('This email is not registered.');
      }
      throw _handleError(e);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Update User Password (for Deep Link / Reset Flow)
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Fetch User Profile from `profiles` table
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) return null;
      return UserProfile.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (_) {
      // Ignore network errors on sign out to ensure local session clear
    }
  }
}
