import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../core/prefs.dart';
import '../../core/push.dart';
import '../../core/session.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart' show appVersion, signOut;
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../../widgets/workspace.dart';

/// Profile, usage, appearance, default models, push settings, integrations and repositories.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final usage = ref.watch(usageProvider);
    final settings = ref.watch(settingsProvider);
    final prefs = ref.watch(prefsProvider);
    final session = ref.watch(sessionProvider).value;
    final workspace = ref.watch(currentWorkspaceProvider);
    final workspaces = ref.watch(meProvider).value?.workspaces?.length ?? 0;
    final lang = prefs.locale?.languageCode;

    Widget group(List<Widget> rows) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: ListGroup(children: rows));
    Widget card(Widget child) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: HCard(child: child));

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(usageProvider);
            ref.invalidate(settingsProvider);
            ref.invalidate(integrationsProvider);
            ref.invalidate(reposProvider);
            ref.invalidate(lessonsProvider);
            ref.invalidate(meProvider);
          },
          child: ListView(padding: const EdgeInsets.only(bottom: 24), children: [
            PageHeader(title: l.mobileMore, actions: [
              _RoundButton(
                icon: Icons.refresh_rounded,
                tooltip: l.mobileRefresh,
                onTap: () async {
                  try {
                    await ref.read(apiProvider)!.getUsageApi().refreshUsage();
                  } catch (e) {
                    if (context.mounted) showSnack(context, errorMessage(e, l.commonError));
                  }
                },
              ),
            ]),
            // Profile (.profile)
            if (session != null) ...[
              card(Row(children: [
                _Avatar(session.username),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(session.username, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: c.ink)),
                    Text(l.mmoreSignedInTo(Uri.tryParse(session.server)?.host ?? session.server),
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: c.ink3)),
                  ]),
                ),
              ])),
              const SizedBox(height: 10),
            ],
            // The workspace everything here belongs to; tap to switch.
            if (workspace != null) ...[
              group([
                ListRow(
                  title: l.wsTitle,
                  subtitle: roleLabel(l, workspace.role),
                  value: workspace.name,
                  onTap: workspaces > 1 ? () => showWorkspaceSheet(context, ref) : null,
                ),
              ]),
              const SizedBox(height: 10),
            ],
            // Plan usage (.u-row, .bar, .u-foot)
            card(usage.when(
              data: (u) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                UsageBar(label: l.mobileSession, utilization: u.fiveHour.utilization, note: resetText(l, u.fiveHour.resetsAt)),
                const SizedBox(height: 8),
                UsageBar(
                  label: l.mobileWeek,
                  utilization: u.sevenDay.utilization,
                  note: resetText(l, u.sevenDay.resetsAt),
                  noteRight: u.updatedAt == null ? null : l.usageUpdated(_ago(l, u.updatedAt!)),
                ),
                if (u.paused)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(l.mobilePaused, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.warnInk)),
                  ),
              ]),
              error: (_, _) => Text(l.commonError),
              loading: () => const LinearProgressIndicator(),
            )),
            // Learn: lessons from pushed changes, with how many are new.
            const SizedBox(height: 10),
            group([
              ListRow(
                leading: HIcon('learn', size: 22, color: c.primary),
                title: l.learnTitle,
                value: '${ref.watch(lessonsProvider('new')).value?.unlearned ?? ''}',
                onTap: () => context.push('/learn'),
              ),
              ListRow(
                leading: HIcon('learnQueue', size: 22, color: c.primary),
                title: l.navLearnQueue,
                value: '${ref.watch(learnQueueProvider).value?.where((x) => x.status == LearnQueueItemStatusEnum.running || x.status == LearnQueueItemStatusEnum.pending).length ?? ''}',
                onTap: () => context.push('/learn-queue'),
              ),
            ]),
            // Appearance
            SectionHeader(l.mobileAppearance),
            group([
              // Title and switch on one line, or the switch below when the words are long.
              Container(
                constraints: const BoxConstraints(minHeight: 52),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                alignment: Alignment.centerLeft,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Text(l.mobileTheme, style: TextStyle(fontSize: 15, color: c.ink)),
                    Segmented<ThemeMode>(
                      options: [
                        (ThemeMode.system, l.mobileThemeSystem),
                        (ThemeMode.light, l.mobileThemeLight),
                        (ThemeMode.dark, l.mobileThemeDark),
                      ],
                      value: prefs.theme,
                      onChanged: (m) => ref.read(prefsProvider.notifier).setTheme(m),
                    ),
                  ],
                ),
              ),
              ListRow(
                title: l.mobileLanguage,
                value: lang == null ? l.mmoreLangPhone : _langName(lang),
                onTap: () => _pickLanguage(context, ref, lang),
              ),
            ]),
            // Default models and push notifications
            ...settings.when(
              data: (s) => [_ModelsSection(s), _PushSection(s)],
              error: (_, _) => [SectionHeader(l.mobileDefaultModels), card(Text(l.commonError))],
              loading: () => [const Padding(padding: EdgeInsets.all(16), child: LinearProgressIndicator())],
            ),
            // Integrations
            SectionHeader(l.mobileIntegrations),
            ref.watch(integrationsProvider).when(
                  data: (list) => list.isEmpty
                      ? card(Text(l.mobileNoEvents, style: TextStyle(color: c.ink3)))
                      : group([
                          for (final i in list)
                            ListRow(
                              leading: _ProviderTile(i.provider),
                              title: _providerName(l, i.provider),
                              subtitle: i.account,
                              trailing: ToneBadge(i.connected ? l.mobileConnected : l.mobileNotConnected, i.connected ? Tone.ok : Tone.gray),
                            ),
                        ]),
                  error: (_, _) => card(Text(l.commonError)),
                  loading: () => const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: LinearProgressIndicator()),
                ),
            // Repositories
            SectionHeader(l.mobileRepositories),
            ref.watch(reposProvider).when(
                  data: (list) => list.isEmpty
                      ? card(Text(l.mobileNoEvents, style: TextStyle(color: c.ink3)))
                      : group([
                          for (final r in list)
                            ListRow(
                              title: r.name,
                              subtitle: [
                                r.defaultBranch,
                                if ((r.toolchains ?? const []).isNotEmpty) r.toolchains!.map((t) => '${t.tool} ${t.version}').join(', '),
                                r.testCmd.isEmpty ? '—' : r.testCmd,
                              ].join(' · '),
                              value: '${r.openTickets}',
                              onTap: () => context.push(Uri(path: '/repos/${r.id}', queryParameters: {'name': r.name}).toString()),
                            ),
                        ]),
                  error: (_, _) => card(Text(l.commonError)),
                  loading: () => const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: LinearProgressIndicator()),
                ),
            const SizedBox(height: 22),
            group([
              ListRow(title: l.mobileSignOut, titleColor: c.badInk, trailing: const SizedBox.shrink(), onTap: () => signOut(ref)),
            ]),
            // .foot-note
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

