import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for LearnApi
void main() {
  final instance = AgntsApi().getLearnApi();

  group(LearnApi, () {
    // Done tickets whose learn run is running, queued, failed or never happened
    //
    //Future<List<LearnQueueItem>> getLearnQueue() async
    test('test getLearnQueue', () async {
      // TODO
    });

    // One lesson with its explanation, code references, quiz and reading
    //
    //Future<Lesson> getLesson(int id) async
    test('test getLesson', () async {
      // TODO
    });

    // Queue a learn run for a pushed ticket (again, if it already ran)
    //
    //Future<Ticket> learnFromTicket(String key) async
    test('test learnFromTicket', () async {
      // TODO
    });

    // Lessons agnts learned from pushed tickets, newest first
    //
    //Future<LessonList> listLessons({ int repo, String ticket, String status, String q, int limit }) async
    test('test listLessons', () async {
      // TODO
    });

    // Mark a lesson learned
    //
    //Future<Lesson> markLessonLearned(int id) async
    test('test markLessonLearned', () async {
      // TODO
    });

    // Mark a lesson as not learned yet
    //
    //Future<Lesson> unmarkLessonLearned(int id) async
    test('test unmarkLessonLearned', () async {
      // TODO
    });

  });
}
