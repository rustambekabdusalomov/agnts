import 'package:agnts_api/agnts_api.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/ui.dart';

const _firstError = '=== first error ===';
const _endOfLog = '=== end of the log ===';

/// The part of a CI failure's log excerpt worth reading first: the first
/// error block between the server's markers (`first` is true), else the last
/// [tail] lines. The excerpt is untrusted plain text; it is only displayed.
/// An excerpt cut in the middle ("\n…\n") with no end marker keeps the part
/// before the cut.
({String text, bool first}) sampleExcerpt(String sample, {int tail = 40}) {
  final s = sample.replaceAll('\r\n', '\n');
  final i = s.indexOf(_firstError);
  if (i >= 0) {
    var block = s.substring(i + _firstError.length);
    final end = block.indexOf(_endOfLog);
    if (end >= 0) {
      block = block.substring(0, end);
    } else {
      final cut = block.indexOf('\n…\n');
      if (cut >= 0) block = block.substring(0, cut);
    }
    block = block.replaceFirst(RegExp(r'^\n+'), '').trimRight();
    if (block.isNotEmpty) return (text: block, first: true);
  }
  final lines = s.trimRight().split('\n');
  final from = lines.length > tail ? lines.length - tail : 0;
  return (text: lines.sublist(from).join('\n').replaceFirst(RegExp(r'^\n+'), ''), first: false);
}

/// A CI status's label and tone.
(String, Tone) ciStatusBadge(AppLocalizations l, CIStatus s) => switch (s) {
      CIStatus.triage => (l.mciStatus_triage, Tone.gray),
      CIStatus.open => (l.mciStatus_open, Tone.bad),
      CIStatus.fixing => (l.mciStatus_fixing, Tone.info),
      CIStatus.fixed => (l.mciStatus_fixed, Tone.ok),
      CIStatus.resolved => (l.mciStatus_resolved, Tone.ok),
      CIStatus.flaky => (l.mciStatus_flaky, Tone.warn),
      CIStatus.infra => (l.mciStatus_infra, Tone.gray),
      CIStatus.muted => (l.mciStatus_muted, Tone.gray),
      CIStatus.regression => (l.mciStatus_regression, Tone.bad),
    };

/// Whether the failure's ticket is still at work (not done or rejected).
bool hasLiveTicket(CIFailure f) {
  final s = f.ticketState;
  return f.ticketKey.isNotEmpty && s != null && s != TicketState.done && s != TicketState.rejected;
}

/// Whether "Fix it" applies: a red group of agnts's own branches that no
/// ticket works on. The server checks the same.
bool canFixCI(CIFailure f) => (f.status == CIStatus.open || f.status == CIStatus.regression) && !hasLiveTicket(f) && f.prNumber == 0;

/// A commit's short hash.
String shortSha(String sha) => sha.length > 7 ? sha.substring(0, 7) : sha;
