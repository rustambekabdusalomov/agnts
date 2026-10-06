import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for TasksApi
void main() {
  final instance = AgntsApi().getTasksApi();

  group(TasksApi, () {
    // Create a side-project task
    //
    //Future<Ticket> createTask(TaskCreate taskCreate) async
    test('test createTask', () async {
      // TODO
    });

    // Delete a task that has not started
    //
    //Future deleteTask(String key) async
    test('test deleteTask', () async {
      // TODO
    });

    // Edit a task that has not started
    //
    //Future<Ticket> updateTask(String key, TaskUpdate taskUpdate) async
    test('test updateTask', () async {
      // TODO
    });

  });
}
