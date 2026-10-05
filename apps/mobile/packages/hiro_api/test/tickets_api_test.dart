import 'package:test/test.dart';
import 'package:hiro_api/hiro_api.dart';


/// tests for TicketsApi
void main() {
  final instance = HiroApi().getTicketsApi();

  group(TicketsApi, () {
    // Answer the ticket's questions; when all are answered, coding starts
    //
    //Future<Ticket> answerQuestions(String key, AnswersRequest answersRequest) async
    test('test answerQuestions', () async {
      // TODO
    });

    // Approve the reviewed work
    //
    // For a change, hiro pushes the branch and opens the pull request. For a report, the ticket is done; the report is posted to the tracker issue only when postReport is true.
    //
    //Future<Ticket> approveTicket(String key, { ApproveTicketRequest approveTicketRequest }) async
    test('test approveTicket', () async {
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

    // Change what the ticket produces
    //
    // Allowed on a new ticket, while hiro waits for answers, and on a failed or rate-limited one that has not pushed. auto lets the analysis pick the kind again; any other kind is final.
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

  });
}
