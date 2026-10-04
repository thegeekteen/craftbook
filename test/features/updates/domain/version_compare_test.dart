import 'package:craftbook/features/updates/domain/version_compare.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a higher patch, minor or major is newer', () {
    expect(isNewerVersion('1.0.2', '1.0.1'), isTrue);
    expect(isNewerVersion('1.1.0', '1.0.9'), isTrue);
    expect(isNewerVersion('2.0.0', '1.9.9'), isTrue);
  });

  test('compares parts as numbers, not text', () {
    expect(isNewerVersion('1.0.10', '1.0.9'), isTrue);
    expect(isNewerVersion('1.0.9', '1.0.10'), isFalse);
  });

  test('the same or an older version is not newer', () {
    expect(isNewerVersion('1.0.1', '1.0.1'), isFalse);
    expect(isNewerVersion('1.0.0', '1.0.1'), isFalse);
  });

  test('missing parts count as zero', () {
    expect(isNewerVersion('1.1', '1.1.0'), isFalse);
    expect(isNewerVersion('1.1.1', '1.1'), isTrue);
  });

  test('ignores build numbers and pre-release tags', () {
    expect(isNewerVersion('1.0.1+5', '1.0.1+4'), isFalse);
    expect(isNewerVersion('1.0.2-beta', '1.0.1'), isTrue);
  });
}
