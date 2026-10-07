import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for Repository
void main() {
  final Repository? instance = /* Repository(...) */ null;
  // TODO add properties to the entity

  group(Repository, () {
    // int id
    test('to test the property `id`', () async {
      // TODO
    });

    // String name
    test('to test the property `name`', () async {
      // TODO
    });

    // jira when the repository has a Jira project key, plane when it has only a Plane project, else side. Every repository takes side-project tasks.
    // String kind
    test('to test the property `kind`', () async {
      // TODO
    });

    // String provider
    test('to test the property `provider`', () async {
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

    // String taskPrefix
    test('to test the property `taskPrefix`', () async {
      // TODO
    });

    // Extra instructions added to every prompt
    // String instructions
    test('to test the property `instructions`', () async {
      // TODO
    });

    // String jiraProject
    test('to test the property `jiraProject`', () async {
      // TODO
    });

    // Plane project identifier (WEB in WEB-123); empty when not linked
    // String planeProject
    test('to test the property `planeProject`', () async {
      // TODO
    });

    // String claudeMd
    test('to test the property `claudeMd`', () async {
      // TODO
    });

    // int openTickets
    test('to test the property `openTickets`', () async {
      // TODO
    });

    // String deployWorkflow
    test('to test the property `deployWorkflow`', () async {
      // TODO
    });

    // Set while the repository is archived
    // DateTime archivedAt
    test('to test the property `archivedAt`', () async {
      // TODO
    });

    // RepoPreview preview
    test('to test the property `preview`', () async {
      // TODO
    });

    // Toolchain names, comma-separated (go,node)
    // String stack
    test('to test the property `stack`', () async {
      // TODO
    });

    // Installed into every run container
    // List<Toolchain> toolchains
    test('to test the property `toolchains`', () async {
      // TODO
    });

    // Set by a person; detection leaves them alone
    // bool toolchainsOverride
    test('to test the property `toolchainsOverride`', () async {
      // TODO
    });

    // DateTime toolchainsDetectedAt
    test('to test the property `toolchainsDetectedAt`', () async {
      // TODO
    });

    // What detection could not handle
    // List<String> toolchainNotes
    test('to test the property `toolchainNotes`', () async {
      // TODO
    });

    // Custom runner image (built FROM agnts-runner); empty uses the default
    // String runnerImage
    test('to test the property `runnerImage`', () async {
      // TODO
    });

    // Run container memory; 0 uses the server default
    // int memoryMb
    test('to test the property `memoryMb`', () async {
      // TODO
    });

    // bool buildEnvSet
    test('to test the property `buildEnvSet`', () async {
      // TODO
    });

    // Names of the build environment variables; the values are never returned
    // List<String> buildEnvNames
    test('to test the property `buildEnvNames`', () async {
      // TODO
    });

  });
}
