import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for Settings
void main() {
  final Settings? instance = /* Settings(...) */ null;
  // TODO add properties to the entity

  group(Settings, () {
    // StageModels models
    test('to test the property `models`', () async {
      // TODO
    });

    // int maxTurns
    test('to test the property `maxTurns`', () async {
      // TODO
    });

    // int timeoutMin
    test('to test the property `timeoutMin`', () async {
      // TODO
    });

    // List<String> allow
    test('to test the property `allow`', () async {
      // TODO
    });

    // List<String> deny
    test('to test the property `deny`', () async {
      // TODO
    });

    // bool askFirst
    test('to test the property `askFirst`', () async {
      // TODO
    });

    // bool autoResume
    test('to test the property `autoResume`', () async {
      // TODO
    });

    // Learn from every pushed ticket
    // bool autoLearn
    test('to test the property `autoLearn`', () async {
      // TODO
    });

    // Review every result while it waits for review
    // bool autoReview
    test('to test the property `autoReview`', () async {
      // TODO
    });

    // Take screenshots of every UI change in repositories with a preview command
    // bool autoPreview
    test('to test the property `autoPreview`', () async {
      // TODO
    });

    // Coding runs may start the app and look at the pages they changed
    // bool visualCheck
    test('to test the property `visualCheck`', () async {
      // TODO
    });

    // Survey a repository without a brief when its first ticket is analysed, and refresh the brief after merges
    // bool autoBrief
    test('to test the property `autoBrief`', () async {
      // TODO
    });

    // Send blocker and major findings of agnts's code review back to the coder once per revision, before a person reviews
    // bool selfReview
    test('to test the property `selfReview`', () async {
      // TODO
    });

    // Learn from change requests and rejections: suggest rules, which apply once someone adopts them
    // bool reflect
    test('to test the property `reflect`', () async {
      // TODO
    });

    // Hosts run containers may reach besides the built-in list, such as a staging API; .example.com matches subdomains
    // List<String> egressAllow
    test('to test the property `egressAllow`', () async {
      // TODO
    });

    // Runs suggest follow-up tickets (off by default; a ticket can override it)
    // bool suggestFollowUps
    test('to test the property `suggestFollowUps`', () async {
      // TODO
    });

    // How many repositories one ticket, and one repository group, may have (6 by default)
    // int maxTicketRepos
    test('to test the property `maxTicketRepos`', () async {
      // TODO
    });

    // PullReviewSettings pullReviews
    test('to test the property `pullReviews`', () async {
      // TODO
    });

    // PRCommentSettings prComments
    test('to test the property `prComments`', () async {
      // TODO
    });

    // CISettings ci
    test('to test the property `ci`', () async {
      // TODO
    });

    // GuardSettings guard
    test('to test the property `guard`', () async {
      // TODO
    });

    // What agnts does when a run looks stuck: nothing, note it on the ticket, or also tell Claude to step back (once per run)
    // String stalls
    test('to test the property `stalls`', () async {
      // TODO
    });

    // Bug fixes need a test that fails before the change and passes after it; agnts checks it
    // bool proveFixes
    test('to test the property `proveFixes`', () async {
      // TODO
    });

    // Coding runs get agnts's method skills: add one more of something the way the repository does, follow its style, reuse before writing, change a schema safely
    // bool methodSkills
    test('to test the property `methodSkills`', () async {
      // TODO
    });

    // Specialist passes in the code review (security, silent failures, tests, types); auto: large or complex work
    // String deepReview
    test('to test the property `deepReview`', () async {
      // TODO
    });

    // Suggest tips from runs that had trouble (failed checks, a stall)
    // bool learnFromRuns
    test('to test the property `learnFromRuns`', () async {
      // TODO
    });

    // A model that critiques the chosen approach of complex tickets (codex:<model> or a Claude model); empty turns it off
    // String secondOpinion
    test('to test the property `secondOpinion`', () async {
      // TODO
    });

    // int pauseAbove
    test('to test the property `pauseAbove`', () async {
      // TODO
    });

    // int parallel
    test('to test the property `parallel`', () async {
      // TODO
    });

    // GitSettings git
    test('to test the property `git`', () async {
      // TODO
    });

    // NotifySettings notify
    test('to test the property `notify`', () async {
      // TODO
    });

  });
}
