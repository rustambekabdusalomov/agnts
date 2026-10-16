import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for RepositoryInput
void main() {
  final RepositoryInput? instance = /* RepositoryInput(...) */ null;
  // TODO add properties to the entity

  group(RepositoryInput, () {
    // String name
    test('to test the property `name`', () async {
      // TODO
    });

    // Ignored; derived from jiraProject and planeProject.
    // String kind
    test('to test the property `kind`', () async {
      // TODO
    });

    // String cloneUrl
    test('to test the property `cloneUrl`', () async {
      // TODO
    });

    // String defaultBranch
    test('to test the property `defaultBranch`', () async {
      // TODO
    });

    // String buildCmd
    test('to test the property `buildCmd`', () async {
      // TODO
    });

    // String lintCmd
    test('to test the property `lintCmd`', () async {
      // TODO
    });

    // String testCmd
    test('to test the property `testCmd`', () async {
      // TODO
    });

    // String branchPrefix
    test('to test the property `branchPrefix`', () async {
      // TODO
    });

    // Branch name template; must contain {key} or {number}. Empty uses {prefix}{key}
    // String branchTemplate
    test('to test the property `branchTemplate`', () async {
      // TODO
    });

    // Commit message template; must contain {subject} or {title}. Empty uses KEY: Title
    // String commitTemplate
    test('to test the property `commitTemplate`', () async {
      // TODO
    });

    // String taskPrefix
    test('to test the property `taskPrefix`', () async {
      // TODO
    });

    // String instructions
    test('to test the property `instructions`', () async {
      // TODO
    });

    // String jiraProject
    test('to test the property `jiraProject`', () async {
      // TODO
    });

    // String planeProject
    test('to test the property `planeProject`', () async {
      // TODO
    });

    // GitHub workflow file run by Deploy, e.g. deploy.yml
    // String deployWorkflow
    test('to test the property `deployWorkflow`', () async {
      // TODO
    });

    // RepoPreviewInput preview
    test('to test the property `preview`', () async {
      // TODO
    });

    // Absent keeps the stored list
    // List<Toolchain> toolchains
    test('to test the property `toolchains`', () async {
      // TODO
    });

    // true: these toolchains were set by hand; detection keeps them
    // bool toolchainsOverride
    test('to test the property `toolchainsOverride`', () async {
      // TODO
    });

    // String runnerImage
    test('to test the property `runnerImage`', () async {
      // TODO
    });

    // int memoryMb
    test('to test the property `memoryMb`', () async {
      // TODO
    });

    // KEY=value lines given to every run (registry tokens); replaces the stored one, \"\" clears it, absent keeps it
    // String buildEnv
    test('to test the property `buildEnv`', () async {
      // TODO
    });

  });
}
