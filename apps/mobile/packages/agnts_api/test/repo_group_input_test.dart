import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for RepoGroupInput
void main() {
  final RepoGroupInput? instance = /* RepoGroupInput(...) */ null;
  // TODO add properties to the entity

  group(RepoGroupInput, () {
    // String name
    test('to test the property `name`', () async {
      // TODO
    });

    // String description
    test('to test the property `description`', () async {
      // TODO
    });

    // String instructions
    test('to test the property `instructions`', () async {
      // TODO
    });

    // String taskPrefix
    test('to test the property `taskPrefix`', () async {
      // TODO
    });

    // Branch name template (as a repository's); must contain {key} or {number}. Empty keeps each repository's own
    // String branchTemplate
    test('to test the property `branchTemplate`', () async {
      // TODO
    });

    // Commit message template (as a repository's); must contain {subject} or {title}. Empty keeps each repository's own
    // String commitTemplate
    test('to test the property `commitTemplate`', () async {
      // TODO
    });

    // Pull request title template (as a repository's); must contain {subject} or {title}. Empty keeps each repository's own
    // String prTemplate
    test('to test the property `prTemplate`', () async {
      // TODO
    });

    // In order; the first is the primary repository of the group's tickets
    // List<RepoGroupInputMembersInner> members
    test('to test the property `members`', () async {
      // TODO
    });

  });
}
