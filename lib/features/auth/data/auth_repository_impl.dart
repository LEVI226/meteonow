import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/errors/result.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._client);

  final SupabaseClient _client;

  AppUser? _toAppUser(User? user) => user == null ? null : AppUser(id: user.id, email: user.email ?? '');

  @override
  AppUser? get currentUser => _toAppUser(_client.auth.currentUser);

  @override
  Stream<AppUser?> authStateChanges() {
    return _client.auth.onAuthStateChange.map((state) => _toAppUser(state.session?.user));
  }

  @override
  Future<Result<AppUser>> signIn({required String email, required String password}) async {
    try {
      final response = await _client.auth.signInWithPassword(email: email, password: password);
      final user = _toAppUser(response.user);
      if (user == null) return const Err(AuthFailure('Invalid email or password.'));
      return Ok(user);
    } on AuthException catch (e) {
      return Err(AuthFailure(e.message));
    } catch (_) {
      return const Err(NetworkFailure());
    }
  }

  @override
  Future<Result<AppUser>> signUp({required String email, required String password}) async {
    try {
      final response = await _client.auth.signUp(email: email, password: password);
      final user = _toAppUser(response.user);
      if (user == null) return const Err(AuthFailure('Could not create account.'));
      return Ok(user);
    } on AuthException catch (e) {
      return Err(AuthFailure(e.message));
    } catch (_) {
      return const Err(NetworkFailure());
    }
  }

  @override
  Future<Result<void>> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(OAuthProvider.google);
      return const Ok(null);
    } on AuthException catch (e) {
      return Err(AuthFailure(e.message));
    } catch (_) {
      return const Err(AuthFailure('Google sign-in failed.'));
    }
  }

  @override
  Future<void> signOut() => _client.auth.signOut();
}
