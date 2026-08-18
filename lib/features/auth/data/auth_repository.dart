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
  final SupabaseClient? _supabaseClient;

  AuthRepository({SupabaseClient? supabase}) : _supabaseClient = supabase;

  SupabaseClient get _supabase {
    final client = _supabaseClient;
    if (client != null) return client;
    return Supabase.instance.client;
  }

  /// Get the current authenticated Supabase session
  Session? get currentSession {
    try {
      return _supabase.auth.currentSession;
    } catch (_) {
      return null;
    }
  }

  /// Get current user ID
  String? get currentUserId {
    try {
      return _supabase.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }

  /// Stream of Auth State changes
  Stream<AuthState> get onAuthStateChange {
    try {
      return _supabase.auth.onAuthStateChange;
    } catch (_) {
      return const Stream.empty();
    }
  }

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
      return const AuthExceptionCustom(
        'Network error. Please check your internet connection and try again.',
      );
    }
    if (e is AuthException) {
      return AuthExceptionCustom(e.message);
    }
    return const AuthExceptionCustom(
      'An unexpected error occurred. Please try again.',
    );
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
    final cleanEmail = email.trim().toLowerCase();

    // 1. Proactive check: Check if email is already registered via RPC
    try {
      final alreadyExists = await checkEmailExists(cleanEmail);
      if (alreadyExists) {
        throw const AuthExceptionCustom(
          'This email is already registered. Please log in.',
        );
      }
    } catch (e) {
      if (e is AuthExceptionCustom) rethrow;
      // If checkEmailExists encounters an unhandled issue, proceed to Supabase Auth signUp
    }

    try {
      final response = await _supabase.auth.signUp(
        email: cleanEmail,
        password: password,
        data: {'full_name': fullName.trim()},
        emailRedirectTo: AppEnv.emailVerificationRedirectUrl,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthExceptionCustom(
          'Failed to create account. Please try again.',
        );
      }

      // 2. Supabase Auth duplicate detection check:
      // When email confirmations are enabled in Supabase, duplicate signUps return a user object
      // with an empty identities list ([]) rather than throwing an exception.
      if (user.identities != null && user.identities!.isEmpty) {
        throw const AuthExceptionCustom(
          'This email is already registered. Please log in.',
        );
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
      if (msg.contains('already registered') ||
          msg.contains('already exists') ||
          msg.contains('already in use') ||
          e.code == 'user_already_exists') {
        throw const AuthExceptionCustom(
          'This email is already registered. Please log in.',
        );
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
      return profile ??
          UserProfile(id: user.id, email: cleanEmail, fullName: '');
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();

      // Detect unverified account
      if (msg.contains('email not confirmed') ||
          e.code == 'email_not_confirmed') {
        throw const AuthExceptionCustom(
          'Please verify your email address before signing in.',
        );
      }

      // Handle invalid credentials
      if (msg.contains('invalid login credentials') ||
          msg.contains('invalid credentials') ||
          e.code == 'invalid_credentials' ||
          e.code == 'invalid_grant') {
        final exists = await checkEmailExists(cleanEmail);
        if (!exists) {
          throw const AuthExceptionCustom(
            'Incorrect email or password. If you do not have an account, please sign up.',
          );
        } else {
          throw const AuthExceptionCustom(
            'Incorrect password. Please try again.',
          );
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
      if (msg.contains('user not found') ||
          msg.contains('unable to find user')) {
        throw const AuthExceptionCustom('This email is not registered.');
      }
      throw _handleError(e);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Check if password reset link was verified / active recovery session exists
  Future<bool> checkIsPasswordResetVerified([String? email]) async {
    // 1. Check if an active session or currentUser exists
    if (_supabase.auth.currentSession != null ||
        _supabase.auth.currentUser != null) {
      return true;
    }

    // 2. Try refreshing session
    try {
      final res = await _supabase.auth.refreshSession();
      if (res.session != null || res.user != null) {
        return true;
      }
    } catch (_) {}

    // 3. Try fetching live user from backend
    try {
      final userRes = await _supabase.auth.getUser();
      if (userRes.user != null) {
        return true;
      }
    } catch (_) {}

    return false;
  }

  /// Update User Password (for Deep Link / Reset Flow)
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
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

  /// Resend Signup Verification Email
  Future<void> resendVerificationEmail(String email) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email.trim().toLowerCase(),
        emailRedirectTo: AppEnv.emailVerificationRedirectUrl,
      );
    } on AuthException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Check if the user's email is confirmed by querying Supabase RPC / refreshing session / fetching live user
  Future<bool> isEmailVerified([String? email]) async {
    final cleanEmail = email?.trim().toLowerCase();

    // 1. Try Supabase RPC: check_email_verified (checks auth.users directly via security definer)
    if (cleanEmail != null && cleanEmail.isNotEmpty) {
      try {
        final response = await _supabase.rpc<bool>(
          'check_email_verified',
          params: {'email_to_check': cleanEmail},
        );
        if (response == true) {
          return true;
        }
      } catch (e) {
        debugPrint('check_email_verified RPC fallback: $e');
      }
    }

    // 2. Force refresh session from Supabase backend
    try {
      final res = await _supabase.auth.refreshSession();
      final user = res.user ?? _supabase.auth.currentUser;
      if (user != null &&
          user.emailConfirmedAt != null &&
          user.emailConfirmedAt!.isNotEmpty) {
        return true;
      }
    } catch (_) {}

    // 3. Query live user endpoint from Supabase server
    try {
      final freshUserRes = await _supabase.auth.getUser();
      final freshUser = freshUserRes.user;
      if (freshUser != null &&
          freshUser.emailConfirmedAt != null &&
          freshUser.emailConfirmedAt!.isNotEmpty) {
        return true;
      }
    } catch (_) {}

    // 4. Fallback check on active session user object
    final currentUser = _supabase.auth.currentUser;
    return currentUser != null &&
        currentUser.emailConfirmedAt != null &&
        currentUser.emailConfirmedAt!.isNotEmpty;
  }

  /// Permanently delete user account and all data after password confirmation
  Future<void> deleteAccount({required String password}) async {
    final session = currentSession;
    final email =
        session?.user.email ??
        (await getUserProfile(currentUserId ?? ''))?.email;

    if (session == null || email == null || email.trim().isEmpty) {
      throw const AuthExceptionCustom(
        'Active session not found. Please log in again.',
      );
    }

    final cleanEmail = email.trim().toLowerCase();

    // 1. Verify user password by authenticating credentials
    try {
      final reauthResponse = await _supabase.auth.signInWithPassword(
        email: cleanEmail,
        password: password,
      );
      if (reauthResponse.user == null) {
        throw const AuthExceptionCustom(
          'Incorrect password. Please enter your valid password.',
        );
      }
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid') ||
          msg.contains('grant') ||
          e.code == 'invalid_credentials' ||
          e.code == 'invalid_grant') {
        throw const AuthExceptionCustom(
          'Incorrect password. Please enter your valid password.',
        );
      }
      throw _handleError(e);
    } catch (e) {
      if (e is AuthExceptionCustom) rethrow;
      throw _handleError(e);
    }

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthExceptionCustom('Unable to identify user account.');
    }

    // 2. Call delete_user_account RPC function to delete auth user and cascade database records
    try {
      await _supabase.rpc('delete_user_account');
    } catch (rpcError) {
      debugPrint('delete_user_account RPC fallback: $rpcError');
      // Fallback manual deletes for profiles & child tables
      try {
        await _supabase.from('animals').delete().eq('account_id', userId);
        await _supabase.from('foals').delete().eq('account_id', userId);
        await _supabase.from('puppies').delete().eq('account_id', userId);
        await _supabase.from('contacts').delete().eq('account_id', userId);
        await _supabase.from('profiles').delete().eq('id', userId);
      } catch (_) {}
    }

    // 3. Clear session and sign out
    await signOut();
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
