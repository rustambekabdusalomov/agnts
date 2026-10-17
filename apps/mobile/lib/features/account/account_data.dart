import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../core/data.dart';

// The account's and the workspace's settings (Profile, Workspace).

/// The person's own Claude account.
final myClaudeProvider = FutureProvider.autoDispose<ClaudeConnectionState>((ref) async {
  return (await requireApi(ref).getAccountApi().getMyClaude()).data!;
});

/// The current workspace in full.
final workspaceDetailProvider = FutureProvider.autoDispose<WorkspaceDetail>((ref) async {
  ref.watch(currentWorkspaceProvider.select((w) => w?.slug));
  return (await requireApi(ref).getWorkspaceApi().getWorkspace()).data!;
});

/// Which Claude account the workspace's runs use.
final workspaceClaudeProvider = FutureProvider.autoDispose<WorkspaceClaude>((ref) async {
  ref.watch(currentWorkspaceProvider.select((w) => w?.slug));
  return (await requireApi(ref).getWorkspaceApi().getWorkspaceClaude()).data!;
});

final membersProvider = FutureProvider.autoDispose<List<Member>>((ref) async {
  ref.watch(currentWorkspaceProvider.select((w) => w?.slug));
  return (await requireApi(ref).getWorkspaceApi().listMembers()).data ?? const [];
});

/// Open invites (the owner's).
final invitesProvider = FutureProvider.autoDispose<List<Invite>>((ref) async {
  ref.watch(currentWorkspaceProvider.select((w) => w?.slug));
  return (await requireApi(ref).getWorkspaceApi().listInvites()).data ?? const [];
});

/// The owner's billing: plan, parallel runs, credits and their history.
final billingProvider = FutureProvider.autoDispose<Billing>((ref) async {
  ref.watch(currentWorkspaceProvider.select((w) => w?.slug));
  return (await requireApi(ref).getBillingApi().getBilling()).data!;
});

/// Whether the person owns the current workspace.
final isOwnerProvider = Provider.autoDispose<bool>((ref) => ref.watch(currentWorkspaceProvider)?.role == WorkspaceRole.owner);
