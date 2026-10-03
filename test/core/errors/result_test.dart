import 'package:flutter_test/flutter_test.dart';
import 'package:meteonow/core/errors/app_failure.dart';
import 'package:meteonow/core/errors/result.dart';

void main() {
  test('Ok wraps a success value', () {
    const result = Ok<int>(42);
    switch (result) {
      case Ok<int>(:final value):
        expect(value, 42);
      // ignore: dead_code, pattern_never_matches_value_type
      case Err<int>():
        // ignore: dead_code
        fail('expected Ok');
    }
  });

  test('Err wraps a typed failure', () {
    const result = Err<int>(NetworkFailure());
    switch (result) {
      // ignore: dead_code, pattern_never_matches_value_type
      case Ok<int>():
        fail('expected Err');
      case Err<int>(:final failure):
        expect(failure, isA<NetworkFailure>());
        expect(failure.message, isNotEmpty);
    }
  });
}