/// "just now" / "5m ago".
String _ago(AppLocalizations l, DateTime at) {
  final d = DateTime.now().difference(at);
  return d.inMinutes < 1 ? l.mmoreJustNow : l.mmoreAgo(shortDuration(d));
}

// Language names are written in their own language, so they are not translated.
const _languages = {'en': 'English', 'ru': 'Русский', 'uz': 'Oʻzbekcha'};
String _langName(String code) => _languages[code] ?? code.toUpperCase();

Future<void> _pickLanguage(BuildContext context, WidgetRef ref, String? current) async {
  final l = AppLocalizations.of(context);
  final picked = await _pickOne<String?>(
    context,
    title: l.mobileLanguage,
    options: [(null, l.mmoreLangPhone), for (final e in _languages.entries) (e.key, e.value)],
    current: current,
  );
  if (picked == null) return;
  await ref.read(prefsProvider.notifier).setLocale(picked.$1 == null ? null : Locale(picked.$1!));
}

/// A bottom sheet with a list of choices; returns the picked one (wrapped, so null can be a choice).
Future<(T,)?> _pickOne<T>(BuildContext context, {required String title, String? sub, required List<(T, String)> options, required T current}) {
  return showModalBottomSheet<(T,)>(
    context: context,
    builder: (ctx) {
      final c = Agnts.of(ctx);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(padding: const EdgeInsets.only(left: 4, bottom: 4), child: Text(title, style: Theme.of(ctx).textTheme.titleLarge)),
            if (sub != null) Padding(padding: const EdgeInsets.only(left: 4, bottom: 4), child: Text(sub, style: TextStyle(fontSize: 14, color: c.ink3))),
            const SizedBox(height: 10),
            ListGroup(children: [
              for (final o in options)
                ListRow(
                  title: o.$2,
                  trailing: o.$1 == current ? HIcon('check', size: 20, color: c.primary, stroke: 2.4) : const SizedBox(width: 20),
                  onTap: () => Navigator.pop(ctx, (o.$1,)),
                ),
            ]),
          ]),
        ),
      );
    },
  );
}

