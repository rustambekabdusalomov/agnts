import 'package:agnts_api/agnts_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import 'rule_sheet.dart' show SheetHead;

/// The starter packs for a repository's languages.
final starterPacksProvider = FutureProvider.autoDispose.family<List<StarterPack>, int>((ref, repoId) async {
  return (await requireApi(ref).getRulesApi().listStarterPacks(id: repoId)).data ?? const [];
});

/// Starter rules: pick a repository, then suggest a pack's rules for it.
/// They arrive as suggestions; nothing applies until adopted.
Future<void> showStarterRulesSheet(BuildContext context, {required List<Repository> repos, int? initialRepo}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
    builder: (_) => _StarterSheet(repos: repos, initialRepo: repos.any((r) => r.id == initialRepo) ? initialRepo : repos.firstOrNull?.id),
  );
}

class _StarterSheet extends ConsumerStatefulWidget {
  const _StarterSheet({required this.repos, this.initialRepo});
  final List<Repository> repos;
  final int? initialRepo;

  @override
  ConsumerState<_StarterSheet> createState() => _StarterSheetState();
}

class _StarterSheetState extends ConsumerState<_StarterSheet> {
  late int? _repo = widget.initialRepo;
  bool _busy = false;

  Future<void> _offer(String pack) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final res = await ref.read(apiProvider)!.getRulesApi().offerStarterRules(
            id: _repo!,
            offerStarterRulesRequest: OfferStarterRulesRequest(pack: pack),
          );
      ref.invalidate(starterPacksProvider(_repo!));
      if (mounted) showSnack(context, l.harnessRepoStarterAdded(res.data?.length ?? 0));
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final repo = _repo;
    final packs = repo == null ? null : ref.watch(starterPacksProvider(repo));
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SheetHead(title: l.harnessRepoStarterTitle, sub: l.harnessRepoStarterSub),
      Flexible(
        child: ListView(shrinkWrap: true, padding: const EdgeInsets.fromLTRB(20, 4, 20, 20), children: [
          Text(l.mqualityStarterFor, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink2)),
          const SizedBox(height: 6),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final r in widget.repos) FilterChipH(label: r.name, selected: r.id == repo, onTap: () => setState(() => _repo = r.id)),
          ]),
          const SizedBox(height: 14),
          if (packs == null)
            Text(l.mqualityStarterPick, style: TextStyle(color: c.ink3))
          else
            switch (packs) {
              AsyncData(:final value) when value.isEmpty => Text(l.harnessRepoStarterNone, style: TextStyle(color: c.ink3)),
              AsyncData(:final value) => ListGroup(children: [
                  for (final p in value)
                    ListRow(
                      title: p.name,
                      subtitle: l.harnessRepoStarterRules(p.rules),
                      trailing: p.offered
                          ? ToneBadge(l.harnessRepoStarterOffered, Tone.gray, small: true)
                          : FilledButton(
                              onPressed: _busy ? null : () => _offer(p.pack),
                              child: Text(l.harnessRepoStarterOffer(p.rules)),
                            ),
                    ),
                ]),
              AsyncError(:final error) => HelpBox(errorMessage(error, l.commonError), tone: Tone.bad),
              _ => const LinearProgressIndicator(),
            },
        ]),
      ),
    ]);
  }
}
