import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for FeedbackApi
void main() {
  final instance = AgntsApi().getFeedbackApi();

  group(FeedbackApi, () {
    // Send feedback to the platform's Admins
    //
    //Future<Feedback> sendFeedback(SendFeedbackRequest sendFeedbackRequest) async
    test('test sendFeedback', () async {
      // TODO
    });

  });
}
