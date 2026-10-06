import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for AuthApi
void main() {
  final instance = AgntsApi().getAuthApi();

  group(AuthApi, () {
    // The signed-in user
    //
    //Future<User> getMe() async
    test('test getMe', () async {
      // TODO
    });

    // Sign in with password and TOTP code
    //
    //Future<LoginResponse> login(LoginRequest loginRequest) async
    test('test login', () async {
      // TODO
    });

    // End the current session
    //
    //Future logout() async
    test('test logout', () async {
      // TODO
    });

  });
}
