import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for TaskCreate
void main() {
  final TaskCreate? instance = /* TaskCreate(...) */ null;
  // TODO add properties to the entity

  group(TaskCreate, () {
    // Omit for a task without a repository (report kinds or auto)
    // int repoId
    test('to test the property `repoId`', () async {
      // TODO
    });

    // Several repositories instead of repoId; the first is the primary. Give one of repoId, repoIds and groupId.
    // List<int> repoIds
    test('to test the property `repoIds`', () async {
      // TODO
    });

    // A repository group: the task works in its repositories (copied now)
    // int groupId
    test('to test the property `groupId`', () async {
      // TODO
    });

    // TicketKindChoice kind
    test('to test the property `kind`', () async {
      // TODO
    });

    // String title
    test('to test the property `title`', () async {
      // TODO
    });

    // String description
    test('to test the property `description`', () async {
      // TODO
    });

    // String priority
    test('to test the property `priority`', () async {
      // TODO
    });

    // String afterApprove
    test('to test the property `afterApprove`', () async {
      // TODO
    });

    // ask = analyse and ask first, code = no questions, queue = keep until started
    // String start
    test('to test the property `start`', () async {
      // TODO
    });

    // FollowUpsMode followUps
    test('to test the property `followUps`', () async {
      // TODO
    });

    // Uploads to attach to the description
    // List<int> attachments
    test('to test the property `attachments`', () async {
      // TODO
    });

  });
}
