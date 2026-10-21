import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for TicketsApi
void main() {
  final instance = AgntsApi().getTicketsApi();

  group(TicketsApi, () {
    // Create tickets from chosen suggestions
    //
    // Each chosen suggestion becomes a queued (held) ticket, as a local task, a new Jira issue or a new Plane work item. Nothing runs until it is started. Items are handled one by one; each result says what happened to its suggestion. What the analysis suggested can be created at once; what the work or its review found waits until this ticket is done.
    //
    //Future<AcceptFollowUpsResult> acceptFollowUps(String key, AcceptFollowUps acceptFollowUps) async
    test('test acceptFollowUps', () async {
      // TODO
    });

    // Accept a relation agnts proposed; the queue follows it from now on
    //
    //Future<Relation> acceptRelation(String key, int id) async
    test('test acceptRelation', () async {
      // TODO
    });

    // Confirm that the lines flagged as secrets in the change under review are not real credentials
    //
    // A change with lines agnts's scan flagged as secrets (or a dotenv file) cannot be approved until a person confirms, for that commit, that they are not real credentials.
    //
    //Future<Ticket> acknowledgeSecrets(String key) async
    test('test acknowledgeSecrets', () async {
      // TODO
    });

    // Make this ticket wait for another, or keep the two from running side by side
    //
    // depends_on: this ticket does not start coding until the other is merged (or rejected). conflicts: whichever of the two starts coding second waits until the first is merged. A dependency that would make two tickets wait for each other is refused (400). Adding a relation agnts proposed or someone dismissed makes it active.
    //
    //Future<Relation> addRelation(String key, RelationInput relationInput) async
    test('test addRelation', () async {
      // TODO
    });

    // Send reviewers' threads on the ticket's open pull requests back to coding: the given ones, or every unresolved thread by someone else not sent yet. After the fix is approved and pushed, agnts answers in each thread
    //
    //Future<Ticket> addressPullComments(String key, { AddressPullCommentsRequest addressPullCommentsRequest }) async
    test('test addressPullComments', () async {
      // TODO
    });

    // Answer the ticket's questions; when all are answered, coding starts
    //
    //Future<Ticket> answerQuestions(String key, AnswersRequest answersRequest) async
    test('test answerQuestions', () async {
      // TODO
    });

    // Approve the reviewed work
    //
    // For a change, agnts pushes the branch and opens the pull request. For a report, the ticket is done; the report is posted to the tracker issue only when postReport is true.
    //
    //Future<Ticket> approveTicket(String key, { ApproveTicketRequest approveTicketRequest }) async
    test('test approveTicket', () async {
      // TODO
    });

    // Pick a rejected ticket up again where it stopped
    //
    // Goes back to the stage it was rejected at (the ticket's continueTo). A ticket rejected at review goes back to review, or to coding when a note or files ask for changes. When the work's commits are gone, it starts over from analysis. 
    //
    //Future<Ticket> continueTicket(String key, { ContinueTicketRequest continueTicketRequest }) async
    test('test continueTicket', () async {
      // TODO
    });

    // Decline a suggestion; later runs will not suggest it again
    //
    //Future<FollowUpSuggestion> dismissFollowUp(String key, int id) async
    test('test dismissFollowUp', () async {
      // TODO
    });

    // Dismiss a relation (run anyway); agnts does not propose it again
    //
    //Future<Relation> dismissRelation(String key, int id) async
    test('test dismissRelation', () async {
      // TODO
    });

    // Change the message of one of agnts's commits before it pushes them
    //
    // One of the repository's commits (its commits, ticket detail only), under the rules of renameTicketBranch: a branch never pushed, while the ticket waits for review or stopped on an error. The commits after it are made again on top, so the repository's headSha changes; the same message changes nothing. 
    //
    //Future<Ticket> editCommitMessage(String key, EditCommitMessageRequest editCommitMessageRequest) async
    test('test editCommitMessage', () async {
      // TODO
    });

    // Turn a code review finding into a follow-up suggestion
    //
    // No Claude run is involved.
    //
    //Future<FollowUpSuggestion> followUpFromFinding(String key, int index) async
    test('test followUpFromFinding', () async {
      // TODO
    });

    // One preview screenshot, as PNG
    //
    //Future<Uint8List> getPreviewShot(String key, int runId, String shotId) async
    test('test getPreviewShot', () async {
      // TODO
    });

    // A ticket with its questions, analysis and latest result
    //
    //Future<TicketDetail> getTicket(String key) async
    test('test getTicket', () async {
      // TODO
    });

    // Make the code task that carries out a done plan or bug investigation
    //
    // Creates a local code task linked back to the report (parentKey), with the approved report in its description. A report is implemented once. repoId is needed only when the report has no repository.
    //
    //Future<Ticket> implementTicket(String key, { ImplementInput implementInput }) async
    test('test implementTicket', () async {
      // TODO
    });

    // Keep working from the version agnts started with; this newer version of the issue is not asked about again
    //
    //Future<Ticket> keepCurrentVersion(String key) async
    test('test keepCurrentVersion', () async {
      // TODO
    });

    // Suggested follow-up tickets and the tickets made from them
    //
    //Future<FollowUps> listFollowUps(String key) async
    test('test listFollowUps', () async {
      // TODO
    });

    // The ticket's ordering constraints and what holds it back now
    //
    //Future<Relations> listRelations(String key) async
    test('test listRelations', () async {
      // TODO
    });

    // The ticket's log, oldest first; poll with `after` for live updates
    //
    //Future<List<Event>> listTicketEvents(String key, { int after, int limit }) async
    test('test listTicketEvents', () async {
      // TODO
    });

    // Commits on the git host linked to the ticket by its number or key, newest first
    //
    // Anyone's commits whose branch or message has the ticket's number (or its key), as whole words ignoring case: feature/AMANAT-2288-login, \"AMANAT-2288: fix\". They come from the git hosts' push webhooks, and from a scan of the repositories' recent history when the ticket arrives, its number changes or a repository is added. A number that open and closed tickets share links to the open one. Commit subjects are written by people. 
    //
    //Future<LinkedCommits> listTicketLinkedCommits(String key, { int limit, int offset }) async
    test('test listTicketLinkedCommits', () async {
      // TODO
    });

    // Tickets, most recently active first
    //
    //Future<List<Ticket>> listTickets({ List<TicketState> state }) async
    test('test listTickets', () async {
      // TODO
    });

    // Record that a done ticket's pull request was merged
    //
    // For setups without a git host webhook. Tickets waiting for this one may start coding.
    //
    //Future<Ticket> markTicketMerged(String key) async
    test('test markTicketMerged', () async {
      // TODO
    });

    // Queue a preview (screenshots of the running app) of a ticket waiting for review, again if one already ran
    //
    //Future<Ticket> previewTicket(String key, { PreviewInput previewInput }) async
    test('test previewTicket', () async {
      // TODO
    });

    // Write agnts's unpushed commit messages again from the commit format in effect
    //
    // For commits made before a format was set. Each repository's commits (its commits) get the format of the ticket's group, else of the repository, filled with the type, scope and subject the coding run that made the commit gave (the ticket's kind and title when it gave none). Repositories without a format are left as they are. Same rules as editCommitMessage. With dryRun nothing changes: changes lists what would. 
    //
    //Future<ReapplyCommitFormat200Response> reapplyCommitFormat(String key, { ReapplyCommitFormatRequest reapplyCommitFormatRequest }) async
    test('test reapplyCommitFormat', () async {
      // TODO
    });

    // Stop work on the ticket for good
    //
    //Future<Ticket> rejectTicket(String key, { RejectTicketRequest rejectTicketRequest }) async
    test('test rejectTicket', () async {
      // TODO
    });

    // Rename the ticket's branch before agnts pushes it
    //
    // Only a branch that was never pushed (the repository's canRenameBranch), while the ticket waits for review or stopped on an error. The pull request opens from the new name, and later runs keep it. 409 when the name is taken, in agnts or on the git host. 
    //
    //Future<Ticket> renameTicketBranch(String key, RenameTicketBranchRequest renameTicketBranchRequest) async
    test('test renameTicketBranch', () async {
      // TODO
    });

    // Re-run a done code or test ticket with today's agnts, from the commit it started from, to compare the two (Analytics → Replay evaluation). The replay is a new local task that is never pushed.
    //
    //Future<Ticket> replayTicket(String key) async
    test('test replayTicket', () async {
      // TODO
    });

    // Send the ticket back to coding with feedback
    //
    //Future<Ticket> requestChanges(String key, RequestChangesRequest requestChangesRequest) async
    test('test requestChanges', () async {
      // TODO
    });

    // Start the ticket over from the newer version of its issue; the work so far is dropped
    //
    //Future<Ticket> restartWithUpdate(String key) async
    test('test restartWithUpdate', () async {
      // TODO
    });

    // Resume a failed or rate-limited ticket where it stopped
    //
    //Future<Ticket> retryTicket(String key, { RetryTicketRequest retryTicketRequest }) async
    test('test retryTicket', () async {
      // TODO
    });

    // Queue a code review of a ticket waiting for review (again, if one already ran)
    //
    //Future<Ticket> reviewTicket(String key) async
    test('test reviewTicket', () async {
      // TODO
    });

    // Turn follow-up suggestions on or off for this ticket
    //
    // inherit follows Settings (suggestFollowUps). Suggestions add a little to every prompt of the ticket's runs, so they are off unless asked for.
    //
    //Future<Ticket> setFollowUps(String key, FollowUpsSetting followUpsSetting) async
    test('test setFollowUps', () async {
      // TODO
    });

    // Put a merged code or test ticket in the benchmark, or take it out
    //
    //Future<Ticket> setTicketBenchmark(String key, SetTicketBenchmarkRequest setTicketBenchmarkRequest) async
    test('test setTicketBenchmark', () async {
      // TODO
    });

    // Change what the ticket produces
    //
    // Allowed on a new ticket, while agnts waits for answers, and on a failed or rate-limited one that has not pushed. auto lets the analysis pick the kind again; any other kind is final.
    //
    //Future<Ticket> setTicketKind(String key, TicketKindInput ticketKindInput) async
    test('test setTicketKind', () async {
      // TODO
    });

    // Make a member the ticket's member (per-member Claude mode runs it on their account)
    //
    //Future<Ticket> setTicketMember(String key, SetTicketMemberRequest setTicketMemberRequest) async
    test('test setTicketMember', () async {
      // TODO
    });

    // Override models for this ticket; omit a stage to use the default
    //
    //Future<Ticket> setTicketModels(String key, ModelOverrides modelOverrides) async
    test('test setTicketModels', () async {
      // TODO
    });

    // Change the team's number for the work until the ticket is closed
    //
    // The number ({number}) branch and commit names are made from, like AMANAT-2677; empty clears it, so the key stands for it. Any state but done and rejected. Branches and commits made from then on use it; ones already made keep their names until renamed (renameTicketBranch, reapplyCommitFormat). The same number changes nothing. 
    //
    //Future<Ticket> setTicketNumber(String key, SetTicketNumberRequest setTicketNumberRequest) async
    test('test setTicketNumber', () async {
      // TODO
    });

    // Link the ticket to a repository
    //
    // Allowed on a new ticket, or a failed or rate-limited one that has not pushed. A stopped ticket starts over from analysis on retry, since its analysis and branch belonged to the old repository. The same as PUT /tickets/{key}/repos with one repository.
    //
    //Future<Ticket> setTicketRepo(String key, TicketRepo ticketRepo) async
    test('test setTicketRepo', () async {
      // TODO
    });

    // Set the ticket's repositories (one, several or a group)
    //
    // Allowed while no stage runs and nothing was pushed: on a new ticket, or a failed or rate-limited one. A stopped ticket starts over from analysis on retry. Give repoIds (the first is the primary) or groupId, not both.
    //
    //Future<Ticket> setTicketRepos(String key, TicketReposInput ticketReposInput) async
    test('test setTicketRepos', () async {
      // TODO
    });

    // Start a held ticket now (it is queued for the next free slot)
    //
    //Future<Ticket> startTicket(String key) async
    test('test startTicket', () async {
      // TODO
    });

    // Pick a rejected ticket up again from scratch
    //
    // Drops the analysis, answers and commits and analyses the ticket again. Only when nothing of it was pushed (the ticket's canStartOver).
    //
    //Future<Ticket> startTicketOver(String key) async
    test('test startTicketOver', () async {
      // TODO
    });

    // Stop the running stage; the ticket moves to failed and can be retried
    //
    //Future<Ticket> stopTicket(String key) async
    test('test stopTicket', () async {
      // TODO
    });

    // Translate a ticket's texts (its own and what agnts wrote) into a language
    //
    // Translations are stored per text, so a text is sent to Claude only once per language; asking again, or for a later revision that keeps most texts, answers from the store. Texts not yet translated are translated in this request, which can take a minute.
    //
    //Future<Translation> translateTicket(String key, TranslateInput translateInput) async
    test('test translateTicket', () async {
      // TODO
    });

  });
}
