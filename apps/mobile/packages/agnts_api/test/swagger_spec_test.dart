import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for SwaggerSpec
void main() {
  final SwaggerSpec? instance = /* SwaggerSpec(...) */ null;
  // TODO add properties to the entity

  group(SwaggerSpec, () {
    // An uploaded spec, or one fetched with a token, kept for an hour: pass it to createSwaggerTest
    // String specRef
    test('to test the property `specRef`', () async {
      // TODO
    });

    // Where the spec was found (a docs page leads to its spec)
    // String url
    test('to test the property `url`', () async {
      // TODO
    });

    // String title
    test('to test the property `title`', () async {
      // TODO
    });

    // String version
    test('to test the property `version`', () async {
      // TODO
    });

    // \"swagger 2.0\" or \"openapi 3.x\"
    // String format
    test('to test the property `format`', () async {
      // TODO
    });

    // List<SwaggerServer> servers
    test('to test the property `servers`', () async {
      // TODO
    });

    // List<SwaggerOperation> operations
    test('to test the property `operations`', () async {
      // TODO
    });

    // List<SwaggerSecurityScheme> securitySchemes
    test('to test the property `securitySchemes`', () async {
      // TODO
    });

    // The specs a docs page offers; read the chosen one's url
    // List<SwaggerSpecChoicesInner> choices
    test('to test the property `choices`', () async {
      // TODO
    });

  });
}
