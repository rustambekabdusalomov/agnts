import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for ReviewsApi
void main() {
  final instance = AgntsApi().getReviewsApi();

  group(ReviewsApi, () {
    // Tell agnts something about how you review; the next review for that user reads it
    //
    //Future<ReviewerNote> addReviewerNote(ReviewerNoteInput reviewerNoteInput) async
    test('test addReviewerNote', () async {
      // TODO
    });

    // Forget a note (one already folded into a profile stays there until the profile is edited)
    //
    //Future deleteReviewerNote(int id) async
    test('test deleteReviewerNote', () async {
      // TODO
    });

    // How each person agnts reviews pull requests for reviews, as it learned from their notes
    //
    //Future<Reviewers> listReviewers() async
    test('test listReviewers', () async {
      // TODO
    });

    // Post agnts's latest review of a pull request on it (once per reviewed commit): the summary, and the chosen findings on their lines in one review. Posting the review of new commits edits agnts's earlier summary, answers its findings that are still there and resolves the ones that are gone
    //
    //Future<Ticket> postPullReview(String key, { PostReviewInput postReviewInput }) async
    test('test postPullReview', () async {
      // TODO
    });

    // Replace a reviewer profile with your text; empty text clears it
    //
    //Future<Reviewer> saveReviewerProfile(String login, ReviewerProfileInput reviewerProfileInput) async
    test('test saveReviewerProfile', () async {
      // TODO
    });

    // Ask the git host for the pull requests waiting for you and queue reviews of the new ones
    //
    //Future<ReviewSync> syncReviews() async
    test('test syncReviews', () async {
      // TODO
    });

  });
}
