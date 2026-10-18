import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/ui.dart';

/// The ticket page's sections a person closed (by id: "diff", "notes"),
/// kept on this phone: closed once, a section stays closed on every ticket
/// until it is opened again.
class ClosedSectionsNotifier extends Notifier<Set<String>> {
  static const _pref = 'ticketSectionsClosed';

  @override
  Set<String> build() {
    _load();
    return const {};
  }

  Future<void> _load() async {
    final saved = (await SharedPreferences.getInstance()).getStringList(_pref);
    if (saved != null) state = saved.toSet();
  }

  Future<void> toggle(String id) async {
    state = state.contains(id) ? ({...state}..remove(id)) : {...state, id};
    await (await SharedPreferences.getInstance()).setStringList(_pref, state.toList());
  }
}

final closedSectionsProvider = NotifierProvider<ClosedSectionsNotifier, Set<String>>(ClosedSectionsNotifier.new);

/// A titled part of the ticket page (Commits, Notes, Diff…), as a card like
/// the page's other folds (History): tapping the title closes or opens it,
/// remembered on this phone for every ticket, and while open its title stays
/// at the top of the page as its content scrolls past. [hint] shows next to
/// the title (a count), so a closed section still says what is in it.
class TicketSection extends ConsumerWidget {
  const TicketSection({super.key, required this.id, required this.title, required this.children, this.hint});
  final String id;
  final String title;
  final String? hint;
  final List<Widget> children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Fold(
        title: title,
        hint: hint,
        open: !ref.watch(closedSectionsProvider).contains(id),
        onToggle: () => ref.read(closedSectionsProvider.notifier).toggle(id),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
      ),
    );
  }
}