/// Saves a changed copy of the settings.
Future<void> _save(BuildContext context, WidgetRef ref, Settings s, Map<String, dynamic> Function(Map<String, dynamic>) change) async {
  final l = AppLocalizations.of(context);
  try {
    final next = Settings.fromJson(change(s.toJson()));
    await ref.read(apiProvider)!.getSettingsApi().putSettings(settings: next);
    ref.invalidate(settingsProvider);
    if (context.mounted) showSnack(context, l.mobileSaved);
  } catch (e) {
    if (context.mounted) showSnack(context, errorMessage(e, l.commonError));
  }
}

String _modelName(Model m) => switch (m) {
      Model.haiku => 'Haiku',
      Model.sonnet => 'Sonnet',
      Model.opus => 'Opus',
    };

class _ModelsSection extends ConsumerWidget {
  const _ModelsSection(this.s);
  final Settings s;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final stages = [
      ('analyze', l.settingsStageAnalyze, l.settingsStageAnalyzeHelp, s.models.analyze),
      ('coding', l.settingsStageCoding, l.settingsStageCodingHelp, s.models.coding),
      ('retry', l.settingsStageRetry, l.settingsStageRetryHelp, s.models.retry),
      ('helper', l.settingsStageHelper, l.settingsStageHelperHelp, s.models.helper),
      ('learn', l.settingsStageLearn, l.settingsStageLearnHelp, s.models.learn ?? Model.sonnet),
      if (s.models.preview != null) ('preview', l.mpreviewSettingsModel, l.mpreviewSettingsModelHelp, s.models.preview!),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionHeader(l.mobileDefaultModels),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListGroup(children: [
          for (final (key, label, help, model) in stages)
            ListRow(
              title: label,
              subtitle: help,
              value: _modelName(model),
              onTap: () async {
                final picked = await _pickOne<Model>(
                  context,
                  title: label,
                  sub: l.settingsModelsHelp,
                  options: [for (final m in const [Model.haiku, Model.sonnet, Model.opus]) (m, _modelName(m))],
                  current: model,
                );
                if (picked == null || picked.$1 == model || !context.mounted) return;
                await _save(context, ref, s, (j) {
                  final m = Map<String, dynamic>.from(j['models'] as Map);
                  m[key] = picked.$1.value;
                  return {...j, 'models': m};
                });
              },
            ),
          _reviewRow(context, ref, l),
        ]),
      ),
    ]);
  }

  /// Code review may also be Auto: Opus for complex tickets, Sonnet for the rest.
  Widget _reviewRow(BuildContext context, WidgetRef ref, AppLocalizations l) {
    final model = s.models.review ?? ReviewModel.auto;
    String name(ReviewModel m) => switch (m) {
          ReviewModel.auto => l.settingsModelAuto,
          ReviewModel.haiku => _modelName(Model.haiku),
          ReviewModel.sonnet => _modelName(Model.sonnet),
          ReviewModel.opus => _modelName(Model.opus),
        };
    return ListRow(
      title: l.settingsStageReview,
      subtitle: l.settingsStageReviewHelp,
      value: name(model),
      onTap: () async {
        final picked = await _pickOne<ReviewModel>(
          context,
          title: l.settingsStageReview,
          sub: l.settingsModelsHelp,
          options: [for (final m in ReviewModel.values) (m, name(m))],
          current: model,
        );
        if (picked == null || picked.$1 == model || !context.mounted) return;
        await _save(context, ref, s, (j) {
          final m = Map<String, dynamic>.from(j['models'] as Map);
          m['review'] = picked.$1.value;
          return {...j, 'models': m};
        });
      },
    );
  }
}

