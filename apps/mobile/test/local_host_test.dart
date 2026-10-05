import 'package:flutter_test/flutter_test.dart';
import 'package:hiro_mobile/features/auth/login_screen.dart';

void main() {
  test('only private-network hosts count as local', () {
    for (final h in ['localhost', 'my-mac.local', '192.168.10.27', '10.0.0.5', '172.20.10.3', '127.0.0.1']) {
      expect(isLocalHost(h), isTrue, reason: h);
    }
    for (final h in ['hiro.example.com', '8.8.8.8', '172.32.0.1', '192.169.0.1', '192.168.1', 'local']) {
      expect(isLocalHost(h), isFalse, reason: h);
    }
  });
}
