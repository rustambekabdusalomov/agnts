import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../core/prefs.dart';

// The assistant's server data. The live stream (live.dart) refreshes it on
// assistant_answered and assistant_failed; the screen also polls while an
// answer is being made, in case the stream is down.

/// The person's conversations, newest first, each with its last message.
final assistantConversationsProvider = FutureProvider<List<AssistantConversation>>((ref) async {
  return (await requireApi(ref).getAssistantApi().listAssistantConversations()).data ?? const [];
});

/// One conversation with all its messages.
final assistantConversationProvider = FutureProvider.family<AssistantConversation, int>((ref, id) async {
  return (await requireApi(ref).getAssistantApi().getAssistantConversation(conversationId: id)).data!;
});

/// How the workspace's assistant did in the last [days] days (owners).
final assistantStatsProvider = FutureProvider.family<AssistantStats, int>((ref, days) async {
  return (await requireApi(ref).getAssistantApi().getAssistantStats(days: days)).data!;
});

/// Rated answers with their questions (owners).
final assistantRatedProvider = FutureProvider<List<AssistantRated>>((ref) async {
  return (await requireApi(ref).getAssistantApi().listAssistantRated()).data ?? const [];
});

/// What a live assistant event says about an answer being made.
class AssistantLive {
  const AssistantLive({this.file, this.text});
  final String? file; // the snapshot file it reads now
  final String? text; // what it said last
}

/// The latest live progress of each answer, by message id.
class AssistantLiveNotifier extends Notifier<Map<int, AssistantLive>> {
  @override
  Map<int, AssistantLive> build() => const {};

  void apply(Map<String, dynamic> e) {
    final data = e['data'];
    if (data is! Map) return;
    final id = (data['message_id'] as num?)?.toInt();
    if (id == null) return;
    final now = state[id] ?? const AssistantLive();
    switch (e['type']) {
      case 'assistant_progress':
        state = {...state, id: AssistantLive(file: data['file'] as String?, text: now.text)};
      case 'assistant_partial':
        state = {...state, id: AssistantLive(file: now.file, text: data['text'] as String?)};
      case 'assistant_answered' || 'assistant_failed':
        state = {...state}..remove(id);
    }
  }
}

final assistantLiveProvider = NotifierProvider<AssistantLiveNotifier, Map<int, AssistantLive>>(AssistantLiveNotifier.new);

/// Called by the live stream for every assistant_* event.
void onAssistantEvent(Ref ref, Map<String, dynamic> e) {
  ref.read(assistantLiveProvider.notifier).apply(e);
  final type = e['type'];
  if (type != 'assistant_answered' && type != 'assistant_failed' && type != 'assistant_answering') return;
  final data = e['data'];
  final conv = data is Map ? (data['conversation_id'] as num?)?.toInt() : null;
  if (conv != null) ref.invalidate(assistantConversationProvider(conv));
  ref.invalidate(assistantConversationsProvider);
}

/// The language answers come in: the app's, else the phone's, else English.
AssistantLanguage assistantLanguage(WidgetRef ref, BuildContext context) {
  final code = ref.read(prefsProvider).locale?.languageCode ?? Localizations.localeOf(context).languageCode;
  return switch (code) {
    'ru' => AssistantLanguage.ru,
    'uz' => AssistantLanguage.uz,
    _ => AssistantLanguage.en,
  };
}

/// Whether the answer is still being made.
bool isOpen(AssistantMessage m) => m.status == AssistantMessageStatusEnum.pending || m.status == AssistantMessageStatusEnum.answering;