class _PushSection extends ConsumerWidget {
  const _PushSection(this.s);
  final Settings s;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final n = s.notify;
    Widget sw(String label, bool value, String field, {String? help}) => ListRow(
          title: label,
          subtitle: help,
          trailing: Switch(
            value: value,
            onChanged: (v) => _save(context, ref, s, (j) {
              final m = Map<String, dynamic>.from((j['notify'] as Map?) ?? {});
              m[field] = v;
              return {...j, 'notify': m};
            }),
          ),
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionHeader(l.mobilePush),
      if (!Push.available)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text(l.mobilePushUnavailable, style: TextStyle(fontSize: 13, color: c.ink3)),
        ),
      if (n != null)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListGroup(children: [
            sw(l.mobilePushOn, n.push, 'push'),
            sw(l.mobilePushNeeds, n.needsYou, 'needsYou', help: l.settingsNeedsYouHelp),
            sw(l.mobilePushStopped, n.stopped, 'stopped'),
            sw(l.mobilePushDone, n.done, 'done'),
            if (n.lessons != null) sw(l.settingsLessons, n.lessons!, 'lessons'),
            if (n.review != null) sw(l.settingsReviewDone, n.review!, 'review'),
            if (n.preview != null) sw(l.mpreviewNotify, n.preview!, 'preview'),
            if (n.followUps != null) sw(l.followUpsNotifyLabel, n.followUps!, 'followUps'),
            if (s.suggestFollowUps != null)
              ListRow(
                title: l.followUpsSettingLabel,
                subtitle: l.followUpsSettingHelp,
                trailing: Switch(
                  value: s.suggestFollowUps!,
                  onChanged: (v) => _save(context, ref, s, (j) => {...j, 'suggestFollowUps': v}),
                ),
              ),
          ]),
        ),
    ]);
  }
}

/// The round initials avatar (.av).
class _Avatar extends StatelessWidget {
  const _Avatar(this.name);
  final String name;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    final parts = name.trim().split(RegExp(r'[\s._-]+')).where((p) => p.isNotEmpty).toList();
    final initials = parts.isEmpty
        ? '?'
        : parts.length == 1
            ? parts.first.substring(0, parts.first.length < 2 ? parts.first.length : 2)
            : '${parts[0][0]}${parts[1][0]}';
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle),
      child: Text(initials.toUpperCase(), style: TextStyle(color: c.onPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
    );
  }
}

/// A round 40px button like the header's icon buttons (.ibtn), with a Material icon.
class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap, required this.tooltip});
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: c.surface,
        shape: CircleBorder(side: BorderSide(color: c.line)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(width: 40, height: 40, child: Icon(icon, size: 21, color: c.ink2)),
        ),
      ),
    );
  }
}

String _providerName(AppLocalizations l, String p) => switch (p) {
      'jira' => l.integrationsName_jira,
      'plane' => l.integrationsName_plane,
      'github' => l.integrationsName_github,
      'gitlab' => l.integrationsName_gitlab,
      'claude' => l.integrationsName_claude,
      'telegram' => l.integrationsName_telegram,
      _ => p.isEmpty ? p : p[0].toUpperCase() + p.substring(1),
    };

const _gitIcon = '<circle cx="6" cy="5" r="2.2"/><circle cx="6" cy="19" r="2.2"/><circle cx="18" cy="7" r="2.2"/>'
    '<path d="M6 7.2v9.6M18 9.2c0 4-6 3.5-11.2 8"/>';
const _trackerIcon = '<rect x="4" y="3" width="16" height="18" rx="2.5"/><path d="M8 8h8M8 12h8M8 16h5"/>';
const _plugIcon = '<path d="M9 7V3M15 7V3M7 7h10v4a5 5 0 0 1-10 0z"/><path d="M12 16v5"/>';
const _sendIcon = '<path d="M21 4L3 11l6 2.5L11 20l3-5 5 4z"/>';
const _sparkIcon = '<path d="M12 3v4M12 17v4M3 12h4M17 12h4M6 6l2.5 2.5M15.5 15.5L18 18M18 6l-2.5 2.5M8.5 15.5L6 18"/>';

/// The coloured square provider tile (.ptile).
class _ProviderTile extends StatelessWidget {
  const _ProviderTile(this.provider);
  final String provider;

  @override
  Widget build(BuildContext context) {
    final (tint, icon) = switch (provider) {
      'github' => (const Color(0xFF24292F), _gitIcon),
      'gitlab' => (const Color(0xFFC2410C), _gitIcon),
      'jira' => (const Color(0xFF1D4ED8), _trackerIcon),
      'plane' => (const Color(0xFF3F76FF), _trackerIcon),
      'telegram' => (const Color(0xFF229ED9), _sendIcon),
      'claude' => (const Color(0xFFC15F3C), _sparkIcon),
      _ => (const Color(0xFF6B6F7A), _plugIcon),
    };
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(9)),
      child: SvgPicture.string(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#ffffff" stroke-width="1.8" '
        'stroke-linecap="round" stroke-linejoin="round">$icon</svg>',
        width: 18,
        height: 18,
      ),
    );
  }
}
