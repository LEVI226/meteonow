import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:meteonow/core/errors/app_failure.dart';
import 'package:meteonow/core/errors/result.dart';
import 'package:meteonow/features/auth/data/auth_repository_impl.dart';
import 'package:meteonow/features/auth/domain/app_user.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

void main() {
  late MockSupabaseClient client;
  late MockGoTrueClient auth;
  late AuthRepositoryImpl repository;

  setUp(() {
    client = MockSupabaseClient();
    auth = MockGoTrueClient();
    when(() => client.auth).thenReturn(auth);
    repository = AuthRepositoryImpl(client);
  });

  test('signIn maps a successful response to an AppUser', () async {
    final user = MockUser();
    when(() => user.id).thenReturn('user-123');
    when(() => user.email).thenReturn('yannick@example.com');
    when(() => auth.signInWithPassword(email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((_) async => AuthResponse(user: user));

    final result = await repository.signIn(email: 'yannick@example.com', password: 'secret123');

    expect(result, isA<Ok<AppUser>>());
    final appUser = (result as Ok<AppUser>).value;
    expect(appUser.id, 'user-123');
    expect(appUser.email, 'yannick@example.com');
  });

  test('signIn maps an AuthException to an AuthFailure, not an uncaught exception', () async {
    when(() => auth.signInWithPassword(email: any(named: 'email'), password: any(named: 'password')))
        .thenThrow(const AuthException('Invalid login credentials'));

    final result = await repository.signIn(email: 'yannick@example.com', password: 'wrong');

    expect(result, isA<Err<AppUser>>());
    final failure = (result as Err<AppUser>).failure;
    expect(failure, isA<AuthFailure>());
    expect(failure.message, 'Invalid login credentials');
  });
}
