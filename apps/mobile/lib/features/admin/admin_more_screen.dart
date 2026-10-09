import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data.dart';
import '../../core/session.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart' show appVersion, signOut;
import '../../theme.dart';
import '../../widgets/ui.dart';
import '../more/more_screen.dart' show AppearanceSection, Avatar;
import 'admin_data.dart';

/// The cabinet's last tab: who is signed in, the Admins, appearance and sign-out.
class AdminMoreScreen extends ConsumerWidget {
  const AdminMoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final session = ref.watch(sessionProvider).value;
    final me = ref.watch(meProvider).value;
    final admins = ref.watch(platformUsersProvider).value?.where((u) => u.user.isAdmin == true).length;

    Widget group(List<Widget> rows) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: ListGroup(children: rows));

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(meProvider);
            ref.invalidate(platformUsersProvider);
          },
          child: ListView(padding: const EdgeInsets.only(bottom: 24), children: [
            PageHeader(title: l.mobileMore),
            if (session != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: HCard(
                  child: Row(children: [
                    Avatar(session.username),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(me == null ? session.username : nameOf(me), style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: c.ink)),
                        Text(l.mmoreSignedInTo(Uri.tryParse(session.server)?.host ?? session.server),
                            maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: c.ink3)),
                        const SizedBox(height: 6),
                        ToneBadge(l.platformCabinetBadge, Tone.info, small: true),
                      ]),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 10),
            ],
            group([
              ListRow(
                leading: HIcon('shield', size: 22, color: c.primary),
                title: l.platformAdmins,
                value: admins == null ? null : '$admins',
                onTap: () => context.push('/admin/admins'),
              ),
            ]),
            const AppearanceSection(),
            const SizedBox(height: 22),
            group([
              ListRow(title: l.mobileSignOut, titleColor: c.badInk, trailing: const SizedBox.shrink(), onTap: () => signOut(ref)),
            ]),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
              child: Text(l.mobileVersion(appVersion), textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: c.ink3)),
            ),
          ]),
        ),
      ),
    );
  }
}
