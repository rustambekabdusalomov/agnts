import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for PlatformApi
void main() {
  final instance = AgntsApi().getPlatformApi();

  group(PlatformApi, () {
    // Create an Admin account that signs in with a password (Admin)
    //
    //Future<User> createPlatformAdmin(CreatePlatformAdminRequest createPlatformAdminRequest) async
    test('test createPlatformAdmin', () async {
      // TODO
    });

    // Delete an Admin account; not your own (Admin)
    //
    //Future deletePlatformAdmin(int id) async
    test('test deletePlatformAdmin', () async {
      // TODO
    });

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

    // Every feedback people sent, newest first (Admin)
    //
    //Future<List<Feedback>> listPlatformFeedback() async
    test('test listPlatformFeedback', () async {
      // TODO
    });

    // Every user, with their workspaces and last sign-in (Admin)
    //
    //Future<List<PlatformUser>> listPlatformUsers() async
    test('test listPlatformUsers', () async {
      // TODO
    });

    // Every workspace, metadata only (Admin)
    //
    //Future<List<PlatformWorkspace>> listPlatformWorkspaces() async
    test('test listPlatformWorkspaces', () async {
      // TODO
    });

    // Mark a feedback done, or new again (Admin)
    //
    //Future<Feedback> updatePlatformFeedback(int id, UpdatePlatformFeedbackRequest updatePlatformFeedbackRequest) async
    test('test updatePlatformFeedback', () async {
      // TODO
    });

    // Grant or remove the Admin role (Admin); refused when Admins and Users are separate accounts
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
