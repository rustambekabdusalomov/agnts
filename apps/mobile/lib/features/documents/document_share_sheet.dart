import 'package:agnts_api/agnts_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../account/account_data.dart' show membersProvider;
import 'documents_data.dart';
import 'documents_logic.dart';

/// Who can open a document (its owner only): private or public with its
/// link, what everyone in the workspace gets, and each member's access.
Future<void> showDocumentShareSheet(BuildContext context, int id) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.92),
      builder: (_) => DocumentShareSheet(id: id),
    );

class DocumentShareSheet extends ConsumerStatefulWidget {
  const DocumentShareSheet({super.key, required this.id});
  final int id;

  @override
  ConsumerState<DocumentShareSheet> createState() => _DocumentShareSheetState();
}

typedef _Level = DocumentShareInputGrantsInnerLevelEnum;

class _DocumentShareSheetState extends ConsumerState<DocumentShareSheet> {
  DocumentSharing? _loaded;
  bool _public = false;
  DocumentShareInputWorkspaceAccessEnum _ws = DocumentShareInputWorkspaceAccessEnum.none;
  final Map<int, _Level> _grants = {};
  bool _busy = false;
  String? _error;
  List<(int, String)> _secrets = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = (await ref.read(apiProvider)!.getDocumentsApi().getDocumentSharing(id: widget.id)).data!;
      if (!mounted) return;
      setState(() => _apply(s));
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(e, AppLocalizations.of(context).commonError));
    }
  }

  void _apply(DocumentSharing s) {
    _loaded = s;
    _public = s.type == DocumentSharingTypeEnum.public;
    _ws = DocumentShareInputWorkspaceAccessEnum.values.firstWhere((x) => x.value == s.workspaceAccess.value);
    _grants
      ..clear()
      ..addEntries(s.grants.map((g) => MapEntry(g.userId, _Level.values.firstWhere((x) => x.value == g.level.value))));
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
      _secrets = const [];
    });
    try {
      final input = DocumentShareInput(
        type: _public ? DocumentShareInputTypeEnum.public : DocumentShareInputTypeEnum.private,
        workspaceAccess: _ws,
        grants: [for (final e in _grants.entries) DocumentShareInputGrantsInner(userId: e.key, level: e.value)],
      );
      final s = (await ref.read(apiProvider)!.getDocumentsApi().shareDocument(id: widget.id, documentShareInput: input)).data!;
      ref.invalidate(documentProvider(widget.id));
      ref.invalidate(documentsProvider);
      if (!mounted) return;
      setState(() => _apply(s));
      showSnack(context, l.mdocumentsSaved);
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.response?.statusCode == 422) {
          _secrets = secretLines(e.response?.data);
          _public = false;
        } else {
          _error = errorMessage(e, l.commonError);
        }
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reset() async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final s = (await ref.read(apiProvider)!.getDocumentsApi().resetDocumentLink(id: widget.id)).data!;
      ref.invalidate(documentProvider(widget.id));
      if (!mounted) return;
      setState(() => _apply(s));
      showSnack(context, l.mdocumentsResetDone);
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
    final s = _loaded;
    final members = ref.watch(membersProvider).value ?? const <Member>[];
    String accessLabel(String v) => switch (v) { 'view' => l.mdocumentsAccessView, 'edit' => l.mdocumentsAccessEdit, _ => l.mdocumentsAccessNone };
    return Material(
      color: c.bg,
      child: s == null
          ? Padding(
              padding: const EdgeInsets.all(32),
              child: Center(child: _error != null ? Text(_error!) : const CircularProgressIndicator()),
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + MediaQuery.viewInsetsOf(context).bottom),
              children: [
                Text(l.mdocumentsSharing, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: c.ink)),
                const SizedBox(height: 14),
                ListGroup(children: [
                  SwitchListTile(
                    title: Text(l.mdocumentsPublicLink),
                    subtitle: Text(s.publicAllowed ? l.mdocumentsPublicHint : l.mdocumentsPublicOff),
                    value: _public,
                    onChanged: _busy || (!s.publicAllowed && !_public) ? null : (v) => setState(() => _public = v),
                  ),
                  if (s.publicUrl != null && _public)
                    ListRow(
                      title: s.publicUrl!,
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        CopyButton(s.publicUrl!),
                        TextButton(onPressed: _busy ? null : _reset, child: Text(l.mdocumentsResetLink)),
                      ]),
                    ),
                ]),
                if (_secrets.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  HelpBox(
                    l.mdocumentsSecrets,
                    tone: Tone.bad,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      for (final (line, ex) in _secrets) Text(l.mdocumentsSecretLine('$line', ex), style: const TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5)),
                    ]),
                  ),
                ],
                SectionHeader(l.mdocumentsWorkspaceAccess, padding: const EdgeInsets.fromLTRB(4, 18, 4, 8)),
                Segmented<DocumentShareInputWorkspaceAccessEnum>(
                  full: true,
                  options: [for (final v in DocumentShareInputWorkspaceAccessEnum.values) (v, accessLabel(v.value))],
                  value: _ws,
                  onChanged: (v) => setState(() => _ws = v),
                ),
                SectionHeader(l.mdocumentsPeople, padding: const EdgeInsets.fromLTRB(4, 18, 4, 8)),
                ListGroup(children: [
                  for (final m in members)
                    if (m.userId != s.ownerId)
                      ListRow(
                        title: m.displayName?.isNotEmpty == true ? m.displayName! : m.username,
                        subtitle: m.role == WorkspaceRole.viewer ? l.mdocumentsViewerOnlyView : null,
                        trailing: DropdownButton<String>(
                          value: _grants[m.userId]?.value ?? 'none',
                          underline: const SizedBox.shrink(),
                          items: [
                            for (final v in ['none', 'view', if (m.role != WorkspaceRole.viewer) 'edit'])
                              DropdownMenuItem(value: v, child: Text(accessLabel(v))),
                          ],
                          onChanged: (v) => setState(() {
                            if (v == null || v == 'none') {
                              _grants.remove(m.userId);
                            } else {
                              _grants[m.userId] = grantLevelFor(m.role, _Level.values.firstWhere((x) => x.value == v));
                            }
                          }),
                        ),
                      ),
                ]),
                if (_error != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_error!, style: TextStyle(color: c.badInk))),
                const SizedBox(height: 16),
                FilledButton(onPressed: _busy ? null : _save, child: Text(l.mdocumentsSave)),
              ],
            ),
    );
  }
}
