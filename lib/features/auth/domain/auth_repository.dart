import '../../../core/errors/result.dart';
import 'app_user.dart';

abstract class AuthRepository {
  AppUser? get currentUser;

  Stream<AppUser?> authStateChanges();

  Future<Result<AppUser>> signIn({required String email, required String password});

  Future<Result<AppUser>> signUp({required String email, required String password});

  Future<Result<void>> signInWithGoogle();

  Future<void> signOut();
}
