import 'package:flutter/widgets.dart' hide Feedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';

// The Admin cabinet's data (system Admins only): every user and workspace on
// the platform, the server's runs and queue, and the feedback people sent.

/// The server's capacity, runs and queue. The dashboard refreshes it while open.
final platformOverviewProvider = FutureProvider<PlatformOverview>((ref) async {
  return (await requireApi(ref).getPlatformApi().getPlatformOverview()).data!;
});

final platformWorkspacesProvider = FutureProvider<List<PlatformWorkspace>>((ref) async {
  return (await requireApi(ref).getPlatformApi().listPlatformWorkspaces()).data ?? const [];
});

/// Every account, Users and Admins alike, each with their workspaces.
final platformUsersProvider = FutureProvider<List<PlatformUser>>((ref) async {
  return (await requireApi(ref).getPlatformApi().listPlatformUsers()).data ?? const [];
});

final platformFeedbackProvider = FutureProvider<List<Feedback>>((ref) async {
  return (await requireApi(ref).getPlatformApi().listPlatformFeedback()).data ?? const [];
});

/// Rows of the audit log asked for at a time.
const auditPage = 100;

/// The newest page of the audit log: what Admins read of customer content.
/// Older pages are fetched with [fetchAuditBefore].
final platformAuditProvider = FutureProvider<List<AdminAuditEntry>>((ref) async {
  return (await requireApi(ref).getPlatformApi().listPlatformAudit(limit: auditPage)).data ?? const [];
});

/// The page of the audit log below the row [before].
Future<List<AdminAuditEntry>> fetchAuditBefore(AgntsApi api, int before) async {
  return (await api.getPlatformApi().listPlatformAudit(before: before, limit: auditPage)).data ?? const [];
}

/// Refetches everything the cabinet shows.
void refreshPlatform(WidgetRef ref) {
  ref.invalidate(platformOverviewProvider);
  ref.invalidate(platformWorkspacesProvider);
  ref.invalidate(platformUsersProvider);
  ref.invalidate(platformFeedbackProvider);
  ref.invalidate(platformAuditProvider);
}

/// A person's name as the cabinet shows it.
String nameOf(User u) => (u.displayName?.isNotEmpty ?? false) ? u.displayName! : u.username;

/// Email, else username: the line under a name.
String contactOf(User u) => (u.email?.isNotEmpty ?? false) ? u.email! : u.username;

/// Whether [at] is within the last [days] days.
bool within(DateTime? at, int days) => at != null && DateTime.now().difference(at) < Duration(days: days);

/// "just now", "5m ago", "2d 3h ago", or the date once it is a month old.
String agoText(BuildContext context, DateTime? at) {
  if (at == null) return '—';
  final l = AppLocalizations.of(context);
  final d = DateTime.now().difference(at);
  if (d.inMinutes < 1) return l.mmoreJustNow;
  if (d.inDays >= 30) return DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(at.toLocal());
  return l.mmoreAgo(shortDuration(d));
}

/// Counts per day for the last [days] days (oldest first), by each time.
List<int> perDay(Iterable<DateTime?> times, int days) {
  final now = DateTime.now();
  // Calendar days in UTC, so a daylight-saving change does not shift a bucket.
  final first = DateTime.utc(now.year, now.month, now.day - (days - 1));
  final out = List<int>.filled(days, 0);
  for (final t in times) {
    if (t == null) continue;
    final local = t.toLocal();
    final i = DateTime.utc(local.year, local.month, local.day).difference(first).inDays;
    if (i >= 0 && i < days) out[i]++;
  }
  return out;
}

/// Gigabytes from megabytes: "8 GB", "1.5 GB".
String gb(int mb) => '${(mb / 1024).toStringAsFixed(mb % 1024 == 0 ? 0 : 1)} GB';
