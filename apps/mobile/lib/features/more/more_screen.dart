import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final session = ref.watch(sessionProvider).value;
    final workspace = ref.watch(currentWorkspaceProvider);
    final workspaces = ref.watch(meProvider).value?.workspaces?.length ?? 0;

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
            ref.invalidate(ciFailuresProvider);
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
                Avatar(session.username),
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
            // The assistant: questions about the workspace.
            const SizedBox(height: 10),
            group([
              ListRow(
                leading: HIcon('assistant', size: 22, color: c.primary),
                title: l.massistantMoreRow,
                subtitle: l.massistantMoreRowSub,
                onTap: () => context.push('/assistant'),
              ),
            ]),
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
            // CI failures on watched branches, with how many are red.
            const SizedBox(height: 10),
            group([
              ListRow(
                leading: HIcon('running', size: 22, color: c.badInk),
                title: l.mciTitle,
                value: '${ref.watch(ciFailuresProvider('red')).value?.length ?? ''}',
                onTap: () => context.push('/ci'),
              ),
            ]),
            // Workspace setup and the pages that manage it.
            const SizedBox(height: 10),
            group([
              _NavRow('users', l.navWorkspace, '/workspace'),
              _NavRow('repos', l.navRepos, '/repos'),
              _NavRow('plug', l.navIntegrations, '/integrations'),
              _NavRow('shield', l.navRules, '/rules'),
              _NavRow('check', l.navReviews, '/reviews'),
              _NavRow('tasks', l.swaggerSuites, '/swagger-suites'),
              _NavRow('usage', l.navUsage, '/usage'),
              _NavRow('dashboard', l.networkTitle, '/networks'),
              _NavRow('assistant', l.mcpTitle, '/mcp'),
            ]),
            const SizedBox(height: 10),
            group([
              _NavRow('users', l.navProfile, '/profile'),
              _NavRow('feedback', l.feedbackTitle, '/feedback'),
            ]),
            // Settings, each on a page of its own: the list here stays short.
            SectionHeader(l.navSettings),
            group([
              _NavRow('image', l.mobileAppearance, '/settings/appearance'),
              _NavRow('analytics', l.mobileDefaultModels, '/settings/models'),
              _NavRow('needs', l.mobilePush, '/settings/notifications'),
            ]),
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

/// A More setting on a page of its own, under a bar back to More.
class _SettingsPage extends StatelessWidget {
  const _SettingsPage({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: DetailBar(backLabel: AppLocalizations.of(context).mobileMore, title: title),
        body: ListView(padding: const EdgeInsets.only(top: 8, bottom: 24), children: [child]),
      );
}

/// Theme and language (Settings → Appearance).
class AppearancePage extends StatelessWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context) =>
      _SettingsPage(title: AppLocalizations.of(context).mobileAppearance, child: const AppearanceSection(header: false));
}

/// The workspace's models per stage (Settings → Default models).
class DefaultModelsPage extends ConsumerWidget {
  const DefaultModelsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => _SettingsPage(
        title: AppLocalizations.of(context).mobileDefaultModels,
        child: _settingsBody(context, ref, (s) => _ModelsSection(s)),
      );
}

/// Which push notifications this phone gets (Settings → Notifications).
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => _SettingsPage(
        title: AppLocalizations.of(context).mobilePush,
        child: _settingsBody(context, ref, (s) => _PushSection(s)),
      );
}

Widget _settingsBody(BuildContext context, WidgetRef ref, Widget Function(Settings s) of) => ref.watch(settingsProvider).when(
      data: of,
      error: (_, _) => Padding(padding: const EdgeInsets.all(16), child: Text(AppLocalizations.of(context).commonError)),
      loading: () => const Padding(padding: EdgeInsets.all(16), child: LinearProgressIndicator()),
    );

/// Theme and language: on this phone only.
class AppearanceSection extends ConsumerWidget {
  const AppearanceSection({super.key, this.header = true});

  /// Off on its own page, whose title says it already.
  final bool header;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final prefs = ref.watch(prefsProvider);
    final lang = prefs.locale?.languageCode;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (header) SectionHeader(l.mobileAppearance),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListGroup(children: [
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
      ),
    ]);
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

