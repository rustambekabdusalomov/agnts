import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/ui.dart';
import '../integrations/providers.dart';
import 'manage_widgets.dart';

/// Repositories the connected GitHub or GitLab token can reach.
final remoteReposProvider = FutureProvider.autoDispose.family<List<RemoteRepository>, String>((ref, provider) async {
  return (await requireApi(ref).getIntegrationsApi().listRemoteRepos(provider: provider)).data!;
});

/// Pick a repository the connected GitHub or GitLab token can reach; pops
/// with the one picked, for the repository form to finish (ImportDrawer).
class ImportSheet extends ConsumerStatefulWidget {
  const ImportSheet({super.key});

  @override
  ConsumerState<ImportSheet> createState() => _ImportSheetState();
}

class _ImportSheetState extends ConsumerState<ImportSheet> {
  String? _provider;
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final integrations = ref.watch(integrationsProvider);
    final connected = [
      for (final p in const ['github', 'gitlab'])
        if (integrations.value?.any((i) => i.provider == p && i.connected) ?? false) p,
    ];
    final provider = connected.contains(_provider) ? _provider! : connected.firstOrNull;

    Widget body;
    if (integrations.isLoading) {
      body = const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()));
    } else if (provider == null) {
      body = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: HelpBox(
          l.reposImportNone,
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/integrations');
              },
              child: Text(l.reposImportConnect),
            ),
          ),
        ),
      );
    } else {
      final remote = ref.watch(remoteReposProvider(provider));
      final s = _q.trim().toLowerCase();
      final rows = (remote.value ?? const <RemoteRepository>[])
          .where((r) => s.isEmpty || r.fullName.toLowerCase().contains(s) || (r.description?.toLowerCase().contains(s) ?? false))
          .toList();
      body = Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (connected.length > 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Segmented<String>(
              full: true,
              options: [for (final p in connected) (p, providerName(l, p))],
              value: provider,
              onChanged: (p) => setState(() => _provider = p),
            ),
          ),
        SearchBox(hint: l.reposImportSearch, onChanged: (v) => setState(() => _q = v)),
        Flexible(
          child: switch (remote) {
            AsyncError(:final error) => Padding(padding: const EdgeInsets.all(20), child: ErrorLine(errorMessage(error, l.commonError))),
            AsyncData(:final value) when rows.isEmpty => EmptyState(title: value.isNotEmpty ? l.reposNoMatch : l.reposImportEmpty),
            AsyncData() => ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                itemCount: rows.length,
                separatorBuilder: (_, _) => Divider(height: 1, color: c.line2),
                itemBuilder: (_, i) {
                  final r = rows[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Wrap(spacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
                            Text(r.fullName, style: TextStyle(fontWeight: FontWeight.w700, color: c.ink)),
                            if (r.private) ToneBadge(l.reposImportPrivate, Tone.gray, small: true),
                          ]),
                          if ((r.description ?? '').isNotEmpty) Text(r.description!, style: TextStyle(fontSize: 13, color: c.ink2)),
                          Text(
                            [r.defaultBranch, if (r.updatedAt != null) l.reposImportUpdated(agoText(l, r.updatedAt!))].join(' · '),
                            style: TextStyle(fontSize: 12.5, color: c.ink3),
                          ),
                        ]),
                      ),
                      const SizedBox(width: 8),
                      r.added
                          ? ToneBadge(l.reposImportAdded, Tone.ok, small: true)
                          : OutlinedButton(onPressed: () => Navigator.pop(context, r), child: Text(l.reposImportPick)),
                    ]),
                  );
                },
              ),
            _ => Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [const LinearProgressIndicator(), const SizedBox(height: 8), Text(l.reposImportLoading)]),
              ),
          },
        ),
      ]);
    }
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SheetTitle(l.reposImportTitle, sub: l.reposImportSub),
      Flexible(child: body),
      const SizedBox(height: 12),
    ]);
  }
}
