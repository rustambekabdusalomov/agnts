import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for WorkspaceApi
void main() {
  final instance = AgntsApi().getWorkspaceApi();

  group(WorkspaceApi, () {
    // Invite someone by email or by a link (valid 7 days)
    //
    //Future<CreateInvite201Response> createInvite(CreateInviteRequest createInviteRequest) async
    test('test createInvite', () async {
      // TODO
    });

    // Delete the workspace (kept 7 days for undo, then purged)
    //
    //Future deleteWorkspace(DeleteWorkspaceRequest deleteWorkspaceRequest) async
    test('test deleteWorkspace', () async {
      // TODO
    });

    // Disconnect the workspace's shared Claude or Muse account
    //
    //Future deleteWorkspaceClaudeConnection({ String provider }) async
    test('test deleteWorkspaceClaudeConnection', () async {
      // TODO
    });

    // Where the workspace's tickets stand in the queue
    //
    //Future<QueueStatus> getQueue() async
    test('test getQueue', () async {
      // TODO
    });

    // The current workspace and your role in it
    //
    //Future<WorkspaceDetail> getWorkspace() async
    test('test getWorkspace', () async {
      // TODO
    });

    // Which Claude or Muse account the workspace's runs use
    //
    //Future<WorkspaceClaude> getWorkspaceClaude({ String provider }) async
    test('test getWorkspaceClaude', () async {
      // TODO
    });

    // Leave the workspace
    //
    //Future leaveWorkspace() async
    test('test leaveWorkspace', () async {
      // TODO
    });

    // Open invites
    //
    //Future<List<Invite>> listInvites() async
    test('test listInvites', () async {
      // TODO
    });

    // The workspace's members
    //
    //Future<List<Member>> listMembers() async
    test('test listMembers', () async {
      // TODO
    });

    // Remove a member
    //
    //Future removeMember(int userId) async
    test('test removeMember', () async {
      // TODO
    });

    // Revoke an open invite
    //
    //Future revokeInvite(int id) async
    test('test revokeInvite', () async {
      // TODO
    });

    // Make a member (not the owner) a user or a viewer
    //
    //Future setMemberRole(int userId, SetMemberRoleRequest setMemberRoleRequest) async
    test('test setMemberRole', () async {
      // TODO
    });

    // Connect the workspace's shared Claude account
    //
    //Future<WorkspaceClaude> setWorkspaceClaudeConnection(ClaudeConnectionInput claudeConnectionInput) async
    test('test setWorkspaceClaudeConnection', () async {
      // TODO
    });

    // Make another member the owner
    //
    //Future transferWorkspace(TransferWorkspaceRequest transferWorkspaceRequest) async
    test('test transferWorkspace', () async {
      // TODO
    });

    // Rename the workspace or change its address
    //
    //Future<WorkspaceDetail> updateWorkspace(UpdateWorkspaceRequest updateWorkspaceRequest) async
    test('test updateWorkspace', () async {
      // TODO
    });

    // Choose the Claude mode, the fallback and the default member
    //
    //Future<WorkspaceClaude> updateWorkspaceClaude(UpdateWorkspaceClaudeRequest updateWorkspaceClaudeRequest) async
    test('test updateWorkspaceClaude', () async {
      // TODO
    });

  });
}
