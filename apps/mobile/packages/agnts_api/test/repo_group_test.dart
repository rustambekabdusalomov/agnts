import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for RepoGroup
void main() {
  final RepoGroup? instance = /* RepoGroup(...) */ null;
  // TODO add properties to the entity

  group(RepoGroup, () {
    // int id
    test('to test the property `id`', () async {
      // TODO
    });

    // String name
    test('to test the property `name`', () async {
      // TODO
    });

    // String description
    test('to test the property `description`', () async {
      // TODO
    });

    // How the repositories fit together; added to every prompt of its tickets
    // String instructions
    test('to test the property `instructions`', () async {
      // TODO
    });

    // Key prefix of tasks made from the group; empty uses the first repository's
    // String taskPrefix
    test('to test the property `taskPrefix`', () async {
      // TODO
    });

    // List<RepoGroupMember> members
    test('to test the property `members`', () async {
      // TODO
    });

    // What the repositories share uneasily in one run container (a build variable both set)
    // List<String> warnings
    test('to test the property `warnings`', () async {
      // TODO
    });

    // DateTime createdAt
    test('to test the property `createdAt`', () async {
      // TODO
    });

    // DateTime updatedAt
    test('to test the property `updatedAt`', () async {
      // TODO
    });

  });
}
