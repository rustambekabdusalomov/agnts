import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../l10n/app_localizations.dart';

/// Providers shown on the Integrations screen, in the web's order. Claude
/// lives in workspace settings and gets its own card.
const integrationProviders = ['jira', 'plane', 'github', 'gitlab', 'telegram', 'openai'];

/// Providers that hand tickets to agnts.
bool isTracker(String p) => p == 'jira' || p == 'plane';

/// The kinds a tracker label can name, in the order the server picks one
/// when an issue has several (domain.Kinds).
const trackerKinds = ['code', 'test', 'plan', 'analysis', 'bug'];

/// The labels that hand a ticket to agnts: the base one and one per kind.
List<String> trackerLabels(String base) => [base, for (final k in trackerKinds) '$base-$k'];

/// The JQL agnts runs for Jira, as the web shows it.
String jiraQuery(String label, {required bool assignedOnly}) =>
    'labels in (${trackerLabels(label).map((l) => '"$l"').join(', ')}) AND statusCategory != Done'
    '${assignedOnly ? ' AND assignee = currentUser()' : ''}'
    ' ORDER BY created ASC';

/// Whether a Telegram bot token looks complete, so its getUpdates page can be linked.
bool telegramTokenLooksValid(String token) => RegExp(r'^\d+:[\w-]{20,}$').hasMatch(token.trim());

/// Where to get the provider's token, or null.
String? tokenPage(String provider, {String gitlabUrl = '', String token = ''}) => switch (provider) {
  'github' => 'https://github.com/settings/personal-access-tokens/new',
  'gitlab' =>
    '${RegExp(r'^https://[^\s/]+').hasMatch(gitlabUrl.trim()) ? gitlabUrl.trim().replaceAll(RegExp(r'/+$'), '') : 'https://gitlab.com'}'
        '/-/user_settings/personal_access_tokens',
  'jira' => 'https://id.atlassian.com/manage-profile/security/api-tokens',
  'plane' => 'https://developers.plane.so/api-reference/introduction',
  'openai' => 'https://platform.openai.com/api-keys',
  'telegram' => 'https://t.me/BotFather',
  _ => null,
};

String providerName(AppLocalizations l, String p) => switch (p) {
  'jira' => l.integrationsName_jira,
  'plane' => l.integrationsName_plane,
  'github' => l.integrationsName_github,
  'gitlab' => l.integrationsName_gitlab,
  'claude' => l.integrationsName_claude,
  'telegram' => l.integrationsName_telegram,
  'openai' => l.integrationsName_openai,
  _ => p.isEmpty ? p : p[0].toUpperCase() + p.substring(1),
};

String providerDesc(AppLocalizations l, String p) => switch (p) {
  'jira' => l.integrationsDesc_jira,
  'plane' => l.integrationsDesc_plane,
  'github' => l.integrationsDesc_github,
  'gitlab' => l.integrationsDesc_gitlab,
  'claude' => l.integrationsDesc_claude,
  'telegram' => l.integrationsDesc_telegram,
  'openai' => l.integrationsDesc_openai,
  _ => '',
};

const _gitIcon =
    '<circle cx="6" cy="5" r="2.2"/><circle cx="6" cy="19" r="2.2"/><circle cx="18" cy="7" r="2.2"/>'
    '<path d="M6 7.2v9.6M18 9.2c0 4-6 3.5-11.2 8"/>';
const _trackerIcon = '<rect x="4" y="3" width="16" height="18" rx="2.5"/><path d="M8 8h8M8 12h8M8 16h5"/>';
const _planeIcon = '<path d="M4 4h8v8H4zM12 12h8v8h-8zM12 4h8v8"/>';
const _plugIcon = '<path d="M9 7V3M15 7V3M7 7h10v4a5 5 0 0 1-10 0z"/><path d="M12 16v5"/>';
const _sendIcon = '<path d="M21 4L3 11l6 2.5L19 7l-8 8 .5 5 3-3.5 4.5 3.5z"/>';
const _sparkIcon = '<path d="M12 3v18M3 12h18M5.6 5.6l12.8 12.8M18.4 5.6L5.6 18.4"/>';
const _openaiIcon = '<path d="M12 3l7.8 4.5v9L12 21l-7.8-4.5v-9z"/><circle cx="12" cy="12" r="3"/>';

/// The coloured square provider tile (.ptile).
class ProviderTile extends StatelessWidget {
  const ProviderTile(this.provider, {super.key, this.size = 32});
  final String provider;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (tint, icon) = switch (provider) {
      'github' => (const Color(0xFF24292F), _gitIcon),
      'gitlab' => (const Color(0xFFC2410C), _gitIcon),
      'jira' => (const Color(0xFF1D4ED8), _trackerIcon),
      'plane' => (const Color(0xFF3F76FF), _planeIcon),
      'telegram' => (const Color(0xFF229ED9), _sendIcon),
      'claude' => (const Color(0xFFC15F3C), _sparkIcon),
      'openai' => (const Color(0xFF10A37F), _openaiIcon),
      _ => (const Color(0xFF6B6F7A), _plugIcon),
    };
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(size * 0.28)),
      child: SvgPicture.string(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#ffffff" stroke-width="1.8" '
        'stroke-linecap="round" stroke-linejoin="round">$icon</svg>',
        width: size * 0.56,
        height: size * 0.56,
      ),
    );
  }
}
