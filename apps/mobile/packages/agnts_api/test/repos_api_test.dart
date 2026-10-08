import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for ReposApi
void main() {
  final instance = AgntsApi().getReposApi();

  group(ReposApi, () {
    // Make the draft the brief that runs read
    //
    //Future<RepoBrief> approveRepoBrief(int id) async
    test('test approveRepoBrief', () async {
      // TODO
    });

    // Archive the repository; it keeps its history but takes no new tickets or tasks
    //
    //Future<Repository> archiveRepo(int id) async
    test('test archiveRepo', () async {
      // TODO
    });

    //Future<Repository> createRepo(RepositoryInput repositoryInput) async
    test('test createRepo', () async {
      // TODO
    });

    // Start a deployment (GitLab manual job, or the GitHub deploy workflow). Never available from MCP.
    //
    //Future deployRepo(int id, DeployRepoRequest deployRepoRequest) async
    test('test deployRepo', () async {
      // TODO
    });

    // Work out a repository's toolchains and check commands
    //
    // Reads the default branch (of a saved repository by id, or of any clone URL) and returns what it needs, without saving. With deep, Claude also reads the README and CI files when the file scan finds nothing; that takes a minute and uses the Claude plan. 
    //
    //Future<RepoDetection> detectRepo(RepoDetectInput repoDetectInput) async
    test('test detectRepo', () async {
      // TODO
    });

    // Drop the draft a survey wrote
    //
    //Future<RepoBrief> discardRepoBriefDraft(int id) async
    test('test discardRepoBriefDraft', () async {
      // TODO
    });

    //Future<Repository> getRepo(int id) async
    test('test getRepo', () async {
      // TODO
    });

    // What agnts knows about how the repository works; empty and idle before the first survey
    //
    //Future<RepoBrief> getRepoBrief(int id) async
    test('test getRepoBrief', () async {
      // TODO
    });

    // Branches with their tip, ahead/behind the default branch and checks
    //
    //Future<List<Branch>> listRepoBranches(int id) async
    test('test listRepoBranches', () async {
      // TODO
    });

    // Commits on the default branch, newest first, 50 per page; a shorter page is the last
    //
    //Future<List<Commit>> listRepoCommits(int id, { int page }) async
    test('test listRepoCommits', () async {
      // TODO
    });

    // Deployment environments and what runs there
    //
    //Future<List<Environment>> listRepoEnvironments(int id) async
    test('test listRepoEnvironments', () async {
      // TODO
    });

    // Branches in agnts's own clones on the server, and whether origin has them
    //
    //Future<List<LocalBranch>> listRepoLocalBranches(int id) async
    test('test listRepoLocalBranches', () async {
      // TODO
    });

    // People with access to the repository on its git host
    //
    //Future<List<RepoMember>> listRepoMembers(int id) async
    test('test listRepoMembers', () async {
      // TODO
    });

    // CI runs with their stages, newest first, 20 per page; a shorter page is the last
    //
    //Future<List<Pipeline>> listRepoPipelines(int id, { int page }) async
    test('test listRepoPipelines', () async {
      // TODO
    });

    //Future<List<Repository>> listRepos() async
    test('test listRepos', () async {
      // TODO
    });

    // Replace the approved brief with your text; empty text removes it
    //
    //Future<RepoBrief> saveRepoBrief(int id, RepoBriefInput repoBriefInput) async
    test('test saveRepoBrief', () async {
      // TODO
    });

    // Have Claude survey the repository and write a draft brief (an update when it has one)
    //
    //Future<RepoBrief> surveyRepoBrief(int id) async
    test('test surveyRepoBrief', () async {
      // TODO
    });

    // Restore an archived repository
    //
    //Future<Repository> unarchiveRepo(int id) async
    test('test unarchiveRepo', () async {
      // TODO
    });

    //Future<Repository> updateRepo(int id, RepositoryInput repositoryInput) async
    test('test updateRepo', () async {
      // TODO
    });

  });
}
