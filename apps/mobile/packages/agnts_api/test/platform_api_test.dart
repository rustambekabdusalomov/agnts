import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for PlatformApi
void main() {
  final instance = AgntsApi().getPlatformApi();

  group(PlatformApi, () {
    // Servers, runs and the queue across every workspace (Admin)
    //
    //Future<PlatformOverview> getPlatformOverview() async
    test('test getPlatformOverview', () async {
      // TODO
    });

    // Grant (or take back, when negative) credits (Admin)
    //
    //Future<PlatformWorkspace> grantCredits(int id, GrantCreditsRequest grantCreditsRequest) async
    test('test grantCredits', () async {
      // TODO
    });

    // Every user (Admin)
    //
    //Future<List<User>> listPlatformUsers() async
    test('test listPlatformUsers', () async {
      // TODO
    });

    // Every workspace, metadata only (Admin)
    //
    //Future<List<PlatformWorkspace>> listPlatformWorkspaces() async
    test('test listPlatformWorkspaces', () async {
      // TODO
    });

    // Grant or remove the Admin role (Admin)
    //
    //Future<User> updatePlatformUser(int id, UpdatePlatformUserRequest updatePlatformUserRequest) async
    test('test updatePlatformUser', () async {
      // TODO
    });

    // Change a workspace's plan, slots, member limit, or suspend it (Admin)
    //
    //Future<PlatformWorkspace> updatePlatformWorkspace(int id, UpdatePlatformWorkspaceRequest updatePlatformWorkspaceRequest) async
    test('test updatePlatformWorkspace', () async {
      // TODO
    });

  });
}
