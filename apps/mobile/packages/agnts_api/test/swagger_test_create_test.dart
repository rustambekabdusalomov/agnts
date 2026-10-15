import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for SwaggerTestCreate
void main() {
  final SwaggerTestCreate? instance = /* SwaggerTestCreate(...) */ null;
  // TODO add properties to the entity

  group(SwaggerTestCreate, () {
    // Defaults to \"Swagger test: <API> on <host>\"
    // String title
    test('to test the property `title`', () async {
      // TODO
    });

    // The URL readSwaggerSpec read (served from its cache)
    // String specUrl
    test('to test the property `specUrl`', () async {
      // TODO
    });

    // An uploaded spec, from readSwaggerSpec
    // String specRef
    test('to test the property `specRef`', () async {
      // TODO
    });

    // String baseUrl
    test('to test the property `baseUrl`', () async {
      // TODO
    });

    // List<String> operations
    test('to test the property `operations`', () async {
      // TODO
    });

    // Send POST, PUT, PATCH and DELETE too; off by default
    // bool writeEnabled
    test('to test the property `writeEnabled`', () async {
      // TODO
    });

    // Confirms the base URL is not production; required with writeEnabled
    // bool notProduction
    test('to test the property `notProduction`', () async {
      // TODO
    });

    // SwaggerAuthInput auth
    test('to test the property `auth`', () async {
      // TODO
    });

    // Optional: the API's repository, to explain failures
    // int repoId
    test('to test the property `repoId`', () async {
      // TODO
    });

    // What to test: which endpoints, cases or data. Without operations, it decides the scope.
    // String notes
    test('to test the property `notes`', () async {
      // TODO
    });

    // Requests a second (0: 5)
    // int rateLimit
    test('to test the property `rateLimit`', () async {
      // TODO
    });

    // Requests per run (0: 300)
    // int maxRequests
    test('to test the property `maxRequests`', () async {
      // TODO
    });

    // String priority
    test('to test the property `priority`', () async {
      // TODO
    });

    // code starts now; queue keeps it until started
    // String start
    test('to test the property `start`', () async {
      // TODO
    });

  });
}
