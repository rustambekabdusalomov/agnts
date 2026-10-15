import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for ReviewsApi
void main() {
  final instance = AgntsApi().getReviewsApi();

  group(ReviewsApi, () {
    // Accept the summary and every open finding at least as severe as minSeverity (every one when left out)
    //
    //Future<List<ReviewDraft>> acceptAllReviewDrafts(String key, { AcceptAllReviewDraftsRequest acceptAllReviewDraftsRequest }) async
    test('test acceptAllReviewDrafts', () async {
      // TODO
    });

    // Add your own comment to the review, on a line of the new version or on the pull request; it is published with the accepted drafts
    //
    //Future<ReviewDraft> addReviewDraft(String key, AddReviewDraftRequest addReviewDraftRequest) async
    test('test addReviewDraft', () async {
      // TODO
    });

    // Tell agnts something about how you review; the next review for that user reads it
    //
    //Future<ReviewerNote> addReviewerNote(ReviewerNoteInput reviewerNoteInput) async
    test('test addReviewerNote', () async {
      // TODO
    });

    // Delete your own draft comment (agnts's drafts are dismissed instead)
    //
    //Future deleteReviewDraft(String key, int draftId) async
    test('test deleteReviewDraft', () async {
      // TODO
    });

    // Forget a note (one already folded into a profile stays there until the profile is edited)
    //
    //Future deleteReviewerNote(int id) async
    test('test deleteReviewerNote', () async {
      // TODO
    });

    // The draft comments of a pull request review: agnts's summary and findings, and people's own comments, with what was decided about each
    //
    //Future<List<ReviewDraft>> listReviewDrafts(String key) async
    test('test listReviewDrafts', () async {
      // TODO
    });

    // How each person agnts reviews pull requests for reviews, as it learned from their notes
    //
    //Future<Reviewers> listReviewers() async
    test('test listReviewers', () async {
      // TODO
    });

    // Post agnts's latest review of a pull request on it: accepts the drafts of the summary (with the findings not on a changed line) and of the chosen findings, then publishes every accepted draft (see publishReviewDrafts). Kept for older clients
    //
    //Future<Ticket> postPullReview(String key, { PostReviewInput postReviewInput }) async
    test('test postPullReview', () async {
      // TODO
    });

    // Publish the accepted drafts on the pull request as one review, as the git host token's user: comments on their lines, the summary (edited in place when agnts posted one before) with the accepted findings not on a changed line. Also answers in the threads of findings agnts posted before that are still there, and resolves the ones that are gone. Drafts not accepted stay in agnts
    //
    //Future<PublishedReview> publishReviewDrafts(String key, { PublishReviewDraftsRequest publishReviewDraftsRequest }) async
    test('test publishReviewDrafts', () async {
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

    // Accept, dismiss or reopen a draft, or rewrite its text before it is published
    //
    //Future<ReviewDraft> updateReviewDraft(String key, int draftId, UpdateReviewDraftRequest updateReviewDraftRequest) async
    test('test updateReviewDraft', () async {
      // TODO
    });

  });
}
