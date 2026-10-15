import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for PullsApi
void main() {
  final instance = AgntsApi().getPullsApi();

  group(PullsApi, () {
    // Comment on a pull request, or on a line of its diff, as the git host token's user
    //
    //Future<PullThread> addPullComment(int id, int number, NewPullComment newPullComment) async
    test('test addPullComment', () async {
      // TODO
    });

    // Delete a comment (your own, on the git host)
    //
    //Future deletePullComment(int id, int number, String commentId) async
    test('test deletePullComment', () async {
      // TODO
    });

    // Replace the text of a comment (your own, on the git host)
    //
    //Future<PullComment> editPullComment(int id, int number, EditPullCommentRequest editPullCommentRequest) async
    test('test editPullComment', () async {
      // TODO
    });

    // A pull request as it stands on the git host, with the files it changes
    //
    //Future<PullDetail> getRepoPull(int id, int number) async
    test('test getRepoPull', () async {
      // TODO
    });

    // A pull request's conversation: general comments, review summaries and threads on diff lines, oldest first
    //
    //Future<List<PullThread>> listPullThreads(int id, int number) async
    test('test listPullThreads', () async {
      // TODO
    });

    // The repository's pull requests (GitLab merge requests), most recently updated first, 30 per page; a shorter page is the last
    //
    //Future<List<PullItem>> listRepoPulls(int id, { String state, int page }) async
    test('test listRepoPulls', () async {
      // TODO
    });

    // Answer in a thread of a pull request
    //
    //Future<PullComment> replyPullThread(int id, int number, ReplyPullThreadRequest replyPullThreadRequest) async
    test('test replyPullThread', () async {
      // TODO
    });

    // Resolve or reopen a thread on a diff line
    //
    //Future resolvePullThread(int id, int number, ResolvePullThreadRequest resolvePullThreadRequest) async
    test('test resolvePullThread', () async {
      // TODO
    });

  });
}
