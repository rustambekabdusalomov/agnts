import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for WorkspacesApi
void main() {
  final instance = AgntsApi().getWorkspacesApi();

  group(WorkspacesApi, () {
    // Join the workspace an invite is for
    //
    //Future<WorkspaceSummary> acceptInvite(String token) async
    test('test acceptInvite', () async {
      // TODO
    });

    // Create a workspace you own
    //
    //Future<WorkspaceSummary> createWorkspace(CreateWorkspaceRequest createWorkspaceRequest) async
    test('test createWorkspace', () async {
      // TODO
    });

    // What an invite link is for
    //
    //Future<InvitePreview> getInvite(String token) async
    test('test getInvite', () async {
      // TODO
    });

    // How the workspace's Meta sign-in is going
    //
    //Future<MuseLogin> getWorkspaceMuseLogin(String id) async
    test('test getWorkspaceMuseLogin', () async {
      // TODO
    });

    // The workspaces you are a member of
    //
    //Future<List<WorkspaceSummary>> listWorkspaces() async
    test('test listWorkspaces', () async {
      // TODO
    });

    // Connect the workspace's Muse account by signing in with Meta
    //
    //Future<MuseLogin> startWorkspaceMuseLogin() async
    test('test startWorkspaceMuseLogin', () async {
      // TODO
    });

  });
}
