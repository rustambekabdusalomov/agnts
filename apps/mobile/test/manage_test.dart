import 'package:agnts_api/agnts_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agnts_mobile/core/data.dart';
import 'package:agnts_mobile/features/integrations/integration_screen.dart';
import 'package:agnts_mobile/features/integrations/integrations_screen.dart';
import 'package:agnts_mobile/features/integrations/providers.dart';
import 'package:agnts_mobile/features/repos/manage_logic.dart';
import 'package:agnts_mobile/features/repos/repos_screen.dart';
import 'package:agnts_mobile/features/settings/mcp_screen.dart';
import 'package:agnts_mobile/features/settings/network_logic.dart';
import 'package:agnts_mobile/features/settings/networks_screen.dart';
import 'package:agnts_mobile/l10n/app_localizations.dart';
import 'package:agnts_mobile/theme.dart';

Widget _app(Widget child, List overrides) => ProviderScope(
  overrides: [...overrides],
  child: MaterialApp(
    theme: agntsTheme(Brightness.light),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  ),
);

Repository _repo(int id, String name, {DateTime? archivedAt, RepositoryClaudeMdEnum claude = RepositoryClaudeMdEnum.found}) => Repository(
  id: id,
  name: name,
  kind: RepositoryKindEnum.side,
  provider: RepositoryProviderEnum.github,
  cloneUrl: 'https://github.com/acme/$name.git',
  defaultBranch: 'main',
  buildCmd: '',
  lintCmd: '',
  testCmd: 'go test ./...',
  branchPrefix: 'agnts/',
  taskPrefix: 'VIS',
  instructions: '',
  jiraProject: 'PAY',
  claudeMd: claude,
  openTickets: 3,
  archivedAt: archivedAt,
);

