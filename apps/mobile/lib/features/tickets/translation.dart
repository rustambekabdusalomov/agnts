import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';

// A ticket can be read in another language; texts show translated where a
// translation exists. The server stores every translation, so switching
// back or a later revision only waits for texts never translated before.

/// Shows a text in the language the ticket is read in.
typedef Tr = String Function(String);

String _same(String s) => s;

/// Languages a ticket can be read in, each named in itself.
const translationLanguages = <(TranslationLanguage, String)>[
  (TranslationLanguage.en, 'English'),
  (TranslationLanguage.ru, 'Русский'),
  (TranslationLanguage.uz, 'Oʻzbekcha'),
  (TranslationLanguage.kk, 'Қазақша'),
  (TranslationLanguage.tr, 'Türkçe'),
  (TranslationLanguage.de, 'Deutsch'),
  (TranslationLanguage.es, 'Español'),
  (TranslationLanguage.fr, 'Français'),
  (TranslationLanguage.zh, '中文'),
  (TranslationLanguage.ja, '日本語'),
  (TranslationLanguage.ko, '한국어'),
  (TranslationLanguage.ar, 'العربية'),
];

/// The language a ticket is read in (null: as written), remembered per ticket on this phone.
/// A document uses it too, keyed `doc:<id>`.
class TicketLangNotifier extends Notifier<TranslationLanguage?> {
  TicketLangNotifier(this.ticketKey);
  final String ticketKey;

  String get _pref => 'translate:$ticketKey';

  @override
  TranslationLanguage? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    try {
      final v = (await SharedPreferences.getInstance()).getString(_pref);
      final lang = TranslationLanguage.values.where((x) => x.value == v).firstOrNull;
      if (lang != null) state = lang;
    } catch (_) {
      // No stored choice: the ticket reads as written.
    }
  }

  Future<void> set(TranslationLanguage? lang) async {
    state = lang;
    final p = await SharedPreferences.getInstance();
    if (lang == null) {
      await p.remove(_pref);
    } else {
      await p.setString(_pref, lang.value);
    }
  }
}

final ticketLangProvider = NotifierProvider.family<TicketLangNotifier, TranslationLanguage?, String>(TicketLangNotifier.new);

/// A ticket's texts in [lang], for the ticket as of [version] (its updatedAt).
final ticketTranslationProvider =
    FutureProvider.family<Map<String, String>, ({String key, TranslationLanguage lang, DateTime version})>((ref, a) async {
  final r = await requireApi(ref).getTicketsApi().translateTicket(key: a.key, translateInput: TranslateInput(lang: a.lang));
  return {for (final i in r.data?.items ?? const <TranslationItemsInner>[]) i.source_: i.text};
});

/// The translation of [ticket] as the screen reads it: the function, and
/// the request's state while a language is picked.
({Tr tr, AsyncValue<Map<String, String>>? state}) watchTranslation(WidgetRef ref, Ticket ticket) {
  final lang = ref.watch(ticketLangProvider(ticket.key));
  if (lang == null) return (tr: _same, state: null);
  final v = ref.watch(ticketTranslationProvider((key: ticket.key, lang: lang, version: ticket.updatedAt)));
  final m = v.value;
  if (m == null || m.isEmpty) return (tr: _same, state: v);
  return (tr: (s) => m[s] ?? s, state: v);
}

/// The detail bar's translate button: the language picked, or "Translate".
/// ticketKey is a ticket's key, or `doc:<id>` for a document.
class TranslateButton extends ConsumerWidget {
  const TranslateButton(this.ticketKey, {super.key});
  final String ticketKey;

  Future<void> _pick(BuildContext context, WidgetRef ref, TranslationLanguage? current) async {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final ui = Localizations.localeOf(context).languageCode;
    // The UI language first, then the rest.
    final langs = [
      ...translationLanguages.where((x) => x.$1.value == ui),
      ...translationLanguages.where((x) => x.$1.value != ui),
    ];
    final picked = await showModalBottomSheet<(TranslationLanguage?,)>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.75),
          child: ListView(shrinkWrap: true, padding: const EdgeInsets.only(bottom: 12), children: [
            Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 8), child: Text(l.ticketTranslate, style: Theme.of(ctx).textTheme.titleLarge)),
            for (final (lang, name) in [(null, l.ticketTranslateOriginal), ...langs])
              ListTile(
                title: Text(name),
                trailing: lang == current ? Icon(Icons.check_rounded, color: c.primary) : null,
                onTap: () => Navigator.pop(ctx, (lang,)),
              ),
          ]),
        ),
      ),
    );
    if (picked == null || picked.$1 == current) return;
    await ref.read(ticketLangProvider(ticketKey).notifier).set(picked.$1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final lang = ref.watch(ticketLangProvider(ticketKey));
    final name = lang == null ? null : translationLanguages.where((x) => x.$1 == lang).firstOrNull?.$2;
    return TextButton.icon(
      onPressed: () => _pick(context, ref, lang),
      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: const Size(40, 40)),
      icon: Icon(Icons.translate_rounded, size: 19, color: c.primary),
      label: Text(name ?? l.ticketTranslate, style: TextStyle(color: c.primary, fontSize: 14, fontWeight: FontWeight.w700)),
    );
  }
}

/// While a translation loads or after it failed, a line saying so.
class TranslationStatus extends StatelessWidget {
  const TranslationStatus(this.state, {super.key});
  final AsyncValue<Object?>? state;

  @override
  Widget build(BuildContext context) {
    final s = state;
    if (s == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    if (s.isLoading) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Row(children: [
          SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: c.primary)),
          const SizedBox(width: 8),
          Expanded(child: Text(l.ticketTranslating, style: TextStyle(fontSize: 13, color: c.ink3))),
        ]),
      );
    }
    if (s.hasError) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Text(l.ticketTranslateFailed(errorMessage(s.error!, l.commonError)), style: TextStyle(fontSize: 13, color: c.badInk)),
      );
    }
    return const SizedBox.shrink();
  }
}
