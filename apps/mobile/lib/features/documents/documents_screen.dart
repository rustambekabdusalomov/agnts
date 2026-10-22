import 'package:agnts_api/agnts_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../ci/ci_screen.dart' show ciAgo;
import 'documents_data.dart';
import 'documents_logic.dart';

/// The documents you can open: all, your own, or shared with you. Opened
/// from More. Writing and AI generation start on the web.
class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  DocScope _scope = DocScope.all;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final docs = ref.watch(documentsProvider(_scope));
    return Scaffold(
      backgroundColor: c.bg,
      appBar: DetailBar(backLabel: l.navBack, onBack: () => context.canPop() ? context.pop() : context.go('/more')),
      body: AsyncBody<List<DocumentSummary>>(
        value: docs,
        onRefresh: () => ref.refresh(documentsProvider(_scope).future),
        builder: (all) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            PageHeader(title: l.mdocumentsTitle),
            ChipRow(children: [
              for (final (s, label) in [(DocScope.all, l.mdocumentsAll), (DocScope.mine, l.mdocumentsMine), (DocScope.shared, l.mdocumentsShared)])
                FilterChipH(label: label, selected: _scope == s, onTap: () => setState(() => _scope = s)),
            ]),
            const SizedBox(height: 10),
            if (all.isEmpty)
              EmptyState(title: l.mdocumentsEmpty, text: l.mdocumentsEmptyText)
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListGroup(children: [for (final d in all) DocumentRow(d)]),
              ),
          ],
        ),
      ),
    );
  }
}

/// One document in a list: title, its owner and last change, a public
/// badge, and whether agnts is writing it.
class DocumentRow extends StatelessWidget {
  const DocumentRow(this.d, {super.key});
  final DocumentSummary d;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    return InkWell(
      onTap: () => context.push('/documents/${d.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink)),
            const SizedBox(height: 3),
            Text(l.mdocumentsMeta(d.ownerName, ciAgo(l, d.updatedAt.toLocal())), style: TextStyle(fontSize: 13, color: c.ink3)),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 4, children: [
              d.type == DocumentSummaryTypeEnum.public
                  ? ToneBadge(l.mdocumentsTypePublic, Tone.info, small: true)
                  : ToneBadge(l.mdocumentsTypePrivate, Tone.gray, small: true),
              if (docWriting(d.generation)) ToneBadge(l.mdocumentsWriting, Tone.warn, small: true),
              if (docFailed(d.generation)) ToneBadge(l.mdocumentsFailed, Tone.bad, small: true),
            ]),
          ],
        ),
      ),
    );
  }
}
