import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for SwaggerApi
void main() {
  final instance = AgntsApi().getSwaggerApi();

  group(SwaggerApi, () {
    // Keep a Swagger test ticket's test as a suite that runs again on a schedule or after each deploy
    //
    //Future<SwaggerSuite> createSwaggerSuite(SwaggerSuiteInput swaggerSuiteInput) async
    test('test createSwaggerSuite', () async {
      // TODO
    });

    // Create a Swagger test ticket; it starts at once (no analysis) unless start is queue
    //
    //Future<Ticket> createSwaggerTest(SwaggerTestCreate swaggerTestCreate) async
    test('test createSwaggerTest', () async {
      // TODO
    });

    // Delete a suite; its past runs stay
    //
    //Future deleteSwaggerSuite(int id) async
    test('test deleteSwaggerSuite', () async {
      // TODO
    });

    // One logged request and response of a Swagger test's latest run (credentials masked)
    //
    //Future<ApiExchange> getApiRequest(String key, String requestId) async
    test('test getApiRequest', () async {
      // TODO
    });

    // A Swagger test's latest results, its request log (without bodies) and how it compares with the run before
    //
    //Future<SwaggerResults> getApiResults(String key) async
    test('test getApiResults', () async {
      // TODO
    });

    // One suite
    //
    //Future<SwaggerSuite> getSwaggerSuite(int id) async
    test('test getSwaggerSuite', () async {
      // TODO
    });

    // Saved Swagger test suites
    //
    //Future<List<SwaggerSuite>> listSwaggerSuites() async
    test('test listSwaggerSuites', () async {
      // TODO
    });

    // Fetch (from a URL or a docs page in front of it) or read (uploaded text) a Swagger/OpenAPI spec for the Swagger test form; nothing is stored
    //
    // A URL is fetched by a short container behind the egress proxy, never by the agnts server: at most one fetch at a time per workspace and 10 a minute, and a URL fetched in the last 10 minutes comes from the cache. An uploaded spec is kept for an hour under specRef, which the create call refers to. A docs page offering several specs returns them as choices.
    //
    //Future<SwaggerSpec> readSwaggerSpec(SwaggerSpecInput swaggerSpecInput) async
    test('test readSwaggerSpec', () async {
      // TODO
    });

    // Run a Swagger test again
    //
    // An open test (in review or failed) runs again in place; a new token is optional. A closed one (done or rejected) runs again as a new ticket, returned here, and needs a token: closing deleted the old one.
    //
    //Future<Ticket> rerunSwaggerTest(String key, { SwaggerRerunInput swaggerRerunInput }) async
    test('test rerunSwaggerTest', () async {
      // TODO
    });

    // Make a new deploy hook URL for a suite (shown once; the old one stops working)
    //
    // A deploy pipeline POSTs to the URL, with no body, to run the suite after each deploy.
    //
    //Future<RotateSwaggerSuiteHook200Response> rotateSwaggerSuiteHook(int id) async
    test('test rotateSwaggerSuiteHook', () async {
      // TODO
    });

    // Run a suite now, as a new Swagger test ticket
    //
    //Future<Ticket> runSwaggerSuite(int id) async
    test('test runSwaggerSuite', () async {
      // TODO
    });

    // Rename a suite, change its schedule, pause it or give it a new token
    //
    //Future<SwaggerSuite> updateSwaggerSuite(int id, SwaggerSuiteInput swaggerSuiteInput) async
    test('test updateSwaggerSuite', () async {
      // TODO
    });

  });
}
