import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/auth_repository.dart';
import '../../domain/user_profile.dart';

/// Provider for AuthRepository instance
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Provider for active Supabase Auth Session
final authStateStreamProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).onAuthStateChange;
});

/// Onboarding state notifier to track first time experience
class OnboardingNotifier extends StateNotifier<bool> {
  static const String _onboardingKey = 'has_seen_onboarding';

  OnboardingNotifier() : super(false) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
    state = true;
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, bool>((
  ref,
) {
  return OnboardingNotifier();
});

/// Auth Controller to manage Auth operations & state (loading, error, success)
class AuthController extends StateNotifier<AsyncValue<UserProfile?>> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(const AsyncValue.data(null)) {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final session = _authRepository.currentSession;
    if (session != null) {
      state = const AsyncValue.loading();
      final profile = await _authRepository.getUserProfile(session.user.id);
      state = AsyncValue.data(
        profile ??
            UserProfile(
              id: session.user.id,
              email: session.user.email ?? '',
              fullName: '',
            ),
      );
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final profile = await _authRepository.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      state = AsyncValue.data(profile);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      final profile = await _authRepository.signIn(
        email: email,
        password: password,
      );
      state = AsyncValue.data(profile);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<bool> resetPasswordForEmail(String email) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.resetPasswordForEmail(email);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.updatePassword(newPassword);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<bool> resendVerificationEmail(String email) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.resendVerificationEmail(email);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<bool> checkIsEmailVerified([String? email]) async {
    final verified = await _authRepository.isEmailVerified(email);
    if (verified) {
      await _loadCurrentUser();
    }
    return verified;
  }

  Future<bool> checkIsPasswordResetVerified([String? email]) async {
    return await _authRepository.checkIsPasswordResetVerified(email);
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final currentProfile = state.value;
    try {
      await _authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      if (currentProfile != null) {
        state = AsyncValue.data(currentProfile);
      } else {
        await _loadCurrentUser();
      }
      return true;
    } catch (e, stack) {
      if (currentProfile != null) {
        state = AsyncValue.data(currentProfile);
      } else {
        state = AsyncValue.error(e, stack);
      }
      return false;
    }
  }

  Future<bool> deleteAccount({required String password}) async {
    final currentProfile = state.value;
    try {
      await _authRepository.deleteAccount(password: password);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      if (currentProfile != null) {
        state = AsyncValue.data(currentProfile);
      } else {
        state = AsyncValue.error(e, stack);
      }
      return false;
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    await _authRepository.signOut();
    state = const AsyncValue.data(null);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<UserProfile?>>((ref) {
      final repository = ref.watch(authRepositoryProvider);
      return AuthController(repository);
    });
