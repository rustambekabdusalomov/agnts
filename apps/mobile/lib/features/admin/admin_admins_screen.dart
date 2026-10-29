import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import 'admin_data.dart';
import 'admin_widgets.dart';

/// The platform's operators. An Admin is its own account (it signs in with a
/// password and has no workspaces), so Admins are created here, not promoted
/// from Users.
class AdminAdminsScreen extends ConsumerWidget {
  const AdminAdminsScreen({super.key});

  static const _minPassword = 12;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final me = ref.watch(meProvider).value;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: DetailBar(backLabel: l.navBack, onBack: () => context.canPop() ? context.pop() : context.go('/admin/more')),
      body: AsyncBody<List<PlatformUser>>(
        value: ref.watch(platformUsersProvider),
        onRefresh: () async {
          ref.invalidate(platformUsersProvider);
          await ref.read(platformUsersProvider.future);
        },
        builder: (all) {
          final admins = all.where((u) => u.user.isAdmin == true).toList();
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              PageHeader(title: l.platformAdmins, sub: l.platformAdminsLede),
              SectionHeader(l.platformAdminsCount(admins.length)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListGroup(
                  children: [
                    for (final u in admins)
                      PersonRow(
                        user: u.user,
                        nameSuffix: u.user.id == me?.id ? l.platformYou : null,
                        sub: [
                          contactOf(u.user),
                          if (u.user.hasTotp == true) '2FA',
                          l.platformLastSeenAgo(agoText(context, u.lastSignInAt)),
                        ].join(' · '),
                        trailing: u.user.id == me?.id
                            ? null
                            : TextButton(
                                style: TextButton.styleFrom(foregroundColor: c.badInk),
                                onPressed: () => _delete(context, ref, u.user),
                                child: Text(l.platformDeleteAdmin),
                              ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FilledButton(onPressed: () => _add(context, ref), child: Text(l.platformAddAdmin)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final name = TextEditingController();
    final username = TextEditingController();
    final email = TextEditingController();
    final password = TextEditingController();
    String? added;
    final done = await showFormSheet(
      context,
      title: l.platformAddAdmin,
      sub: l.platformAddAdminSub,
      action: l.platformCreateAdmin,
      ready: () => username.text.trim().length >= 2 && password.text.length >= _minPassword,
      fields: (setState) => [
        LabeledField(label: l.platformAdminName, controller: name, maxLength: 100),
        LabeledField(
          label: '${l.platformAdminUsername} *',
          controller: username,
          maxLength: 32,
          autocorrect: false,
          onChanged: (_) => setState(() {}),
        ),
        LabeledField(label: l.platformEmail, controller: email, maxLength: 254, autocorrect: false, keyboard: TextInputType.emailAddress),
        LabeledField(
          label: '${l.authPassword} *',
          controller: password,
          obscure: true,
          help: l.platformAdminPasswordHint('$_minPassword'),
          onChanged: (_) => setState(() {}),
        ),
      ],
      submit: () async {
        String? opt(TextEditingController t) => t.text.trim().isEmpty ? null : t.text.trim();
        try {
          final res = await ref
              .read(apiProvider)!
              .getPlatformApi()
              .createPlatformAdmin(
                createPlatformAdminRequest: CreatePlatformAdminRequest(
                  username: username.text.trim(),
                  password: password.text,
                  email: opt(email),
                  displayName: opt(name),
                ),
              );
          added = res.data == null ? username.text.trim() : nameOf(res.data!);
          ref.invalidate(platformUsersProvider);
          return null;
        } catch (e) {
          return errorMessage(e, l.commonError);
        }
      },
    );
    if (done && context.mounted) showSnack(context, l.platformAdminAdded(added ?? ''));
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, User u) async {
    final l = AppLocalizations.of(context);
    final ok = await confirmAction(
      context,
      title: l.platformDeleteAdminTitle(nameOf(u)),
      body: l.platformDeleteAdminBody,
      action: l.platformDeleteAdmin,
      danger: true,
    );
    if (!ok) return;
    try {
      await ref.read(apiProvider)!.getPlatformApi().deletePlatformAdmin(id: u.id);
      ref.invalidate(platformUsersProvider);
      if (context.mounted) showSnack(context, l.platformAdminRemoved(nameOf(u)));
    } catch (e) {
      if (context.mounted) showSnack(context, errorMessage(e, l.commonError));
    }
  }
}