void main() {
  group('tracker labels', () {
    test('a base label and one per kind', () {
      expect(trackerLabels('agnts'), ['agnts', 'agnts-code', 'agnts-test', 'agnts-plan', 'agnts-analysis', 'agnts-bug']);
    });

    test('the Jira query follows the assigned-only switch', () {
      expect(jiraQuery('x', assignedOnly: true), contains('AND assignee = currentUser()'));
      expect(jiraQuery('x', assignedOnly: false), isNot(contains('assignee')));
      expect(jiraQuery('x', assignedOnly: false), startsWith('labels in ("x", "x-code"'));
    });

    test('the GitLab token page follows the instance URL', () {
      expect(tokenPage('gitlab', gitlabUrl: 'https://git.corp.dev/'), 'https://git.corp.dev/-/user_settings/personal_access_tokens');
      expect(tokenPage('gitlab', gitlabUrl: 'not a url'), 'https://gitlab.com/-/user_settings/personal_access_tokens');
      expect(telegramTokenLooksValid('123456:AAbbccddeeffgghhiijjkk'), isTrue);
      expect(telegramTokenLooksValid('123456'), isFalse);
    });
  });

  group('network routes', () {
    test('hosts and ranges, with ports', () {
      final r = toRoutes([
        (target: 'gitlab.corp.local', ports: '80, 443 x'),
        (target: '10.20.0.0/16', ports: ''),
        (target: '  ', ports: '1'),
      ]);
      expect(r, hasLength(2));
      expect(r[0].host, 'gitlab.corp.local');
      expect(r[0].ports, [80, 443]);
      expect(r[1].cidr, '10.20.0.0/16');
      expect(r[1].ports, isNull);
      expect(routeText(r), 'gitlab.corp.local :80 :443, 10.20.0.0/16');
      expect(fromRoutes(r).first, (target: 'gitlab.corp.local', ports: '80, 443'));
    });

    test('the agnts-link command', () {
      final cmd = linkCommand(name: 'Client A', linkUrl: 'wss://x/link', token: '', routes: toRoutes([(target: 'a.local', ports: '')]));
      expect(cmd, contains('--name agnts-link-client-a'));
      expect(cmd, contains('AGNTS_LINK_TOKEN=<token>'));
      expect(cmd, contains('AGNTS_LINK_ALLOW=a.local'));
      expect(byteText(512), '512 B');
      expect(byteText(1536), '1.5 KB');
    });
  });

  group('repository form', () {
    test('toolchains', () {
      expect(toolchainSpec(parseToolchain('Node@20')!), 'node@20');
      expect(parseToolchain('python')!.version, 'latest');
      expect(parseToolchain('9bad@1'), isNull);
      final list = withToolchain([parseToolchain('node@18')!], parseToolchain('node@20')!);
      expect(list.map(toolchainSpec), ['node@20']);
    });

    test('templates and helpers', () {
      expect(branchExample('', branchPrefix: '', taskPrefix: 'pay'), 'agnts/PAY-42');
      expect(branchExample('{type}/{number}-{slug}', branchPrefix: 'x/', taskPrefix: ''), 'feature/AMANAT-2288-add-login-page');
      expect(commitExample('', taskPrefix: ''), '');
      expect(commitExample('{key}: {subject}', taskPrefix: ''), 'VIS-42: bump protos to v1.63.0');
      expect(lines(' a \n\n b'), ['a', 'b']);
      expect(moved([1, 2, 3], 0, 1), [2, 1, 3]);
      expect(moved([1, 2, 3], 0, -1), [1, 2, 3]);
      expect(memoryGb(0), isNull);
      expect(memoryGb(4096), '4 GB');
      expect(isGitHubUrl('https://GitHub.com/a/b'), isTrue);
    });
  });

  testWidgets('repositories: active, archived and search', (tester) async {
    await tester.pumpWidget(
      _app(const ReposScreen(), [
        reposProvider.overrideWith(
          (_) async => [
            _repo(1, 'api', claude: RepositoryClaudeMdEnum.missing),
            _repo(2, 'web'),
            _repo(3, 'old', archivedAt: DateTime(2026)),
          ],
        ),
        repoGroupsProvider.overrideWith((_) async => <RepoGroup>[]),
        currentWorkspaceProvider.overrideWithValue(null),
      ]),
    );
    await tester.pumpAndSettle();
    expect(find.text('api'), findsOneWidget);
    expect(find.text('web'), findsOneWidget);
    expect(find.text('old'), findsNothing);
    expect(find.text('Active (2)'), findsOneWidget);
    // One active repository has no CLAUDE.md.
    expect(find.textContaining('no CLAUDE.md'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'web');
    await tester.pumpAndSettle();
    expect(find.text('api'), findsNothing);

    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.text('Archived (1)'));
    await tester.pumpAndSettle();
    expect(find.text('old'), findsOneWidget);
    expect(find.text('api'), findsNothing);
  });

  testWidgets('integrations show status and the Claude card', (tester) async {
    await tester.pumpWidget(
      _app(const IntegrationsScreen(), [
        integrationsProvider.overrideWith(
          (_) async => [Integration(provider: 'github', connected: true, account: 'octo', tokenHint: 'abcd', settings: const {})],
        ),
      ]),
    );
    await tester.pumpAndSettle();
    expect(find.text('GitHub'), findsOneWidget);
    expect(find.text('octo'), findsOneWidget);
    expect(find.text('Manage'), findsOneWidget);
    // The others are offered to connect, and Claude points to the workspace settings.
    expect(find.text('Connect'), findsWidgets);
    await tester.scrollUntilVisible(find.text('Workspace → AI accounts'), 300, scrollable: find.byType(Scrollable).first);
    expect(find.text('Workspace → AI accounts'), findsOneWidget);
  });

  testWidgets('MCP shows the connector and token state', (tester) async {
    await tester.pumpWidget(
      _app(const McpScreen(), [
        mcpProvider.overrideWith((_) async => McpStatus(url: 'https://agnts.example/mcp', staticToken: false, connections: 2)),
      ]),
    );
    await tester.pumpAndSettle();
    expect(find.text('https://agnts.example/mcp'), findsOneWidget);
    expect(find.text('Not set'), findsOneWidget);
    expect(find.text('Create static token'), findsOneWidget);
  });

  testWidgets('a connected Jira shows its settings and saves only when changed', (tester) async {
    await tester.pumpWidget(
      _app(const IntegrationScreen(provider: 'jira'), [
        integrationsProvider.overrideWith(
          (_) async => [
            Integration(
              provider: 'jira',
              connected: true,
              account: 'me@acme.dev',
              settings: const {'site': 'https://acme.atlassian.net', 'label': 'bot'},
            ),
          ],
        ),
      ]),
    );
    await tester.pumpAndSettle();
    expect(find.text('https://acme.atlassian.net'), findsOneWidget);
    expect(find.text('Sync now'), findsOneWidget);
    expect(find.textContaining('labels in ("bot"'), findsOneWidget);
    expect(find.text('You have unsaved changes'), findsNothing);
    await tester.enterText(find.widgetWithText(TextField, 'bot'), 'agnts2');
    await tester.pump();
    expect(find.textContaining('labels in ("agnts2"'), findsOneWidget);
  });

  testWidgets('a disconnected provider shows the connect form', (tester) async {
    await tester.pumpWidget(
      _app(const IntegrationScreen(provider: 'gitlab'), [integrationsProvider.overrideWith((_) async => <Integration>[])]),
    );
    await tester.pumpAndSettle();
    expect(find.text('Connect GitLab'), findsWidgets);
    expect(find.text('read_repository'), findsOneWidget);
  });

  testWidgets('networks list their status and routes', (tester) async {
    await tester.pumpWidget(
      _app(const NetworksScreen(), [
        currentWorkspaceProvider.overrideWithValue(null),
        networksProvider.overrideWith(
          (_) async => PrivateNetworkList(
            available: true,
            linkUrl: 'wss://x/link',
            max: 5,
            networks: [
              PrivateNetwork(
                id: 1,
                name: 'Office',
                kind: PrivateNetworkKindEnum.wireguard,
                enabled: true,
                routes: [
                  NetworkRoute(host: 'gitlab.corp.local', ports: const [443]),
                ],
                status: PrivateNetworkStatusEnum.up,
                tokenSet: false,
                webhooks: PrivateNetworkWebhooksEnum.polling,
                pollMinutes: 5,
                updatedAt: DateTime(2026),
              ),
            ],
          ),
        ),
        networkActivityProvider.overrideWith((_, _) async => NetworkActivity(today: 3, refused: 1, dials: const [])),
      ]),
    );
    await tester.pumpAndSettle();
    expect(find.text('Office'), findsOneWidget);
    expect(find.text('Connected'), findsOneWidget);
    expect(find.text('gitlab.corp.local :443'), findsOneWidget);
    // Not the owner: no edit buttons.
    expect(find.text('Edit'), findsNothing);
  });
}