/// A model's name: Haiku, Sonnet, Opus, or "Codex" and the model for a
/// run on Codex CLI ("codex:" and the model).
String _modelName(String m) {
  if (m.startsWith('codex:')) return 'Codex ${m.substring(6)}';
  return m.isEmpty ? m : '${m[0].toUpperCase()}${m.substring(1)}';
}

class _ModelsSection extends ConsumerWidget {
  const _ModelsSection(this.s);
  final Settings s;
  static const header = false; // on its own page

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final stages = [
      ('analyze', l.settingsStageAnalyze, l.settingsStageAnalyzeHelp, s.models.analyze),
      ('coding', l.settingsStageCoding, l.settingsStageCodingHelp, s.models.coding),
      ('retry', l.settingsStageRetry, l.settingsStageRetryHelp, s.models.retry),
      ('helper', l.settingsStageHelper, l.settingsStageHelperHelp, s.models.helper),
      ('learn', l.settingsStageLearn, l.settingsStageLearnHelp, s.models.learn ?? 'sonnet'),
      if (s.models.preview != null) ('preview', l.mpreviewSettingsModel, l.mpreviewSettingsModelHelp, s.models.preview!),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (header) SectionHeader(l.mobileDefaultModels),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListGroup(children: [
          for (final (key, label, help, model) in stages)
            ListRow(
              title: label,
              subtitle: help,
              value: _modelName(model),
              onTap: () async {
                final picked = await _pickOne<String>(
                  context,
                  title: label,
                  sub: l.settingsModelsHelp,
                  options: [for (final m in const ['haiku', 'sonnet', 'opus']) (m, _modelName(m))],
                  current: model,
                );
                if (picked == null || picked.$1 == model || !context.mounted) return;
                await _save(context, ref, s, (j) {
                  final m = Map<String, dynamic>.from(j['models'] as Map);
                  m[key] = picked.$1;
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
    final model = s.models.review ?? 'auto';
    String name(String m) => m == 'auto' ? l.settingsModelAuto : _modelName(m);
    return ListRow(
      title: l.settingsStageReview,
      subtitle: l.settingsStageReviewHelp,
      value: name(model),
      onTap: () async {
        final picked = await _pickOne<String>(
          context,
          title: l.settingsStageReview,
          sub: l.settingsModelsHelp,
          options: [for (final m in const ['auto', 'haiku', 'sonnet', 'opus']) (m, name(m))],
          current: model,
        );
        if (picked == null || picked.$1 == model || !context.mounted) return;
        await _save(context, ref, s, (j) {
          final m = Map<String, dynamic>.from(j['models'] as Map);
          m['review'] = picked.$1;
          return {...j, 'models': m};
        });
      },
    );
  }
}

class _PushSection extends ConsumerWidget {
  const _PushSection(this.s);
  final Settings s;
  static const header = false; // on its own page

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
      if (header) SectionHeader(l.mobilePush),
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
            if (n.progress != null) sw(l.mobilePushProgress, n.progress!, 'progress', help: l.mobilePushProgressHelp),
            if (n.lessons != null) sw(l.settingsLessons, n.lessons!, 'lessons'),
            if (n.review != null) sw(l.settingsReviewDone, n.review!, 'review'),
            if (n.preview != null) sw(l.mpreviewNotify, n.preview!, 'preview'),
            if (n.followUps != null) sw(l.followUpsNotifyLabel, n.followUps!, 'followUps'),
            if (n.ci != null) sw(l.mciNotify, n.ci!, 'ci'),
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
class Avatar extends StatelessWidget {
  const Avatar(this.name, {super.key});
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

/// A More row that opens one of the workspace pages.
class _NavRow extends StatelessWidget {
  const _NavRow(this.icon, this.title, this.path);
  final String icon;
  final String title;
  final String path;

  @override
  Widget build(BuildContext context) => ListRow(
        leading: HIcon(icon, size: 22, color: Agnts.of(context).primary),
        title: title,
        onTap: () => context.push(path),
      );
}

