// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get analyticsLede => 'How well agnts works for you over time: throughput, quality, where time goes, and what it costs your plan.';

  @override
  String get analyticsPeriod => 'Period';

  @override
  String analyticsDays(num n) {
    return '$n days';
  }

  @override
  String get analyticsExportCsv => 'Export CSV';

  @override
  String get analyticsLoading => 'Loading analytics…';

  @override
  String get analyticsError => 'Could not load analytics. Try again.';

  @override
  String get analyticsEmptyTitle => 'No data for this period yet';

  @override
  String get analyticsEmpty => 'Charts fill in as agnts picks up tickets and runs. Label a Jira issue or create a task to get started.';

  @override
  String get analyticsKpiPushed => 'Tickets pushed';

  @override
  String analyticsKpiPushedNote(String n) {
    return 'of $n picked up';
  }

  @override
  String get analyticsKpiSuccess => 'Success rate';

  @override
  String get analyticsKpiSuccessNote => 'Pushed out of picked up';

  @override
  String get analyticsKpiFirstTry => 'Approved on first try';

  @override
  String get analyticsKpiFirstTryNote => 'No changes requested';

  @override
  String get analyticsKpiAgnts => 'agnts time per ticket';

  @override
  String get analyticsKpiAgntsNote => 'Analyze, coding and tests';

  @override
  String get analyticsKpiWait => 'Waiting on you';

  @override
  String get analyticsKpiWaitNote => 'Average per ticket';

  @override
  String get analyticsKpiTurns => 'Average turns';

  @override
  String get analyticsKpiTurnsNote => 'Per ticket';

  @override
  String analyticsCompared(num n) {
    return 'Changes are compared with the previous $n days. Green means better.';
  }

  @override
  String get analyticsThroughput => 'Throughput';

  @override
  String get analyticsThroughputSub => 'Tickets picked up and how they ended, per day';

  @override
  String get analyticsPushed => 'Pushed';

  @override
  String get analyticsRejected => 'Rejected';

  @override
  String get analyticsStopped => 'Stopped';

  @override
  String get analyticsOutcomes => 'Outcomes';

  @override
  String get analyticsOutcomesSub => 'How finished tickets ended';

  @override
  String get analyticsFirstTry => 'Approved on first try';

  @override
  String get analyticsAfterChanges => 'Approved after changes';

  @override
  String get analyticsDonutSub => 'pushed';

  @override
  String get analyticsSpeed => 'Speed';

  @override
  String get analyticsSpeedSub => 'Average minutes per ticket: agnts working versus waiting on you';

  @override
  String get analyticsAgntsWorking => 'agnts working';

  @override
  String get analyticsWaitingOnYou => 'Waiting on you';

  @override
  String get analyticsSteps => 'Where the time goes';

  @override
  String get analyticsStepsSub => 'Average per ticket, by step';

  @override
  String get analyticsTurns => 'Turns per ticket';

  @override
  String get analyticsTurnsSub => 'Fewer turns means agnts finds its way faster and uses less of your plan';

  @override
  String get analyticsAvgTurns => 'Average turns';

  @override
  String get analyticsStops => 'Why runs stop';

  @override
  String analyticsStopsSub(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n stopped runs in this period',
      one: '$n stopped run in this period',
    );
    return '$_temp0';
  }

  @override
  String get analyticsStopTests => 'Tests kept failing';

  @override
  String get analyticsStopLimit => 'Plan limit reached';

  @override
  String get analyticsStopYou => 'Stopped by you';

  @override
  String get analyticsStopTurns => 'Turn limit reached';

  @override
  String get analyticsStopOther => 'Other errors';

  @override
  String get analyticsModels => 'Models';

  @override
  String get analyticsModelsSub => 'Runs per model and how they turned out';

  @override
  String get analyticsChangeModels => 'Change models';

  @override
  String get analyticsColModel => 'Model';

  @override
  String get analyticsColRuns => 'Runs';

  @override
  String get analyticsColShare => 'Share';

  @override
  String get analyticsColReview => 'Reached review';

  @override
  String get analyticsColTurns => 'Average turns';

  @override
  String get analyticsNoRuns => 'No runs in this period.';

  @override
  String get analyticsUsage => 'Plan usage';

  @override
  String get analyticsUsageSub => 'Peak session usage per day';

  @override
  String get analyticsSession => 'Session';

  @override
  String get analyticsAvgPeak => 'Average peak';

  @override
  String get analyticsDaysAbove => 'Days above 80%';

  @override
  String get analyticsNoUsage => 'No usage readings in this period.';

  @override
  String get analyticsSpend => 'Token spend';

  @override
  String get analyticsSpendSub => 'Tokens Claude used per day, input and output';

  @override
  String get analyticsSpendTokens => 'Tokens in and out';

  @override
  String get analyticsSpendCost => 'At API prices';

  @override
  String get analyticsSpendStages => 'Spend by stage';

  @override
  String get analyticsSpendStagesSub => 'Where the tokens went, costliest first';

  @override
  String get analyticsNoSpend => 'No Claude runs recorded in this period.';

  @override
  String get analyticsRepos => 'By repository';

  @override
  String get analyticsReposSub => 'Where agnts works best, and where it struggles';

  @override
  String get analyticsColRepo => 'Repository';

  @override
  String get analyticsColSource => 'Source';

  @override
  String get analyticsColTickets => 'Tickets';

  @override
  String get analyticsColSuccess => 'Success rate';

  @override
  String get analyticsColAgnts => 'agnts time';

  @override
  String get analyticsColClaudeMd => 'CLAUDE.md';

  @override
  String get analyticsSrcJira => 'Jira';

  @override
  String get analyticsSrcTask => 'Task';

  @override
  String get analyticsMdFound => 'Found';

  @override
  String get analyticsMdMissing => 'Missing';

  @override
  String get analyticsMdUnknown => 'Unknown';

  @override
  String get analyticsNoRepos => 'No repository had tickets in this period.';

  @override
  String get analyticsHours => 'Activity by hour';

  @override
  String analyticsHoursSub(String hour) {
    return 'When agnts works, summed over the period. Busiest hour: $hour:00';
  }

  @override
  String get analyticsEvents => 'Events';

  @override
  String get analyticsInsights => 'Insights';

  @override
  String get analyticsInsightsSub => 'What the numbers suggest';

  @override
  String get analyticsNoInsights => 'Not enough data for insights yet.';

  @override
  String analyticsInsightClaudeMd(String gain, String repos) {
    return 'Repositories with a CLAUDE.md finish in $gain% fewer turns. Adding one to $repos is the quickest win.';
  }

  @override
  String analyticsInsightWaiting(String share, String review) {
    return '$share% of a ticket\'s total time is spent waiting on you. Reviews take about $review min on average.';
  }

  @override
  String analyticsInsightStopsTests(String n) {
    return 'Most stopped runs ($n) end on failing tests. Clearer acceptance criteria in tickets help agnts know when it\'s done.';
  }

  @override
  String analyticsInsightStopsLimit(String n) {
    return 'Plan limits stop more runs ($n) than anything else. Fewer parallel runs or Haiku for summaries save usage.';
  }

  @override
  String analyticsInsightNight(String pct) {
    return '$pct% of agnts\'s work happens between 22:00 and 07:00, while you\'re offline.';
  }

  @override
  String analyticsMinutes(String n) {
    return '$n min';
  }

  @override
  String analyticsHoursMinutes(String h, String m) {
    return '$h h $m min';
  }

  @override
  String get appName => 'agnts';

  @override
  String get appTagline => 'Your no sleep agent';

  @override
  String get authTitle => 'Sign in';

  @override
  String get authLede => 'Use your account and the code from your authenticator app.';

  @override
  String get authUsername => 'Username';

  @override
  String get authPassword => 'Password';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authCode => 'Authenticator code';

  @override
  String get authCodeHint => '6 digits from your authenticator app';

  @override
  String get authSubmit => 'Sign in';

  @override
  String get authSubmitting => 'Signing in…';

  @override
  String get authSignOut => 'Sign out';

  @override
  String get authSignOutTitle => 'Sign out?';

  @override
  String get authSignOutBody => 'You’ll need your password and authenticator code to sign back in.';

  @override
  String get authWrongCredentials => 'Wrong username, password or code.';

  @override
  String authRateLimited(num seconds) {
    String _temp0 = intl.Intl.pluralLogic(seconds, locale: localeName, other: '$seconds seconds', one: '$seconds second');
    return 'Too many attempts. Try again in $_temp0.';
  }

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonError => 'Something went wrong. Try again.';

  @override
  String commonSignedInAs(String username) {
    return 'Signed in as $username';
  }

  @override
  String commonVersion(String version) {
    return 'Version $version';
  }

  @override
  String dashboardGreetNight(String name) {
    return 'Good night, $name';
  }

  @override
  String dashboardGreetMorning(String name) {
    return 'Good morning, $name';
  }

  @override
  String dashboardGreetAfternoon(String name) {
    return 'Good afternoon, $name';
  }

  @override
  String dashboardGreetEvening(String name) {
    return 'Good evening, $name';
  }

  @override
  String dashboardLede(String date) {
    return '$date. Here\'s what agnts is doing and what\'s waiting on you.';
  }

  @override
  String get dashboardOpenAnalytics => 'Open analytics';

  @override
  String get dashboardNeedsYou => 'Needs you';

  @override
  String dashboardNeedsNote(String answers, String reviews, String stopped) {
    return '$answers answers, $reviews reviews, $stopped stopped';
  }

  @override
  String get dashboardRunningNow => 'Running now';

  @override
  String dashboardRunningNote(String n) {
    return '$n at a time allowed';
  }

  @override
  String get dashboardPushedWeek => 'Pushed this week';

  @override
  String dashboardPushedNote(String n) {
    return 'vs $n last week';
  }

  @override
  String get dashboardPlanSession => 'Plan session';

  @override
  String get dashboardWaitingTitle => 'Waiting on you';

  @override
  String get dashboardWaitingSub => 'Oldest first. Every minute here is a minute agnts can\'t work.';

  @override
  String get dashboardOpenInbox => 'Open inbox';

  @override
  String get dashboardNothingWaiting => 'Nothing is waiting on you. agnts will show tickets here when it needs answers or a review.';

  @override
  String get dashboardColTicket => 'Ticket';

  @override
  String get dashboardColStatus => 'Status';

  @override
  String get dashboardColWaiting => 'Waiting';

  @override
  String get dashboardActAnswer => 'Answer';

  @override
  String get dashboardActReview => 'Review';

  @override
  String get dashboardActRetry => 'Retry';

  @override
  String get dashboardActResume => 'Resume';

  @override
  String get dashboardUsageTitle => 'Plan usage';

  @override
  String dashboardUpdated(String time) {
    return 'Updated $time';
  }

  @override
  String get dashboardNotUpdated => 'No reading yet';

  @override
  String get dashboardSession => 'Current session';

  @override
  String get dashboardWeek => 'This week';

  @override
  String get dashboardPaused => 'New runs are paused until the limit resets.';

  @override
  String get dashboardLiveTitle => 'Live runs';

  @override
  String get dashboardLiveSub => 'Tickets in containers right now';

  @override
  String get dashboardNoRuns => 'No runs at the moment.';

  @override
  String dashboardTurns(String n, String max) {
    return '$n / $max turns';
  }

  @override
  String get dashboardPipelineTitle => 'Pipeline';

  @override
  String get dashboardPipelineSub => 'Open tickets by step';

  @override
  String get dashboardPipeQueue => 'In queue';

  @override
  String get dashboardPipeAnalyze => 'Analyze';

  @override
  String get dashboardPipeAnswers => 'Your answers';

  @override
  String get dashboardPipeCoding => 'Coding';

  @override
  String get dashboardPipeReview => 'Your review';

  @override
  String get dashboardPipeStopped => 'Stopped';

  @override
  String get dashboardTodayTitle => 'Today by hour';

  @override
  String get dashboardTodaySub => 'Events recorded today. agnts keeps working while you sleep.';

  @override
  String get dashboardTodayAria => 'Events today by hour';

  @override
  String get dashboardLegendAgnts => 'agnts working';

  @override
  String get dashboardLegendYou => 'Your actions';

  @override
  String get dashboardLegendProblems => 'Warnings and errors';

  @override
  String get dashboardWeekTitle => 'This week';

  @override
  String get dashboardWeekSub => 'Compared with last week';

  @override
  String get dashboardPicked => 'Tickets picked up';

  @override
  String get dashboardFirstTry => 'Approved on first try';

  @override
  String get dashboardAvgTurns => 'Average turns';

  @override
  String get dashboardAvgWait => 'Waiting on you, average';

  @override
  String get dashboardStoppedRuns => 'Stopped runs';

  @override
  String get dashboardReposTitle => 'Repositories';

  @override
  String get dashboardReposSub => 'Open work and the latest ticket in each';

  @override
  String get dashboardAllRepos => 'All repositories';

  @override
  String get dashboardColRepo => 'Repository';

  @override
  String get dashboardColOpen => 'Open';

  @override
  String get dashboardColLatest => 'Latest ticket';

  @override
  String get dashboardColClaudeMd => 'CLAUDE.md';

  @override
  String get dashboardFound => 'Found';

  @override
  String get dashboardMissing => 'Missing';

  @override
  String get dashboardUnknown => 'Unknown';

  @override
  String get dashboardNoRepos => 'No repository has open work.';

  @override
  String get dashboardRecentTitle => 'Recent activity';

  @override
  String get dashboardLogs => 'Logs';

  @override
  String get dashboardNoActivity => 'No activity yet.';

  @override
  String get followUpsTitle => 'Follow-up tickets';

  @override
  String get followUpsSub =>
      'What finishing this ticket still needs, as agnts sees it. Pick the ones you want: they are created queued, so nothing runs until you start them.';

  @override
  String get followUpsMode => 'Follow-up suggestions';

  @override
  String get followUpsModeInherit => 'As in Settings';

  @override
  String get followUpsModeOn => 'On';

  @override
  String get followUpsModeOff => 'Off';

  @override
  String get followUpsModeHint => 'When on, agnts\'s runs suggest tickets this one still needs. It makes every prompt a little longer.';

  @override
  String get followUpsOffEmpty =>
      'Follow-up suggestions are off for this ticket. Turn them on to have the next run suggest what finishing it still needs.';

  @override
  String get followUpsOnEmpty => 'Nothing suggested yet. Most tickets need no follow-up.';

  @override
  String get followUpsType_prerequisite => 'Prerequisite';

  @override
  String get followUpsType_split => 'Split off';

  @override
  String get followUpsType_unfinished => 'Left undone';

  @override
  String get followUpsType_gap => 'Gap';

  @override
  String get followUpsSource_analyze => 'from the analysis';

  @override
  String get followUpsSource_work => 'from the work';

  @override
  String get followUpsSource_review => 'from the code review';

  @override
  String get followUpsSource_manual => 'from a review finding';

  @override
  String followUpsPick(String title) {
    return 'Create “$title”';
  }

  @override
  String get followUpsEditTitle => 'Ticket title';

  @override
  String get followUpsServes => 'Why';

  @override
  String get followUpsDetails => 'Details';

  @override
  String get followUpsWaitsForDone => 'It builds on this ticket\'s work: you can create it once this ticket is done.';

  @override
  String get followUpsTarget => 'Create as';

  @override
  String get followUpsTargetLocal => 'Local task';

  @override
  String get followUpsTargetJira => 'Jira issue';

  @override
  String get followUpsJiraOff => 'Connect Jira to file issues there';

  @override
  String followUpsCreate(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Create $count tickets',
      one: 'Create $count ticket',
      zero: 'Create tickets',
    );
    return '$_temp0';
  }

  @override
  String get followUpsQueuedHint => 'Created tickets wait in the queue until you start them.';

  @override
  String get followUpsDismiss => 'Dismiss';

  @override
  String followUpsDismissedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dismissed suggestions',
      one: '$count dismissed suggestion',
    );
    return '$_temp0';
  }

  @override
  String get followUpsChildren => 'Created from this ticket';

  @override
  String get followUpsFollowUpOf => 'Follow-up of';

  @override
  String followUpsCreatedNotice(num count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count tickets created', one: '$count ticket created');
    return '$_temp0, queued until you start them.';
  }

  @override
  String followUpsFailedItem(String title, String error) {
    return '$title: $error';
  }

  @override
  String get followUpsFromFinding => 'Make follow-up';

  @override
  String get followUpsFromFindingDone => 'Suggested as a follow-up';

  @override
  String get followUpsFromFindingHint => 'For work outside this change: suggest it as a follow-up ticket instead of sending it back';

  @override
  String followUpsOpenBadge(num count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count follow-ups', one: '$count follow-up');
    return '$_temp0';
  }

  @override
  String get followUpsSettingLabel => 'Suggest follow-up tickets';

  @override
  String get followUpsSettingHelp =>
      'Analysis, work and review runs suggest tickets that finishing a ticket still needs: prerequisites, parts to split off, work left undone, gaps a report found. You pick which to create. Off by default because it makes every prompt a little longer; a ticket can turn it on for itself.';

  @override
  String get followUpsNotifyLabel => 'Follow-up tickets suggested';

  @override
  String get followUpsJiraIssueType => 'Issue type for follow-ups';

  @override
  String get followUpsJiraIssueTypeHelp => 'The type of the Jira issues agnts files when you create a follow-up in Jira. Default: Task.';

  @override
  String get formSave => 'Save changes';

  @override
  String get formSaving => 'Saving…';

  @override
  String get formDiscard => 'Discard';

  @override
  String get formCancel => 'Cancel';

  @override
  String get formUnsaved => 'You have unsaved changes';

  @override
  String get formClose => 'Close';

  @override
  String get formAdd => 'Add';

  @override
  String formRemove(String name) {
    return 'Remove $name';
  }

  @override
  String get formAddCommand => 'Add command';

  @override
  String get formDecrease => 'Decrease';

  @override
  String get formIncrease => 'Increase';

  @override
  String get formCopy => 'Copy';

  @override
  String get formCopied => 'Copied';

  @override
  String get formSaved => 'Saved';

  @override
  String get formSearch => 'Search';

  @override
  String get formNoMatch => 'No matches';

  @override
  String get implementTitle => 'Next step';

  @override
  String get implementSubPlan =>
      'Have agnts carry out this plan: a code task linked to this one, with the plan as its brief. You review the diff as usual.';

  @override
  String get implementSubBug =>
      'Have agnts make the proposed fix: a code task linked to this one, with the investigation as its brief. You review the diff as usual.';

  @override
  String get implementImplement => 'Implement this plan';

  @override
  String get implementFix => 'Fix this bug';

  @override
  String get implementPickRepo => 'Repository to implement it in';

  @override
  String get implementQueue => 'Keep the task in the queue instead of starting it';

  @override
  String get implementDoneBy => 'Implemented by';

  @override
  String get implementImplements => 'Implements';

  @override
  String get integrationsTitle => 'Integrations';

  @override
  String get integrationsLede =>
      'The services agnts works with. Tokens are stored encrypted on your server and only used for the actions listed on each page.';

  @override
  String get integrationsName_jira => 'Jira';

  @override
  String get integrationsName_github => 'GitHub';

  @override
  String get integrationsName_claude => 'Claude';

  @override
  String get integrationsDesc_jira => 'Pick up tickets with the agnts label and keep their status up to date.';

  @override
  String get integrationsDesc_github => 'Clone code, push branches and open pull requests.';

  @override
  String get integrationsDesc_claude => 'Your Claude subscription, which runs Claude Code.';

  @override
  String get integrationsConnected => 'Connected';

  @override
  String get integrationsNotConnected => 'Not connected';

  @override
  String get integrationsConnect => 'Connect';

  @override
  String get integrationsManage => 'Manage';

  @override
  String get integrationsTest => 'Test connection';

  @override
  String get integrationsDisconnect => 'Disconnect';

  @override
  String integrationsDisconnectConfirm(String name) {
    return 'Disconnect $name? agnts forgets the token and stops using it.';
  }

  @override
  String integrationsDisconnected(String name) {
    return '$name disconnected';
  }

  @override
  String get integrationsAccount => 'Account';

  @override
  String get integrationsToken => 'Token';

  @override
  String get integrationsLastChecked => 'Last checked';

  @override
  String get integrationsLastError => 'Last error';

  @override
  String get integrationsNever => 'Never';

  @override
  String get integrationsComing => 'Coming later';

  @override
  String get integrationsComingSub => 'Planned integrations';

  @override
  String get integrationsBack => 'Back to integrations';

  @override
  String integrationsConnectedAs(String account, String time) {
    return 'Connected as $account. Last checked $time.';
  }

  @override
  String get integrationsNotYet => 'Not connected yet.';

  @override
  String integrationsConnectTitle(String name) {
    return 'Connect $name';
  }

  @override
  String get integrationsConnectSub_jira => 'Use an API token from your Atlassian account.';

  @override
  String get integrationsTokenOpen_jira => 'Open Atlassian API tokens';

  @override
  String get integrationsTokenStep1_jira =>
      'Sign in to the Atlassian account agnts should act as, and open Account settings → Security → API tokens (or use the button below).';

  @override
  String get integrationsTokenStep2_jira =>
      'Click Create API token (not the one with scopes), name it (for example agnts) and pick an expiration date.';

  @override
  String get integrationsTokenStep3_jira => 'Copy the token and paste it below. Atlassian shows it only once.';

  @override
  String get integrationsTokenStep4_jira =>
      'For Site, enter your Jira address (https://your-team.atlassian.net), and for Account email the email of that same account. It needs access to the Jira projects agnts works on.';

  @override
  String get integrationsConnectSub_github => 'Create a fine-grained personal access token with the permissions below, then paste it here.';

  @override
  String get integrationsTokenHow => 'How to get the token';

  @override
  String get integrationsTokenCommand => 'Command';

  @override
  String get integrationsTokenOpen_github => 'Open GitHub token page';

  @override
  String get integrationsTokenStep1_github =>
      'On GitHub, open Settings → Developer settings → Personal access tokens → Fine-grained tokens and click Generate new token (or use the button below).';

  @override
  String get integrationsTokenStep2_github =>
      'Name it (for example agnts), pick an expiration, set Resource owner to the account or organization that owns your repositories, and under Repository access choose the repositories agnts may work on.';

  @override
  String get integrationsTokenStep3_github =>
      'Under Repository permissions set Contents and Pull requests to Read and write. For the Pipelines tab also set Actions to Read (Read and write to use Deploy) and Deployments to Read. Metadata (read) is added automatically.';

  @override
  String get integrationsTokenStep4_github =>
      'Click Generate token, copy it (it starts with github_pat_) and paste it below. GitHub shows it only once. For an organization, an owner may need to approve the token first.';

  @override
  String get integrationsConnectSub_claude =>
      'Run `claude setup-token` on a machine where you are signed in to your Claude plan, then paste the token.';

  @override
  String get integrationsTokenStep1_claude =>
      'You need a Claude Pro or Max plan. On any computer, install Claude Code: npm install -g @anthropic-ai/claude-code';

  @override
  String get integrationsTokenStep2_claude => 'Run claude once in a terminal and sign in with your Claude account.';

  @override
  String get integrationsTokenStep3_claude =>
      'Run the command below. It opens the browser to approve access and then prints a long-lived token.';

  @override
  String get integrationsTokenStep4_claude =>
      'Copy the token (it starts with sk-ant-) and paste it below. It lasts about a year, and runs count against your plan\'s usage.';

  @override
  String get integrationsSite => 'Site';

  @override
  String get integrationsSiteHelp => 'For example https://your-team.atlassian.net';

  @override
  String get integrationsEmail => 'Account email';

  @override
  String get integrationsApiToken => 'API token';

  @override
  String get integrationsApiTokenHelp => 'id.atlassian.com → Security → API tokens';

  @override
  String get integrationsAccessToken => 'Access token';

  @override
  String get integrationsTokenHelp => 'Stored encrypted on your server. agnts never shows it again.';

  @override
  String get integrationsScopes => 'Required permissions';

  @override
  String get integrationsPermContents => 'Read and write. Clone code and push branches.';

  @override
  String get integrationsPermPulls => 'Read and write. Open pull requests.';

  @override
  String get integrationsPermMetadata => 'Read. List repositories and branches.';

  @override
  String get integrationsPermActions => 'Read for the Pipelines tab and environments; Read and write to use Deploy.';

  @override
  String get integrationsPermDeployments => 'Read. Shows what is deployed to each environment.';

  @override
  String get integrationsRequired => 'Required';

  @override
  String get integrationsRecommended => 'Recommended';

  @override
  String get integrationsConnecting => 'Checking the token…';

  @override
  String integrationsConnectedToast(String name) {
    return '$name connected';
  }

  @override
  String integrationsTestOk(String name) {
    return '$name: connection works';
  }

  @override
  String integrationsTestFail(String name, String error) {
    return '$name: $error';
  }

  @override
  String get integrationsWebhookTitle => 'Set up the Jira webhook';

  @override
  String get integrationsWebhookSteps => 'In Jira, open Settings → System → WebHooks → Create, and enter:';

  @override
  String get integrationsWebhookUrl => 'URL';

  @override
  String get integrationsWebhookSecret => 'Secret';

  @override
  String get integrationsWebhookOnce => 'This secret is shown only once. Paste it into Jira now.';

  @override
  String get integrationsEvents => 'Events';

  @override
  String get integrationsEventsValue => 'Issue created, Issue updated';

  @override
  String get integrationsConnection => 'Connection';

  @override
  String get integrationsPickup => 'Pickup rules';

  @override
  String get integrationsPickupSub => 'Which tickets agnts takes';

  @override
  String get integrationsLabel => 'Label';

  @override
  String get integrationsLabelHelp => 'Add this label to a ticket to hand it to agnts';

  @override
  String get integrationsQuery => 'The query agnts runs';

  @override
  String get integrationsStatuses => 'Status updates';

  @override
  String get integrationsStatusesSub => 'How agnts moves tickets on your board. Leave empty to keep the status.';

  @override
  String get integrationsMapStarted => 'When agnts starts';

  @override
  String get integrationsMapReview => 'When changes are pushed';

  @override
  String get integrationsMapRejected => 'When you reject the changes';

  @override
  String get integrationsKeepStatus => 'Keep status';

  @override
  String get integrationsComments => 'Comments';

  @override
  String get integrationsCommentsSub => 'What agnts writes on the ticket';

  @override
  String get integrationsCQuestions => 'agnts\'s questions';

  @override
  String get integrationsCQuestionsHelp => 'So teammates can see what was unclear';

  @override
  String get integrationsCPlan => 'The plan before coding';

  @override
  String get integrationsCPr => 'Link to the pull request';

  @override
  String get integrationsCSummary => 'Summary of the changes';

  @override
  String get integrationsCStatus => 'Pauses at the plan limit';

  @override
  String get integrationsSync => 'Sync';

  @override
  String get integrationsSyncNow => 'Sync now';

  @override
  String integrationsSynced(String found, String created) {
    return '$found open issues, $created new';
  }

  @override
  String get integrationsSyncHelp =>
      'Jira sends new tickets to the webhook right away; agnts also checks every hour in case a delivery was missed.';

  @override
  String get integrationsWebhook => 'Webhook';

  @override
  String integrationsSaved(String name) {
    return '$name settings saved';
  }

  @override
  String get integrationsSecretsHelp =>
      'agnts only reads tickets that match the query, and only writes the status changes and comments you turn on here.';

  @override
  String get integrationsGithubHelp =>
      'Use a token from an account that can push to your repositories. Commits are authored with the name and email in Settings.';

  @override
  String get integrationsClaudeHelp => 'The token lasts about a year. Renew it with `claude setup-token` before it expires.';

  @override
  String get integrationsName_telegram => 'Telegram';

  @override
  String get integrationsDesc_telegram =>
      'Messages when something needs you. Answer questions and approve or request changes right from the chat.';

  @override
  String get integrationsConnectSub_telegram =>
      'Create a bot with @BotFather, paste its token, and add your chat id. agnts registers the webhook for you.';

  @override
  String get integrationsTokenOpen_telegram => 'Open @BotFather';

  @override
  String get integrationsChatIdFind => 'Find my chat id';

  @override
  String get integrationsTokenStep1_telegram =>
      'In Telegram, open @BotFather (button below), send /newbot and choose a name and a username ending in bot.';

  @override
  String get integrationsTokenStep2_telegram =>
      'BotFather replies with the bot token (like 123456789:AA…). Paste it into Access token below.';

  @override
  String get integrationsTokenStep3_telegram => 'Open your new bot in Telegram and press Start, so it has a message from you.';

  @override
  String get integrationsTokenStep4_telegram =>
      'Click Find my chat id (it appears once the token is pasted). In the page that opens, find \"chat\" and copy the number after \"id\" into Your chat id. If the page shows no messages, write to the bot again and reload it.';

  @override
  String get integrationsChatId => 'Your chat id';

  @override
  String get integrationsChatIdHelp => 'The chat allowed to use the bot. Only this chat can act.';

  @override
  String get integrationsTelegramHelp => 'Approve and Reject ask for a second tap to confirm, and confirmations expire after 10 minutes.';

  @override
  String integrationsTelegramHttps(String url) {
    return 'Telegram only sends updates to a public HTTPS address, and this agnts runs on $url, so connecting will fail here. Connect Telegram on a deployment with HTTPS, where AGNTS_PUBLIC_URL is an https:// address.';
  }

  @override
  String get integrationsName_gitlab => 'GitLab';

  @override
  String get integrationsDesc_gitlab => 'Clone code, push branches and open merge requests on gitlab.com or your own GitLab.';

  @override
  String get integrationsConnectSub_gitlab => 'Create a personal access token with the scopes below, then paste it here.';

  @override
  String get integrationsTokenOpen_gitlab => 'Open GitLab token page';

  @override
  String get integrationsTokenStep1_gitlab =>
      'Fill in the instance URL below first. Then in GitLab open your avatar → Edit profile → Access tokens → Add new token (or use the button below).';

  @override
  String get integrationsTokenStep2_gitlab =>
      'Name it (for example agnts) and set an expiration date. Use an account that can push to your projects.';

  @override
  String get integrationsTokenStep3_gitlab => 'Select the scopes api, read_repository and write_repository.';

  @override
  String get integrationsTokenStep4_gitlab =>
      'Click Create token, copy it (it starts with glpat-) and paste it below. GitLab shows it only once.';

  @override
  String get integrationsGitlabUrl => 'Instance URL';

  @override
  String get integrationsGitlabUrlHelp => 'https://gitlab.com or your own GitLab server.';

  @override
  String get integrationsGlApi => 'Full API access. Open merge requests and read pipelines.';

  @override
  String get integrationsGlRead => 'Clone code.';

  @override
  String get integrationsGlWrite => 'Push branches.';

  @override
  String get integrationsGitlabHelp =>
      'Use a token from an account that can push to your projects. Run containers never see it; pushes happen on the server after you approve.';

  @override
  String get integrationsMapMerged => 'When the pull request is merged';

  @override
  String get integrationsGitWebhookSteps_github =>
      'In the repository (or organisation) go to Settings → Webhooks → Add webhook. Content type application/json, paste the URL and secret below.';

  @override
  String get integrationsGitWebhookSteps_gitlab =>
      'In the project go to Settings → Webhooks. Paste the URL, put the secret below in Secret token.';

  @override
  String get integrationsGitEvents_github => 'Pull requests, Workflow runs';

  @override
  String get integrationsGitEvents_gitlab => 'Merge request events, Pipeline events';

  @override
  String get integrationsGitWebhookWhy =>
      'When a pull or merge request is merged, agnts marks the ticket merged and moves the Jira issue to the merged status set on the Jira page. Pipeline events keep the repository page current.';

  @override
  String get kindTitle => 'Kind';

  @override
  String get kindAuto => 'Auto';

  @override
  String get kindAutoHint => 'agnts picks the kind while reading the ticket';

  @override
  String get kindCode => 'Code';

  @override
  String get kindCodeHint => 'Implement a change. Needs a repository; ends in a pull request.';

  @override
  String get kindTest => 'Tests';

  @override
  String get kindTestHint => 'Write or fix automated tests. Needs a repository; ends in a pull request.';

  @override
  String get kindPlan => 'Plan';

  @override
  String get kindPlanHint => 'Write an implementation plan. Changes no code; ends in a report.';

  @override
  String get kindAnalysis => 'Analysis';

  @override
  String get kindAnalysisHint => 'Research a question and report the findings. Changes no code.';

  @override
  String get kindBug => 'Bug investigation';

  @override
  String get kindBugHint => 'Find the root cause of a bug and propose a fix. Changes no code.';

  @override
  String get kindPickerHint => 'What agnts produces. Choosing a kind makes it final; Auto lets agnts decide while reading the ticket.';

  @override
  String kindSwitchTo(String kind) {
    return 'Switch to $kind';
  }

  @override
  String get learnTitle => 'Learn';

  @override
  String get learnLede =>
      'When a change agnts ships does something this codebase never did before, agnts explains it here: what it is, why the change needed it, where to look, and a short quiz.';

  @override
  String learnViewNew(String n) {
    return 'New ($n)';
  }

  @override
  String get learnViewLearned => 'Learned';

  @override
  String learnViewAll(String n) {
    return 'All ($n)';
  }

  @override
  String get learnViewLabel => 'Show';

  @override
  String get learnAllRepos => 'All repositories';

  @override
  String get learnRepoLabel => 'Repository';

  @override
  String get learnNone => 'No lessons yet. When agnts pushes a change that does something new for its repository, the lesson appears here.';

  @override
  String get learnNoneNew => 'You\'re up to date: every lesson is marked learned.';

  @override
  String get learnNoMatch => 'No lessons match the search.';

  @override
  String learnFromTicket(String key) {
    return 'From $key';
  }

  @override
  String learnQuizCount(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n quiz questions', one: '$n quiz question');
    return '$_temp0';
  }

  @override
  String get learnNewBadge => 'New';

  @override
  String get learnLearned => 'Learned';

  @override
  String get learnMarkLearned => 'Mark as learned';

  @override
  String get learnMarkUnlearned => 'Mark as not learned';

  @override
  String get learnMarkedLearned => 'Marked as learned';

  @override
  String get learnBack => 'Back to lessons';

  @override
  String get learnNotFound => 'This lesson does not exist.';

  @override
  String get learnWhatTitle => 'What it is';

  @override
  String get learnWhyTitle => 'Why this change needed it';

  @override
  String get learnWhereTitle => 'Where to look';

  @override
  String learnWhereSub(String repo, String key) {
    return 'Files in $repo at the time of $key.';
  }

  @override
  String get learnQuizTitle => 'Check yourself';

  @override
  String get learnQuizSub => 'Pick an answer to see whether it\'s right.';

  @override
  String get learnCorrect => 'Correct.';

  @override
  String get learnWrong => 'Not quite.';

  @override
  String learnScore(String right, String total) {
    return '$right of $total right';
  }

  @override
  String get learnRetry => 'Try again';

  @override
  String get learnReadingTitle => 'Further reading';

  @override
  String get learnReadingNote => 'Claude suggested these links. Check them before relying on them.';

  @override
  String get learnCategory_pattern => 'Pattern';

  @override
  String get learnCategory_architecture => 'Architecture';

  @override
  String get learnCategory_algorithm => 'Algorithm';

  @override
  String get learnCategory_library => 'Library';

  @override
  String get learnCategory_language => 'Language';

  @override
  String get learnCategory_testing => 'Testing';

  @override
  String get learnCategory_security => 'Security';

  @override
  String get learnCategory_performance => 'Performance';

  @override
  String get learnCategory_tooling => 'Tooling';

  @override
  String get learnCategory_other => 'Other';

  @override
  String get learnLevel_beginner => 'Beginner';

  @override
  String get learnLevel_intermediate => 'Intermediate';

  @override
  String get learnLevel_advanced => 'Advanced';

  @override
  String get learnTicketTitle => 'What\'s new in this change';

  @override
  String get learnTicketSub => 'Techniques this change brought to the repository for the first time.';

  @override
  String get learnTicketPending => 'agnts is reading this change for anything the repository never did before.';

  @override
  String get learnTicketNone => 'Nothing new: this change only used techniques the repository already had.';

  @override
  String get learnTicketFailed => 'agnts could not finish reading this change. The log shows why.';

  @override
  String get learnTicketIdle => 'agnts has not looked at this change for lessons yet.';

  @override
  String get learnLearnNow => 'Find what\'s new';

  @override
  String get learnLearnAgain => 'Look again';

  @override
  String get learnQueued => 'Queued: agnts will look at this change for something new.';

  @override
  String get learnQueueTitle => 'Learning queue';

  @override
  String get learnQueueSub => 'Pushed tickets agnts reads for new techniques, one at a time when no ticket needs a worker.';

  @override
  String get learnStatus_running => 'Learning now';

  @override
  String get learnStatus_pending => 'Queued';

  @override
  String get learnStatus_failed => 'Failed';

  @override
  String get learnStatus_none => 'Not learned yet';

  @override
  String learnQueuePosition(String n) {
    return '#$n in queue';
  }

  @override
  String get learnQueueBtn => 'Learn';

  @override
  String get learnRetryBtn => 'Retry';

  @override
  String learnQueueAll(String n) {
    return 'Learn from all ($n)';
  }

  @override
  String learnQueuedAll(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n tickets queued', one: '$n ticket queued');
    return '$_temp0';
  }

  @override
  String learnReadTime(num n) {
    return '$n min read';
  }

  @override
  String get learnQueueLede =>
      'Pushed tickets agnts reads for techniques the codebase never used before. Queue any done ticket, or retry one that failed.';

  @override
  String get learnQueueEmpty => 'Nothing to learn from right now: every pushed ticket has been read.';

  @override
  String get logsTitle => 'Logs';

  @override
  String get logsLede => 'Every step agnts takes, recorded as it happens. Use it to see where time goes and why runs stop.';

  @override
  String get logsLive => 'Live';

  @override
  String get logsExportJson => 'Export JSON';

  @override
  String get logsExportCsv => 'Export CSV';

  @override
  String get logsRunsStarted => 'Runs started';

  @override
  String get logsRunsNote => 'Coding sessions, including retries';

  @override
  String get logsReached => 'Reached your review';

  @override
  String logsReachedNote(String n, String total) {
    return '$n of $total runs passed tests';
  }

  @override
  String get logsAvgTurns => 'Average turns';

  @override
  String get logsAvgTurnsNote => 'Per ticket';

  @override
  String get logsStops => 'Stops and pauses';

  @override
  String logsStopsNote(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n error events in total', one: '$n error event in total');
    return '$_temp0';
  }

  @override
  String get logsPeriod => 'Last 30 days';

  @override
  String get logsWhereTime => 'Where the time goes';

  @override
  String get logsWhereTimeSub => 'Average time spent in each step, across all tickets and tasks';

  @override
  String get logsNoData => 'No data';

  @override
  String get logsLegendAgnts => 'agnts working';

  @override
  String get logsLegendYou => 'Waiting on you';

  @override
  String get logsEventsTitle => 'Events';

  @override
  String logsEventsSub(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n events shown', one: '$n event shown');
    return '$_temp0, newest first. Select a row to see its raw data.';
  }

  @override
  String get logsTabAll => 'All';

  @override
  String get logsTabState => 'State changes';

  @override
  String get logsTabTool => 'Tool calls';

  @override
  String get logsTabCommand => 'Commands';

  @override
  String get logsTabUser => 'Your actions';

  @override
  String get logsTabLimit => 'Plan limits';

  @override
  String get logsTabProblems => 'Warnings and errors';

  @override
  String get logsKeyFilter => 'Ticket key, e.g. PAY-214';

  @override
  String get logsKeyFilterLabel => 'Filter by ticket key';

  @override
  String get logsErrorsOnly => 'Errors only';

  @override
  String get logsClear => 'Clear filters';

  @override
  String get logsColTime => 'Time';

  @override
  String get logsColTicket => 'Ticket';

  @override
  String get logsColStep => 'Step';

  @override
  String get logsColType => 'Type';

  @override
  String get logsColEvent => 'Event';

  @override
  String get logsColDuration => 'Duration';

  @override
  String get logsNoEvents => 'No events match these filters.';

  @override
  String get logsNoDetail => 'No extra data for this event.';

  @override
  String get logsShowMore => 'Show more';

  @override
  String get logsTypeState => 'State';

  @override
  String get logsTypeTool => 'Tool';

  @override
  String get logsTypeCommand => 'Command';

  @override
  String get logsTypeYou => 'You';

  @override
  String get logsTypeLimit => 'Limit';

  @override
  String get logsTypeError => 'Error';

  @override
  String get logsTypeEvent => 'Event';

  @override
  String manalyticsTickets(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n tickets', one: '$n ticket');
    return '$_temp0';
  }

  @override
  String manalyticsTurns(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n turns', one: '$n turn');
    return '$_temp0';
  }

  @override
  String manalyticsShareOfRuns(String n) {
    return '$n% of runs';
  }

  @override
  String manalyticsReachedReview(String n) {
    return '$n% reached review';
  }

  @override
  String get manalyticsAbout => 'About analytics';

  @override
  String manalyticsStopped(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n stopped runs in this period',
      one: '$n stopped run in this period',
    );
    return '$_temp0';
  }

  @override
  String manalyticsDays(num n) {
    return '$n days';
  }

  @override
  String manalyticsCompared(num n) {
    return 'Changes are compared with the previous $n days. Green means better.';
  }

  @override
  String get mcpTitle => 'Claude chat (MCP)';

  @override
  String get mcpSub => 'Manage agnts from Claude on the web, desktop and phone';

  @override
  String get mcpUrl => 'Connector URL';

  @override
  String get mcpConnections => 'Connected Claude apps';

  @override
  String get mcpStaticToken => 'Static token';

  @override
  String get mcpSet => 'Set';

  @override
  String get mcpNotSet => 'Not set';

  @override
  String get mcpHowTo =>
      'In Claude, open Settings → Connectors → Add custom connector and paste the URL. Claude sends you here to approve the connection. In chat, every change (answers, approve, reject, new tasks) is prepared first and only runs after you confirm it. For Claude Code or Claude Desktop you can use a static token instead: send it as Authorization: Bearer.';

  @override
  String get mcpNewToken => 'New token';

  @override
  String get mcpShownOnce => 'Copy it now: it is shown only once. The previous token no longer works.';

  @override
  String get mcpCreate => 'Create static token';

  @override
  String get mcpRotate => 'Replace static token';

  @override
  String get mcpRevoke => 'Disconnect all';

  @override
  String get mcpRevokeConfirm => 'Disconnect every Claude app and delete the static token?';

  @override
  String get mcpRevoked => 'All Claude connections removed';

  @override
  String get mcpConsentTitle => 'Connect Claude to agnts';

  @override
  String mcpConsentAsk(String client, String user) {
    return '$client wants to use agnts as $user.';
  }

  @override
  String get mcpConsentWhat =>
      'It can read your tickets, logs, usage and repositories, and prepare actions. Nothing changes until you confirm each action in the chat. Deploys, settings and integrations are not available to it.';

  @override
  String mcpConsentRedirect(String host) {
    return 'You will return to $host.';
  }

  @override
  String get mcpAllow => 'Allow';

  @override
  String get mcpDeny => 'Deny';

  @override
  String get mdetailApprove => 'Approve';

  @override
  String get mdetailWorking => 'agnts is working. You\'ll get a notification when it needs you.';

  @override
  String get mdetailCopyPr => 'Copy pull request link';

  @override
  String get mdetailCopied => 'Link copied';

  @override
  String get mdetailFactTime => 'Time';

  @override
  String mhomeRunningNote(String parallel, String queued) {
    return '$parallel at a time allowed, $queued in queue';
  }

  @override
  String mhomeWaiting(String time) {
    return 'Waiting $time';
  }

  @override
  String get mhomeActAnswers => 'Answer agnts\'s questions';

  @override
  String get mhomeActReview => 'Review the changes';

  @override
  String get mhomeActStopped => 'Stopped. Tell agnts what to try';

  @override
  String get mhomeActResume => 'Resume when you\'re ready';

  @override
  String get mhomeActStart => 'Kept in queue. Tap to start';

  @override
  String get mhomeLiveFallback => 'Working…';

  @override
  String get mhomeSearchEmpty => 'No tickets match your search.';

  @override
  String mmoreAgo(String time) {
    return '$time ago';
  }

  @override
  String get mmoreJustNow => 'just now';

  @override
  String get mmoreLangPhone => 'Phone language';

  @override
  String mmoreSignedInTo(String server) {
    return 'Signed in to $server';
  }

  @override
  String get mmorePipelineRuns => 'Pipeline runs';

  @override
  String get mmoreLoginLede => 'Sign in to your agnts server to answer questions, review changes and follow runs.';

  @override
  String get mobileServer => 'Server address';

  @override
  String get mobileServerHint => 'https://agnts.example.com';

  @override
  String get mobileServerInvalid => 'Enter the https address of your agnts server.';

  @override
  String get mobileHome => 'Home';

  @override
  String get mobileActivity => 'Activity';

  @override
  String get mobileMore => 'More';

  @override
  String mobileGreeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get mobileNeedsYou => 'Needs you';

  @override
  String get mobileRunningNow => 'Running now';

  @override
  String get mobileInQueue => 'In queue';

  @override
  String get mobileNothingWaiting => 'Nothing is waiting on you.';

  @override
  String get mobileNoRuns => 'No runs at the moment.';

  @override
  String get mobileLiveRuns => 'Live runs';

  @override
  String mobileTurnsOf(String turns, String max) {
    return '$turns of $max turns';
  }

  @override
  String mobileWaitingFor(String time) {
    return 'waiting $time';
  }

  @override
  String get mobileUsage => 'Plan usage';

  @override
  String get mobileSession => 'Current session';

  @override
  String get mobileWeek => 'This week';

  @override
  String get mobileRefresh => 'Refresh';

  @override
  String get mobilePaused => 'New runs are paused until the limit resets.';

  @override
  String get mobileAppearance => 'Appearance';

  @override
  String get mobileTheme => 'Theme';

  @override
  String get mobileThemeSystem => 'System';

  @override
  String get mobileThemeLight => 'Day';

  @override
  String get mobileThemeDark => 'Night';

  @override
  String get mobileLanguage => 'Language';

  @override
  String get mobileDefaultModels => 'Default models';

  @override
  String get mobilePush => 'Push notifications';

  @override
  String get mobilePushOn => 'Send to this phone';

  @override
  String get mobilePushNeeds => 'When something needs you';

  @override
  String get mobilePushStopped => 'When a run stops or pauses';

  @override
  String get mobilePushDone => 'When changes are pushed';

  @override
  String get mobilePushUnavailable => 'Push is not set up on this server.';

  @override
  String get mobileIntegrations => 'Integrations';

  @override
  String get mobileRepositories => 'Repositories';

  @override
  String get mobileConnected => 'Connected';

  @override
  String get mobileNotConnected => 'Not connected';

  @override
  String get mobileSaved => 'Saved';

  @override
  String get mobileSignOut => 'Sign out';

  @override
  String get mobileNewTask => 'New task';

  @override
  String get mobileTaskTitle => 'Title';

  @override
  String get mobileTaskDescription => 'What should be done';

  @override
  String get mobileTaskRepo => 'Repository';

  @override
  String get mobileTaskPriority => 'Priority';

  @override
  String get mobilePriorityLow => 'Low';

  @override
  String get mobilePriorityMedium => 'Medium';

  @override
  String get mobilePriorityHigh => 'High';

  @override
  String get mobileAfterApprove => 'After you approve';

  @override
  String get mobileAfterMain => 'Push to main';

  @override
  String get mobileAfterPr => 'Open pull request';

  @override
  String get mobileStart => 'How to start';

  @override
  String get mobileStartAsk => 'Ask questions first';

  @override
  String get mobileStartCode => 'Start coding right away';

  @override
  String get mobileStartQueue => 'Keep in queue';

  @override
  String get mobileCreate => 'Create';

  @override
  String get mobileNoSideRepos => 'Add a side-project repository in the admin panel first.';

  @override
  String get mobileNoTasks => 'No tasks yet.';

  @override
  String get mobileNoEvents => 'Nothing here yet.';

  @override
  String get mobileFilterAll => 'All';

  @override
  String get mobileFilterProblems => 'Problems';

  @override
  String get mobileFilterYou => 'Your actions';

  @override
  String get mobileAnswer => 'Answer';

  @override
  String get mobileReview => 'Review';

  @override
  String get mobileConfirm => 'Confirm';

  @override
  String get mobileCancel => 'Cancel';

  @override
  String get mobileRetry => 'Retry';

  @override
  String get mobileStop => 'Stop';

  @override
  String get mobileOffline => 'Can\'t reach the server. Pull to retry.';

  @override
  String get mobileOpenInBrowser => 'Open in browser';

  @override
  String mobileVersion(String version) {
    return 'Version $version';
  }

  @override
  String get mobileBranches => 'Branches';

  @override
  String get mobileCommits => 'Commits';

  @override
  String get mobilePipelines => 'Pipelines';

  @override
  String get mobileDeploy => 'Deploy';

  @override
  String mobileDeployConfirm(String stage) {
    return 'Start $stage? This deploys to a live environment.';
  }

  @override
  String get mobileDeployStarted => 'Deploy started';

  @override
  String mobileAheadBehind(String ahead, String behind) {
    return '↑$ahead ↓$behind';
  }

  @override
  String get mobileCiOk => 'Passed';

  @override
  String get mobileCiFail => 'Failed';

  @override
  String get mobileCiRun => 'Running';

  @override
  String get mobileCiWaiting => 'Waiting';

  @override
  String get mobileCiManual => 'Waiting for you';

  @override
  String get mobileCiNone => 'No pipeline';

  @override
  String get mobileGitHostError => 'The git host returned an error. Check the integration.';

  @override
  String get mobileLastDays => 'Last 7 days';

  @override
  String get mobilePushed => 'Pushed';

  @override
  String get mobileFirstTry => 'First try';

  @override
  String get mobileWaitingAvg => 'Waiting on you';

  @override
  String mobileMinutes(String n) {
    return '$n min';
  }

  @override
  String get mpreviewTitle => 'agnts\'s preview';

  @override
  String get mpreviewSub => 'Screenshots of the app with this change. Advice beside your review: it never blocks approval.';

  @override
  String get mpreviewPending => 'Queued: agnts starts the app and takes screenshots as soon as a worker is free.';

  @override
  String get mpreviewRunning => 'agnts is starting the app and taking screenshots…';

  @override
  String get mpreviewFailed => 'The preview failed. Check the app yourself, or run it again.';

  @override
  String get mpreviewAppFailed => 'The app did not start, so there are no screenshots. The end of its log:';

  @override
  String mpreviewStale(String n) {
    return 'These screenshots are of revision $n; the work changed since.';
  }

  @override
  String get mpreviewRun => 'Take screenshots';

  @override
  String get mpreviewRunAgain => 'Run again';

  @override
  String get mpreviewCompare => 'Compare with the default branch';

  @override
  String get mpreviewCompareHelp => 'Also takes the same screenshots without this change.';

  @override
  String get mpreviewStatus_ok => 'Ready';

  @override
  String get mpreviewStatus_partial => 'Partial';

  @override
  String get mpreviewStatus_failed => 'Did not start';

  @override
  String mpreviewModel(String model) {
    return 'Checked by $model';
  }

  @override
  String mpreviewIssues(num count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count issues', one: '$count issue', zero: 'No issues');
    return '$_temp0';
  }

  @override
  String get mpreviewNoIssues => 'agnts saw no visual problems.';

  @override
  String get mpreviewSev_high => 'High';

  @override
  String get mpreviewSev_medium => 'Medium';

  @override
  String get mpreviewSev_low => 'Low';

  @override
  String get mpreviewShowShot => 'Show screenshot';

  @override
  String get mpreviewDesktop => 'Desktop';

  @override
  String get mpreviewPhone => 'Phone';

  @override
  String get mpreviewBefore => 'Before';

  @override
  String get mpreviewAfter => 'After';

  @override
  String get mpreviewNoShots => 'No screenshots at this width.';

  @override
  String mpreviewConsoleErrors(num count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count console errors', one: '$count console error');
    return '$_temp0';
  }

  @override
  String get mpreviewLoadFailed => 'Could not load the screenshot.';

  @override
  String get mpreviewAddToFeedback => 'Add to feedback';

  @override
  String get mpreviewAdded => 'In feedback';

  @override
  String get mpreviewAttached => 'Screenshots sent with the feedback';

  @override
  String mpreviewAttachLimit(String max) {
    return 'Up to $max screenshots can go with the feedback.';
  }

  @override
  String get mpreviewRemove => 'Remove';

  @override
  String get mpreviewSettingsModel => 'Preview';

  @override
  String get mpreviewSettingsModelHelp => 'Looks at screenshots of the running app';

  @override
  String get mpreviewNotify => 'Preview screenshots are ready';

  @override
  String get mtasksActAnswers => 'Answer agnts\'s questions';

  @override
  String get mtasksActReview => 'Review the changes';

  @override
  String get mtasksActFailed => 'Stopped. Tell agnts what to try';

  @override
  String get mtasksActResume => 'Resume when you\'re ready';

  @override
  String get mtasksActAnalyze => 'Tap to analyze';

  @override
  String get mtasksActHeld => 'Kept in queue. Tap to start';

  @override
  String get mtasksYesterday => 'Yesterday';

  @override
  String get navOverview => 'Overview';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get navTickets => 'Tickets';

  @override
  String get navNeeds => 'Needs you';

  @override
  String get navRunning => 'Running';

  @override
  String get navQueue => 'In queue';

  @override
  String get navDone => 'Finished';

  @override
  String get navAll => 'All tickets';

  @override
  String get navSideProjects => 'Side projects';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navMonitor => 'Monitor';

  @override
  String get navLogs => 'Logs';

  @override
  String get navUsage => 'Plan usage';

  @override
  String get navSetup => 'Setup';

  @override
  String get navIntegrations => 'Integrations';

  @override
  String get navRepos => 'Repositories';

  @override
  String get navSettings => 'Settings';

  @override
  String get navSearch => 'Search tickets and tasks';

  @override
  String get navSyncJira => 'Sync Jira';

  @override
  String navSynced(String found, String created) {
    return 'Jira synced: $found open, $created new';
  }

  @override
  String get navSession => 'Current session';

  @override
  String get navWeek => 'This week';

  @override
  String get navDayMode => 'Switch to day mode';

  @override
  String get navNightMode => 'Switch to night mode';

  @override
  String get navCollapseSidebar => 'Collapse sidebar';

  @override
  String get navExpandSidebar => 'Expand sidebar';

  @override
  String get navLanguage => 'Language';

  @override
  String get navGuide => 'How this page works';

  @override
  String get navClose => 'Close';

  @override
  String get navMain => 'Main';

  @override
  String get navLive => 'Live';

  @override
  String get navOffline => 'Reconnecting…';

  @override
  String navResetsIn(String time) {
    return 'Resets in $time';
  }

  @override
  String get navResettingNow => 'Resetting now';

  @override
  String get navUsageUnknown => 'Usage unknown';

  @override
  String get navBack => 'Back';

  @override
  String get navLedeNeeds => 'Tickets waiting on your answers or your review, plus runs that stopped.';

  @override
  String get navLedeRunning => 'Tickets agnts is working on right now.';

  @override
  String get navLedeQueue => 'Tickets with the agnts label that haven\'t been analyzed yet.';

  @override
  String get navLedeDone => 'Pushed or rejected tickets.';

  @override
  String get navLedeAll => 'Every ticket agnts has picked up from Jira.';

  @override
  String get navKnowledge => 'Knowledge';

  @override
  String get navLearn => 'Learn';

  @override
  String get navLearnQueue => 'Learning queue';

  @override
  String get navRules => 'Rules';

  @override
  String get previewTab => 'Preview';

  @override
  String get previewTitle => 'Screenshots of the app';

  @override
  String get previewSub => 'agnts started the app with this change and took screenshots. Advice only: it never blocks approval.';

  @override
  String get previewPending => 'Queued: agnts takes screenshots as soon as a worker is free.';

  @override
  String get previewRunning => 'agnts is starting the app and taking screenshots…';

  @override
  String get previewFailed => 'The preview run failed. Check the run log, or run it again.';

  @override
  String previewStale(String n) {
    return 'These screenshots are of revision $n; the change moved on since.';
  }

  @override
  String get previewNone => 'No screenshots yet.';

  @override
  String get previewStatus_ok => 'Captured';

  @override
  String get previewStatus_partial => 'Partly captured';

  @override
  String get previewStatus_failed => 'App did not start';

  @override
  String previewModel(num n, String model) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n screenshots', one: '$n screenshot', zero: 'No screenshots');
    return '$_temp0 by $model';
  }

  @override
  String get previewWithBase => 'with the default branch for comparison';

  @override
  String get previewSev_high => 'High';

  @override
  String get previewSev_medium => 'Medium';

  @override
  String get previewSev_low => 'Low';

  @override
  String get previewNoIssues => 'agnts saw no visual problems.';

  @override
  String get previewViewport => 'Screen size';

  @override
  String get previewVp_all => 'All';

  @override
  String get previewVp_desktop => 'Desktop';

  @override
  String get previewVp_phone => 'Phone';

  @override
  String get previewMode => 'Show';

  @override
  String get previewMode_after => 'After';

  @override
  String get previewMode_before => 'Before';

  @override
  String get previewMode_side => 'Side by side';

  @override
  String get previewMode_slider => 'Slider';

  @override
  String get previewSlider => 'Drag to compare before and after';

  @override
  String previewConsoleErrors(num count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count console errors', one: '$count console error');
    return '$_temp0';
  }

  @override
  String get previewNoBefore => 'No before screenshot: this page is new or could not open on the default branch.';

  @override
  String get previewAddToFeedback => 'Add to feedback';

  @override
  String get previewAdded => 'In feedback';

  @override
  String get previewCompare => 'Compare with the default branch';

  @override
  String get previewRun => 'Take screenshots';

  @override
  String get previewRunAgain => 'Take screenshots again';

  @override
  String previewTooMany(String n) {
    return 'Feedback can carry $n screenshots at most.';
  }

  @override
  String get previewAttached => 'Screenshots sent with the feedback';

  @override
  String previewDetach(String name) {
    return 'Remove $name';
  }

  @override
  String get previewRepoTitle => 'Preview';

  @override
  String get previewRepoHelp =>
      'How agnts starts the app to take screenshots of UI changes before you review them. Leave the command empty to turn previews off.';

  @override
  String get previewRepoCommand => 'Start command';

  @override
  String get previewRepoCommandHelp =>
      'Runs in /workspace inside the run container: install, build and start the dev server. It must listen on the port below.';

  @override
  String get previewRepoPort => 'Port';

  @override
  String get previewRepoReady => 'Ready path';

  @override
  String get previewRepoUiPaths => 'UI files';

  @override
  String get previewRepoUiPathsHelp =>
      'One glob per line, relative to the repository root. A change touching one gets screenshots. Empty: every change.';

  @override
  String get previewRepoRoutes => 'Always capture';

  @override
  String get previewRepoRoutesHelp => 'Routes captured on every preview, one per line, besides the ones agnts picks from the diff.';

  @override
  String get previewRepoLogin => 'Signing in';

  @override
  String get previewRepoLoginPh => 'Sign in as demo@acme.test; the password is in PREVIEW_PASSWORD.';

  @override
  String get previewRepoLoginHelp => 'Tell agnts how to get past a login, if the app has one. Refer to secrets by variable name.';

  @override
  String get previewRepoEnv => 'Environment';

  @override
  String previewRepoEnvSet(String names) {
    return 'Set: $names. The values are never shown.';
  }

  @override
  String get previewRepoEnvReplace => 'Replace';

  @override
  String get previewRepoEnvClear => 'Clear';

  @override
  String get previewRepoEnvCleared => 'The environment will be cleared when you save.';

  @override
  String get previewRepoEnvHelp =>
      'KEY=value lines given to the app, such as a staging API URL. Stored encrypted and never shown again. Use staging-only credentials: the app and agnts can read them. Add any host the app calls to Settings → Previews → Allowed hosts.';

  @override
  String get previewSettingsTitle => 'Previews';

  @override
  String get previewSettingsSub => 'Screenshots of UI changes, for repositories with a preview command.';

  @override
  String get previewAutoPreview => 'Take screenshots of every UI change';

  @override
  String get previewAutoPreviewHelp =>
      'While a change waits for you, agnts starts the app, opens the pages it touches and shows screenshots next to the diff. It never blocks approval.';

  @override
  String get previewVisualCheck => 'Let coding runs look at the app';

  @override
  String get previewVisualCheckHelp =>
      'Claude may start the app and look at the pages it changed before it finishes, and fix what looks broken. Costs a few more turns.';

  @override
  String get previewModel_ => 'Preview model';

  @override
  String get previewModelHelp => 'Picks the pages and judges the screenshots.';

  @override
  String get previewEgress => 'Allowed hosts';

  @override
  String get previewEgressHelp =>
      'Hosts run containers may reach besides the built-in list (Claude, git hosts, package registries), such as a staging API your app calls in a preview. .example.com allows its subdomains.';

  @override
  String get previewNotify => 'When preview screenshots are ready';

  @override
  String get previewNotifyPhotos => 'Send phone screenshots to Telegram';

  @override
  String get previewNotifyPhotosHelp => 'Up to four screenshots go with the Telegram message.';

  @override
  String get relationsTab => 'Order';

  @override
  String get relationsTitle => 'Order and conflicts';

  @override
  String get relationsSub =>
      'agnts codes several tickets at once and merges them one by one. A ticket waits for the tickets it depends on to be merged, and two tickets that change the same code never code side by side.';

  @override
  String get relationsWaitingTitle => 'Waiting for other tickets';

  @override
  String get relationsWaitingSub => 'Coding starts by itself once these are merged or rejected.';

  @override
  String get relationsWaitingBadge => 'Waiting';

  @override
  String get relationsWaitsFor => 'Waits for';

  @override
  String get relationsWaitedBy => 'Holds back';

  @override
  String get relationsConflicts => 'Not alongside';

  @override
  String get relationsProposedTitle => 'Suggested by agnts';

  @override
  String get relationsProposedSub =>
      'agnts is not sure about these. Accepted ones hold the queue; dismissed ones are never suggested again.';

  @override
  String get relationsActiveTitle => 'In effect';

  @override
  String get relationsEmpty => 'No relations. This ticket runs as soon as a slot is free.';

  @override
  String get relationsAccept => 'Accept';

  @override
  String get relationsDismiss => 'Dismiss';

  @override
  String get relationsRemove => 'Run anyway';

  @override
  String relationsRemoveConfirm(String key, String other) {
    return '$key and $other will no longer wait for each other. Continue?';
  }

  @override
  String relationsConfidence(String pct) {
    return '$pct% sure';
  }

  @override
  String get relationsLanded => 'merged';

  @override
  String get relationsSource_jira => 'Jira link';

  @override
  String get relationsSource_user => 'Added by you';

  @override
  String get relationsSource_agnts => 'agnts';

  @override
  String get relationsSource_rule => 'Predicted overlap';

  @override
  String get relationsSource_git => 'Found in the diffs';

  @override
  String relationsBasis_files(String files) {
    return 'Both change $files';
  }

  @override
  String get relationsBasis_migrations => 'Both add a database migration';

  @override
  String get relationsBasis_lockfile => 'Both change dependency lockfiles';

  @override
  String get relationsBasis_codegen => 'Both change the API spec or generated code';

  @override
  String get relationsBasis_i18n => 'Both change translation files';

  @override
  String relationsBasis_diff(String files) {
    return 'The finished changes touch the same lines in $files';
  }

  @override
  String get relationsConfirmed => 'Confirmed by the diffs';

  @override
  String relationsDismissedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count dismissed', one: '$count dismissed');
    return '$_temp0';
  }

  @override
  String get relationsAddTitle => 'Add a relation';

  @override
  String get relationsAddType => 'Relation';

  @override
  String get relationsAddOther => 'Ticket key';

  @override
  String get relationsAddOtherPh => 'PAY-12';

  @override
  String get relationsAdd => 'Add';

  @override
  String get relationsAddHint =>
      'Waits for: this ticket starts coding once the other is merged. Not alongside: whichever starts second waits until the first is merged.';

  @override
  String get relationsAdded => 'Relation added';

  @override
  String get relationsFootprintTitle => 'Predicted footprint';

  @override
  String get relationsFootprintSub =>
      'What the analysis expects this ticket to change. agnts compares footprints to keep colliding tickets apart.';

  @override
  String get relationsFootprintFiles => 'Files';

  @override
  String get relationsFootprintProvides => 'Adds';

  @override
  String get relationsFootprintConsumes => 'Needs';

  @override
  String get relationsFootprintMigrations => 'Adds a database migration';

  @override
  String get relationsMarkMerged => 'Mark merged';

  @override
  String get relationsMarkMergedHint => 'No merge webhook? Mark the pull request merged so tickets waiting for it can start.';

  @override
  String get repoBack => 'Back to repositories';

  @override
  String get repoNotFound => 'No such repository.';

  @override
  String get repoEdit => 'Edit settings';

  @override
  String get repoBranches => 'Branches';

  @override
  String get repoCommits => 'Commits';

  @override
  String get repoPipelines => 'Pipelines';

  @override
  String get repoMembers => 'Members';

  @override
  String get repoMembersSub_github => 'Collaborators on GitHub. Pull requests can be assigned to them when you approve a review.';

  @override
  String get repoMembersSub_gitlab =>
      'Project members on GitLab, including those from groups. Merge requests can be assigned to them when you approve a review.';

  @override
  String get repoMembersSearch => 'Search members';

  @override
  String get repoMembersNone => 'No members found. The token may not be allowed to list them.';

  @override
  String repoBranchesSub(String branch) {
    return 'agnts works on its own branch for every ticket and never commits to $branch.';
  }

  @override
  String repoArchivedBanner(String time) {
    return 'Archived $time. agnts takes no new tickets or tasks for this repository until you restore it.';
  }

  @override
  String get repoSrcLabel => 'Where';

  @override
  String get repoSrcOrigin => 'Origin';

  @override
  String get repoSrcLocal => 'Local';

  @override
  String repoSrcLocalN(String n) {
    return 'Local ($n)';
  }

  @override
  String repoLocalSub(String branch) {
    return 'Branches in agnts\'s own clones on your server. agnts commits here first and pushes only after you approve; it never commits to $branch.';
  }

  @override
  String get repoColPush => 'On origin';

  @override
  String get repoPush_local => 'Not pushed';

  @override
  String get repoPush_pushed => 'Pushed';

  @override
  String repoPush_unpushed(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n commits not pushed', one: '$n commit not pushed');
    return '$_temp0';
  }

  @override
  String get repoPush_differs => 'Origin changed';

  @override
  String get repoPush_local_help => 'Only on the server. agnts pushes it when you approve the review.';

  @override
  String get repoPush_pushed_help => 'Origin has the same commit.';

  @override
  String get repoPush_unpushed_help => 'Origin has the branch, but not the newest commits.';

  @override
  String get repoPush_differs_help => 'Someone pushed commits to this branch that agnts\'s copy does not have.';

  @override
  String get repoLocalNone => 'No local branches yet. agnts creates one when it starts work on a ticket.';

  @override
  String get repoCommitsSub => 'Recent commits on the default branch, newest first.';

  @override
  String get repoLoadMore => 'Load more';

  @override
  String get repoMoreError => 'Could not load more.';

  @override
  String repoCommitsEnd(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'All $n commits', one: '$n commit');
    return '$_temp0 shown';
  }

  @override
  String get repoPipelinesSub => 'Build, test and deploy runs on the git host.';

  @override
  String repoPipelinesEnd(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'All $n runs', one: '$n run');
    return '$_temp0 shown';
  }

  @override
  String get repoFilterAll => 'All';

  @override
  String get repoFilterOthers => 'Others';

  @override
  String get repoColBranch => 'Branch';

  @override
  String get repoColCommit => 'Latest commit';

  @override
  String get repoColAuthor => 'Author';

  @override
  String get repoColAheadBehind => 'Ahead / behind';

  @override
  String get repoColChecks => 'Checks';

  @override
  String get repoColUpdated => 'Updated';

  @override
  String get repoDefault => 'Default';

  @override
  String get repoNone => 'Nothing here yet.';

  @override
  String get repoCi_ok => 'Passed';

  @override
  String get repoCi_fail => 'Failed';

  @override
  String get repoCi_run => 'Running';

  @override
  String get repoCi_pending => 'Waiting';

  @override
  String get repoCi_manual => 'Waiting for you';

  @override
  String get repoCi_skip => 'Skipped';

  @override
  String get repoCi_canceled => 'Canceled';

  @override
  String get repoCi_none => 'No pipeline';

  @override
  String get repoKpiBranches => 'Branches';

  @override
  String repoKpiBranchesNote(String n) {
    return '$n by agnts';
  }

  @override
  String get repoKpiCommits => 'Commits this week';

  @override
  String repoKpiCommitsNote(String n) {
    return '$n written by agnts';
  }

  @override
  String get repoKpiPipelines => 'Pipeline success';

  @override
  String repoKpiPipelinesNote(String n) {
    return 'Last $n finished runs';
  }

  @override
  String get repoKpiProd => 'Production';

  @override
  String repoDeployedAgo(String time) {
    return 'Deployed $time';
  }

  @override
  String get repoNotDeployed => 'Not deployed yet';

  @override
  String get repoDeployed => 'Deployed';

  @override
  String get repoEmpty => 'Empty';

  @override
  String get repoCommit => 'Commit';

  @override
  String get repoOpen => 'Open';

  @override
  String get repoNoEnvironments => 'No deployment environments on the git host.';

  @override
  String get repoDeployHelp =>
      'agnts waits for checks before a ticket reaches your review. Deploying is always your decision, and it is never available from Claude chat.';

  @override
  String repoDeployBranch(String branch) {
    return 'Deploy $branch';
  }

  @override
  String get repoDeploy => 'Deploy';

  @override
  String repoDeployConfirm(String stage, String sha) {
    return 'Start $stage for $sha?';
  }

  @override
  String repoDeployWorkflowConfirm(String workflow, String branch) {
    return 'Run $workflow on $branch?';
  }

  @override
  String get repoDeployStarted => 'Deploy started';

  @override
  String get repoStage => 'Stage';

  @override
  String get repoStatus => 'Status';

  @override
  String get repoDuration => 'Duration';

  @override
  String get repoOpenRun => 'Open on the git host';

  @override
  String get reposTitle => 'Repositories';

  @override
  String get reposLede =>
      'Code agnts can work in. Each run clones the repository into a fresh container on your server, then runs these checks before anything reaches your review.';

  @override
  String get reposAdd => 'Add repository';

  @override
  String get reposViewLabel => 'Show';

  @override
  String reposViewActive(String n) {
    return 'Active ($n)';
  }

  @override
  String reposViewArchived(String n) {
    return 'Archived ($n)';
  }

  @override
  String get reposArchivedSub =>
      'Archived repositories keep their history but take no new tickets or tasks. Restore one to work on it again.';

  @override
  String get reposArchive => 'Archive';

  @override
  String get reposRestore => 'Restore';

  @override
  String reposArchived(String name) {
    return '$name archived';
  }

  @override
  String reposRestored(String name) {
    return '$name restored';
  }

  @override
  String reposArchiveConfirm(String name) {
    return 'Archive $name? It moves to the archive and keeps its tickets and history, but agnts stops picking up new Jira tickets and tasks for it. Work already started still finishes. You can restore it any time.';
  }

  @override
  String get reposNoArchived => 'No archived repositories.';

  @override
  String get reposImport => 'Import from GitHub/GitLab';

  @override
  String get reposImportTitle => 'Import a repository';

  @override
  String get reposImportSub => 'Repositories your GitHub or GitLab token can reach. Pick one, then set its checks.';

  @override
  String get reposImportFrom => 'Import from';

  @override
  String get reposImportSearch => 'Search repositories';

  @override
  String get reposImportLoading => 'Loading repositories…';

  @override
  String get reposImportEmpty => 'The token cannot reach any repositories. Check which repositories it was given access to.';

  @override
  String get reposImportNone => 'Connect GitHub or GitLab first.';

  @override
  String get reposImportConnect => 'Open Integrations';

  @override
  String get reposImportPrivate => 'Private';

  @override
  String reposImportUpdated(String time) {
    return 'updated $time';
  }

  @override
  String get reposImportAdded => 'Added';

  @override
  String get reposImportPick => 'Add';

  @override
  String reposMissingHelp(num count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count repositories have', one: '$count repository has');
    return '$_temp0 no CLAUDE.md. agnts still works, but spends more turns finding its way around. Add one with the project\'s structure, conventions and test commands.';
  }

  @override
  String get reposColRepo => 'Repository';

  @override
  String get reposColSource => 'Source';

  @override
  String get reposColBranch => 'Branch';

  @override
  String get reposColTest => 'Test command';

  @override
  String get reposColClaude => 'CLAUDE.md';

  @override
  String get reposColOpen => 'Open';

  @override
  String reposJira(String project) {
    return 'Jira $project';
  }

  @override
  String get reposSide => 'Side project';

  @override
  String get reposFound => 'Found';

  @override
  String get reposMissing => 'Missing';

  @override
  String get reposUnknown => 'Not checked';

  @override
  String get reposNoMatch => 'No repositories match your search.';

  @override
  String get reposNone => 'No repositories yet. Add the first one to let agnts work on it.';

  @override
  String get reposDrawerSub => 'Takes side-project tasks, and Jira tickets once it has a Jira project key';

  @override
  String get reposName => 'Name';

  @override
  String get reposCloneUrl => 'Clone URL';

  @override
  String get reposCloneHelp => 'An https URL on github.com or your connected GitLab. agnts uses that host\'s token to clone and push.';

  @override
  String get reposJiraProject => 'Jira project key';

  @override
  String get reposJiraHelp => 'Optional. Tickets from this Jira project with the agnts label run here.';

  @override
  String get reposTaskPrefix => 'Task key prefix';

  @override
  String reposTaskPrefixHelp(String prefix) {
    return 'Side-project tasks are numbered like $prefix-1, $prefix-2. Must differ from the Jira project key.';
  }

  @override
  String get reposBranch => 'Default branch';

  @override
  String get reposBranchHelp => 'Work branches start from here.';

  @override
  String get reposBuild => 'Build command';

  @override
  String get reposLint => 'Lint command';

  @override
  String get reposTest => 'Test command';

  @override
  String get reposTestHelp => 'Must pass before a ticket reaches your review.';

  @override
  String get reposInstructions => 'Extra instructions';

  @override
  String get reposInstructionsHelp => 'Added to every prompt for this repository, on top of its CLAUDE.md.';

  @override
  String get reposClaudeFound => 'Found in the repository root';

  @override
  String get reposClaudeMissing => 'Missing. agnts still works, but a CLAUDE.md saves turns.';

  @override
  String get reposClaudeUnknown => 'Checked after saving';

  @override
  String get reposSaved => 'Repository saved';

  @override
  String get reposEdit => 'Edit';

  @override
  String get reposDeployWorkflow => 'Deploy workflow';

  @override
  String get reposDeployWorkflowHelp =>
      'GitHub Actions workflow file with workflow_dispatch, e.g. deploy.yml. Deploy on the repository page runs it.';

  @override
  String get reviewTitle => 'agnts\'s code review';

  @override
  String get reviewReportTitle => 'agnts\'s review of the report';

  @override
  String get reviewSub => 'A second opinion while you review. It never blocks approval: you decide.';

  @override
  String get reviewPending => 'Queued: agnts reviews this as soon as a worker is free. You can review it yourself meanwhile.';

  @override
  String get reviewRunning => 'agnts is reviewing this now…';

  @override
  String get reviewFailed => 'The review failed. Review it yourself, or run it again.';

  @override
  String get reviewNone => 'Not reviewed by agnts.';

  @override
  String reviewStale(String n) {
    return 'This review is of revision $n; the work changed since.';
  }

  @override
  String get reviewRun => 'Review with agnts';

  @override
  String get reviewRunAgain => 'Review again';

  @override
  String get reviewVerdict_looks_good => 'Looks good';

  @override
  String get reviewVerdict_has_concerns => 'Has concerns';

  @override
  String get reviewVerdict_needs_changes => 'Needs changes';

  @override
  String get reviewSev_blocker => 'Blocker';

  @override
  String get reviewSev_major => 'Major';

  @override
  String get reviewSev_minor => 'Minor';

  @override
  String get reviewSev_nit => 'Nit';

  @override
  String get reviewCat_correctness => 'Correctness';

  @override
  String get reviewCat_security => 'Security';

  @override
  String get reviewCat_performance => 'Performance';

  @override
  String get reviewCat_tests => 'Tests';

  @override
  String get reviewCat_rules => 'Team rules';

  @override
  String get reviewCat_maintainability => 'Maintainability';

  @override
  String get reviewCat_accuracy => 'Accuracy';

  @override
  String get reviewCat_completeness => 'Completeness';

  @override
  String get reviewCat_other => 'Other';

  @override
  String reviewFindings(num count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count findings', one: '$count finding', zero: 'No findings');
    return '$_temp0';
  }

  @override
  String get reviewNoFindings => 'agnts found no problems.';

  @override
  String get reviewStrengths => 'Done well';

  @override
  String get reviewSuggestion => 'Suggestion';

  @override
  String get reviewAddToFeedback => 'Add to feedback';

  @override
  String get reviewAdded => 'In feedback';

  @override
  String get reviewAddAll => 'Add all to feedback';

  @override
  String get reviewShowInDiff => 'Show in diff';

  @override
  String reviewModel(String model, String reason) {
    return 'Reviewed by $model: $reason';
  }

  @override
  String get rulesTitle => 'Rules';

  @override
  String get rulesLede =>
      'Instructions agnts follows on every ticket: global rules for all repositories and rules for one repository. Claude reviews each rule and asks about anything unclear before it applies.';

  @override
  String get rulesAdd => 'Add rule';

  @override
  String get rulesAddSubmit => 'Add and review';

  @override
  String get rulesDrawerSub => 'Write it the way you would brief a new teammate. Claude checks it before any ticket follows it.';

  @override
  String get rulesRuleTitle => 'Title';

  @override
  String get rulesTitlePlaceholder => 'Tests for new endpoints';

  @override
  String get rulesScope => 'Applies to';

  @override
  String get rulesScopeHelp => 'Global rules apply in every repository. A repository rule wins where the two disagree.';

  @override
  String get rulesGlobal => 'Global';

  @override
  String get rulesGlobalHint => 'Every repository';

  @override
  String get rulesBody => 'Rule';

  @override
  String get rulesBodyPlaceholder => 'Every new HTTP endpoint gets an integration test next to its handler.';

  @override
  String get rulesBodyHelp => 'Say what to do, where, and what to do when it cannot be followed.';

  @override
  String get rulesEnabled => 'On';

  @override
  String rulesEnabledFor(String title) {
    return 'Rule $title on';
  }

  @override
  String get rulesRereviewHelp =>
      'You changed what the rule says, so Claude reviews it again. Tickets stop getting it until the review is done.';

  @override
  String get rulesSaved => 'Rule saved';

  @override
  String get rulesSavedReview => 'Rule saved; Claude is reviewing it';

  @override
  String get rulesScopeLabel => 'Show rules for';

  @override
  String rulesScopeAll(String n) {
    return 'All rules ($n)';
  }

  @override
  String rulesScopeGlobal(String n) {
    return 'Global ($n)';
  }

  @override
  String get rulesNone => 'No rules yet. Add one to tell agnts how your team works: testing, naming, logging, what never to touch.';

  @override
  String get rulesNoMatch => 'No rules match.';

  @override
  String rulesWaitingHelp(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n rules are waiting for your answers. They do not apply to tickets until they are answered.',
      one: '$n rule is waiting for your answers. It does not apply to tickets until it is answered.',
    );
    return '$_temp0';
  }

  @override
  String get rulesStatus_pending => 'Queued for review';

  @override
  String get rulesStatus_analyzing => 'Reviewing';

  @override
  String get rulesStatus_questions => 'Needs answers';

  @override
  String get rulesStatus_ready => 'Applies';

  @override
  String get rulesStatus_failed => 'Review failed';

  @override
  String get rulesOff => 'Off';

  @override
  String get rulesEdit => 'Edit';

  @override
  String get rulesDelete => 'Delete';

  @override
  String rulesDeleteBody(String title) {
    return 'Delete the rule “$title”? Tickets that start after this no longer follow it.';
  }

  @override
  String get rulesPending => 'Waiting for a free worker. Claude reviews rules before the next ticket starts.';

  @override
  String get rulesAnalyzing => 'Claude is reading the rule and checking it for anything unclear or conflicting.';

  @override
  String rulesQuestionsTitle(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n questions before this rule applies',
      one: '$n question before this rule applies',
    );
    return '$_temp0';
  }

  @override
  String get rulesQuestionsSub => 'Claude found something unclear. Your answers become part of the rule.';

  @override
  String get rulesYourAnswer => 'Your answer';

  @override
  String get rulesAddDetails => 'Add details (optional)';

  @override
  String rulesAnswerFor(String n) {
    return 'Answer to question $n';
  }

  @override
  String rulesDetailsFor(String n) {
    return 'Details for question $n';
  }

  @override
  String get rulesSendAnswers => 'Send answers';

  @override
  String rulesQuestionsLeft(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n questions left to answer', one: '$n question left to answer');
    return '$_temp0';
  }

  @override
  String get rulesAllAnswered => 'All questions answered';

  @override
  String get rulesAccept => 'Use as written';

  @override
  String get rulesAcceptTitle => 'Use the rule as written?';

  @override
  String get rulesAcceptBody => 'Tickets get the rule as you wrote it, with the answers given so far. Open questions are dropped.';

  @override
  String rulesFailed(String error) {
    return 'Claude could not review this rule: $error';
  }

  @override
  String get rulesReviewAgain => 'Review again';

  @override
  String get rulesInterpretation => 'How agnts reads it';

  @override
  String get rulesClarified => 'What tickets get';

  @override
  String get rulesAsWritten => 'Used as written.';

  @override
  String rulesAnswersTitle(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n answered questions', one: '$n answered question');
    return '$_temp0';
  }

  @override
  String rulesReviewedAgo(String ago) {
    return 'Reviewed $ago';
  }

  @override
  String rulesAddedAgo(String ago) {
    return 'Added $ago';
  }

  @override
  String get rulesAnswered => 'Answers sent; Claude is reviewing the rule again';

  @override
  String get rulesAccepted => 'The rule applies as written';

  @override
  String get rulesQueued => 'Queued for review';

  @override
  String get rulesDeleted => 'Rule deleted';

  @override
  String get rulesTurnedOn => 'Rule turned on';

  @override
  String get rulesTurnedOff => 'Rule turned off';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLede => 'How agnts connects to your tools and how it behaves during runs.';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsAppearanceSub => 'Saved in this browser, applied right away';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeHelp => 'System follows your device\'s day or night setting';

  @override
  String get settingsSystem => 'System';

  @override
  String get settingsDay => 'Day';

  @override
  String get settingsNight => 'Night';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsIntegrations => 'Integrations';

  @override
  String get settingsIntegrationsSub => 'Where tickets come from and where code is pushed';

  @override
  String get settingsManageAll => 'Manage';

  @override
  String get settingsManage => 'Manage';

  @override
  String get settingsConnect => 'Connect';

  @override
  String get settingsConnected => 'Connected';

  @override
  String get settingsNotConnected => 'Not connected';

  @override
  String get settingsClaude => 'Claude Code';

  @override
  String get settingsClaudeSub => 'The engine that does the coding';

  @override
  String get settingsModels => 'Models by stage';

  @override
  String get settingsModelsHelp => 'Pick which model runs each step. Haiku uses the least of your plan, Opus the most.';

  @override
  String get settingsStageAnalyze => 'Reading the ticket and asking questions';

  @override
  String get settingsStageAnalyzeHelp => 'Read-only. Runs once per ticket.';

  @override
  String get settingsStageCoding => 'Coding';

  @override
  String get settingsStageCodingHelp => 'The main run. Uses most of your plan.';

  @override
  String get settingsStageRetry => 'Retries and requested changes';

  @override
  String get settingsStageRetryHelp => 'After failed tests, your feedback or a stopped run.';

  @override
  String get settingsStageHelper => 'Usage refresh and short writing';

  @override
  String get settingsStageHelperHelp => 'Small tasks like the idle usage refresh.';

  @override
  String get settingsStageLearn => 'Lessons from finished work';

  @override
  String get settingsStageLearnHelp => 'Reads each pushed change and writes lessons about what is new to the repository.';

  @override
  String get settingsStageReview => 'Code review';

  @override
  String get settingsStageReviewHelp =>
      'Reviews each result while you review it. Auto uses Opus for complex tickets and Sonnet for the rest.';

  @override
  String get settingsModelAuto => 'Auto';

  @override
  String get settingsMaxTurns => 'Turn limit per run';

  @override
  String get settingsMaxTurnsHelp => 'The run stops and reports when it reaches this';

  @override
  String get settingsTimeout => 'Run timeout';

  @override
  String settingsMinutes(String n) {
    return '$n min';
  }

  @override
  String get settingsAllow => 'Allowed commands';

  @override
  String get settingsAllowHelp => 'Claude Code can run these without asking';

  @override
  String get settingsDeny => 'Blocked commands';

  @override
  String get settingsDenyHelp => 'Always refused, even if a ticket asks for them. Pushing is done by agnts, never by Claude Code.';

  @override
  String get settingsCommits => 'Commits and pull requests';

  @override
  String get settingsCommitsSub => 'Who commits appear from, and how pull requests open';

  @override
  String get settingsAuthorName => 'Author name';

  @override
  String get settingsAuthorNameHelp => 'Commits are made as you';

  @override
  String get settingsAuthorEmail => 'Author email';

  @override
  String get settingsAuthorEmailHelp => 'Must match your GitHub account to show as yours';

  @override
  String get settingsCoAuthor => 'Add a Co-authored-by: agnts line';

  @override
  String get settingsCoAuthorHelp => 'Teammates can see which commits agnts wrote';

  @override
  String get settingsPrTitle => 'Pull request title';

  @override
  String settingsPrTitleHelp(String key, String title) {
    return '\'$key\' and \'$title\' are replaced with the ticket\'s key and title';
  }

  @override
  String get settingsDraft => 'Open as draft';

  @override
  String get settingsRuns => 'Runs';

  @override
  String get settingsRunsSub => 'Defaults for every ticket and task';

  @override
  String get settingsAskFirst => 'Ask questions before coding';

  @override
  String get settingsAskFirstHelp => 'Default for new Jira tickets. Tasks choose this when you create them.';

  @override
  String get settingsAutoResume => 'Resume paused runs after the limit resets';

  @override
  String get settingsAutoLearn => 'Learn from every pushed change';

  @override
  String get settingsAutoLearnHelp =>
      'After a push, agnts looks for techniques the repository never used before and writes lessons under Learn. Uses plan usage only when no ticket is waiting.';

  @override
  String get settingsAutoReview => 'Review every result';

  @override
  String get settingsAutoReviewHelp =>
      'While a change or report waits for you, agnts reviews it and shows its findings next to it. It never blocks approval.';

  @override
  String get settingsPauseAbove => 'Don\'t start new runs above';

  @override
  String get settingsPauseAboveHelp => 'Session usage. Runs already going keep going.';

  @override
  String get settingsParallel => 'Runs at the same time';

  @override
  String get settingsParallelHelp => 'More runs finish sooner but use your plan limit faster';

  @override
  String get settingsNotify => 'Notifications';

  @override
  String get settingsNotifySub => 'Push to your phone and Telegram messages';

  @override
  String get settingsPush => 'Push notifications';

  @override
  String get settingsPushHelp => 'To the agnts app on your phone';

  @override
  String get settingsTelegram => 'Telegram messages';

  @override
  String get settingsTelegramHelp => 'Only sent once Telegram is connected on the Integrations page';

  @override
  String get settingsNeedsYou => 'When something needs you';

  @override
  String get settingsNeedsYouHelp => 'Questions to answer or changes to review';

  @override
  String get settingsStopped => 'When a run stops or pauses';

  @override
  String get settingsDone => 'When changes are pushed';

  @override
  String get settingsLessons => 'When agnts finds something new to learn';

  @override
  String get settingsReviewDone => 'When agnts\'s code review finishes';

  @override
  String get settingsOnThisPage => 'On this page';

  @override
  String get settingsSecretsHelp => 'Tokens for Jira, GitHub and Claude are stored encrypted on your server. This page never shows them.';

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get spendTitle => 'Token spend';

  @override
  String spendSub(String tokens, String cost) {
    return '$tokens tokens in and out · about $cost at API prices';
  }

  @override
  String get spendEmpty => 'Nothing recorded yet. Spend appears after agnts\'s first Claude run on this ticket.';

  @override
  String get spendInput => 'Input';

  @override
  String get spendOutput => 'Output';

  @override
  String spendCache(String read, String write) {
    return 'Cache: $read read, $write written';
  }

  @override
  String spendCalls(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n runs', one: '$n run');
    return '$_temp0';
  }

  @override
  String get spendPartial => 'A run was cut off, so its cost is unknown';

  @override
  String get spendCostNote =>
      'Cost is Claude Code\'s estimate of the same work at API prices. On a Claude plan you are not charged it; it shows the relative weight of each stage.';

  @override
  String spendTokens(String n) {
    return '$n tokens';
  }

  @override
  String get spendColTokens => 'Tokens';

  @override
  String get spendStageAnalyze => 'Analysis';

  @override
  String get spendStageCoding => 'Coding';

  @override
  String get spendStageWriting => 'Writing';

  @override
  String get spendStageRetry => 'Fixes and changes';

  @override
  String get spendStageReview => 'Code review';

  @override
  String get spendStagePreview => 'Preview';

  @override
  String get spendStageLearn => 'Lessons';

  @override
  String get spendStageHelper => 'Helper';

  @override
  String get spendTopTitle => 'Tickets by spend';

  @override
  String spendTopSub(String tokens, String cost) {
    return '$tokens tokens in and out · about $cost at API prices';
  }

  @override
  String get spendTopSubEmpty => 'Which tickets used the most of your plan';

  @override
  String get spendTopEmpty => 'No Claude runs recorded in this period.';

  @override
  String get spendTopNote =>
      'Ranked by Claude Code\'s cost estimate, which weighs cache traffic properly. Share is of the period\'s estimated cost. Only spend inside the period counts.';

  @override
  String get spendColStage => 'Costliest stage';

  @override
  String get spendColCost => 'Est. cost';

  @override
  String get spendColShare => 'Share';

  @override
  String get stateNew => 'In queue';

  @override
  String get stateAnalyzing => 'Reading the code';

  @override
  String get stateWaiting_for_answers => 'Needs your answers';

  @override
  String get stateCoding => 'Coding';

  @override
  String get stateTesting => 'Running tests';

  @override
  String get stateWaiting_for_review => 'Ready for review';

  @override
  String get statePushing => 'Pushing';

  @override
  String get stateDone => 'Pushed';

  @override
  String get stateRejected => 'Rejected';

  @override
  String get stateFailed => 'Stopped';

  @override
  String get stateRate_limited => 'Paused at plan limit';

  @override
  String get stateReportCoding => 'Writing';

  @override
  String get stateReportPushing => 'Delivering';

  @override
  String get stateReportDone => 'Done';

  @override
  String get tasksTitle => 'Tasks';

  @override
  String get tasksLede =>
      'Work for your side projects. Tasks stay in agnts and never touch Jira. Everything else works the same: questions, coding, your review.';

  @override
  String get tasksNew => 'New task';

  @override
  String tasksAllRepos(String count) {
    return 'All repositories $count';
  }

  @override
  String get tasksFilterLabel => 'Filter by repository';

  @override
  String get tasksColTask => 'Task';

  @override
  String get tasksColRepo => 'Repository';

  @override
  String get tasksColStatus => 'Status';

  @override
  String get tasksColUpdated => 'Updated';

  @override
  String get tasksNoMatch => 'No tasks match your search.';

  @override
  String get tasksEmpty => 'No tasks in this repository yet.';

  @override
  String get tasksRepos => 'Repositories';

  @override
  String get tasksReposSub => 'Your side-project repositories on this server';

  @override
  String tasksRepoLine(String test, String open) {
    return 'tests: $test, $open open';
  }

  @override
  String get tasksNoTest => 'none';

  @override
  String get tasksNoRepos => 'No side-project repositories yet.';

  @override
  String get tasksHelp =>
      'For repositories only you work on, you can let agnts push straight to main after you approve. It still never pushes without your review.';

  @override
  String get tasksDrawerSub => 'For your side projects. Not synced to Jira.';

  @override
  String get tasksRepository => 'Repository';

  @override
  String get tasksFieldTitle => 'Title';

  @override
  String get tasksTitlePh => 'For example: Add a rest timer between sets';

  @override
  String get tasksFieldDesc => 'What should be done';

  @override
  String get tasksDescPh => 'Describe the result you want. The clearer this is, the fewer questions agnts asks.';

  @override
  String get tasksPriority => 'Priority';

  @override
  String get tasksLow => 'Low';

  @override
  String get tasksMedium => 'Medium';

  @override
  String get tasksHigh => 'High';

  @override
  String get tasksAfter => 'After you approve';

  @override
  String get tasksAfterMain => 'Push to main';

  @override
  String get tasksAfterPr => 'Open pull request';

  @override
  String get tasksStart => 'How to start';

  @override
  String get tasksStartAsk => 'Ask questions first';

  @override
  String get tasksStartAskHint => 'agnts reads the code and asks before coding. Best for anything unclear.';

  @override
  String get tasksStartCode => 'Start coding right away';

  @override
  String get tasksStartCodeHint => 'Skip questions. Good for small, well-described tasks.';

  @override
  String get tasksStartQueue => 'Keep in queue';

  @override
  String get tasksStartQueueHint => 'Save it and start later.';

  @override
  String get tasksCreate => 'Create task';

  @override
  String get tasksCreateStart => 'Create and start';

  @override
  String get tasksAddRepoFirst => 'Add a side-project repository first.';

  @override
  String get tasksTitleRequired => 'Enter a title.';

  @override
  String tasksCreated(String key) {
    return 'Task $key created';
  }

  @override
  String tasksCount(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n tasks', one: '$n task');
    return '$_temp0';
  }

  @override
  String get tasksNoRepo => 'No repository';

  @override
  String get tasksRepoNeeded => 'Code and tests need a repository: pick one, or choose another kind.';

  @override
  String get ticketBack => 'All tickets';

  @override
  String get ticketPlan => 'Plan';

  @override
  String get ticketAnalysis => 'What agnts found';

  @override
  String get ticketQuestions => 'Questions';

  @override
  String get ticketYourAnswer => 'Your answer';

  @override
  String get ticketNote => 'Note (optional)';

  @override
  String get ticketSendAnswers => 'Send answers and start coding';

  @override
  String get ticketChanges => 'Changes';

  @override
  String ticketFilesChanged(num count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count files changed', one: '$count file changed');
    return '$_temp0';
  }

  @override
  String get ticketChecks => 'Checks';

  @override
  String get ticketPassed => 'passed';

  @override
  String get ticketFailedCheck => 'failed';

  @override
  String get ticketNotes => 'Notes for the reviewer';

  @override
  String get ticketApprove => 'Approve and push';

  @override
  String ticketApproveConfirm(String branch) {
    return 'Push $branch and open a pull request?';
  }

  @override
  String get ticketRequestChanges => 'Request changes';

  @override
  String get ticketFeedbackPlaceholder => 'What should change?';

  @override
  String get ticketSend => 'Send';

  @override
  String get ticketCancel => 'Cancel';

  @override
  String get ticketReject => 'Reject';

  @override
  String ticketRejectConfirm(String key) {
    return 'Stop all work on $key? This cannot be undone.';
  }

  @override
  String get ticketRetry => 'Retry';

  @override
  String ticketPullRequest(String number) {
    return 'Pull request #$number';
  }

  @override
  String get ticketBranch => 'Branch';

  @override
  String ticketRevision(String n) {
    return 'Revision $n';
  }

  @override
  String get ticketLog => 'Live log';

  @override
  String get ticketLogEmpty => 'Nothing logged yet.';

  @override
  String ticketNotFound(String key) {
    return 'No ticket $key.';
  }

  @override
  String get ticketConflict => 'The ticket moved on; refreshed.';

  @override
  String get ticketStopAnalyze => 'Analyze';

  @override
  String get ticketStopAnswers => 'Your answers';

  @override
  String get ticketStopCoding => 'Coding';

  @override
  String get ticketStopTests => 'Tests';

  @override
  String get ticketStopReview => 'Your review';

  @override
  String get ticketStopPushed => 'Pushed';

  @override
  String get ticketProgress => 'Progress';

  @override
  String ticketBackTo(String page) {
    return 'Back to $page';
  }

  @override
  String get ticketQueuedTitle => 'Waiting in queue';

  @override
  String get ticketQueuedSub =>
      'agnts reads the ticket and the related code, then comes back with a plan and questions. Nothing is changed in this step.';

  @override
  String get ticketHeldSub => 'This task is kept in the queue until you start it.';

  @override
  String get ticketStart => 'Start now';

  @override
  String get ticketStartHint => 'Starts when a run slot is free';

  @override
  String get ticketAnalyzingTitle => 'Reading the code';

  @override
  String ticketAnalyzingSub(String repo) {
    return 'Looking through $repo to build a plan.';
  }

  @override
  String ticketQuestionsTitle(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n questions before coding', one: '$n question before coding');
    return '$_temp0';
  }

  @override
  String get ticketQuestionsSub => 'Pick an option or write your own answer. Answers go into the coding prompt with the plan.';

  @override
  String get ticketAddDetails => 'Add details (optional)';

  @override
  String ticketDetailsFor(String n) {
    return 'Details for question $n';
  }

  @override
  String ticketAnswerFor(String n) {
    return 'Answer to question $n';
  }

  @override
  String get ticketStartCoding => 'Start coding';

  @override
  String ticketQuestionsLeft(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n questions left to answer', one: '$n question left to answer');
    return '$_temp0';
  }

  @override
  String get ticketAllAnswered => 'All questions answered';

  @override
  String get ticketCodingTitle => 'Coding';

  @override
  String get ticketTestingTitle => 'Running tests';

  @override
  String ticketRevisionSuffix(String title, String n) {
    return '$title, revision $n';
  }

  @override
  String ticketCodingSub(String branch) {
    return 'Working in a fresh container on $branch. You review the diff before anything is pushed.';
  }

  @override
  String get ticketFactModel => 'Model';

  @override
  String get ticketFactTurns => 'Turns';

  @override
  String get ticketFactTurnLimit => 'Turn limit';

  @override
  String get ticketFactSession => 'Session usage';

  @override
  String get ticketFactTests => 'Tests';

  @override
  String get ticketFactChanged => 'Changed';

  @override
  String ticketChangedValue(num n, String add, String del) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n files', one: '$n file');
    return '$_temp0, +$add −$del';
  }

  @override
  String ticketChecksPassed(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n checks passed', one: '$n check passed');
    return '$_temp0';
  }

  @override
  String get ticketNoChecks => 'No checks configured';

  @override
  String get ticketStopRun => 'Stop run';

  @override
  String ticketStopConfirm(String key) {
    return 'Stop the run on $key? You can retry it later.';
  }

  @override
  String get ticketReviewTitle => 'Review the changes';

  @override
  String ticketReviewSubPr(String branch) {
    return 'Nothing has left the server yet. Approving pushes $branch and opens a pull request.';
  }

  @override
  String ticketReviewSubJira(String branch) {
    return 'Nothing has left the server yet. Approving pushes $branch, opens a pull request and updates the Jira ticket.';
  }

  @override
  String get ticketReviewSubMain => 'Nothing has left the server yet. Approving pushes straight to the default branch.';

  @override
  String get ticketWhatAgntsDid => 'What agnts did';

  @override
  String get ticketDiff => 'Diff';

  @override
  String get ticketFeedback => 'Feedback';

  @override
  String get ticketAssignTitle => 'Assign the pull request';

  @override
  String get ticketAssignSub => 'Optional. Pick who it is assigned to on the git host when agnts opens it.';

  @override
  String ticketAssignError(String error) {
    return 'Could not load the repository members: $error. You can still approve without assignees.';
  }

  @override
  String get ticketAssignNone => 'No repository members to pick from.';

  @override
  String ticketApproveAssignees(String names) {
    return 'Assign it to $names.';
  }

  @override
  String get ticketKvAssignees => 'Assignees';

  @override
  String get ticketFeedbackHint => 'Describe what to change. Required for Request changes.';

  @override
  String get ticketApproveMainConfirm => 'Push the changes straight to the default branch?';

  @override
  String get ticketPushingTitle => 'Pushing';

  @override
  String get ticketPushingSub => 'Committing as you and opening the pull request.';

  @override
  String get ticketDoneTitle => 'Pushed';

  @override
  String ticketDoneMain(String repo) {
    return 'Committed as you and pushed to the default branch of $repo.';
  }

  @override
  String ticketDonePr(String number, String branch) {
    return 'Pull request #$number is open on $branch.';
  }

  @override
  String ticketOpenPr(String number) {
    return 'Open pull request #$number';
  }

  @override
  String get ticketRejectedTitle => 'Rejected';

  @override
  String get ticketRejectedSub => 'agnts stopped working on this ticket. The branch was not pushed.';

  @override
  String get ticketFailedTitle => 'agnts stopped';

  @override
  String get ticketFailedUnknown => 'The run stopped. Check the run log for details.';

  @override
  String get ticketTakeItMyself => 'Take it myself';

  @override
  String get ticketRateTitle => 'Paused at plan limit';

  @override
  String get ticketResume => 'Resume run';

  @override
  String ticketRateHint(String pct) {
    return 'Session usage is $pct% now.';
  }

  @override
  String get ticketModelsTitle => 'Models for this ticket';

  @override
  String get ticketModelsHint => 'Override the defaults from Settings for this ticket only.';

  @override
  String ticketModelDefault(String model) {
    return 'Default ($model)';
  }

  @override
  String get ticketStageAnalyze => 'Reading the ticket and asking questions';

  @override
  String get ticketStageCoding => 'Coding';

  @override
  String get ticketStageRetry => 'Retries and requested changes';

  @override
  String get ticketStageReview => 'Code review by agnts';

  @override
  String get ticketStagePreview => 'Screenshots (preview)';

  @override
  String ticketModelAuto(String model) {
    return 'Auto ($model)';
  }

  @override
  String get ticketSideTicket => 'Ticket';

  @override
  String get ticketSideTask => 'Task';

  @override
  String get ticketKvKey => 'Key';

  @override
  String get ticketKvSource => 'Source';

  @override
  String get ticketKvRepo => 'Repository';

  @override
  String get ticketKvAfter => 'After approval';

  @override
  String get ticketKvPriority => 'Priority';

  @override
  String get ticketKvBranch => 'Branch';

  @override
  String get ticketKvRevision => 'Revision';

  @override
  String get ticketKvTurns => 'Turns used';

  @override
  String get ticketKvCodingModel => 'Coding model';

  @override
  String get ticketKvRetryModel => 'Retry model';

  @override
  String get ticketSrcJira => 'Jira';

  @override
  String get ticketSrcTask => 'agnts task';

  @override
  String get ticketAfterMain => 'Push to main';

  @override
  String get ticketAfterPr => 'Open pull request';

  @override
  String get ticketHistoryTitle => 'History';

  @override
  String get ticketHistoryEmpty => 'No history yet.';

  @override
  String get ticketAnswersTitle => 'Your answers';

  @override
  String get ticketAnswersSub => 'Sent with the coding prompt';

  @override
  String get ticketRunLog => 'Run log';

  @override
  String ticketRunLogSub(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n events', one: '$n event');
    return '$_temp0, grouped by step';
  }

  @override
  String ticketGroupEvents(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n events', one: '$n event');
    return '$_temp0';
  }

  @override
  String ticketGroupErrors(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n errors', one: '$n error');
    return '$_temp0';
  }

  @override
  String get ticketOpenInLogs => 'Open in Logs';

  @override
  String get ticketStepOther => 'General';

  @override
  String get ticketDelete => 'Delete';

  @override
  String ticketDeleteConfirm(String key) {
    return 'Delete task $key?';
  }

  @override
  String get ticketUsageTitle => 'Plan usage';

  @override
  String get ticketUsageSession => 'Current session';

  @override
  String get ticketUsageWeek => 'This week';

  @override
  String get ticketMerged => 'Merged';

  @override
  String ticketMergedAt(String time) {
    return 'Merged $time.';
  }

  @override
  String get ticketRepoTitle => 'Repository';

  @override
  String get ticketRepoHint => 'Where agnts analyzes and codes this ticket.';

  @override
  String get ticketRepoNone => 'Choose a repository…';

  @override
  String get ticketRepoMissing => 'No repository is linked to this ticket. Choose one, then retry.';

  @override
  String get ticketRepoRestartTitle => 'Change repository?';

  @override
  String ticketRepoRestart(String repo, String next) {
    return 'This ticket made progress in $repo. In $next it starts over from analysis when you retry.';
  }

  @override
  String get ticketRepoChange => 'Change';

  @override
  String ticketRepoChanged(String repo) {
    return 'Repository set to $repo';
  }

  @override
  String get ticketQueuedSubReport =>
      'agnts reads the ticket (and the code, if there is a repository) and comes back with a plan and questions. Nothing is changed.';

  @override
  String get ticketAnalyzingTitleNoRepo => 'Reading the ticket';

  @override
  String get ticketAnalyzingSubNoRepo => 'No repository: agnts works from the ticket text.';

  @override
  String get ticketStartWriting => 'Start writing';

  @override
  String get ticketWritingTitle => 'Writing the report';

  @override
  String get ticketWritingSub => 'Working in a fresh container. Nothing in the code changes; you review the report first.';

  @override
  String get ticketReviewReportTitle => 'Review the report';

  @override
  String get ticketReviewReportSub => 'Approving keeps the report here and closes the task.';

  @override
  String get ticketReviewReportSubJira =>
      'Approving keeps the report here and closes the ticket. It goes to Jira only if you tick the box below.';

  @override
  String get ticketReport => 'Report';

  @override
  String get ticketReportMissing => 'No report was stored.';

  @override
  String ticketPostReport(String key) {
    return 'Also post the report as a comment on $key in Jira';
  }

  @override
  String get ticketFeedbackReportHint => 'What should the report change or cover?';

  @override
  String get ticketApproveReport => 'Approve';

  @override
  String get ticketApproveReportConfirm => 'Approve the report and close this ticket?';

  @override
  String ticketApproveReportPostConfirm(String key) {
    return 'Approve the report, close this ticket and post the report to $key in Jira?';
  }

  @override
  String get ticketDeliveringTitle => 'Finishing up';

  @override
  String get ticketDeliveringSub => 'Saving the approved report and posting it to Jira if you asked.';

  @override
  String get ticketDoneReportTitle => 'Report approved';

  @override
  String get ticketDoneReport => 'The report is kept here.';

  @override
  String ticketDoneReportPosted(String key) {
    return 'The report is kept here and was posted to $key in Jira.';
  }

  @override
  String get ticketStopWriting => 'Writing';

  @override
  String get ticketStopDone => 'Done';

  @override
  String get ticketTabsLabel => 'Ticket details';

  @override
  String get ticketTabReview => 'Code review';

  @override
  String get ticketTabFollowUps => 'Follow-ups';

  @override
  String get ticketTabAnswers => 'Answers';

  @override
  String get ticketTabLessons => 'Lessons';

  @override
  String get ticketShowMore => 'Show more';

  @override
  String get ticketShowLess => 'Show less';

  @override
  String get ticketTranslate => 'Translate';

  @override
  String get ticketTranslateOriginal => 'Original language';

  @override
  String get ticketTranslating => 'Translating… the first time takes up to a minute; after that it is saved.';

  @override
  String ticketTranslateFailed(String error) {
    return 'Could not translate: $error';
  }

  @override
  String get ticketsTitle => 'Tickets';

  @override
  String get ticketsNeedsYou => 'Needs you';

  @override
  String get ticketsRunning => 'Running';

  @override
  String get ticketsFinished => 'Finished';

  @override
  String get ticketsAll => 'All';

  @override
  String get ticketsEmpty => 'No tickets here.';

  @override
  String ticketsEmptyHint(String label) {
    return 'Label a Jira issue “$label” and agnts picks it up.';
  }

  @override
  String ticketsUpdated(String time) {
    return 'Updated $time';
  }

  @override
  String get ticketsColTicket => 'Ticket';

  @override
  String get ticketsColSource => 'Source';

  @override
  String get ticketsColRepo => 'Repository';

  @override
  String get ticketsColStatus => 'Status';

  @override
  String get ticketsColUpdated => 'Updated';

  @override
  String get ticketsSourceJira => 'Jira';

  @override
  String get ticketsSourceTask => 'Task';

  @override
  String ticketsRev(String n) {
    return 'rev $n';
  }

  @override
  String ticketsCount(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n tickets', one: '$n ticket');
    return '$_temp0';
  }

  @override
  String get ticketsViewLabel => 'View';

  @override
  String get ticketsViewTable => 'Table';

  @override
  String get ticketsViewBoard => 'Board';

  @override
  String get ticketsBoardEmpty => 'Nothing here';

  @override
  String get ticketsListSub => 'Jira tickets with the agnts label, plus tasks you create for side projects.';

  @override
  String get ticketsNoMatch => 'No tickets match your search.';

  @override
  String get ticketsEmptyNeeds => 'Nothing is waiting on you. Tickets show up here when agnts has questions or changes to review.';

  @override
  String get ticketsEmptyOther => 'No tickets here yet.';

  @override
  String get ticketsStatNeeds => 'Needs you';

  @override
  String get ticketsStatNeedsNote => 'Answers or reviews waiting';

  @override
  String get ticketsStatRunning => 'Running';

  @override
  String get ticketsStatRunningNote => 'In containers right now';

  @override
  String get ticketsStatPushed => 'Pushed this week';

  @override
  String get ticketsStatPushedNote => 'Pull requests opened';

  @override
  String get ticketsStatSession => 'Plan session';

  @override
  String get usageTitle => 'Plan usage';

  @override
  String get usageLede => 'agnts runs on your Claude subscription. These limits are shared with your own Claude and Claude Code use.';

  @override
  String get usageCard => 'Plan usage';

  @override
  String usageUpdated(String time) {
    return 'Updated $time';
  }

  @override
  String get usageNoReading => 'No reading yet';

  @override
  String get usageRefresh => 'Refresh';

  @override
  String get usageRefreshing => 'Refreshing…';

  @override
  String get usageRefreshStarted => 'Refresh started. New numbers arrive in a minute.';

  @override
  String get usageSession => 'Current session';

  @override
  String get usageWeek => 'This week';

  @override
  String get usageUnknown => 'Usage unknown';

  @override
  String usageResetsIn(String time) {
    return 'Resets in $time';
  }

  @override
  String usageResetsAt(String time) {
    return 'Resets $time';
  }

  @override
  String get usageResettingNow => 'Resetting now';

  @override
  String get usageNoReset => 'Reset time unknown';

  @override
  String get usageWarn80 => 'Session usage is above 80%. New runs may pause before they finish.';

  @override
  String usagePaused(String time) {
    return 'New runs are paused at the plan limit until $time.';
  }

  @override
  String get usagePausedNoTime => 'New runs are paused at the plan limit.';

  @override
  String get usageStatus => 'Status';

  @override
  String get usageStatus_allowed => 'Allowed';

  @override
  String get usageStatus_allowed_warning => 'Close to the limit';

  @override
  String get usageStatus_rejected => 'Limit reached';

  @override
  String get usageStatus_unknown => 'Unknown';

  @override
  String get usageSource => 'Read from Claude Code\'s rate limit events. Includes your own Claude use on this account.';

  @override
  String get usageLimitTitle => 'When a limit is reached';

  @override
  String get usageLimitSub => 'How agnts behaves near the limit';

  @override
  String usageAbove(String pct) {
    return 'Above $pct% of the session';
  }

  @override
  String get usageAboveDo => 'Don\'t start new runs; runs already going keep going';

  @override
  String get usageMidRun => 'Limit reached mid-run';

  @override
  String get usageMidRunDo => 'Pause, keep the branch';

  @override
  String get usageAfterReset => 'After reset';

  @override
  String get usageResumeAuto => 'Resume paused runs automatically';

  @override
  String get usageResumeManual => 'Wait for you to resume';

  @override
  String get usageIdle => 'Idle refresh';

  @override
  String get usageIdleDo => 'Every 30 min';

  @override
  String get usageHelp =>
      'Numbers come from the rate limit events Claude Code emits during each run. When agnts is idle, a tiny refresh run keeps them current.';
}
