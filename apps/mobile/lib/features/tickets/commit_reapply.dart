import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';

/// One change of a re-apply preview.
typedef CommitReapplyChange = ReapplyCommitFormat200ResponseChangesInner;

/// Asks the server to re-apply the commit format: with [dryRun] it only
/// lists the changes; otherwise it makes those in [only] (by sha).
typedef CommitReapplyCall = Future<List<CommitReapplyChange>> Function(String? number, bool dryRun, List<String>? only);

/// Writes a ticket's unpushed commit messages again from the commit format
/// (the group's, else each repository's), as the web panel does: the ticket
/// number {number} stands for, a preview of every change, the suggested
/// ones ticked (a message written by hand is not), then only the ticked
/// ones. Pops true once applied.
class CommitReapplySheet extends StatefulWidget {
  const CommitReapplySheet({super.key, required this.ticket, required this.call});
  final Ticket ticket;
  final CommitReapplyCall call;

  @override
  State<CommitReapplySheet> createState() => _CommitReapplySheetState();
}

class _CommitReapplySheetState extends State<CommitReapplySheet> {
  late final _number = TextEditingController(text: widget.ticket.ticketNumber ?? '');
  List<CommitReapplyChange>? _changes;
  Set<String> _picked = {};
  bool _busy = false;
  String _error = '';

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  String? get _numberValue => _number.text.trim().isEmpty ? null : _number.text.trim();

  Future<void> _go(bool dryRun) async {
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = '';
    });
    try {
      final changes = await widget.call(_numberValue, dryRun, dryRun ? null : _picked.toList());
      if (!mounted) return;
      if (!dryRun) {
        Navigator.pop(context, true);
        return;
      }
      setState(() {
        _changes = changes;
        _picked = {
          for (final c in changes)
            if (c.suggested) c.sha,
        };
      });
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final grey = TextStyle(fontSize: 12.5, color: c.ink3);
    final mono = TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink);
    final multi = (widget.ticket.repos?.length ?? 0) > 1;
    final changes = _changes;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.ticketCommitsReapply, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(l.ticketCommitsReapplyHelp, style: grey),
              const SizedBox(height: 12),
              TextField(
                controller: _number,
                enabled: !_busy,
                autocorrect: false,
                enableSuggestions: false,
                inputFormatters: [LengthLimitingTextInputFormatter(64)],
                style: const TextStyle(fontFamily: AgntsFonts.mono, fontSize: 14),
                decoration: InputDecoration(labelText: l.ticketCommitsNumber('{number}'), hintText: widget.ticket.key),
                onChanged: (_) => setState(() => _changes = null),
              ),
              const SizedBox(height: 10),
              OutlinedButton(onPressed: _busy ? null : () => _go(true), child: Text(l.ticketCommitsPreview)),
              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_error, style: TextStyle(fontSize: 13, color: c.badInk)),
                ),
              if (changes != null && changes.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(l.ticketCommitsUpToDate, style: grey),
                ),
              if (changes != null && changes.isNotEmpty) ...[
                const SizedBox(height: 6),
                for (final x in changes)
                  CheckboxListTile(
                    key: ValueKey(x.sha),
                    value: _picked.contains(x.sha),
                    onChanged: _busy
                        ? null
                        : (v) => setState(() {
                            _picked = {..._picked};
                            if (v ?? false) {
                              _picked.add(x.sha);
                            } else {
                              _picked.remove(x.sha);
                            }
                          }),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: Text('${multi ? '${x.repoName} · ' : ''}${x.sha.length > 7 ? x.sha.substring(0, 7) : x.sha}', style: grey),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          x.from.split('\n').first,
                          style: mono.copyWith(color: c.ink3, decoration: TextDecoration.lineThrough),
                        ),
                        const SizedBox(height: 2),
                        Text(x.to, style: mono),
                        if (!x.suggested)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(l.ticketCommitsNotSuggested, style: grey),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _busy || _picked.isEmpty ? null : () => _go(false),
                  child: Text(l.ticketCommitsApply(_picked.length)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
