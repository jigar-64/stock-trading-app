import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/storage/storage_providers.dart';

/// State representation for Authentication.
class AuthState {
  const AuthState({
    required this.isLoggedIn,
    this.email = 'jigar.prajapati@021trading.com',
    this.clientId = 'TRD-884920',
  });

  final bool isLoggedIn;
  final String email;
  final String clientId;

  AuthState copyWith({
    bool? isLoggedIn,
    String? email,
    String? clientId,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      email: email ?? this.email,
      clientId: clientId ?? this.clientId,
    );
  }
}

/// Notifier managing authentication status and SharedPreferences persistence.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._prefs)
      : super(
          AuthState(
            isLoggedIn: _prefs.getBool(_keyIsLoggedIn) ?? false,
            email: _prefs.getString(_keyEmail) ?? 'jigar.prajapati@021trading.com',
            clientId: 'TRD-884920',
          ),
        );

  final SharedPreferences _prefs;
  static const String _keyIsLoggedIn = 'auth_is_logged_in';
  static const String _keyEmail = 'auth_user_email';

  /// Performs user login with email & password.
  Future<bool> login({required String email, required String password}) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      return false;
    }

    state = state.copyWith(isLoggedIn: true, email: email.trim());
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyEmail, email.trim());
    return true;
  }

  /// 1-Tap Quick Demo Login.
  Future<void> quickDemoLogin() async {
    state = state.copyWith(
      isLoggedIn: true,
      email: 'jigar.prajapati@021trading.com',
    );
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyEmail, 'jigar.prajapati@021trading.com');
  }

  /// Logs out the user.
  Future<void> logout() async {
    state = state.copyWith(isLoggedIn: false);
    await _prefs.setBool(_keyIsLoggedIn, false);
  }
}

/// Provider for Authentication state.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthNotifier(prefs);
});
