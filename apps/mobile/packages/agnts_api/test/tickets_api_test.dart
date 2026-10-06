import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for TicketsApi
void main() {
  final instance = AgntsApi().getTicketsApi();

  group(TicketsApi, () {
    // Create tickets from chosen suggestions
    //
    // Each chosen suggestion becomes a queued (held) ticket, as a local task or a new Jira issue. Nothing runs until it is started. Items are handled one by one; each result says what happened to its suggestion. What the analysis suggested can be created at once; what the work or its review found waits until this ticket is done.
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

    // Make this ticket wait for another, or keep the two from running side by side
    //
    // depends_on: this ticket does not start coding until the other is merged (or rejected). conflicts: whichever of the two starts coding second waits until the first is merged. A dependency that would make two tickets wait for each other is refused (400). Adding a relation agnts proposed or someone dismissed makes it active.
    //
    //Future<Relation> addRelation(String key, RelationInput relationInput) async
    test('test addRelation', () async {
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

    // Turn a code review finding into a follow-up suggestion
    //
    // No Claude run is involved.
    //
    //Future<FollowUpSuggestion> followUpFromFinding(String key, int index) async
    test('test followUpFromFinding', () async {
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

    // Stop work on the ticket for good
    //
    //Future<Ticket> rejectTicket(String key, { RejectTicketRequest rejectTicketRequest }) async
    test('test rejectTicket', () async {
      // TODO
    });

    // Send the ticket back to coding with feedback
    //
    //Future<Ticket> requestChanges(String key, RequestChangesRequest requestChangesRequest) async
    test('test requestChanges', () async {
      // TODO
    });

    // Resume a failed or rate-limited ticket where it stopped
    //
    //Future<Ticket> retryTicket(String key) async
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

    // Change what the ticket produces
    //
    // Allowed on a new ticket, while agnts waits for answers, and on a failed or rate-limited one that has not pushed. auto lets the analysis pick the kind again; any other kind is final.
    //
    //Future<Ticket> setTicketKind(String key, TicketKindInput ticketKindInput) async
    test('test setTicketKind', () async {
      // TODO
    });

    // Override models for this ticket; omit a stage to use the default
    //
    //Future<Ticket> setTicketModels(String key, ModelOverrides modelOverrides) async
    test('test setTicketModels', () async {
      // TODO
    });

    // Link the ticket to a repository
    //
    // Allowed on a new ticket, or a failed or rate-limited one that has not pushed. A stopped ticket starts over from analysis on retry, since its analysis and branch belonged to the old repository.
    //
    //Future<Ticket> setTicketRepo(String key, TicketRepo ticketRepo) async
    test('test setTicketRepo', () async {
      // TODO
    });

    // Start a held ticket now (it is queued for the next free slot)
    //
    //Future<Ticket> startTicket(String key) async
    test('test startTicket', () async {
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
