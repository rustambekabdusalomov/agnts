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
import '../repos/manage_widgets.dart';
import 'providers.dart';

/// The services agnts works with: one card per provider with its status,
/// Connect or Manage, and a quick connection test (IntegrationsPage).
class IntegrationsScreen extends ConsumerStatefulWidget {
  const IntegrationsScreen({super.key});

  @override
  ConsumerState<IntegrationsScreen> createState() => _IntegrationsScreenState();
}

class _IntegrationsScreenState extends ConsumerState<IntegrationsScreen> {
  String? _testing;

  Future<void> _test(String p) async {
    final l = AppLocalizations.of(context);
    setState(() => _testing = p);
    try {
      final v = (await ref.read(apiProvider)!.getIntegrationsApi().testIntegration(provider: p)).data!;
      ref.invalidate(integrationsProvider);
      final name = providerName(l, p);
      if (mounted) showSnack(context, v.lastError != null ? l.integrationsTestFail(name, v.lastError!) : l.integrationsTestOk(name));
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _testing = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final list = ref.watch(integrationsProvider);
    return Scaffold(
      appBar: DetailBar(backLabel: l.mobileMore),
      body: AsyncBody<List<Integration>>(
        value: list,
        onRefresh: () async => ref.invalidate(integrationsProvider),
        builder: (all) {
          Integration? find(String p) => all.where((i) => i.provider == p).firstOrNull;
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              PageHeader(title: l.integrationsTitle, sub: l.integrationsLede, long: true),
              for (final p in integrationProviders)
                padCard(
                  _ProviderCard(
                    provider: p,
                    integration: find(p),
                    testing: _testing == p,
                    onOpen: () => context.push('/integrations/$p'),
                    onTest: () => _test(p),
                  ),
                ),
              // Claude moved to the workspace settings.
              padCard(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const ProviderTile('claude'),
                        const SizedBox(width: 12),
                        Text(
                          l.integrationsName_claude,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.ink),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(l.settingsClaudeMoved, style: TextStyle(fontSize: 13.5, color: c.ink3)),
                    const SizedBox(height: 10),
                    OutlinedButton(onPressed: () => context.push('/workspace?tab=claude'), child: Text(l.settingsClaudeOpen)),
                  ],
                ),
              ),
              SectionHeader(l.integrationsComing),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in const ['Bitbucket', 'Linear', 'Slack']) ToneBadge(s, Tone.gray),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.provider,
    required this.integration,
    required this.testing,
    required this.onOpen,
    required this.onTest,
  });
  final String provider;
  final Integration? integration;
  final bool testing;
  final VoidCallback onOpen;
  final VoidCallback onTest;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final i = integration;
    final on = i?.connected ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ProviderTile(provider),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                providerName(l, provider),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.ink),
              ),
            ),
            ToneBadge(on ? l.integrationsConnected : l.integrationsNotConnected, on ? Tone.ok : Tone.gray, small: true),
          ],
        ),
        const SizedBox(height: 10),
        Text(providerDesc(l, provider), style: TextStyle(fontSize: 13.5, color: c.ink3)),
        if (on) ...[
          const SizedBox(height: 8),
          if (i!.account != null) KvRow(l.integrationsAccount, i.account!),
          if (i.tokenHint != null) KvRow(l.integrationsToken, '•••• ${i.tokenHint}'),
          KvRow(l.integrationsLastChecked, i.checkedAt == null ? l.integrationsNever : agoText(l, i.checkedAt!)),
          if (i.lastError != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: HelpBox(i.lastError!, tone: Tone.bad, copyable: true),
            ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            on
                ? OutlinedButton(onPressed: onOpen, child: Text(l.integrationsManage))
                : FilledButton(onPressed: onOpen, child: Text(l.integrationsConnect)),
            if (on) ...[const SizedBox(width: 8), OutlinedButton(onPressed: testing ? null : onTest, child: Text(l.integrationsTest))],
          ],
        ),
      ],
    );
  }
}
