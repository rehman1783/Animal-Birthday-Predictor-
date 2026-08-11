import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
            .eq('email', cleanEmail)
            .maybeSingle();
        return res != null;
      } catch (_) {
        return false;
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
      final cleanEmail = email.trim();
      final response = await _supabase.auth.signUp(
        email: cleanEmail,
        password: password,
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
      if (e.message.contains('already registered') || e.code == 'user_already_exists') {
        throw const AuthExceptionCustom('An account with this email already exists.');
      }
      throw AuthExceptionCustom(e.message);
    } catch (e) {
      if (e is AuthExceptionCustom) rethrow;
      throw AuthExceptionCustom(e.toString());
    }
  }

  /// Sign In with Email and Password
  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim();

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
      if (e.message.toLowerCase().contains('invalid login credentials') ||
          e.code == 'invalid_credentials') {
        final exists = await checkEmailExists(cleanEmail);
        if (!exists) {
          throw const AuthExceptionCustom('This account does not exist. Please create an account first.');
        } else {
          throw const AuthExceptionCustom('Incorrect password. Please try again.');
        }
      }
      throw AuthExceptionCustom(e.message);
    } catch (e) {
      if (e is AuthExceptionCustom) rethrow;
      throw AuthExceptionCustom(e.toString());
    }
  }

  /// Send Password Reset Link to Email
  Future<void> resetPasswordForEmail(String email) async {
    final cleanEmail = email.trim();

    // Check if account exists
    final exists = await checkEmailExists(cleanEmail);
    if (!exists) {
      throw const AuthExceptionCustom('This email is not registered.');
    }

    try {
      await _supabase.auth.resetPasswordForEmail(
        cleanEmail,
        redirectTo: 'io.supabase.animalbirthdaypredictor://reset-password',
      );
    } on AuthException catch (e) {
      throw AuthExceptionCustom(e.message);
    } catch (e) {
      if (e is AuthExceptionCustom) rethrow;
      throw AuthExceptionCustom(e.toString());
    }
  }

  /// Update User Password (for Deep Link / Reset Flow)
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw AuthExceptionCustom(e.message);
    } catch (e) {
      if (e is AuthExceptionCustom) rethrow;
      throw AuthExceptionCustom(e.toString());
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
    await _supabase.auth.signOut();
  }
}
