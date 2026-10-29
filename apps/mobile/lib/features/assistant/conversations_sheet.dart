import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import 'assistant_data.dart';

/// The person's conversations: tap one to open it, swipe to delete it.
/// Returns the picked conversation's id, 0 for a new one, or null.
Future<int?> showConversationsSheet(BuildContext context, {int? current}) {
  return showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (_) => _ConversationsSheet(current: current),
  );
}

class _ConversationsSheet extends ConsumerWidget {
  const _ConversationsSheet({this.current});
  final int? current;

  Future<bool> _delete(BuildContext context, WidgetRef ref, AssistantConversation conv) async {
    final l = AppLocalizations.of(context);
    try {
      await ref.read(apiProvider)!.getAssistantApi().deleteAssistantConversation(conversationId: conv.id);
      ref.invalidate(assistantConversationsProvider);
      if (context.mounted) showSnack(context, l.massistantDeleted);
      return true;
    } catch (e) {
      if (context.mounted) showSnack(context, errorMessage(e, l.commonError));
      return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final list = ref.watch(assistantConversationsProvider);
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 16, 10),
            child: Row(
              children: [
                Expanded(child: Text(l.massistantHistory, style: Theme.of(context).textTheme.titleLarge)),
                FilledButton.tonalIcon(
                  onPressed: () => Navigator.pop(context, 0),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(l.massistantNewConversation),
                ),
              ],
            ),
          ),
          Flexible(
            child: list.when(
              loading: () => const Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()),
              error: (_, _) => EmptyState(title: l.mobileOffline),
              data: (convs) => convs.isEmpty
                  ? EmptyState(title: l.massistantHistoryEmpty)
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: convs.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final conv = convs[i];
                        final last = conv.messages.isEmpty ? null : conv.messages.last;
                        return Dismissible(
                          key: ValueKey(conv.id),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (_) => _delete(context, ref, conv),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(color: c.badSoft, borderRadius: BorderRadius.circular(18)),
                            child: Text(
                              l.massistantDelete,
                              style: TextStyle(color: c.badInk, fontWeight: FontWeight.w700),
                            ),
                          ),
                          child: HCard(
                            onTap: () => Navigator.pop(context, conv.id),
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                            color: conv.id == current ? c.primarySoft : null,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (conv.mode == ChatMode.code) ...[
                                      ToneBadge(l.codechatCodeBadge, Tone.info, small: true),
                                      const SizedBox(width: 6),
                                    ],
                                    Expanded(
                                      child: Text(
                                        conv.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: c.ink),
                                      ),
                                    ),
                                  ],
                                ),
                                if (conv.mode == ChatMode.code && (conv.tickets?.isNotEmpty ?? false))
                                  Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: Text(
                                      '${conv.tickets!.first.key} · ${stateLabel(l, conv.tickets!.first.state, conv.tickets!.first.kind)}',
                                      style: TextStyle(fontSize: 13, fontFamily: AgntsFonts.mono, color: c.ink3),
                                    ),
                                  ),
                                if (last != null && last.text.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: Text(
                                      last.text.replaceAll(RegExp(r'[#*_`>]'), '').trim(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 13.5, color: c.ink3),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(_ago(l, conv.updatedAt), style: TextStyle(fontSize: 12.5, color: c.ink3)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

String _ago(AppLocalizations l, DateTime at) {
  final d = DateTime.now().difference(at);
  return d.inMinutes < 1 ? l.mmoreJustNow : l.mmoreAgo(shortDuration(d));
}
