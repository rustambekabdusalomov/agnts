// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get accountSignupTitle => 'Create your account';

  @override
  String get accountSignupLede => 'You get a workspace of your own to start in.';

  @override
  String accountSignupInviteLede(String workspace) {
    return 'Create an account to join $workspace.';
  }

  @override
  String get accountSignupClosed => 'Sign-up is by invitation on this server. Ask a workspace owner for an invite link.';

  @override
  String get accountFirstUser => 'This is the first account: it becomes the platform\'s Admin.';

  @override
  String get accountEmail => 'Email';

  @override
  String get accountDisplayName => 'Your name';

  @override
  String get accountUsername => 'Username';

  @override
  String get accountUsernameHelp => 'Optional; made from your email when empty.';

  @override
  String get accountPassword => 'Password';

  @override
  String get accountPasswordHelp => 'At least 12 characters.';

  @override
  String get accountPasswordAgain => 'Repeat password';

  @override
  String get accountPasswordsDiffer => 'The passwords differ.';

  @override
  String get accountWorkspaceName => 'Workspace name';

  @override
  String get accountWorkspaceNameHelp => 'Your first workspace, e.g. your project\'s name. You can rename it.';

  @override
  String get accountCreate => 'Create account';

  @override
  String get accountCreating => 'Creating…';

  @override
  String get accountHaveAccount => 'Already have an account?';

  @override
  String get accountSignIn => 'Sign in';

  @override
  String get accountNoAccount => 'No account yet?';

  @override
  String get accountSignUp => 'Create one';

  @override
  String get accountForgot => 'Forgot password?';

  @override
  String get accountForgotTitle => 'Reset your password';

  @override
  String get accountForgotLede => 'We\'ll email you a link to choose a new one.';

  @override
  String get accountForgotSend => 'Send link';

  @override
  String get accountForgotSent => 'If an account uses that address, a link is on its way. It works for an hour.';

  @override
  String get accountResetTitle => 'Choose a new password';

  @override
  String get accountResetSave => 'Save password';

  @override
  String get accountResetDone => 'Password changed. Every session was signed out.';

  @override
  String get accountVerifyTitle => 'Confirm your email';

  @override
  String get accountVerifying => 'Confirming…';

  @override
  String get accountVerified => 'Your email is confirmed.';

  @override
  String get accountVerifyFailed => 'This link is invalid or expired.';

  @override
  String get accountContinue => 'Continue';

  @override
  String accountInviteTitle(String workspace) {
    return 'Join $workspace';
  }

  @override
  String accountInviteBy(String name) {
    return '$name invited you.';
  }

  @override
  String accountInviteFor(String email) {
    return 'The invite is for $email.';
  }

  @override
  String get accountInviteJoin => 'Join workspace';

  @override
  String get accountInviteJoining => 'Joining…';

  @override
  String get accountInviteInvalid => 'This invite link is invalid or expired. Ask for a new one.';

  @override
  String get accountInviteSignInFirst => 'Sign in or create an account to join.';

  @override
  String get accountWorkspacesTitle => 'Your workspaces';

  @override
  String get accountWorkspacesLede => 'A workspace is one project: its repositories, tickets, members and settings.';

  @override
  String get accountNoWorkspaces => 'You are not in any workspace yet. Create one, or open an invite link someone sent you.';

  @override
  String get accountOpen => 'Open';

  @override
  String get accountCreateWorkspace => 'Create a workspace';

  @override
  String get accountCreateWorkspaceSub => 'You become its owner.';

  @override
  String get accountWorkspaceSlug => 'Address';

  @override
  String get accountWorkspaceSlugHelp => 'Used in links; made from the name when empty.';

  @override
  String get accountCreateWs => 'Create workspace';

  @override
  String get accountProfileTitle => 'Profile';

  @override
  String get accountProfile => 'Your profile';

  @override
  String get accountProfileSub => 'How you appear to the members of your workspaces.';

  @override
  String get accountSaveProfile => 'Save';

  @override
  String get accountProfileSaved => 'Profile saved';

  @override
  String get accountEmailUnverified => 'Not confirmed yet';

  @override
  String get accountEmailVerified => 'Confirmed';

  @override
  String get accountResend => 'Send the link again';

  @override
  String get accountResent => 'Confirmation link sent';

  @override
  String get accountPasswordTitle => 'Password';

  @override
  String get accountPasswordSub => 'Changing it signs out your other sessions.';

  @override
  String get accountCurrentPassword => 'Current password';

  @override
  String get accountNewPassword => 'New password';

  @override
  String get accountChangePassword => 'Change password';

  @override
  String get accountPasswordChanged => 'Password changed';

  @override
  String get accountTotpTitle => 'Two-factor sign-in';

  @override
  String get accountTotpSub => 'A code from an authenticator app at every sign-in.';

  @override
  String get accountTotpOn => 'On';

  @override
  String get accountTotpOff => 'Off';

  @override
  String get accountTotpSetup => 'Turn on';

  @override
  String get accountTotpScan =>
      'Add this account to your authenticator app with the secret (or open the link on your phone), then enter the code it shows.';

  @override
  String get accountTotpSecret => 'Secret';

  @override
  String get accountTotpLink => 'Setup link';

  @override
  String get accountTotpCode => 'Code';

  @override
  String get accountTotpConfirm => 'Confirm';

  @override
  String get accountTotpEnabled => 'Two-factor sign-in is on';

  @override
  String get accountTotpDisable => 'Turn off';

  @override
  String get accountTotpDisabled => 'Two-factor sign-in is off';

  @override
  String get accountMyClaude => 'Your Claude account';

  @override
  String get accountMyClaudeSub => 'Runs of your tickets use it in workspaces set to per-member mode.';

  @override
  String get accountClaudeSaved => 'Claude account connected';

  @override
  String get accountClaudeRemoved => 'Claude account disconnected';

  @override
  String get accountAdmin => 'Platform Admin';

  @override
  String get accountAdminConsole => 'Open the operator console';

  @override
  String get accountReturnTitle => 'Payment';

  @override
  String get accountReturnLede =>
      'Thanks. Credits show in Billing as soon as the payment provider confirms the payment (usually within a minute).';

  @override
  String get accountReturnBack => 'Back to Billing';

  @override
  String get accountLastOpened => 'Last opened';

  @override
  String accountMemberCount(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n members', one: '$n member');
    return '$_temp0';
  }

  @override
  String accountSlotCount(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n parallel runs', one: '$n parallel run');
    return '$_temp0';
  }

  @override
  String get accountSuspended => 'Suspended';

  @override
  String get accountNoWorkspacesTitle => 'No workspaces yet';

  @override
  String get accountCreateFirst => 'Create your first workspace';

  @override
  String get accountInviteGoogle => 'Continue with Google to join. New here? Your account is created on the spot.';

  @override
  String get accountTotpRequiredAdmin => 'Two-factor sign-in is required for Admin accounts, so it stays on.';

  @override
  String get accountGoHome => 'Back to dashboard';

  @override
  String accountBackToDashboard(String name) {
    return 'Back to the $name dashboard';
  }

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
  String get analyticsSrcPlane => 'Plane';

  @override
  String get analyticsQuality => 'Agent quality';

  @override
  String get analyticsQualitySub =>
      'Tickets grouped by the prompt version of their first coding run. Compare versions to see whether a change to the agent helped.';

  @override
  String get analyticsNoQuality => 'No coding runs in this period.';

  @override
  String get analyticsColVersion => 'Prompt version';

  @override
  String get analyticsVersionUnknown => 'before tracking';

  @override
  String get analyticsColFirstPass => 'First pass';

  @override
  String get analyticsColFirstPassHint => 'Done tickets approved without a person asking for changes';

  @override
  String get analyticsColRounds => 'Change rounds';

  @override
  String get analyticsColRoundsHint => 'Average change requests by a person per ticket that reached review';

  @override
  String get analyticsColCIRounds => 'CI rounds';

  @override
  String get analyticsColCIRoundsHint =>
      'Average times red CI on the pull request sent the work back, per ticket that reached review (not counted in change rounds)';

  @override
  String get analyticsColFixes => 'Check fixes';

  @override
  String get analyticsColFixesHint => 'Average times failing checks were sent back to Claude';

  @override
  String get analyticsColSerious => 'Serious findings';

  @override
  String get analyticsColSeriousHint => 'Share of reviewed tickets where agnts\'s review found a blocker or major problem';

  @override
  String get analyticsColFootprint => 'Plan accuracy';

  @override
  String get analyticsColFootprintHint => 'Share of changed files the analysis predicted';

  @override
  String get analyticsColRedFlags => 'Red flags';

  @override
  String get analyticsColRedFlagsHint => 'Skipped tests, removed assertions, silenced linters and the like found in the diffs';

  @override
  String get analyticsColSelfFixes => 'Self-fixes';

  @override
  String get analyticsColSelfFixesHint => 'Times agnts\'s own review sent findings back to the coder before a person looked';

  @override
  String get analyticsTabOverview => 'Overview';

  @override
  String get analyticsTabDelivery => 'Delivery';

  @override
  String get analyticsTabQuality => 'Quality';

  @override
  String get analyticsTabLearning => 'Learning';

  @override
  String get analyticsTabCost => 'Cost';

  @override
  String get analyticsTabRepos => 'Repositories';

  @override
  String analyticsDaysHours(String d, String h) {
    return '$d d $h h';
  }

  @override
  String get analyticsKpiMerged => 'Pull requests merged';

  @override
  String analyticsKpiMergedNote(String n) {
    return '$n closed without merging';
  }

  @override
  String get analyticsKpiCostPerTicket => 'Cost per pushed ticket';

  @override
  String get analyticsKpiCostPerTicketNote => 'At API prices, all stages';

  @override
  String analyticsInsightMergeRate(String pct, String closed) {
    return 'Only $pct% of agnts\'s pull requests were merged; $closed were closed without merging. Check the Delivery tab for why.';
  }

  @override
  String analyticsInsightSlowAnswers(String hours) {
    return 'Tickets wait about $hours h for your answers to agnts\'s questions. Answering sooner is the quickest way to speed delivery up.';
  }

  @override
  String analyticsInsightFollowUpsNoise(String pct) {
    return 'Only $pct% of suggested follow-ups were accepted. Most of them are being dismissed.';
  }

  @override
  String analyticsInsightFlakyJob(String job, String repo, String n) {
    return '$job in $repo passed on re-run $n times: it looks flaky. Fixing or quarantining it saves CI time.';
  }

  @override
  String get analyticsPrMerged => 'Merged';

  @override
  String get analyticsPrClosed => 'Closed without merging';

  @override
  String get analyticsPrOpened => 'Opened';

  @override
  String get analyticsPrOpen => 'Still open';

  @override
  String get analyticsCyclePushed => 'Picked up → pushed';

  @override
  String get analyticsCycleMerged => 'Picked up → merged';

  @override
  String get analyticsSplitAnswers => 'Waiting for answers';

  @override
  String get analyticsSplitReview => 'Waiting for review';

  @override
  String get analyticsSplitQueue => 'Queued or paused';

  @override
  String get analyticsKpiMergeRate => 'Merge rate';

  @override
  String analyticsKpiMergeRateNote(String merged, String closed) {
    return '$merged merged, $closed closed';
  }

  @override
  String get analyticsKpiTimeToMerge => 'Time to merge';

  @override
  String get analyticsKpiTimeToMergeNote => 'From pull request to merge';

  @override
  String get analyticsKpiCyclePushed => 'Picked up → pushed';

  @override
  String get analyticsKpiCyclePushedNote => 'agnts\'s part of the work';

  @override
  String get analyticsKpiCycleMerged => 'Picked up → merged';

  @override
  String get analyticsKpiCycleMergedNote => 'Real delivery time';

  @override
  String get analyticsKpiAnswer => 'Time to answer';

  @override
  String get analyticsKpiAnswerNote => 'Until you answer agnts\'s questions';

  @override
  String get analyticsTypicalNote => 'Times are typical values (median): half the tickets were faster, half slower.';

  @override
  String get analyticsPrOutcomes => 'Pull request outcomes';

  @override
  String get analyticsPrOutcomesSub => 'agnts\'s pull requests opened in the period and what happened to them, merges and closes per day';

  @override
  String analyticsMergeSpread(String p50, String p90) {
    return 'A typical pull request is merged in $p50; the slowest one in ten takes $p90 or more.';
  }

  @override
  String get analyticsStale => 'Open for over a week';

  @override
  String get analyticsStaleSub => 'Pull requests nobody has merged or closed yet';

  @override
  String get analyticsNoStale => 'No pull request has been open for more than a week.';

  @override
  String analyticsOpenDays(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'open $n days', one: 'open $n day');
    return '$_temp0';
  }

  @override
  String get analyticsOpenPr => 'Open pull request';

  @override
  String get analyticsCycle => 'Cycle time';

  @override
  String get analyticsCycleSub => 'Typical time from picking a ticket up to pushing and to merging, per day';

  @override
  String analyticsCycleSpread(String pushed, String pushed90, String merged, String merged90) {
    return 'Pushed in $pushed typically ($pushed90 for the slowest one in ten); merged in $merged ($merged90).';
  }

  @override
  String get analyticsQuestions => 'Questions';

  @override
  String get analyticsQuestionsSub => 'What agnts asked before coding, and how fast it got answers';

  @override
  String get analyticsQuestionsAsked => 'Questions asked';

  @override
  String get analyticsQuestionsShare => 'Tickets with questions';

  @override
  String get analyticsAnswerTypical => 'Typical time to answer';

  @override
  String get analyticsAnswerSlow => 'Slowest one in ten';

  @override
  String get analyticsUnanswered => 'Waiting for an answer now';

  @override
  String get analyticsSlowest => 'Slowest tickets';

  @override
  String get analyticsSlowestSub => 'The tickets that took longest from pick-up to push in this period, and where their time went';

  @override
  String get analyticsNoSlowest => 'No ticket was pushed in this period.';

  @override
  String get analyticsKpiCiSeen => 'CI failures';

  @override
  String analyticsKpiCiSeenNote(String n) {
    return '$n new in this period';
  }

  @override
  String get analyticsKpiCiAuto => 'Fixed by agnts';

  @override
  String analyticsKpiCiAutoNote(String auto, String fixed) {
    return '$auto of $fixed fixed failures';
  }

  @override
  String get analyticsKpiCiFix => 'Time to fix';

  @override
  String get analyticsKpiCiFixNote => 'From first failure to merged fix';

  @override
  String get analyticsKpiCiFlaky => 'Flaky failures';

  @override
  String get analyticsKpiCiFlakyNote => 'Passed when re-run';

  @override
  String get analyticsKpiCiOwn => 'Own PRs fixed';

  @override
  String get analyticsKpiCiOwnNote => 'Red checks on agnts\'s PRs fixed before review';

  @override
  String get analyticsCiUnknown => 'Not classified';

  @override
  String get analyticsCiNew => 'New failures';

  @override
  String get analyticsCiFixed => 'Fixed';

  @override
  String get analyticsCiTitle => 'CI health';

  @override
  String analyticsCiSub(String n) {
    return 'New and fixed CI failures per day. $n need attention now.';
  }

  @override
  String get analyticsCiOffSub =>
      'CI watching is not set up. Turn it on for a repository and agnts triages red builds and fixes the ones caused by code.';

  @override
  String get analyticsCiSetUp => 'Set up CI watching';

  @override
  String get analyticsCiOpen => 'Open CI';

  @override
  String get analyticsCiClasses => 'Failures by cause';

  @override
  String get analyticsCiClassesSub => 'What triage decided each failure was';

  @override
  String get analyticsCiNone => 'No CI failures in this period.';

  @override
  String get analyticsCiFlakiest => 'Flakiest jobs';

  @override
  String get analyticsCiFlakiestSub => 'Jobs that failed and then passed on re-run most often';

  @override
  String get analyticsCiNoFlaky => 'No flaky jobs in this period.';

  @override
  String get analyticsColJob => 'Job';

  @override
  String get analyticsColFailure => 'Failure';

  @override
  String get analyticsColFlaky => 'Passed on re-run';

  @override
  String get analyticsColFailures => 'Failures';

  @override
  String get analyticsKpiLessons => 'Lessons';

  @override
  String analyticsKpiLessonsNote(String n) {
    return '$n marked learned';
  }

  @override
  String get analyticsKpiRulesLearned => 'Rules learned';

  @override
  String analyticsKpiRulesLearnedNote(String n) {
    return 'In use, of $n suggested from tickets';
  }

  @override
  String get analyticsKpiRulesManual => 'Rules written';

  @override
  String get analyticsKpiRulesManualNote => 'Added by people';

  @override
  String get analyticsKpiReflections => 'Reflections';

  @override
  String analyticsKpiReflectionsNote(String n) {
    return 'On changed or rejected tickets; $n rules suggested';
  }

  @override
  String get analyticsKpiFollowUps => 'Follow-ups accepted';

  @override
  String analyticsKpiFollowUpsNote(String n) {
    return '$n suggested in this period';
  }

  @override
  String get analyticsKpiReviewerNotes => 'Reviewer notes';

  @override
  String get analyticsKpiReviewerNotesNote => 'Re-reviews, dismissed findings and notes';

  @override
  String get analyticsLearningNote =>
      'How agnts learns from your feedback: fewer reviewer notes and more adopted rules over time mean it is working.';

  @override
  String get analyticsFollowUps => 'Follow-ups by type';

  @override
  String get analyticsFollowUpsSub => 'Follow-up tickets agnts suggested in this period and what you decided';

  @override
  String get analyticsNoFollowUps => 'No follow-ups were suggested in this period.';

  @override
  String get analyticsColType => 'Type';

  @override
  String get analyticsColSuggested => 'Suggested';

  @override
  String get analyticsColAccepted => 'Accepted';

  @override
  String get analyticsColDismissed => 'Dismissed';

  @override
  String get analyticsColOpen => 'Open';

  @override
  String get analyticsColAcceptRate => 'Accept rate';

  @override
  String get analyticsFollowUpSources => 'Where follow-ups come from';

  @override
  String get analyticsFollowUpSourcesSub => 'Suggested follow-ups by the step that found them';

  @override
  String get analyticsLessons => 'Lessons by topic';

  @override
  String analyticsLessonsSub(String n) {
    return 'Lessons written in this period; $n were marked learned';
  }

  @override
  String get analyticsOpenLearn => 'Open Learn';

  @override
  String get analyticsNoLessons => 'No lessons in this period.';

  @override
  String get analyticsReviewers => 'Reviewers';

  @override
  String get analyticsReviewersSub => 'Who sends agnts the most feedback on code reviews';

  @override
  String get analyticsOpenRules => 'Open Rules';

  @override
  String get analyticsNoReviewers => 'No reviewer notes in this period.';

  @override
  String get analyticsColReviewer => 'Reviewer';

  @override
  String get analyticsColRereview => 'Re-reviews';

  @override
  String get analyticsColRereviewHint => 'Times the reviewer asked agnts to review again';

  @override
  String get analyticsColDismissedNotes => 'Dismissed';

  @override
  String get analyticsColDismissedNotesHint => 'Findings of agnts\'s review the reviewer dismissed';

  @override
  String get analyticsColManual => 'Notes';

  @override
  String get analyticsColManualHint => 'Notes the reviewer wrote by hand';

  @override
  String get analyticsColRepos => 'Repositories';

  @override
  String get analyticsKpiCostNote => 'All Claude calls in the period';

  @override
  String analyticsKpiDaysAboveNote(String n) {
    return '$n days above 80% of the session limit';
  }

  @override
  String get analyticsColCost => 'Cost';

  @override
  String get analyticsColMergeRate => 'Merge rate';

  @override
  String get analyticsColMergeRateHint => 'Pull requests merged, out of those merged or closed in the period';

  @override
  String get analyticsColQuestions => 'Questions per ticket';

  @override
  String get analyticsColQuestionsHint =>
      'Questions agnts asked per analysed ticket. Many questions point to a missing CLAUDE.md or rules.';

  @override
  String get analyticsColCi => 'CI failures';

  @override
  String get analyticsColCiHint => 'CI failure groups that failed in the period';

  @override
  String get analyticsTabAssistant => 'Assistant';

  @override
  String get analyticsColScore => 'Score';

  @override
  String get analyticsColScoreHint =>
      '0–100: done first time 35%, merged 25%, no serious review finding 20%, few change rounds 20%. Recent versions score lower until their pull requests merge.';

  @override
  String get analyticsColCostMerged => '\$/merged';

  @override
  String get analyticsColCostMergedHint => 'What all the version\'s tickets cost, over the ones that merged';

  @override
  String get analyticsFewTickets => 'under 10 tickets: too few to compare';

  @override
  String get analyticsColPeopleEdited => 'People edits';

  @override
  String get analyticsColPeopleEditedHint => 'Average share of agnts\'s lines people changed or removed before merging. Lower is better.';

  @override
  String get analyticsColReverted => 'Reverted';

  @override
  String get analyticsColRevertedHint => 'Tickets whose merged work people reverted';

  @override
  String get appName => 'agnts';

  @override
  String get appTagline => 'Your no sleep agent';

  @override
  String get authTitle => 'Sign in';

  @override
  String get authLede => 'Use your email or username and your password.';

  @override
  String get authUsername => 'Email or username';

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
  String get authCodeLede => 'Enter the code from your authenticator app.';

  @override
  String get authBack => 'Use another account';

  @override
  String get authOr => 'or';

  @override
  String get authGoogleRedirecting => 'Signing you in…';

  @override
  String get authGoogleUnavailable => 'Google sign-in could not load. Check your connection or ad blocker.';

  @override
  String get authGoogleFailed => 'Google sign-in did not go through. Try again.';

  @override
  String get authGoogleClosed => 'Sign-up is by invitation on this server: ask a workspace owner for an invite link.';

  @override
  String get authGoogleRateLimited => 'Too many attempts. Wait a minute and try again.';

  @override
  String get authGoogleError => 'Something went wrong signing you in with Google. Try again in a moment.';

  @override
  String get authUseGoogle => 'Passwords are for Admins only here. Continue with Google instead.';

  @override
  String get authAdminsLede => 'Admins sign in with their password. Everyone else continues with Google.';

  @override
  String get authGoogleInvite => 'This invite link is invalid, already used, expired, or meant for another Google account.';

  @override
  String get authGoogleAdmin => 'This is an Admin account: Admins sign in with their username and password.';

  @override
  String get authSetupLede =>
      'Admins sign in with two factors. Scan this code with an authenticator app (Google Authenticator, 1Password, Authy), then enter the 6-digit code it shows.';

  @override
  String get authSignOutBodyGoogle => 'You can sign back in any time with Continue with Google.';

  @override
  String get billingTitle => 'Billing';

  @override
  String get billingSelfHosted =>
      'This server is self-hosted: there is nothing to pay. Set parallel runs below; the Admin sets member limits.';

  @override
  String get billingPlan => 'Plan';

  @override
  String billingPlanSub(String members) {
    return 'The base plan includes 1 parallel run and $members members.';
  }

  @override
  String billingMonthly(String amount) {
    return '$amount a month';
  }

  @override
  String billingPaidUntil(String date) {
    return 'Paid until $date';
  }

  @override
  String billingTrialUntil(String date) {
    return 'Free trial until $date';
  }

  @override
  String get billingSlots => 'Parallel runs';

  @override
  String billingSlotsHelp(String price) {
    return 'Each extra run at once costs $price a month. Adding one now charges the rest of this month from credits.';
  }

  @override
  String billingSlotsHelpSelfHosted(String max) {
    return 'How many runs this workspace has at once, free on this server. Up to $max; the server\'s AGNTS_MAX_SLOTS sets the limit.';
  }

  @override
  String get billingSlotsSave => 'Change';

  @override
  String billingSlotsSaved(String n) {
    return 'Parallel runs set to $n';
  }

  @override
  String get billingMembers => 'Members';

  @override
  String billingMembersHelp(String included, String price) {
    return '$included included; each one more costs $price a month.';
  }

  @override
  String get billingCredits => 'Credits';

  @override
  String get billingCreditsSub =>
      'Runs on agnts\'s API key (the fallback) spend credits: 1 credit is \$0.01 of Anthropic API cost. The month\'s plan is paid from them too.';

  @override
  String get billingBalance => 'Balance';

  @override
  String billingCreditPrice(String price) {
    return '1 credit = $price';
  }

  @override
  String get billingBuy => 'Buy credits';

  @override
  String get billingAmount => 'Amount (so\'m)';

  @override
  String billingYouGet(String n) {
    return '≈ $n credits';
  }

  @override
  String billingPayWith(String provider) {
    return 'Pay with $provider';
  }

  @override
  String get billingPaymentsOff => 'Payments are not set up on this server yet; ask the Admin to grant credits.';

  @override
  String get billingHistory => 'History';

  @override
  String get billingNoHistory => 'Nothing yet.';

  @override
  String get billingReason_purchase => 'Bought';

  @override
  String get billingReason_run => 'Spent';

  @override
  String get billingReason_refund => 'Refunded';

  @override
  String get billingReason_grant => 'Granted';

  @override
  String get billingReason_document => 'Spent on a document';

  @override
  String get briefTitle => 'Repository brief';

  @override
  String get briefSub =>
      'How this code base works: architecture, recipes for common changes, files to copy, conventions and pitfalls. Every run of this repository\'s tickets reads it, so agnts builds things the way your team does.';

  @override
  String get briefSurvey => 'Survey';

  @override
  String get briefUpdate => 'Update';

  @override
  String get briefEdit => 'Edit';

  @override
  String get briefWrite => 'Write it yourself';

  @override
  String get briefSave => 'Save brief';

  @override
  String get briefCancel => 'Cancel';

  @override
  String get briefEditHint => 'Markdown. What you save is what runs read from now on; leave it empty to give runs no brief.';

  @override
  String get briefNone => 'No brief yet. Survey the repository to have Claude write a draft, or write one yourself.';

  @override
  String get briefSurveying => 'Claude is surveying the repository. The draft appears here for your approval.';

  @override
  String briefFailed(String error) {
    return 'The last survey failed: $error';
  }

  @override
  String briefApproved(String time) {
    return 'Approved $time';
  }

  @override
  String briefAtCommit(String sha) {
    return 'at $sha';
  }

  @override
  String briefMerges(String n, String of) {
    return '$n of $of merges before the next update';
  }

  @override
  String get briefDraftTitle => 'Draft from the survey';

  @override
  String briefDraftSub(String time) {
    return 'Written $time. Runs read it only after you approve it.';
  }

  @override
  String get briefApprove => 'Approve';

  @override
  String get briefDiscard => 'Discard draft';

  @override
  String get briefDiscardBody => 'The draft is deleted; the approved brief stays as it is.';

  @override
  String get briefStatus_pending => 'Survey queued';

  @override
  String get briefStatus_surveying => 'Surveying…';

  @override
  String get briefDone_survey => 'Survey queued';

  @override
  String get briefDone_approve => 'Brief approved: new runs read it';

  @override
  String get briefDone_discard => 'Draft discarded';

  @override
  String get briefDone_save => 'Brief saved';

  @override
  String get briefArchTitle => 'Architecture';

  @override
  String get briefArchSub =>
      'The part of the brief agnts checks work against: layers and the imports each may make, shared helpers to reuse, recipes with files to copy. Runs read it as architecture.json; a change that imports across layers it should not is flagged.';

  @override
  String get briefArchNone => 'No architecture yet. The next survey writes one with the brief, or write it yourself.';

  @override
  String briefArchCounts(String layers, String helpers, String recipes) {
    return '$layers layers · $helpers helpers · $recipes recipes';
  }

  @override
  String get briefArchEdit => 'Edit JSON';

  @override
  String get briefArchEditHint =>
      'Empty removes it. Paths are relative to the repository; layer paths are globs (** for any depth); leave out mayImport for a layer that may import anything.';

  @override
  String get briefArchDraft => 'The draft brief comes with this architecture; approving the brief approves it too.';

  @override
  String get briefDone_saveArch => 'Architecture saved';

  @override
  String get ciTitle => 'CI';

  @override
  String get ciLede =>
      'Failing pipelines on your watched branches, grouped by job and error. agnts re-runs new failures once, then fixes the real ones.';

  @override
  String get ciBack => 'CI';

  @override
  String get ciRepo => 'Repository';

  @override
  String get ciAllRepos => 'All repositories';

  @override
  String get ciFilterLabel => 'Status';

  @override
  String get ciFilter_red => 'Red';

  @override
  String get ciFilter_flaky => 'Flaky';

  @override
  String get ciFilter_infra => 'Infra';

  @override
  String get ciFilter_fixed => 'Fixed';

  @override
  String get ciFilter_muted => 'Muted';

  @override
  String get ciFilter_all => 'All';

  @override
  String get ciStatus_triage => 'New';

  @override
  String get ciStatus_open => 'Failing';

  @override
  String get ciStatus_fixing => 'Fixing';

  @override
  String get ciStatus_fixed => 'Fix merged';

  @override
  String get ciStatus_resolved => 'Green again';

  @override
  String get ciStatus_flaky => 'Flaky';

  @override
  String get ciStatus_infra => 'Infra';

  @override
  String get ciStatus_muted => 'Muted';

  @override
  String get ciStatus_regression => 'Regression';

  @override
  String get ciStatusHelp_triage => 'New failure, waiting for a re-run to confirm it';

  @override
  String get ciStatusHelp_open => 'Confirmed; no ticket is working on it';

  @override
  String get ciStatusHelp_fixing => 'A ticket is working on it';

  @override
  String get ciStatusHelp_fixed => 'The fix is merged; waiting for a green run';

  @override
  String get ciStatusHelp_resolved => 'The branch is green again';

  @override
  String get ciStatusHelp_flaky => 'Passed when re-run';

  @override
  String get ciStatusHelp_infra => 'The runner or the network failed, not the code';

  @override
  String get ciStatusHelp_muted => 'Ignored until unmuted';

  @override
  String get ciStatusHelp_regression => 'Failed again after the fix was merged';

  @override
  String get ciClass_code => 'Code';

  @override
  String get ciClass_test => 'Test';

  @override
  String get ciClass_config => 'Config';

  @override
  String get ciClass_dependency => 'Dependency';

  @override
  String get ciClass_infra => 'Infra';

  @override
  String get ciClass_flaky => 'Flaky';

  @override
  String get ciClass_report => 'Report';

  @override
  String get ciColStatus => 'Status';

  @override
  String get ciColFailure => 'Failure';

  @override
  String get ciColCount => 'Failed';

  @override
  String get ciColLastSeen => 'Last seen';

  @override
  String get ciColTicket => 'Ticket';

  @override
  String get ciColTime => 'Time';

  @override
  String get ciColCommit => 'Commit';

  @override
  String get ciColJob => 'Job';

  @override
  String ciTimes(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n times', one: '$n time');
    return '$_temp0';
  }

  @override
  String get ciFix => 'Fix it';

  @override
  String ciFixStarted(String key) {
    return 'Ticket $key opened';
  }

  @override
  String get ciMute => 'Mute';

  @override
  String get ciUnmute => 'Unmute';

  @override
  String get ciMuted => 'Muted: agnts ignores this failure now';

  @override
  String get ciUnmuted => 'Unmuted';

  @override
  String get ciRerun => 'Re-run';

  @override
  String get ciRerunStarted => 'Re-run started';

  @override
  String get ciCommentOnly => 'Comment only';

  @override
  String get ciEmptyRed => 'Nothing is red. Every watched branch passes.';

  @override
  String get ciEmptyFilter => 'No failures here.';

  @override
  String get ciHowTitle => 'How to start watching';

  @override
  String get ciHowWatch =>
      'Open a repository, go to its CI tab and turn on watching. The default branch is always watched; add others like release/*.';

  @override
  String get ciHowWebhook =>
      'For news within seconds, add the git host webhook for workflow_run (GitHub) or Pipeline events (GitLab). Without it agnts checks every 5 minutes.';

  @override
  String get ciNotFound => 'This CI failure was not found.';

  @override
  String ciOpenTicket(String key) {
    return 'Open $key';
  }

  @override
  String ciPrNote(String n) {
    return 'This failure is on someone else\'s pull request #$n. agnts never opens a ticket or pushes there; with comments on, it posts one diagnosis comment.';
  }

  @override
  String ciRegressionNote(String sha) {
    return 'This failed again on a commit that contains the fix $sha. The original ticket gets a follow-up suggestion.';
  }

  @override
  String get ciLogTitle => 'Log';

  @override
  String get ciLogSub => 'Redacted excerpt of the newest failing run';

  @override
  String get ciLogAnnotations => 'Annotations';

  @override
  String get ciLogFirstError => 'First error';

  @override
  String get ciLogEnd => 'End of the log';

  @override
  String get ciLogTail => 'Last lines';

  @override
  String get ciNoLog => 'No log was saved for this failure.';

  @override
  String get ciOccurrences => 'Failing runs';

  @override
  String get ciOccurrencesSub => 'The last 20 runs this failure appeared in';

  @override
  String get ciNoOccurrences => 'No runs recorded.';

  @override
  String get ciPassedOnRerun => 'Passed on re-run';

  @override
  String get ciOpenRun => 'Open run';

  @override
  String get ciFacts => 'Details';

  @override
  String get ciCount => 'Failed';

  @override
  String get ciFlakyCount => 'Passed on re-run';

  @override
  String get ciFirstSeen => 'First seen';

  @override
  String get ciLastSeen => 'Last seen';

  @override
  String get ciFirstSha => 'First failing commit';

  @override
  String get ciLastSha => 'Last commit';

  @override
  String get ciFixedSha => 'Fix commit';

  @override
  String get ciFixedAt => 'Fix merged';

  @override
  String get ciTicket => 'Ticket';

  @override
  String get ciBranch => 'Branch';

  @override
  String get ciWatchTitle => 'CI watching';

  @override
  String get ciWatchSub => 'agnts reads this repository\'s pipelines and fixes what fails';

  @override
  String get ciWatchEnabled => 'Watch CI';

  @override
  String get ciWatchEnabledHelp => 'Off by default. Failures on watched branches are grouped and fixed.';

  @override
  String get ciBranches => 'Extra branches';

  @override
  String ciBranchesHelp(String branch) {
    return 'Globs, one per line. The default branch ($branch) is always watched.';
  }

  @override
  String get ciIgnore => 'Ignored workflows and jobs';

  @override
  String get ciIgnoreHelp => 'Globs, one per line, matched against workflow and job names. Empty uses *deploy*, *release* and *publish*.';

  @override
  String get ciPrs => 'Other people\'s pull requests';

  @override
  String get ciPrsHelp =>
      'agnts never pushes to a colleague\'s branch. With comments on, it posts one diagnosis comment on the pull request.';

  @override
  String get ciPrs_off => 'Ignore';

  @override
  String get ciPrs_comment => 'Comment';

  @override
  String get ciAutoFix => 'Fix automatically';

  @override
  String get ciAutoFixRepoHelp => 'Open a ticket for every confirmed failure, or wait for Fix it';

  @override
  String get ciAutoFix_inherit => 'Workspace setting';

  @override
  String get ciAutoFix_on => 'On';

  @override
  String get ciAutoFix_off => 'Off';

  @override
  String get ciSave => 'Save';

  @override
  String get ciWatchSaved => 'CI watching saved';

  @override
  String get ciFailuresTitle => 'Failures';

  @override
  String get ciFailuresSub => 'This repository\'s failing jobs, newest first';

  @override
  String get ciFlakyTitle => 'Flaky tests';

  @override
  String get ciFlakySub => 'Failures that passed when re-run';

  @override
  String get ciFlakyEmpty => 'No flaky tests found.';

  @override
  String get ciCardTitle => 'CI failure';

  @override
  String get ciFailingRuns => 'Failing runs';

  @override
  String get ciLastRun => 'Last failing run';

  @override
  String get ciStillFailing => 'Still failing';

  @override
  String get ciWaitingGreen => 'Fix merged, waiting for a green run';

  @override
  String get ciGreenAgain => 'Green again';

  @override
  String get ciOpenFailure => 'Open the failure';

  @override
  String get ciSettingsTitle => 'CI';

  @override
  String get ciSettingsSub => 'What agnts does when a watched pipeline goes red. Watching is turned on per repository.';

  @override
  String get ciAutoFixHelp => 'Open a ticket for every confirmed failure. Off, failures wait for Fix it.';

  @override
  String get ciMaxAutoPerDay => 'Automatic tickets a day';

  @override
  String get ciMaxAutoPerDayHelp => 'Over the limit, failures wait for Fix it. Feedback rounds on agnts\'s own pull requests don\'t count.';

  @override
  String ciPerDay(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n a day', one: '$n a day', zero: 'None');
    return '$_temp0';
  }

  @override
  String get ciRetryFlaky => 'Re-run new failures once';

  @override
  String get ciRetryFlakyHelp => 'A new failure\'s jobs run again before agnts believes it. Passing marks it flaky.';

  @override
  String get ciFeedbackRounds => 'Rounds on agnts\'s pull requests';

  @override
  String get ciFeedbackRoundsHelp => 'How many times a red check sends agnts\'s own pull request back to coding. 0 turns it off.';

  @override
  String get ciInfraPatterns => 'Infra patterns';

  @override
  String get ciInfraPatternsHelp =>
      'Regular expressions, one per line. A matching log is an infra failure: shown and counted, never a ticket. Added to the built-in ones.';

  @override
  String get commitBack => 'Back to commits';

  @override
  String commitBackTo(String repo) {
    return 'Back to $repo';
  }

  @override
  String commitAuthoredAgo(String name, String time) {
    return '$name committed $time';
  }

  @override
  String commitFilesN(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n files', one: '$n file');
    return '$_temp0';
  }

  @override
  String get commitAuthor => 'Author';

  @override
  String get commitAuthored => 'Authored';

  @override
  String get commitCommitter => 'Committed by';

  @override
  String get commitCommitted => 'Committed';

  @override
  String commitParents(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'Parents', one: 'Parent');
    return '$_temp0';
  }

  @override
  String get commitPulls => 'Pull requests';

  @override
  String get commitPullsSub => 'Pull requests (merge requests on GitLab) that contain this commit.';

  @override
  String get commitNoPulls => 'This commit is not in any pull request.';

  @override
  String get commitMessage => 'Message';

  @override
  String get commitPipelinesSub => 'CI runs on this commit, newest first.';

  @override
  String get commitNoPipelines => 'No CI runs on this commit.';

  @override
  String get commitChanges => 'Changes';

  @override
  String commitChangesSub(num n, String add, String del) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n files', one: '$n file');
    return '$_temp0 changed, $add additions, $del deletions.';
  }

  @override
  String get commitNoFiles => 'This commit changes no files.';

  @override
  String commitFilesCapped(String n) {
    return 'This commit changes more files than can be shown here. The first $n are listed; open it on the git host to see all of them.';
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
  String get designApproach => 'Approach';

  @override
  String get designFit => 'Fit with the code base';

  @override
  String designAlternatives(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n alternatives considered', one: '$n alternative considered');
    return '$_temp0';
  }

  @override
  String get designWhyNot => 'Why not';

  @override
  String get designOutOfScope => 'Out of scope';

  @override
  String get designShipping => 'Shipping';

  @override
  String get designShip_migrations => 'Migrations';

  @override
  String get designShip_compatibility => 'Compatibility';

  @override
  String get designShip_rollout => 'Rollout';

  @override
  String get designShip_rollback => 'Rollback';

  @override
  String get designDeviations => 'Departed from the plan';

  @override
  String get designFitTitle => 'Following the existing code';

  @override
  String get designKind_copy => 'copy';

  @override
  String get designKind_adapt => 'adapt';

  @override
  String get designKind_new => 'new pattern';

  @override
  String get designLike => 'like';

  @override
  String get designConventionsFrom => 'conventions from';

  @override
  String get designGoesIn => 'goes in';

  @override
  String get designPrecedent => 'sets a precedent: later work will copy it';

  @override
  String get designReuseTitle => 'Existing helpers to use';

  @override
  String get designTestPlanTitle => 'Tests to add or change';

  @override
  String get designEdgeCasesTitle => 'Edge cases to handle';

  @override
  String get designReproTitle => 'The bug, reproduced';

  @override
  String get designReproNot => 'The analysis could not reproduce it';

  @override
  String get documentsPageTitle => 'Documents';

  @override
  String get documentsLede =>
      'Reports and notes for the team: written by you, or by agnts from tickets, commits, pull requests and repositories.';

  @override
  String get documentsNew => 'New document';

  @override
  String get documentsNewLinked => 'New document';

  @override
  String get documentsScope => 'Which documents';

  @override
  String get documentsScope_all => 'All I can open';

  @override
  String get documentsScope_mine => 'Mine';

  @override
  String get documentsScope_shared => 'Shared with me';

  @override
  String get documentsScope_deleted => 'Trash';

  @override
  String get documentsEmpty => 'No documents yet. Create one, or ask agnts to write a report.';

  @override
  String get documentsTrashEmpty => 'The trash is empty.';

  @override
  String get documentsColTitle => 'Title';

  @override
  String get documentsColOwner => 'Owner';

  @override
  String get documentsColTickets => 'Tickets';

  @override
  String get documentsColUpdated => 'Updated';

  @override
  String get documentsColDeleted => 'Restorable for';

  @override
  String documentsDaysLeft(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n days left', one: '$n day left');
    return '$_temp0';
  }

  @override
  String get documentsRestore => 'Restore';

  @override
  String get documentsRestored => 'Document restored';

  @override
  String get documentsPublic => 'Public';

  @override
  String get documentsPrivate => 'Private';

  @override
  String get documentsWriting => 'agnts is writing';

  @override
  String get documentsGenFailed => 'Generation failed';

  @override
  String get documentsAccess_none => 'No access';

  @override
  String get documentsAccess_view => 'Can view';

  @override
  String get documentsAccess_edit => 'Can edit';

  @override
  String get documentsAccess_owner => 'Owner';

  @override
  String get documentsYouCan_view => 'You can view';

  @override
  String get documentsYouCan_edit => 'You can edit';

  @override
  String get documentsRole_owner => 'Workspace owner';

  @override
  String get documentsRole_user => 'Member';

  @override
  String get documentsRole_viewer => 'Viewer';

  @override
  String get documentsNewTitle => 'New document';

  @override
  String get documentsNewSub => 'Write it yourself, or have agnts write it from what the workspace knows.';

  @override
  String get documentsTitle => 'Title';

  @override
  String get documentsTitlePlaceholder => 'Sprint 42 status report';

  @override
  String get documentsWhoWrites => 'Who writes it';

  @override
  String get documentsByAgnts => 'agnts';

  @override
  String get documentsByMe => 'I write it';

  @override
  String get documentsLanguage => 'Language';

  @override
  String get documentsSource => 'Made from';

  @override
  String get documentsKind_report => 'A ticket’s report';

  @override
  String get documentsKind_tickets => 'Tickets';

  @override
  String get documentsKind_commits => 'Commits';

  @override
  String get documentsKind_pulls => 'Pull requests';

  @override
  String get documentsKind_repo => 'Repository';

  @override
  String get documentsKindHelp_report => 'The approved report of a plan, analysis, bug or review ticket, rewritten for its readers.';

  @override
  String get documentsKindHelp_tickets => 'Chosen tickets, or tickets by state and period: their state, dates, reports and commits.';

  @override
  String get documentsKindHelp_commits => 'Commits of repositories in a period, with the tickets they are linked to.';

  @override
  String get documentsKindHelp_pulls => 'Pull requests with their descriptions and diffs: a review digest or release notes.';

  @override
  String get documentsKindHelp_repo => 'agnts reads the whole repository in a sandbox: architecture, quality, tests, risks.';

  @override
  String get documentsTicket => 'Ticket';

  @override
  String get documentsTickets => 'Tickets';

  @override
  String get documentsTicketsPlaceholder => 'AMANAT-12, AMANAT-15';

  @override
  String get documentsByFilter => 'By state and period';

  @override
  String get documentsChosen => 'Chosen tickets';

  @override
  String get documentsStates => 'States';

  @override
  String get documentsStatesHelp => 'None ticked: every state. The period limits by last update.';

  @override
  String get documentsRepos => 'Repositories';

  @override
  String get documentsRepo => 'Repository';

  @override
  String get documentsChooseRepo => 'Choose a repository';

  @override
  String get documentsBranch => 'Branch';

  @override
  String get documentsBranchPlaceholder => 'The default branch';

  @override
  String get documentsAuthor => 'Author';

  @override
  String get documentsAuthorPlaceholder => 'Everyone';

  @override
  String get documentsPrState => 'Pull requests';

  @override
  String get documentsPr_merged => 'Merged';

  @override
  String get documentsPr_open => 'Open';

  @override
  String get documentsPr_all => 'All';

  @override
  String get documentsPrNumbers => 'Numbers';

  @override
  String get documentsPrNumbersHelp => 'Optional, in one repository. Empty: by state and period.';

  @override
  String get documentsFrom => 'From';

  @override
  String get documentsTo => 'To';

  @override
  String get documentsTemplate => 'Format';

  @override
  String get documentsTemplate_status => 'Status report';

  @override
  String get documentsTemplate_release_notes => 'Release notes';

  @override
  String get documentsTemplate_pr_review => 'Pull request review';

  @override
  String get documentsTemplate_repo_review => 'Repository review';

  @override
  String get documentsTemplate_ticket_summary => 'Summary';

  @override
  String get documentsTemplate_blank => 'Your instruction only';

  @override
  String get documentsTemplateHint_status => 'Done, in progress, blocked, risks, next steps';

  @override
  String get documentsTemplateHint_release_notes => 'New, improved, fixed, internal';

  @override
  String get documentsTemplateHint_pr_review => 'Each change, its risk, what to look at';

  @override
  String get documentsTemplateHint_repo_review => 'Architecture, quality, tests, debt, recommendations';

  @override
  String get documentsTemplateHint_ticket_summary => 'Goal, findings, changes, open questions';

  @override
  String get documentsTemplateHint_blank => 'The shape your instruction asks for';

  @override
  String get documentsInstruction => 'Instruction';

  @override
  String get documentsInstructionPlaceholder => 'For the client, no technical detail. Focus on risks.';

  @override
  String get documentsGenerate => 'Ask agnts to write it';

  @override
  String get documentsCreate => 'Create and edit';

  @override
  String get documentsBack => 'Documents';

  @override
  String get documentsNotFound => 'This document does not exist, or you cannot open it.';

  @override
  String get documentsEditing => 'Editing';

  @override
  String documentsVersionN(String n) {
    return 'Version $n';
  }

  @override
  String documentsOwnedBy(String name) {
    return 'Owner: $name';
  }

  @override
  String documentsDataAsOf(String when) {
    return 'Based on data up to $when';
  }

  @override
  String get documentsEdit => 'Edit';

  @override
  String get documentsRegenerate => 'Write again';

  @override
  String get documentsRegenerateSub => 'agnts writes it again from the same source. The result is a new version; nothing is lost.';

  @override
  String get documentsShare => 'Share';

  @override
  String get documentsDelete => 'Delete';

  @override
  String documentsDeleteConfirm(String title) {
    return 'Move “$title” to the trash? It can be restored for 30 days.';
  }

  @override
  String get documentsDeleted => 'Moved to the trash';

  @override
  String get documentsQueued => 'Waiting for agnts to start writing…';

  @override
  String get documentsWritingNow => 'agnts is writing this document. It appears here when it is done.';

  @override
  String get documentsGenFailedTitle => 'agnts could not write it:';

  @override
  String get documentsTryAgain => 'Try again';

  @override
  String documentsOverwrote(String name, String when) {
    return 'agnts wrote a new version over edits by $name from $when.';
  }

  @override
  String documentsRestoreVersion(String n) {
    return 'Restore version $n';
  }

  @override
  String get documentsMarkdown => 'Markdown';

  @override
  String get documentsPreview => 'Preview';

  @override
  String get documentsConflictTitle => 'Someone saved in between.';

  @override
  String documentsConflictHelp(String n) {
    return 'The document is at version $n now. Keep your text on top of it, or start again from theirs.';
  }

  @override
  String get documentsTheirText => 'Their text';

  @override
  String get documentsKeepMine => 'Keep mine';

  @override
  String get documentsTakeTheirs => 'Use theirs';

  @override
  String get documentsSave => 'Save';

  @override
  String get documentsSaved => 'Saved as a new version';

  @override
  String get documentsLeaveUnsaved => 'Leave without saving your edits?';

  @override
  String get documentsEmptyBody => 'Nothing written yet.';

  @override
  String get documentsPublicLink => 'Public link';

  @override
  String get documentsDownloadMd => 'Markdown';

  @override
  String get documentsDownloadPdf => 'PDF';

  @override
  String get documentsPreparingPdf => 'Preparing PDF…';

  @override
  String get documentsPdfFailed => 'The PDF could not be made. Try again in a few minutes, or download Markdown.';

  @override
  String get documentsPdfSlow => 'The PDF is taking long. Try again in a minute.';

  @override
  String get documentsLinkedTickets => 'Tickets';

  @override
  String get documentsLinkedTicketsSub => 'Tickets this document is about';

  @override
  String get documentsNoTickets => 'Not linked to any ticket.';

  @override
  String get documentsLinkedByAgnts => 'linked by agnts';

  @override
  String get documentsLinkedByAgntsHint => 'agnts linked the tickets the document was made from';

  @override
  String get documentsUnlink => 'Unlink';

  @override
  String get documentsLinkTicket => 'Link';

  @override
  String get documentsLinkPlaceholder => 'Ticket number';

  @override
  String get documentsBadKey => 'That is not a ticket number.';

  @override
  String get documentsVersions => 'Versions';

  @override
  String get documentsNoVersions => 'No versions yet.';

  @override
  String get documentsCurrent => 'current';

  @override
  String documentsByAgntsFor(String name) {
    return 'agnts, for $name';
  }

  @override
  String documentsRestoredBy(String name) {
    return '$name restored it';
  }

  @override
  String documentsVersionTitle(String n) {
    return 'Version $n';
  }

  @override
  String get documentsIsCurrent => 'This is the current version.';

  @override
  String documentsDiffHelp(String n) {
    return 'What changed from version $n to the current text: removed lines are struck through, added ones green.';
  }

  @override
  String get documentsSameText => 'The text is the same as now.';

  @override
  String get documentsShareTitle => 'Share';

  @override
  String get documentsType => 'Who can read it';

  @override
  String get documentsPrivateHelp => 'Only you, the people below and the workspace owner.';

  @override
  String get documentsPublicHelp => 'Anyone with the link can read and download it, without signing in. It shows no names or tickets.';

  @override
  String get documentsPublicOff => 'Public documents are turned off in this workspace’s Settings.';

  @override
  String get documentsSecretsTitle => 'This text looks like it holds secrets.';

  @override
  String get documentsSecretsHelp => 'Remove them from these lines, save, then make the document public.';

  @override
  String documentsLine(String n) {
    return 'Line $n';
  }

  @override
  String get documentsResetLink => 'Reset the link';

  @override
  String get documentsResetHelp => 'The old link stops working at once.';

  @override
  String get documentsWorkspaceAccess => 'Everyone in the workspace';

  @override
  String get documentsWorkspaceAccessHelp => 'At least this for every member. Viewers can only read.';

  @override
  String get documentsPeople => 'People';

  @override
  String get documentsAddPerson => 'Add a person';

  @override
  String get documentsRemove => 'Remove';

  @override
  String get documentsOwnerNote => 'The workspace owner can always open this document.';

  @override
  String get documentsSaveSharing => 'Save';

  @override
  String get documentsTransfer => 'Give to another member';

  @override
  String get documentsTransferTo => 'New owner';

  @override
  String documentsTransferConfirm(String name) {
    return 'Make $name the owner? You keep edit access.';
  }

  @override
  String get documentsTicketTitle => 'Documents';

  @override
  String get documentsTicketSub => 'Documents about this ticket that you can open';

  @override
  String get documentsTicketEmpty => 'No documents yet.';

  @override
  String get documentsFromReport => 'Make a document from the report';

  @override
  String get documentsPublicGoneTitle => 'This link does not work';

  @override
  String get documentsPublicGone => 'The document was made private or deleted, or its link was changed.';

  @override
  String documentsPublicUpdated(String when) {
    return 'Updated $when';
  }

  @override
  String get documentsSettingLabel => 'Public documents';

  @override
  String get documentsSettingHelp =>
      'Let document owners share a public link that anyone can open. Off: every public link of this workspace stops working at once.';

  @override
  String documentsNewForTicket(String number) {
    return 'Linked to $number. Write it yourself, or have agnts write it.';
  }

  @override
  String get documentsDocKind => 'Kind';

  @override
  String get documentsDocKind_page => 'Page';

  @override
  String get documentsDocKind_slides => 'Slides';

  @override
  String get documentsDocKindHelp_page => 'A document to read: detailed, for the team.';

  @override
  String get documentsDocKindHelp_slides => 'A deck to present: short, for clients and people outside the team.';

  @override
  String get documentsKindFilter_all => 'Pages and slides';

  @override
  String get documentsKindFilter_page => 'Pages';

  @override
  String get documentsKindFilter_slides => 'Slides';

  @override
  String get documentsKind_document => 'A document';

  @override
  String get documentsKindHelp_document =>
      'A page of this workspace, retold as slides. The slides are a separate document with their own sharing.';

  @override
  String get documentsSourceDocument => 'Document';

  @override
  String get documentsChooseDocument => 'Choose a document';

  @override
  String get documentsTemplate_presentation => 'Presentation';

  @override
  String get documentsTemplateHint_presentation => 'Key points, what they mean, next steps';

  @override
  String get documentsMakeSlides => 'Make slides';

  @override
  String documentsSlidesOf(String title) {
    return '$title — slides';
  }

  @override
  String get documentsSlidesSub => 'agnts retells this document as slides, in a new document you share on its own.';

  @override
  String get documentsMadeFrom => 'Made from';

  @override
  String documentsSourceChanged(String n) {
    return 'The document has changed since (now version $n).';
  }

  @override
  String get documentsDecksTitle => 'Slides made from this document';

  @override
  String get documentsSlidesHelp =>
      'A line with only --- starts a new slide. A line starting with Notes: begins the speaker notes of its slide.';

  @override
  String get documentsNoSlides => 'No slides yet. Separate slides with a line of ---.';

  @override
  String get documentsPresent => 'Present';

  @override
  String documentsPresentFrom(String n) {
    return 'Present from slide $n';
  }

  @override
  String get documentsStopPresenting => 'Stop presenting';

  @override
  String get documentsPrevSlide => 'Previous slide';

  @override
  String get documentsNextSlide => 'Next slide';

  @override
  String get documentsNotes => 'Notes';

  @override
  String get documentsNoNotes => 'No notes for this slide.';

  @override
  String get documentsStarterSubtitle => 'What it is about, and when';

  @override
  String get documentsStarterPoint => 'The first point';

  @override
  String get documentsComments => 'Comments';

  @override
  String get documentsAddComment => 'Comment';

  @override
  String get documentsCommentPlaceholder => 'Add a comment…';

  @override
  String get documentsReplyPlaceholder => 'Reply…';

  @override
  String get documentsPost => 'Comment';

  @override
  String get documentsNoComments => 'No comments yet.';

  @override
  String get documentsNoCommentsHint => 'Select text to comment on it.';

  @override
  String get documentsGuestsCanRead => 'This document is public: guests with the link read comments.';

  @override
  String documentsSlideN(String n) {
    return 'Slide $n';
  }

  @override
  String get documentsTextChanged => 'The text it was on has changed.';

  @override
  String get documentsEdited => 'edited';

  @override
  String get documentsResolve => 'Resolve';

  @override
  String get documentsResolveHelp => 'Mark as done: the thread is folded away';

  @override
  String get documentsReopen => 'Reopen';

  @override
  String documentsResolvedN(String n) {
    return 'Resolved ($n)';
  }

  @override
  String documentsResolvedBy(String name) {
    return 'Resolved by $name';
  }

  @override
  String documentsRepliesN(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n replies', one: '$n reply');
    return '$_temp0';
  }

  @override
  String get documentsDeleteThreadConfirm => 'Delete this comment and its replies?';

  @override
  String get documentsDeleteCommentConfirm => 'Delete this reply?';

  @override
  String documentsViewingNow(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n viewing now', one: '$n viewing now');
    return '$_temp0';
  }

  @override
  String get documentsYou => 'you';

  @override
  String get documentsGuest => 'guest';

  @override
  String get documentsViaGoogle => 'guest via Google';

  @override
  String get documentsWhoAreYou => 'Who are you?';

  @override
  String get documentsWhoAreYouSub =>
      'Your name is shown to the people working on this document, next to your comments and while you have it open.';

  @override
  String get documentsYourName => 'Your name';

  @override
  String get documentsYourNamePlaceholder => 'Name and company';

  @override
  String get documentsEnter => 'Enter';

  @override
  String get documentsOrGoogle => 'Or, if you prefer, show who you are with Google:';

  @override
  String get documentsViaAccount => 'signed in';

  @override
  String get documentsTranslate => 'Translate';

  @override
  String get documentsTranslateOriginal => 'Original language';

  @override
  String get documentsTranslating => 'Translating… the first time takes up to a minute for a long document; after that it is saved.';

  @override
  String documentsTranslateFailed(String error) {
    return 'Could not translate: $error';
  }

  @override
  String get documentsTranslatedNoComments => 'You are reading a translation. Switch to the original to comment.';

  @override
  String get documentsShowOriginal => 'Show original';

  @override
  String get documentsTranslatedIncomplete => 'Some parts are still in the original language.';

  @override
  String get draftsTitle => 'Review comments';

  @override
  String draftsSub(String host) {
    return 'agnts\'s comments stay here until you accept them. Only accepted ones are published on $host, together as one review; the rest never leave agnts.';
  }

  @override
  String get draftsLockedSub => 'The review is over or the pull request is closed: these comments can only be read.';

  @override
  String get draftsChip => 'Draft';

  @override
  String get draftsSummary => 'Summary';

  @override
  String get draftsSomeone => 'Someone';

  @override
  String get draftsEdited => 'edited';

  @override
  String get draftsState_draft => 'Draft';

  @override
  String get draftsState_accepted => 'Accepted';

  @override
  String get draftsState_publishing => 'Publishing';

  @override
  String get draftsState_dismissed => 'Dismissed';

  @override
  String get draftsState_published => 'Published';

  @override
  String get draftsState_outdated => 'Outdated';

  @override
  String get draftsKind_summary => 'summary';

  @override
  String get draftsKind_finding => 'finding';

  @override
  String get draftsKind_comment => 'comment';

  @override
  String get draftsAccept => 'Accept';

  @override
  String get draftsUndo => 'Undo';

  @override
  String get draftsDismiss => 'Dismiss';

  @override
  String get draftsReopen => 'Back to draft';

  @override
  String get draftsReasonLabel => 'Why? (optional: agnts learns what you call noise)';

  @override
  String get draftsReasonHint => 'e.g. we never bound caches in this service';

  @override
  String draftsDismissedBecause(String reason) {
    return 'Dismissed: $reason';
  }

  @override
  String get draftsOutdatedHint => 'agnts\'s newest review no longer finds this.';

  @override
  String draftsFailed(String error) {
    return 'Publishing failed: $error';
  }

  @override
  String get draftsDeleteTitle => 'Delete your comment?';

  @override
  String get draftsDeleteConfirm => 'It was never published; it is deleted from agnts.';

  @override
  String draftsNAccepted(String n) {
    return '$n accepted';
  }

  @override
  String draftsNDraft(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n drafts', one: '$n draft');
    return '$_temp0';
  }

  @override
  String draftsNDismissed(String n) {
    return '$n dismissed';
  }

  @override
  String draftsNPublished(String n) {
    return '$n published';
  }

  @override
  String draftsNOutdated(String n) {
    return '$n outdated';
  }

  @override
  String get draftsAcceptMajor => 'Accept major and above';

  @override
  String get draftsAcceptAll => 'Accept all';

  @override
  String draftsPublishBtn(num n, String host) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'Publish $n', zero: 'Publish');
    return '$_temp0 to $host';
  }

  @override
  String draftsPublishTitle(String host) {
    return 'Publish to $host';
  }

  @override
  String draftsPublishSub(num n, String host) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'These $n comments go', one: 'This comment goes');
    return '$_temp0 on the pull request as one review, as the $host token\'s user. Comments not on a changed line go in the review\'s text.';
  }

  @override
  String draftsPublishedToast(num n, String host) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n comments published', one: '$n comment published');
    return '$_temp0 on $host';
  }

  @override
  String draftsHeadMoved(String from, String to, String host) {
    return 'New commits since agnts reviewed it ($from, now $to): the comments go on the version agnts reviewed, and $host may show them as outdated. To put them on the newest lines, review it again first.';
  }

  @override
  String draftsShowClosed(String n) {
    return 'Show dismissed, outdated and published ($n)';
  }

  @override
  String draftsDraftsN(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n drafts', one: '$n draft');
    return '$_temp0';
  }

  @override
  String get draftsNotOnDiff => 'agnts\'s comments not on a line shown here (another version, or outside the diff):';

  @override
  String get draftsAddToReview => 'Add to review';

  @override
  String get draftsAddedToast => 'Added to the review: it is published with the accepted comments';

  @override
  String get draftsOnDiff => 'See them on the diff';

  @override
  String get draftsReviewWithBtn => 'Review with agnts';

  @override
  String get draftsReviewAgainBtn => 'Review again with agnts';

  @override
  String draftsReviewTitle(String number) {
    return 'Review #$number with agnts';
  }

  @override
  String get draftsReviewSub =>
      'agnts reviews the pull request as it is now. Its comments stay drafts in agnts until you accept them; only accepted ones go on the pull request. Approving the review merges it only when it is assigned to you or asks for your review.';

  @override
  String get draftsReviewBtn => 'Start the review';

  @override
  String get draftsFocusLabel => 'Anything to look at especially? (optional)';

  @override
  String get draftsFocusHint => 'e.g. the migration and the retry logic';

  @override
  String get draftsDeepLabel => 'Deep review (security, failures, tests and types passes)';

  @override
  String get draftsDeep_default => 'Workspace setting';

  @override
  String get draftsDeep_always => 'On';

  @override
  String get draftsDeep_off => 'Off';

  @override
  String draftsStartedToast(String key) {
    return 'agnts is reviewing it in $key';
  }

  @override
  String draftsReviewingNow(String key) {
    return 'agnts is reviewing this pull request ($key). Its comments appear here as drafts when it is done.';
  }

  @override
  String get draftsFinishBtn => 'Finish review';

  @override
  String draftsFinishConfirm(String number) {
    return 'Finish the review of #$number? Comments not published stay in agnts. The pull request is left as it is: agnts does not merge it.';
  }

  @override
  String draftsReadySub(String host) {
    return 'Go through agnts\'s comments, publish the ones you agree with on $host, then finish the review. Or review again with a note, or dismiss it.';
  }

  @override
  String get draftsFinishedTitle => 'Review finished';

  @override
  String draftsFinishedSub(String number) {
    return 'The review of #$number is finished. The pull request was left as it is.';
  }

  @override
  String get feedbackTitle => 'Send feedback';

  @override
  String get feedbackLede => 'Tell the agnts team what works, what doesn’t, or what you’d like next.';

  @override
  String get feedbackTitleLabel => 'Title';

  @override
  String get feedbackTitlePlaceholder => 'In a few words';

  @override
  String get feedbackDescLabel => 'Description';

  @override
  String get feedbackDescPlaceholder => 'What happened, what you expected, or your idea';

  @override
  String get feedbackSend => 'Send';

  @override
  String get feedbackSent => 'Thanks! Your feedback was sent.';

  @override
  String get feedbackAdminTitle => 'Feedback';

  @override
  String get feedbackAdminLede =>
      'What people sent from their accounts, and connector requests from the website, newest first. Mark each one done once it’s handled.';

  @override
  String get feedbackF_new => 'New';

  @override
  String get feedbackF_done => 'Done';

  @override
  String get feedbackF_all => 'All';

  @override
  String get feedbackS_new => 'New';

  @override
  String get feedbackS_done => 'Done';

  @override
  String get feedbackSearch => 'Search feedback, people or workspaces';

  @override
  String get feedbackNone => 'No feedback here.';

  @override
  String get feedbackNoneNew => 'No new feedback. Nice!';

  @override
  String feedbackFrom(String workspace) {
    return 'from $workspace';
  }

  @override
  String get feedbackAccountGone => 'account deleted';

  @override
  String get feedbackMarkDone => 'Mark done';

  @override
  String get feedbackReopen => 'Reopen';

  @override
  String get feedbackMarkedDone => 'Marked done';

  @override
  String get feedbackReopened => 'Marked new again';

  @override
  String get feedbackKind => 'Kind';

  @override
  String get feedbackK_any => 'Everything';

  @override
  String get feedbackK_feedback => 'Feedback';

  @override
  String get feedbackK_connector => 'Connector requests';

  @override
  String get feedbackConnectorBadge => 'Connector request';

  @override
  String get feedbackFromSite => 'from the website';

  @override
  String get filesTitle => 'Attachments';

  @override
  String get filesAttach => 'Attach files';

  @override
  String get filesAddPhoto => 'Photo';

  @override
  String get filesCamera => 'Camera';

  @override
  String get filesAddFile => 'File';

  @override
  String get filesHint => 'Pictures, PDFs, logs or text, up to 10 MB each. Claude reads them all.';

  @override
  String filesUploading(String name) {
    return 'Uploading $name…';
  }

  @override
  String filesRemove(String name) {
    return 'Remove $name';
  }

  @override
  String filesOpen(String name) {
    return 'Open $name';
  }

  @override
  String filesTooLarge(String name) {
    return '$name is larger than 10 MB';
  }

  @override
  String filesTooMany(String n) {
    return 'Attach at most $n files';
  }

  @override
  String filesFailed(String name) {
    return 'Could not upload $name';
  }

  @override
  String get filesWait => 'Wait for the uploads to finish';

  @override
  String get filesFromTask => 'With the task';

  @override
  String get filesFromRetry => 'With a retry';

  @override
  String get filesFromFeedback => 'With requested changes';

  @override
  String get followUpsTitle => 'Follow-up tickets';

  @override
  String get followUpsSub =>
      'What finishing this ticket still needs, as agnts sees it. Pick the ones you want, then start them now or keep them held until you start each one.';

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
  String get followUpsAfter => 'After';

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
  String followUpsCreateStart(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Create and start $count tickets',
      one: 'Create and start $count ticket',
      zero: 'Create and start',
    );
    return '$_temp0';
  }

  @override
  String get followUpsCreateHeld => 'Create, held';

  @override
  String get followUpsQueuedHint =>
      'Started tickets go to the queue now; one that must wait for another starts coding after that one is merged. Held ones wait until you start them.';

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
  String followUpsStartedNotice(num count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count tickets created', one: '$count ticket created');
    return '$_temp0 and queued to run.';
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
  String get followUpsTargetPlane => 'Plane work item';

  @override
  String get followUpsPlaneOff => 'Connect Plane and link the repository to a Plane project to file work items there';

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
  String groupsView(String n) {
    return 'Groups ($n)';
  }

  @override
  String get groupsSub =>
      'Repositories that change together. A ticket made from a group works in all of them and opens a pull request in each one it changes.';

  @override
  String get groupsNone => 'No groups yet. A group lets one ticket change several repositories, such as an API and its web app.';

  @override
  String get groupsAdd => 'New group';

  @override
  String get groupsDrawerSub => 'Repositories that change together, in order: the first is the primary repository of the group\'s tickets.';

  @override
  String get groupsName => 'Name';

  @override
  String get groupsNamePh => 'Shop';

  @override
  String get groupsDescription => 'Description';

  @override
  String get groupsMembers => 'Repositories';

  @override
  String get groupsMembersHelp =>
      'Order matters: the first is the primary repository. A role tells agnts what each one is, such as backend or web.';

  @override
  String get groupsMembersNeeded => 'Add at least one repository.';

  @override
  String get groupsNoMembers => 'No repositories yet.';

  @override
  String get groupsAddMember => 'Add a repository…';

  @override
  String get groupsNoMoreRepos => 'Every active repository is in the group';

  @override
  String get groupsRolePh => 'Role, e.g. backend';

  @override
  String groupsRoleOf(String name) {
    return 'Role of $name';
  }

  @override
  String groupsMoveUp(String name) {
    return 'Move $name up';
  }

  @override
  String groupsMoveDown(String name) {
    return 'Move $name down';
  }

  @override
  String get groupsPrimary => 'primary';

  @override
  String get groupsArchived => 'archived';

  @override
  String groupsPrefixHelp(String prefix) {
    return 'Key prefix of tasks made from the group, as $prefix-12. Empty uses the first repository\'s.';
  }

  @override
  String groupsBranchTemplateHelp(String key, String number) {
    return 'Names the branches of this group\'s tickets in every repository, so they all get the same name. It replaces each repository\'s own format. Must contain $key or $number. Leave empty to keep each repository\'s own.';
  }

  @override
  String get groupsCommitTemplateHelp =>
      'Writes the commit messages of this group\'s tickets in every repository, replacing each repository\'s own format. Leave empty to keep each repository\'s own.';

  @override
  String get groupsInstructions => 'Instructions';

  @override
  String get groupsInstructionsPh => 'The web app calls the API through src/api; change both together and keep the OpenAPI spec in sync.';

  @override
  String get groupsInstructionsHelp => 'How the repositories fit together, in Markdown. Added to every prompt of the group\'s tickets.';

  @override
  String get groupsWarningsTitle => 'Saved, with warnings:';

  @override
  String groupsWarningsBadge(num count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count warnings', one: '$count warning');
    return '$_temp0';
  }

  @override
  String groupsSaved(String name) {
    return 'Group $name saved';
  }

  @override
  String get groupsDelete => 'Delete';

  @override
  String groupsDeleteConfirm(String name) {
    return 'Delete the group $name? Its tickets keep their repositories.';
  }

  @override
  String groupsDeleted(String name) {
    return 'Group $name deleted';
  }

  @override
  String get groupsColGroup => 'Group';

  @override
  String get groupsColMembers => 'Repositories';

  @override
  String get groupsColPrefix => 'Prefix';

  @override
  String groupsInGroups(String names) {
    return 'In $names';
  }

  @override
  String get groupsInLabel => 'Groups:';

  @override
  String get groupsPickerGroups => 'Repository groups';

  @override
  String get groupsChosen => 'Chosen repositories';

  @override
  String groupsFromGroup(String name) {
    return 'From group $name';
  }

  @override
  String get groupsMakePrimary => 'Make it the primary repository';

  @override
  String groupsMore(String count) {
    return '+$count';
  }

  @override
  String get groupsAllGroups => 'All groups';

  @override
  String get groupsFilterLabel => 'Group';

  @override
  String get groupsKvRepos => 'Repositories';

  @override
  String get groupsKvGroup => 'Group';

  @override
  String groupsTicketRepos(num count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count repositories', one: '$count repository');
    return '$_temp0';
  }

  @override
  String get groupsPartlyMerged => 'Partly merged';

  @override
  String groupsPr(String number) {
    return 'PR #$number';
  }

  @override
  String groupsOpenPrIn(String repo, String number) {
    return 'Open $repo #$number';
  }

  @override
  String groupsFiles(num count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count files', one: '$count file');
    return '$_temp0';
  }

  @override
  String groupsFilesIn(String repo, num count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count files', one: '$count file');
    return '$repo · $_temp0';
  }

  @override
  String groupsPushError(String error) {
    return 'Push failed: $error';
  }

  @override
  String groupsRetryHint(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'A retry pushes the $count repositories that failed; the others stay as they are.',
      one: 'A retry pushes the $count repository that failed; the others stay as they are.',
    );
    return '$_temp0';
  }

  @override
  String get groupsState_pending => 'Not pushed';

  @override
  String get groupsState_unchanged => 'Unchanged';

  @override
  String get groupsState_pushed => 'Pushed';

  @override
  String get groupsState_merged => 'Merged';

  @override
  String get groupsState_dropped => 'Closed';

  @override
  String get groupsMaxTicketRepos => 'Maximum repositories per ticket';

  @override
  String get groupsMaxTicketReposHelp => 'How many repositories one ticket, and one repository group, may have.';

  @override
  String get harnessRepoTab => 'Guardrails';

  @override
  String get harnessRepoTitle => 'Guardrails';

  @override
  String get harnessRepoSub => 'How strictly agnts-guard checks Claude\'s work in this repository, while it works and after.';

  @override
  String get harnessRepoSave => 'Save guardrails';

  @override
  String get harnessRepoSaved => 'Guardrails saved';

  @override
  String get harnessRepoAgentTitle => 'Agent instruction files';

  @override
  String get harnessRepoAgentSub =>
      'agnts scans CLAUDE.md, AGENTS.md, .claude/ and .mcp.json for text that tries to steer an agent. It never runs this repository\'s hooks or MCP servers.';

  @override
  String harnessRepoAgentScanned(String time) {
    return 'Scanned $time';
  }

  @override
  String get harnessRepoAgentNotScanned => 'Not scanned yet: the next run in this repository scans the files.';

  @override
  String get harnessRepoAgentNothing => 'Nothing found.';

  @override
  String harnessRepoAgentWarn(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n lines', one: '$n line');
    return '$_temp0 may try to steer an agent. Runs treat these files as data, never as instructions; read them before you trust them.';
  }

  @override
  String get harnessRepoAgentInfo => 'Configuration agnts ignores';

  @override
  String get harnessRepoKind_hidden_unicode => 'Hidden characters';

  @override
  String get harnessRepoKind_agent_instruction => 'Instruction to an agent';

  @override
  String get harnessRepoKind_exfiltration => 'Sends data out';

  @override
  String get harnessRepoKind_encoded_blob => 'Encoded text';

  @override
  String get harnessRepoKind_hooks => 'Claude Code hooks';

  @override
  String get harnessRepoKind_mcp_server => 'MCP servers';

  @override
  String get harnessRepoProfile => 'Guard profile';

  @override
  String get harnessRepoProfileHelp => 'How strict the in-run checks are for this repository.';

  @override
  String get harnessRepoProfile_ => 'Workspace';

  @override
  String get harnessRepoProfile_minimal => 'Minimal';

  @override
  String get harnessRepoProfile_standard => 'Standard';

  @override
  String get harnessRepoProfile_strict => 'Strict';

  @override
  String get harnessRepoProfileHelp_ => 'Follows the workspace setting.';

  @override
  String get harnessRepoProfileHelp_minimal => 'Only secrets and enforced rules are blocked; build checked before Claude finishes.';

  @override
  String get harnessRepoProfileHelp_standard =>
      'Also blocks skipped tests, silenced linters and edits to check configuration; build and lint must pass before Claude finishes.';

  @override
  String get harnessRepoProfileHelp_strict =>
      'Also blocks swallowed errors and removed assertions, runs the tests before Claude finishes, and may ask for facts before editing a file.';

  @override
  String get harnessRepoSecretAllow => 'Example credentials allowed in';

  @override
  String get harnessRepoSecretAllowHelp => 'Path globs where fake keys are expected, besides testdata/, fixtures/ and *.example.';

  @override
  String get harnessRepoChecksTitle => 'Per-file checks';

  @override
  String get harnessRepoChecksSub =>
      'Quick formatters and linters agnts-guard runs on each file Claude edits, so problems are fixed while the change is fresh.';

  @override
  String get harnessRepoChecksOff => 'Turn per-file checks off';

  @override
  String get harnessRepoChecksOffHelp => 'Claude is not checked after each edit; the checks after the run still apply.';

  @override
  String get harnessRepoOwnChecks => 'Use my own checks';

  @override
  String get harnessRepoOwnChecksHelp => 'Replace the checks agnts derives from the toolchains with your list.';

  @override
  String get harnessRepoDerivedTitle => 'Derived from the toolchains';

  @override
  String get harnessRepoDerivedNone => 'agnts knows no per-file checks for this repository\'s toolchains.';

  @override
  String get harnessRepoCheckName => 'Name';

  @override
  String get harnessRepoCheckGlobs => 'Files (globs, comma-separated)';

  @override
  String get harnessRepoCheckCmd => 'Command';

  @override
  String harnessRepoCheckCmdHelp(String file, String dir) {
    return '\'$file\' is the edited file and \'$dir\' its directory, both relative to the repository.';
  }

  @override
  String get harnessRepoCheckEvery => 'At most every (seconds)';

  @override
  String get harnessRepoAddCheck => 'Add a check';

  @override
  String harnessRepoRemoveCheck(String name) {
    return 'Remove $name';
  }

  @override
  String get harnessRepoCoverageTitle => 'Coverage of changed lines';

  @override
  String get harnessRepoCoverageSub =>
      'After the checks pass, agnts runs the tests once more with coverage and shows which added lines no test ran.';

  @override
  String get harnessRepoCoverage => 'Measure coverage';

  @override
  String get harnessRepoCoverageHelp => 'An extra test run after the checks; it never fails the run.';

  @override
  String get harnessRepoThreshold => 'Threshold';

  @override
  String get harnessRepoThresholdHelp => 'Below it, the code review gets a coverage finding. 0 turns the finding off.';

  @override
  String get harnessRepoCoverageCmd => 'Coverage command';

  @override
  String get harnessRepoCoverageCmdHelp => 'Leave empty to use the command agnts derives.';

  @override
  String get harnessRepoCoverageReport => 'Report file';

  @override
  String get harnessRepoCoverageReportHelp => 'A Go cover profile or lcov file, in the repository or under /agnts/out/.';

  @override
  String get harnessRepoCoverageNoDerived => 'agnts knows no coverage command for these toolchains: set one.';

  @override
  String get harnessRepoAcceptance => 'Check acceptance in the app';

  @override
  String get harnessRepoAcceptanceHelp =>
      'After the preview, agnts checks the ticket\'s acceptance criteria in the running app and shows the results with screenshots.';

  @override
  String get harnessRepoAcceptanceNoPreview => 'Needs a preview command: set one when you edit the repository.';

  @override
  String get harnessRepoStarterTitle => 'Starter rules';

  @override
  String get harnessRepoStarterSub =>
      'Specific, checkable conventions for this repository\'s languages. They are added as suggestions: nothing applies until you adopt them.';

  @override
  String get harnessRepoStarterNone => 'No starter pack fits this repository\'s toolchains.';

  @override
  String harnessRepoStarterRules(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n rules', one: '$n rule');
    return '$_temp0';
  }

  @override
  String harnessRepoStarterOffer(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n rules', one: '$n rule');
    return 'Suggest $_temp0';
  }

  @override
  String get harnessRepoStarterOffered => 'Already suggested';

  @override
  String harnessRepoStarterAdded(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n rules suggested',
      one: '$n rule suggested',
      zero: 'Nothing new to suggest',
    );
    return '$_temp0';
  }

  @override
  String get harnessRepoStarterOpenRules => 'Open the suggestions';

  @override
  String get harnessRepoLayersBlock => 'Block imports across layers';

  @override
  String get harnessRepoLayersBlockHelp =>
      'With an approved architecture, agnts flags a change that adds an import its layers do not allow. On, the flag is a blocker that agnts\'s own review sends back to the coder before you see the change.';

  @override
  String get harnessRulesDelivery => 'How runs get it';

  @override
  String get harnessRulesDelivery_prompt => 'Every prompt';

  @override
  String get harnessRulesDelivery_skill => 'Skill';

  @override
  String get harnessRulesDeliveryHelp_prompt => 'In every prompt, always in view.';

  @override
  String get harnessRulesDeliveryHelp_skill =>
      'A skill Claude loads when its description matches the work: keeps prompts short as rules grow. Keep critical rules in every prompt.';

  @override
  String get harnessRulesEnforce => 'Enforce';

  @override
  String get harnessRulesEnforceHelp => 'agnts-guard checks the rule while Claude works, not only asks for it.';

  @override
  String get harnessRulesOn => 'Check';

  @override
  String get harnessRulesOn_file => 'File edits';

  @override
  String get harnessRulesOn_bash => 'Commands';

  @override
  String get harnessRulesOn_diff => 'Finished change';

  @override
  String get harnessRulesOnHelp_file => 'Edits of the files below; with a pattern, only added lines that match it.';

  @override
  String get harnessRulesOnHelp_bash => 'Shell commands Claude runs that match the pattern.';

  @override
  String get harnessRulesOnHelp_diff => 'The finished change, checked on the server after the run.';

  @override
  String get harnessRulesPaths => 'Files (globs)';

  @override
  String get harnessRulesPathsPlaceholder => 'server/migrations/*.sql';

  @override
  String get harnessRulesPattern => 'Pattern (RE2 regular expression)';

  @override
  String get harnessRulesAction => 'When it matches';

  @override
  String get harnessRulesAction_block => 'Block';

  @override
  String get harnessRulesAction_warn => 'Warn';

  @override
  String get harnessRulesMessage => 'Message to Claude';

  @override
  String get harnessRulesMessagePlaceholder => 'Add a new migration instead.';

  @override
  String get harnessRulesTry => 'Try on history';

  @override
  String get harnessRulesTrying => 'Checking…';

  @override
  String harnessRulesTryChecked(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n changes', one: '$n change');
    return 'Checked $_temp0 agnts made.';
  }

  @override
  String get harnessRulesTryNone => 'It would not have matched any of them.';

  @override
  String harnessRulesTryHits(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n tickets', one: '$n ticket');
    return 'It would have matched $_temp0:';
  }

  @override
  String get harnessRulesBadgeBlock => 'Enforced: blocks';

  @override
  String get harnessRulesBadgeWarn => 'Enforced: warns';

  @override
  String get harnessRulesBadgeSkill => 'Skill';

  @override
  String get harnessRulesBadgeTip => 'Tip';

  @override
  String get harnessRulesSource_reflect => 'From feedback';

  @override
  String get harnessRulesSource_run => 'From a run';

  @override
  String get harnessRulesSource_promoted => 'Seen in several repositories';

  @override
  String harnessRulesSourceStarter(String name) {
    return 'Starter: $name';
  }

  @override
  String harnessRulesConfidence(String n) {
    return 'Confidence $n%';
  }

  @override
  String harnessRulesSeen(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n times', one: '$n time');
    return 'Seen $_temp0';
  }

  @override
  String harnessRulesWatching(String n) {
    return 'Watching ($n)';
  }

  @override
  String get harnessRulesWatchingHelp =>
      'Lessons agnts noticed once or twice. They become suggestions when it sees them again; until then they reach no ticket.';

  @override
  String get harnessSettingsTitle => 'Guardrails';

  @override
  String get harnessSettingsSub =>
      'agnts-guard checks Claude\'s work inside every run, while it happens; agnts\'s checks after the run still apply.';

  @override
  String get harnessSettingsProfile => 'Guard profile';

  @override
  String get harnessSettingsProfile_minimal => 'Minimal';

  @override
  String get harnessSettingsProfile_standard => 'Standard';

  @override
  String get harnessSettingsProfile_strict => 'Strict';

  @override
  String get harnessSettingsProfileHelp_minimal =>
      'Blocks secrets and dotenv files, enforces team rules with a pattern, and asks for a green build before Claude finishes.';

  @override
  String get harnessSettingsProfileHelp_standard =>
      'Minimal, plus: blocks skipped tests, silenced linters, deleted tests and check config changes; lint in the stop gate; quick checks of each edited file.';

  @override
  String get harnessSettingsProfileHelp_strict =>
      'Standard, plus: tests in the stop gate, blocks swallowed errors and removed assertions, and the fact check before first edits.';

  @override
  String get harnessSettingsFactCheck => 'Fact check share';

  @override
  String get harnessSettingsFactCheckHelp =>
      'Share of strict-profile tickets whose runs must say who uses a file before editing it, and how to undo destructive commands. Compare the groups on Analytics.';

  @override
  String get harnessSettingsStalls => 'When a run looks stuck';

  @override
  String get harnessSettingsStallsHelp =>
      'The same command failing again and again, no edits for many tool calls, or one file read over and over.';

  @override
  String get harnessSettingsStalls_off => 'Ignore';

  @override
  String get harnessSettingsStalls_log => 'Note it';

  @override
  String get harnessSettingsStalls_act => 'Step in';

  @override
  String get harnessSettingsProveFixes => 'Prove bug fixes';

  @override
  String get harnessSettingsProveFixesHelp =>
      'A bug fix needs a test that fails before the change and passes after it; agnts runs it both ways and shows the result.';

  @override
  String get harnessSettingsDeepReview => 'Deep review';

  @override
  String get harnessSettingsDeepReviewHelp =>
      'Specialist passes in the code review (security, silent failures, tests, types). Auto: large or complex work only; it costs more tokens.';

  @override
  String get harnessSettingsDeep_off => 'Off';

  @override
  String get harnessSettingsDeep_auto => 'Auto';

  @override
  String get harnessSettingsDeep_always => 'Always';

  @override
  String get harnessSettingsLearnFromRuns => 'Learn from runs';

  @override
  String get harnessSettingsLearnFromRunsHelp =>
      'After a run with failed checks or a stall, agnts may suggest a tip for the repository. Tips stay watched until seen again.';

  @override
  String get harnessSettingsMethodSkills => 'Method skills';

  @override
  String get harnessSettingsMethodSkillsHelp =>
      'Coding runs get agnts\'s method skills: add one more of something the way the repository already does it, follow the surrounding style, reuse before writing, and change a database schema safely. Claude loads one only when it fits; compare on Analytics.';

  @override
  String get harnessSettingsSecondOpinion => 'Second opinion';

  @override
  String get harnessSettingsSecondOpinionHelp =>
      'Another model reads the chosen approach of complex tickets and says whether it agrees. Empty turns it off.';

  @override
  String get harnessSettingsSecondOpinionHint => 'e.g. opus or codex:gpt-5-codex';

  @override
  String get harnessSettingsAdvanced => 'Advanced: guard hooks';

  @override
  String get harnessSettingsAdvancedHelp => 'Turn single hooks off; the profile still decides the rest.';

  @override
  String get harnessSettingsHook_pre_secret => 'refuse credentials and dotenv files';

  @override
  String get harnessSettingsHook_pre_redflags => 'refuse skipped tests, silenced linters, weakened checks';

  @override
  String get harnessSettingsHook_pre_rules => 'enforce team rules with a pattern';

  @override
  String get harnessSettingsHook_pre_fact_check => 'ask for facts before the first edit of a file';

  @override
  String get harnessSettingsHook_pre_destructive => 'ask for a rollback plan before destructive commands';

  @override
  String get harnessSettingsHook_post_edit_check => 'check each edited file (formatter, linter)';

  @override
  String get harnessSettingsHook_stop_gate => 'build and lint must pass before Claude finishes';

  @override
  String get harnessSettingsHook_session_progress => 'give the plan back after the context is compacted';

  @override
  String get harnessSettingsCodex => 'Coding on Codex';

  @override
  String get harnessSettingsCodexHelp =>
      'A Codex model name runs coding on Codex CLI instead of Claude; empty uses Claude. Needs the OpenAI integration and api.openai.com in the allowed hosts (Settings → Preview).';

  @override
  String get harnessSettingsCodexConnect => 'OpenAI integration';

  @override
  String get harnessSettingsQualityTitle => 'Guardrails by prompt version';

  @override
  String get harnessSettingsQualitySub => 'What agnts-guard and the harness checks did for the tickets of each prompt version.';

  @override
  String get harnessSettingsColBlocks => 'Blocked';

  @override
  String get harnessSettingsColBlocksHint => 'Actions agnts-guard refused in coding runs';

  @override
  String get harnessSettingsColStopSaves => 'Stop-gate saves';

  @override
  String get harnessSettingsColStopSavesHint =>
      'Tickets whose stop gate sent failing checks back, after which agnts\'s checks passed first time';

  @override
  String get harnessSettingsColStalls => 'Stalls';

  @override
  String get harnessSettingsColStallsHint => 'Times runs looked stuck';

  @override
  String get harnessSettingsColProven => 'Fixes proven';

  @override
  String get harnessSettingsColProvenHint => 'Bug fixes whose test failed before the change and passed after it, of those with a proof';

  @override
  String get harnessSettingsColAdopted => 'Findings adopted';

  @override
  String get harnessSettingsColAdoptedHint => 'Review findings people put into their feedback';

  @override
  String get harnessSettingsColTokens => 'Tokens per done';

  @override
  String get harnessSettingsColTokensHint => 'Average tokens of a done ticket, all stages';

  @override
  String get harnessSettingsColFactCheck => 'Fact check first try';

  @override
  String get harnessSettingsColFactCheckHint => 'First-try rate of tickets in the fact check group, next to the rate of all done tickets';

  @override
  String get harnessSettingsSkillsTitle => 'Method skills';

  @override
  String get harnessSettingsSkillsSub =>
      'Tickets whose coding runs had each method skill, replays included, next to the tickets that had none. Replay the same tickets with the setting off and on to compare.';

  @override
  String get harnessSettingsSkillNone => 'none (baseline)';

  @override
  String get harnessSettingsColSkill => 'Skill';

  @override
  String get harnessSettingsColSkillTickets => 'Tickets';

  @override
  String get harnessSettingsColSkillTicketsHint => 'Tickets with a coding run that had the skill';

  @override
  String get harnessSettingsColLoaded => 'Loaded';

  @override
  String get harnessSettingsColLoadedHint => 'Share of those tickets where Claude loaded the skill';

  @override
  String get harnessSettingsColSkillFirstTry => 'First try';

  @override
  String get harnessSettingsColSkillFirstTryHint => 'Done without a person asking for changes, of the done tickets';

  @override
  String get harnessSettingsColLoadedFirstTry => 'First try, loaded';

  @override
  String get harnessSettingsColLoadedFirstTryHint => 'First-try rate of the done tickets where Claude loaded the skill';

  @override
  String get harnessSettingsColTargeted => 'Targeted findings';

  @override
  String get harnessSettingsColTargetedHint =>
      'Review findings per ticket of the kinds the skills target: architecture, maintainability, and any on a migration file';

  @override
  String harnessSettingsXOfY(String x, String y) {
    return '$x of $y';
  }

  @override
  String harnessSettingsVsAll(String n) {
    return 'vs $n%';
  }

  @override
  String get harnessSettingsEffort => 'Thinking effort';

  @override
  String get harnessSettingsEffortHelp =>
      'How hard Claude thinks in each stage (Claude Code\'s --effort). Higher is slower and costs more of your plan. Complex tickets use their own level for coding and review.';

  @override
  String get harnessSettingsEffortAnalyze => 'Analysis';

  @override
  String get harnessSettingsEffortCoding => 'Coding';

  @override
  String get harnessSettingsEffortReview => 'Review';

  @override
  String get harnessSettingsEffortComplex => 'Complex tickets';

  @override
  String get harnessSettingsEffort_ => 'Default';

  @override
  String get harnessSettingsEffort_low => 'Low';

  @override
  String get harnessSettingsEffort_medium => 'Medium';

  @override
  String get harnessSettingsEffort_high => 'High';

  @override
  String get harnessSettingsRecheckComplex => 'Re-check complex analyses';

  @override
  String get harnessSettingsRecheckComplexHelp =>
      'When the analysis model rates a ticket complex, the coding model reads the analysis again before any code is written, and fixes what is wrong or missing.';

  @override
  String get harnessSettingsBaselineChecks => 'Check the starting commit first';

  @override
  String get harnessSettingsBaselineChecksHelp =>
      'Before a ticket\'s first coding run, agnts runs the checks on the commit the work starts from. What already fails there is not the ticket\'s: no fix attempts go to it, and the reviewer sees it failed before. Results are shared by tickets from the same commit.';

  @override
  String get harnessTicketFlag_secret => 'Possible secret';

  @override
  String get harnessTicketFlag_env_file => 'Dotenv file added';

  @override
  String get harnessTicketFlag_debug_leftover => 'Debug output left';

  @override
  String get harnessTicketFlag_check_config => 'Check configuration changed';

  @override
  String get harnessTicketFlag_rule_violation => 'Team rule broken';

  @override
  String get harnessTicketSecretsTitle => 'This change may contain a real credential';

  @override
  String harnessTicketSecretsBody(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n lines', one: '$n line');
    return 'agnts flagged $_temp0 as a possible secret or a dotenv file. Check them in the red flags on the Review tab: agnts does not push the change until you confirm they are not real credentials.';
  }

  @override
  String get harnessTicketSecretsConfirm => 'I checked them: not real credentials';

  @override
  String get harnessTicketSecretsDone => 'Confirmed: the flagged lines are not real credentials.';

  @override
  String get harnessTicketSecretsNeeded => 'First confirm that the lines flagged as secrets are not real credentials.';

  @override
  String get harnessTicketProofTitle => 'Proof of the fix';

  @override
  String get harnessTicketProof_proven => 'Proven';

  @override
  String get harnessTicketProof_not_reproduced => 'Not reproduced';

  @override
  String get harnessTicketProof_still_failing => 'Still failing';

  @override
  String get harnessTicketProof_inconclusive => 'Inconclusive';

  @override
  String get harnessTicketProof_no_test => 'No test';

  @override
  String get harnessTicketProof_error => 'Not checked';

  @override
  String get harnessTicketProofHelp_proven => 'The reproducing test fails on the code before the change and passes after it.';

  @override
  String get harnessTicketProofHelp_not_reproduced => 'The test passes before the change too, so it does not show the bug.';

  @override
  String get harnessTicketProofHelp_still_failing => 'The test still fails with the change.';

  @override
  String get harnessTicketProofHelp_inconclusive => 'The test could not run on the code before the change; it may need what the fix adds.';

  @override
  String get harnessTicketProofHelp_no_test => 'No automated test reproduces the bug.';

  @override
  String get harnessTicketProofHelp_error => 'agnts could not run the proof.';

  @override
  String harnessTicketProofBase(String sha) {
    return 'Started from $sha';
  }

  @override
  String harnessTicketProofBefore(String code) {
    return 'Before the change (exit $code)';
  }

  @override
  String harnessTicketProofAfter(String code) {
    return 'After the change (exit $code)';
  }

  @override
  String get harnessTicketCoverageTitle => 'Coverage of changed lines';

  @override
  String harnessTicketCoveragePct(String pct, String covered, String total) {
    return '$pct% of the changed lines ran in the tests ($covered of $total)';
  }

  @override
  String harnessTicketCoverageBelow(String n) {
    return 'Below the repository\'s $n%';
  }

  @override
  String get harnessTicketCoverageNone => 'No changed line is code the coverage report measures.';

  @override
  String harnessTicketCoverageLines(String ranges) {
    return 'Not run: lines $ranges';
  }

  @override
  String harnessTicketCoverageError(String error) {
    return 'Coverage could not be measured: $error';
  }

  @override
  String harnessTicketConfidence(String n) {
    return '$n% sure';
  }

  @override
  String get harnessTicketPass_security => 'Security pass';

  @override
  String get harnessTicketPass_failures => 'Failures pass';

  @override
  String get harnessTicketPass_tests => 'Tests pass';

  @override
  String get harnessTicketPass_types => 'Types pass';

  @override
  String get harnessTicketAdopted => 'In your feedback';

  @override
  String get harnessTicketDeep => 'Deep review';

  @override
  String harnessTicketDropped(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n findings', one: '$n finding');
    return '$_temp0 left out (low confidence or duplicates)';
  }

  @override
  String get harnessTicketDefect => 'Bug fix';

  @override
  String get harnessTicketAcceptanceTitle => 'Acceptance criteria';

  @override
  String get harnessTicketCheck_ui => 'In the app';

  @override
  String get harnessTicketCheck_api => 'API';

  @override
  String get harnessTicketCheck_test => 'Test';

  @override
  String get harnessTicketCheck_manual => 'By hand';

  @override
  String get harnessTicketSecondTitle => 'Second opinion';

  @override
  String harnessTicketSecondBy(String model) {
    return 'From $model';
  }

  @override
  String get harnessTicketSecondAgrees => 'Agrees';

  @override
  String get harnessTicketSecondConcerns => 'Has concerns';

  @override
  String get harnessTicketSecondAlternative => 'Would do instead';

  @override
  String harnessTicketSecondError(String error) {
    return 'No second opinion: $error';
  }

  @override
  String get harnessTicketAccTitle => 'Acceptance check';

  @override
  String get harnessTicketAcc_ok => 'All met';

  @override
  String get harnessTicketAcc_partial => 'Partly checked';

  @override
  String get harnessTicketAcc_failed => 'Not met';

  @override
  String get harnessTicketVerdict_pass => 'Met';

  @override
  String get harnessTicketVerdict_fail => 'Not met';

  @override
  String get harnessTicketVerdict_unknown => 'Not checked';

  @override
  String get harnessTicketAccSteps => 'Steps';

  @override
  String get harnessTicketAccShot => 'Screenshot';

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
  String get integrationsAssignedOnly => 'Only issues assigned to me';

  @override
  String integrationsAssignedOnlyHelp(String email) {
    return 'agnts takes a labelled issue only when it is assigned to the account it connects to Jira with ($email). Turn off to take every labelled issue.';
  }

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
      'Under Repository permissions set Contents and Pull requests to Read and write, and Workflows to Read and write if agnts may change CI files in .github/workflows. For the Pipelines tab also set Actions to Read (Read and write to use Deploy) and Deployments to Read. Metadata (read) is added automatically.';

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
  String get integrationsPermWorkflows =>
      'Read and write. Push changes to .github/workflows (CI files); without it such pushes are refused.';

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
  String get integrationsLabelsTitle => 'How to label tickets';

  @override
  String get integrationsLabelsSub => 'Add one of these labels to a Jira issue that isn\'t done. Case doesn\'t matter.';

  @override
  String get integrationsLabelsRepo =>
      'An issue goes to the repository linked to its project (Repositories → Jira project). To send it to another one, add a label repo: followed by the repository\'s name in agnts, such as repo:web. Without a repository, only plans, analyses and bug investigations can run.';

  @override
  String get integrationsLabelsMany => 'With several kind labels, the first in this list wins.';

  @override
  String get integrationsLabelsLater =>
      'Adding a kind label before work starts changes the ticket\'s kind. Removing every agnts label stops updates from Jira.';

  @override
  String get integrationsPlaneLabelsSub => 'Add one of these labels to an open work item. Case doesn\'t matter.';

  @override
  String get integrationsPlaneLabelsCreate => 'Plane labels belong to a project: create the ones you use in each linked project first.';

  @override
  String get integrationsPlaneLabelsRepo =>
      'Link the project to a repository by its identifier (WEB in WEB-123) under Repositories → Plane project. Sync reads only linked projects, and code and test work needs a repository. To send one work item to another repository, add a label repo: followed by the repository\'s name in agnts, such as repo:web.';

  @override
  String get integrationsPlaneLabelsLater =>
      'Adding a kind label before work starts changes the ticket\'s kind. Removing every agnts label stops updates from Plane.';

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
  String integrationsSynced(String found, String created, String updated, String waiting) {
    return '$found open issues for you, $created new, $updated updated, $waiting changed after agnts started';
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
  String get integrationsGitEvents_github => 'Pushes, Pull requests, Workflow runs';

  @override
  String get integrationsGitEvents_gitlab => 'Push events, Merge request events, Pipeline events';

  @override
  String get integrationsGitWebhookWhy =>
      'When a pull or merge request is merged, agnts marks the ticket merged and moves the Jira issue or Plane work item to the merged status set on its tracker\'s page. Pipeline events keep the repository page current. Pushes link commits whose branch or message has a ticket\'s number to that ticket.';

  @override
  String get integrationsName_plane => 'Plane';

  @override
  String get integrationsDesc_plane =>
      'Pick up work items with the agnts label from Plane Cloud or your own Plane, and keep their state up to date.';

  @override
  String get integrationsConnectSub_plane => 'Use a personal access token from Plane. Works with Plane Cloud and self-hosted Plane.';

  @override
  String get integrationsTokenOpen_plane => 'Open Plane API docs';

  @override
  String get integrationsTokenStep1_plane =>
      'In Plane, sign in as the person agnts should act as (comments appear under this name) and open Profile settings → Personal access tokens.';

  @override
  String get integrationsTokenStep2_plane =>
      'Click Add personal access token, name it (for example agnts), pick an expiry, then copy the token. Plane shows it only once.';

  @override
  String get integrationsTokenStep3_plane =>
      'For API address, keep https://api.plane.so for Plane Cloud, or enter your own Plane\'s address if it is self-hosted.';

  @override
  String get integrationsTokenStep4_plane => 'For Workspace, enter the slug from Plane\'s address: acme in app.plane.so/acme/projects.';

  @override
  String get integrationsPlaneBaseUrl => 'API address';

  @override
  String get integrationsPlaneBaseUrlHelp => 'https://api.plane.so for Plane Cloud, or your Plane\'s address';

  @override
  String get integrationsPlaneWorkspace => 'Workspace';

  @override
  String get integrationsPlaneWorkspaceHelp => 'The slug in Plane\'s address, such as acme';

  @override
  String get integrationsApiKey => 'API key';

  @override
  String get integrationsApiKeyHelp => 'Profile settings → Personal access tokens';

  @override
  String get integrationsPlaneWebhookTitle => 'Set up the Plane webhook';

  @override
  String get integrationsPlaneWebhookSteps =>
      'In Plane, open Workspace settings → Webhooks → Add webhook, enter the URL below and tick the work item (issue) events. Plane then shows a secret once: paste it here.';

  @override
  String get integrationsPlaneEventsValue => 'Work items (issues)';

  @override
  String get integrationsPlaneSecret => 'Secret from Plane';

  @override
  String get integrationsPlaneSecretHelp => 'Plane shows it once when you create the webhook';

  @override
  String get integrationsPlaneSecretSave => 'Save secret';

  @override
  String get integrationsPlaneSecretReplace => 'Replace secret';

  @override
  String get integrationsPlaneSecretSaved => 'Webhook secret saved: Plane deliveries are accepted now';

  @override
  String get integrationsPlaneSecretSet => 'Secret saved. Deliveries are accepted.';

  @override
  String get integrationsPlaneSecretMissing =>
      'No secret yet: agnts refuses deliveries until you paste the secret Plane showed, and only the hourly sync picks up work items.';

  @override
  String integrationsPlaneQueryText(String labels) {
    return 'Open work items in the Plane projects linked to repositories that carry one of these labels: $labels';
  }

  @override
  String get integrationsPlaneNoProjects =>
      'No repository is linked to a Plane project yet. Add the project identifier (WEB in WEB-123) on the repository.';

  @override
  String get integrationsPlaneStatusesSub =>
      'How agnts moves work items. Leave a status on Default to use the first state of the matching group; In review moves only to a state you pick.';

  @override
  String integrationsPlaneStateDefault(String group) {
    return 'Default: first $group state';
  }

  @override
  String get integrationsPlaneStateNone => 'Keep state';

  @override
  String integrationsPlaneStatesError(String error) {
    return 'Could not read the states from Plane: $error';
  }

  @override
  String get integrationsPlaneSyncHelp =>
      'Plane sends changes to the webhook right away; agnts also checks every hour in case a delivery was missed.';

  @override
  String get integrationsPlaneHelp =>
      'agnts reads only work items with its labels in linked projects, and writes only the state changes and comments you turn on here. Plane allows 60 API requests a minute per key; agnts stays under 50.';

  @override
  String integrationsPlaneSynced(String found, String created) {
    return '$found open work items, $created new';
  }

  @override
  String get integrationsName_openai => 'OpenAI';

  @override
  String get integrationsDesc_openai =>
      'An OpenAI API key for runs on Codex CLI, agnts\'s second coding tool. Pick a codex: model in Settings to use it.';

  @override
  String get integrationsConnectSub_openai =>
      'Paste an OpenAI API key. agnts checks it, keeps it encrypted, and gives it only to runs that use Codex.';

  @override
  String get integrationsTokenOpen_openai => 'Open API keys';

  @override
  String get integrationsTokenStep1_openai => 'Open the OpenAI platform\'s API keys page (button below) and sign in.';

  @override
  String get integrationsTokenStep2_openai => 'Create a new secret key, ideally in a project with a spending limit.';

  @override
  String get integrationsTokenStep3_openai => 'Copy the key (it starts with sk-) and paste it into API key below.';

  @override
  String get integrationsTokenStep4_openai =>
      'In Settings → Preview, add api.openai.com to the hosts runs may reach, so Codex runs can call OpenAI.';

  @override
  String get integrationsOpenaiKeyHelp => 'Stored encrypted on your server. Only runs on Codex receive it.';

  @override
  String get integrationsOpenaiHelp =>
      'Codex runs have no agnts-guard hooks: agnts\'s checks after the run (red flags, build, lint, tests, review) still apply. Runs also need api.openai.com in the allowed hosts.';

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
  String get kindReview => 'PR review';

  @override
  String get kindReviewHint => 'Review a pull request someone else opened. Comes from GitHub or GitLab.';

  @override
  String get kindSwaggertest => 'Swagger test';

  @override
  String get kindSwaggertestHint =>
      'Test an HTTP API against its Swagger/OpenAPI spec. Repository optional; ends in a results table and a report.';

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
  String get linkedCommitsTitle => 'Commits';

  @override
  String linkedCommitsSub(String number) {
    return 'Anyone\'s commits whose branch or message has $number, from pushes and the repositories\' recent history.';
  }

  @override
  String linkedCommitsNone(String number) {
    return 'No commits with $number yet. Push a branch or write a commit message with it, and the commits show here.';
  }

  @override
  String linkedCommitsTotal(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n commits', one: '$n commit');
    return '$_temp0';
  }

  @override
  String get linkedCommitsOnBranch => 'branch';

  @override
  String get linkedCommitsOnMessage => 'message';

  @override
  String get linkedCommitsOnBranchHint => 'The branch name has the number';

  @override
  String get linkedCommitsOnMessageHint => 'The commit message has the number';

  @override
  String linkedCommitsMeta(String author, String repo, String branch) {
    return '$author · $repo · $branch';
  }

  @override
  String linkedCommitsMore(String n) {
    return 'Show more ($n left)';
  }

  @override
  String get linkedCommitsLoadError => 'Could not load the commits.';

  @override
  String get linkedCommitsTickets => 'Tickets';

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
  String get maccountPasswordInstead => 'Sign in with a password';

  @override
  String get maccountGoogleInstead => 'Continue with Google instead';

  @override
  String get maccountSetupLede =>
      'Admins sign in with two factors. Add this account to an authenticator app with the secret below (or open the setup link on this phone), then enter the 6-digit code it shows.';

  @override
  String get maccountTotpOpen => 'Open in authenticator app';

  @override
  String get maccountLinkFailed => 'Couldn\'t open the link.';

  @override
  String get maccountCurrent => 'Current';

  @override
  String get maccountHaveInvite => 'Have an invite?';

  @override
  String get maccountInviteHint => 'Paste the invite link';

  @override
  String get maccountInviteOpen => 'Open invite';

  @override
  String maccountJoined(String date) {
    return 'Joined $date';
  }

  @override
  String get maccountPaying => 'Finish the payment in your browser. Credits show here once the payment provider confirms it.';

  @override
  String maccountChars(String n, String max) {
    return '$n / $max';
  }

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
  String get massistantTitle => 'Assistant';

  @override
  String get massistantFab => 'Ask the assistant';

  @override
  String get massistantMoreRow => 'Assistant';

  @override
  String get massistantMoreRowSub => 'Ask about your workspace';

  @override
  String get massistantPlaceholder => 'Ask about tickets, CI, spend…';

  @override
  String get massistantSend => 'Send';

  @override
  String massistantCount(String n) {
    return '$n / 1000';
  }

  @override
  String get massistantNewConversation => 'New conversation';

  @override
  String get massistantHistory => 'Conversations';

  @override
  String get massistantHistoryEmpty => 'No conversations yet.';

  @override
  String get massistantDelete => 'Delete';

  @override
  String get massistantDeleted => 'Conversation deleted';

  @override
  String get massistantEmptyTitle => 'Ask agnts about your work';

  @override
  String get massistantEmptyText =>
      'It answers from your tickets, CI and spend, and links what it mentions. Ask it to approve, start or create something and it offers the action for you to confirm.';

  @override
  String get massistantPrivate => 'Only you see your conversations. They are kept for 30 days.';

  @override
  String get massistantSuggestWaiting => 'What is waiting on me?';

  @override
  String get massistantSuggestCi => 'Why is CI red?';

  @override
  String get massistantSuggestSpend => 'How much did we spend this week?';

  @override
  String get massistantSuggestDone => 'What did agnts finish this week?';

  @override
  String massistantThinking(String seconds) {
    return 'Thinking… ${seconds}s';
  }

  @override
  String massistantReading(String what) {
    return 'Reading $what';
  }

  @override
  String get massistantFileInbox => 'your inbox';

  @override
  String get massistantFileTickets => 'the tickets';

  @override
  String massistantFileTicket(String key) {
    return '$key';
  }

  @override
  String get massistantFileCi => 'CI failures';

  @override
  String get massistantFileUsage => 'plan usage';

  @override
  String get massistantFileAnalytics => 'analytics';

  @override
  String get massistantFileRepos => 'repositories';

  @override
  String get massistantFileLessons => 'lessons';

  @override
  String get massistantFileConversation => 'the conversation';

  @override
  String get massistantFileQuestion => 'your question';

  @override
  String get massistantFileOther => 'the workspace';

  @override
  String get massistantFailed => 'No answer';

  @override
  String get massistantAskAgain => 'Ask again';

  @override
  String massistantLinkCi(String id) {
    return 'CI #$id';
  }

  @override
  String massistantLinkLesson(String id) {
    return 'Lesson #$id';
  }

  @override
  String massistantTook(String seconds) {
    return '${seconds}s';
  }

  @override
  String get massistantHelpful => 'Helpful';

  @override
  String get massistantNotHelpful => 'Not helpful';

  @override
  String get massistantRateTitle => 'How was this answer?';

  @override
  String get massistantRateComment => 'What was wrong or missing? (optional)';

  @override
  String get massistantRateShare => 'Keep this question\'s data so agnts can test better answers';

  @override
  String get massistantRateNote => 'Your rating, comment, question and answer are shown to the workspace owner.';

  @override
  String get massistantRateSend => 'Send';

  @override
  String get massistantRateClear => 'Remove rating';

  @override
  String get massistantRated => 'Thanks for the rating';

  @override
  String get massistantStatsTitle => 'Assistant';

  @override
  String get massistantStatsQuestions => 'Questions';

  @override
  String get massistantStatsAnswered => 'Answered';

  @override
  String get massistantStatsMedian => 'Median time';

  @override
  String get massistantStatsHelpful => 'Helpful';

  @override
  String get massistantStatsTokens => 'Tokens';

  @override
  String massistantStatsPeople(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n people asked', one: '$n person asked');
    return '$_temp0';
  }

  @override
  String get massistantStatsVersions => 'By prompt version';

  @override
  String massistantStatsVersionRow(String answered, String failed, String up, String down, String median) {
    return '$answered answered · $failed failed · $up 👍 $down 👎 · $median';
  }

  @override
  String get massistantStatsNone => 'No questions in this period.';

  @override
  String get massistantStatsRated => 'Rated answers';

  @override
  String get massistantRatedEmpty => 'No rated answers yet.';

  @override
  String get massistantRatedShared => 'Kept for prompt tests';

  @override
  String massistantStatsParts(String start, String snapshot, String claude) {
    return 'Container $start · workspace $snapshot · Claude $claude';
  }

  @override
  String massistantStatsWarm(String n, String total) {
    return '$n of $total reused a warm container';
  }

  @override
  String get massistantStatsSeeRated => 'Rated answers';

  @override
  String get massistantDeleteTitle => 'Delete this conversation?';

  @override
  String get massistantDeleteText => 'Its questions and answers are deleted for good.';

  @override
  String get massistantSendHint => 'Enter to send, Shift+Enter for a new line';

  @override
  String get massistantConversationsLede => 'Your questions and the assistant\'s answers. Only you see them; they are kept for 30 days.';

  @override
  String get massistantOpenChat => 'Open the chat';

  @override
  String get massistantSuggestAct => 'Approve what passed review';

  @override
  String get massistantFileMe => 'your role';

  @override
  String get massistantFileGroups => 'repository groups';

  @override
  String get massistantActionHint => 'Nothing happens until you confirm.';

  @override
  String get massistantActionConfirm => 'Confirm';

  @override
  String get massistantActionDecline => 'Decline';

  @override
  String get massistantActionRunning => 'Doing it…';

  @override
  String get massistantActionDone => 'Done';

  @override
  String get massistantActionFailed => 'Not done';

  @override
  String get massistantActionCancelled => 'Declined';

  @override
  String get massistantActionExpired => 'Expired. Ask again for a new one.';

  @override
  String get massistantActionConfirmTitle => 'Confirm this?';

  @override
  String massistantActionConfirmText(String summary) {
    return '$summary\n\nThis cannot be undone.';
  }

  @override
  String massistantActionNotOffered(String reason) {
    return 'Not offered: $reason';
  }

  @override
  String get massistantStatsActions => 'Actions confirmed';

  @override
  String massistantStatsActionsLine(String proposed, String done, String failed, String cancelled, String expired, String notOffered) {
    return '$proposed offered · $done done · $failed not done · $cancelled declined · $expired expired · $notOffered not offered';
  }

  @override
  String get massistantStatsActionsOffered => 'Offered';

  @override
  String massistantStatsVersionActions(String proposed, String done) {
    return '$proposed actions offered · $done done';
  }

  @override
  String get mciTitle => 'CI failures';

  @override
  String get mciLede => 'Watched branches that went red, one row per error.';

  @override
  String get mciFilterRed => 'Red';

  @override
  String get mciFilterFlaky => 'Flaky';

  @override
  String get mciFilterAll => 'All';

  @override
  String get mciEmptyRed => 'No watched branch is red.';

  @override
  String get mciEmpty => 'No CI failures here.';

  @override
  String get mciStatus_triage => 'Checking';

  @override
  String get mciStatus_open => 'Red';

  @override
  String get mciStatus_fixing => 'Fixing';

  @override
  String get mciStatus_fixed => 'Fixed';

  @override
  String get mciStatus_resolved => 'Green again';

  @override
  String get mciStatus_flaky => 'Flaky';

  @override
  String get mciStatus_infra => 'Infrastructure';

  @override
  String get mciStatus_muted => 'Muted';

  @override
  String get mciStatus_regression => 'Back again';

  @override
  String mciLastSeen(String when) {
    return 'last $when';
  }

  @override
  String get mciFactFirstCommit => 'First failing commit';

  @override
  String get mciFactCount => 'Failed';

  @override
  String mciTimes(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n times', one: '$n time');
    return '$_temp0';
  }

  @override
  String get mciFactLastSeen => 'Last seen';

  @override
  String get mciFactFlaky => 'Passed on re-run';

  @override
  String get mciJob => 'Job';

  @override
  String get mciBranch => 'Branch';

  @override
  String get mciFirstError => 'The first error';

  @override
  String get mciLogTail => 'The end of the log';

  @override
  String get mciLogNote => 'From the job\'s log, with secrets removed.';

  @override
  String get mciNoSample => 'No log excerpt was kept for this failure.';

  @override
  String get mciRuns => 'Failing runs';

  @override
  String mciRunsCount(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n failing runs', one: '$n failing run');
    return '$_temp0';
  }

  @override
  String get mciRunFlaky => 'passed on re-run';

  @override
  String get mciTicket => 'Ticket';

  @override
  String mciForeignPr(String n) {
    return 'This failure is on someone else\'s pull request (#$n): agnts only comments there.';
  }

  @override
  String get mciFix => 'Fix it';

  @override
  String get mciFixConfirm => 'agnts opens a ticket to fix this failure. You review the fix before anything is pushed.';

  @override
  String get mciMute => 'Mute';

  @override
  String get mciUnmute => 'Unmute';

  @override
  String get mciMutedDone => 'Muted: agnts leaves this failure alone until you unmute it.';

  @override
  String get mciUnmutedDone => 'Unmuted.';

  @override
  String get mciRerun => 'Re-run';

  @override
  String get mciRerunDone => 'Re-run started.';

  @override
  String get mciCardTitle => 'CI failure';

  @override
  String get mciCardOpen => 'Open the CI failure';

  @override
  String mciCiFixes(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'CI sent the pull request back $n times',
      one: 'CI sent the pull request back once',
    );
    return '$_temp0';
  }

  @override
  String get mciSourceCi => 'CI';

  @override
  String get mciNotify => 'A watched branch went red';

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
  String get mcpPickWorkspace => 'Workspace';

  @override
  String get mcpPickWorkspaceHelp => 'Claude acts in this workspace, as you.';

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
  String get mdocumentsTitle => 'Documents';

  @override
  String get mdocumentsMoreRowSub => 'Reports and pages of the workspace';

  @override
  String get mdocumentsAll => 'All';

  @override
  String get mdocumentsMine => 'Mine';

  @override
  String get mdocumentsShared => 'Shared with me';

  @override
  String get mdocumentsEmpty => 'No documents yet';

  @override
  String get mdocumentsEmptyText => 'Write documents in the web app, or make one from a ticket\'s report.';

  @override
  String get mdocumentsTypePrivate => 'Private';

  @override
  String get mdocumentsTypePublic => 'Public';

  @override
  String get mdocumentsWriting => 'agnts is writing';

  @override
  String get mdocumentsFailed => 'Writing failed';

  @override
  String mdocumentsFailedText(String error) {
    return 'agnts could not write it: $error';
  }

  @override
  String mdocumentsVersion(String n) {
    return 'Version $n';
  }

  @override
  String mdocumentsAsOf(String date) {
    return 'Based on data up to $date';
  }

  @override
  String mdocumentsMeta(String owner, String time) {
    return '$owner · $time';
  }

  @override
  String get mdocumentsNoBody => 'Nothing written yet.';

  @override
  String get mdocumentsLinkedTickets => 'Linked tickets';

  @override
  String get mdocumentsCopyLink => 'Copy public link';

  @override
  String get mdocumentsLinkCopied => 'Link copied';

  @override
  String get mdocumentsSharing => 'Sharing';

  @override
  String get mdocumentsDownloadMd => 'Download .md';

  @override
  String get mdocumentsDownloadPdf => 'Download .pdf';

  @override
  String get mdocumentsPreparingPdf => 'Preparing the PDF…';

  @override
  String get mdocumentsPdfSlow => 'The PDF is taking longer than usual. Try again in a minute.';

  @override
  String get mdocumentsDownloadFailed => 'Download failed';

  @override
  String get mdocumentsPublicLink => 'Public link';

  @override
  String get mdocumentsPublicHint => 'Anyone with the link can read it without signing in.';

  @override
  String get mdocumentsPublicOff => 'Public documents are turned off in this workspace\'s Settings.';

  @override
  String get mdocumentsResetLink => 'Reset link';

  @override
  String get mdocumentsResetDone => 'New link made; the old one no longer works.';

  @override
  String get mdocumentsWorkspaceAccess => 'Everyone in the workspace';

  @override
  String get mdocumentsAccessNone => 'No access';

  @override
  String get mdocumentsAccessView => 'Can view';

  @override
  String get mdocumentsAccessEdit => 'Can edit';

  @override
  String get mdocumentsPeople => 'People';

  @override
  String get mdocumentsViewerOnlyView => 'Viewers can only view';

  @override
  String get mdocumentsSave => 'Save';

  @override
  String get mdocumentsSaved => 'Saved';

  @override
  String get mdocumentsSecrets => 'The document looks like it holds secrets. Remove them before publishing:';

  @override
  String mdocumentsSecretLine(String line, String excerpt) {
    return 'Line $line: $excerpt';
  }

  @override
  String get mdocumentsTicketSection => 'Documents';

  @override
  String get mdocumentsTicketNone => 'No documents linked yet.';

  @override
  String get mdocumentsFromReport => 'Make a document from this report';

  @override
  String get mdocumentsFromReportStarted => 'agnts is writing the document';

  @override
  String get mdocumentsLedgerSpent => 'Spent on a document';

  @override
  String get mdocumentsSlides => 'Slides';

  @override
  String get mdocumentsPresent => 'Present';

  @override
  String get mdocumentsNotes => 'Notes';

  @override
  String get mdocumentsNoNotes => 'No notes for this slide.';

  @override
  String get mdocumentsNoSlides => 'No slides yet.';

  @override
  String get mdocumentsPrevSlide => 'Previous slide';

  @override
  String get mdocumentsNextSlide => 'Next slide';

  @override
  String get mdocumentsStopPresenting => 'Stop presenting';

  @override
  String mdocumentsMadeFrom(String title) {
    return 'Made from “$title”';
  }

  @override
  String get mgroupsGroups => 'Groups';

  @override
  String get mgroupsRepos => 'Repositories';

  @override
  String get mgroupsPickHint => 'Pick one or more. The first one is the main one.';

  @override
  String get mgroupsInTask => 'In this task';

  @override
  String mgroupsFromGroup(String name) {
    return 'All of $name';
  }

  @override
  String mgroupsFromGroupEdited(String name) {
    return 'From $name, edited';
  }

  @override
  String get mgroupsPrimary => 'main';

  @override
  String mgroupsRemove(String name) {
    return 'Remove $name';
  }

  @override
  String get mgroupsNoMembers => 'This group has no active repositories.';

  @override
  String mgroupsGroup(String name) {
    return 'Group $name';
  }

  @override
  String get mgroupsPartlyMerged => 'Partly merged';

  @override
  String get mgroupsArchived => 'archived';

  @override
  String mgroupsPushError(String error) {
    return 'Push failed: $error';
  }

  @override
  String mgroupsFiles(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n files', one: '$n file');
    return '$_temp0';
  }

  @override
  String mgroupsCiFixes(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n CI fixes', one: '$n CI fix');
    return '$_temp0';
  }

  @override
  String get mgroupsStatePending => 'Pending';

  @override
  String get mgroupsStateUnchanged => 'No changes';

  @override
  String get mgroupsStatePushed => 'Pushed';

  @override
  String get mgroupsStateMerged => 'Merged';

  @override
  String get mgroupsStateDropped => 'Closed';

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
  String minsightsSaved(String name) {
    return '$name saved';
  }

  @override
  String get minsightsEditTask => 'Edit task';

  @override
  String get minsightsEditTaskSub => 'Only a task that hasn\'t started can be changed.';

  @override
  String get minsightsSave => 'Save';

  @override
  String get minsightsTaskSaved => 'Task saved';

  @override
  String minsightsTaskDeleted(String key) {
    return 'Task $key deleted';
  }

  @override
  String get minsightsTaskActions => 'Task actions';

  @override
  String get mmanageFillAll => 'Fill in the required fields.';

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
  String get mobilePushProgress => 'When an agent finishes a step';

  @override
  String get mobilePushProgressHelp => 'Analysis done, code written. Phone only, silent, one notification per ticket';

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
  String get mobileAdminAppOnly => 'This is an Admin account. Open it in the agnts admin app.';

  @override
  String get mobileGoogleContinue => 'Continue with Google';

  @override
  String get mobileGoogleOff => 'Google sign-in is off on this server.';

  @override
  String get mobileGoogleSetup => 'Google sign-in is not set up in this build of the app.';

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
  String get mpullsPlaceholder => 'Markdown';

  @override
  String get mpullsLineHint => 'Tap a line to comment on it.';

  @override
  String mpullsCopyLink(String host) {
    return 'Open on $host';
  }

  @override
  String get mqualityNewTest => 'New Swagger test';

  @override
  String get mqualityStarterFor => 'Starter rules for';

  @override
  String get mqualityStarterPick => 'Pick a repository to see the starter packs for its languages.';

  @override
  String get mqualitySearchRules => 'Search rules';

  @override
  String mqualityRequestTitle(String id) {
    return 'Request $id';
  }

  @override
  String mqualitySpecFile(String name) {
    return 'Spec file: $name';
  }

  @override
  String get mqualityDeployHook => 'Deploy hook';

  @override
  String get mqualityTokenSaved => 'Token saved';

  @override
  String get mqualitySuiteDeleted => 'Suite deleted';

  @override
  String mqualityHourAt(String hour) {
    return '$hour:00 UTC';
  }

  @override
  String get mqualityReviewTickets => 'Pull requests';

  @override
  String get mqualityAddReviewer => 'Add a reviewer';

  @override
  String get mqualityEndpointsTicked => 'Endpoints';

  @override
  String get mqualityShowCases => 'Show cases';

  @override
  String get mqualityHideCases => 'Hide cases';

  @override
  String mrepodetailCopyLink(String host) {
    return 'Open on $host';
  }

  @override
  String get mrepodetailOnePerLine => 'One per line.';

  @override
  String mrepodetailLinesCapped(String n) {
    return 'Only the first $n lines are shown here.';
  }

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
  String get mwsNone => 'You\'re not in a workspace yet. Create one or accept an invite in the web admin, then pull to refresh.';

  @override
  String mwsSwitched(String name) {
    return 'Switched to $name';
  }

  @override
  String mwsMembers(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n members', one: '$n member');
    return '$_temp0';
  }

  @override
  String get mwsSuspended => 'Suspended';

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
  String navSynced(String found, String created, String updated, String waiting) {
    return 'Jira synced: $found open, $created new, $updated updated, $waiting waiting for your choice';
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
  String get navLedeAll => 'Every ticket agnts has picked up from Jira and Plane.';

  @override
  String get navKnowledge => 'Knowledge';

  @override
  String get navLearn => 'Learn';

  @override
  String get navLearnQueue => 'Learning queue';

  @override
  String get navRules => 'Rules';

  @override
  String get navSyncPlane => 'Sync Plane';

  @override
  String navSyncedPlane(String found, String created) {
    return 'Plane synced: $found open, $created new';
  }

  @override
  String get navWorkspace => 'Workspace';

  @override
  String get navProfile => 'Profile';

  @override
  String get navPlatform => 'Admin cabinet';

  @override
  String get navPeople => 'People';

  @override
  String get navAccount => 'Account';

  @override
  String get navReviews => 'PR reviews';

  @override
  String get navCi => 'CI';

  @override
  String get navAiAssistant => 'AI assistant';

  @override
  String get navAssistantChat => 'Chat';

  @override
  String get navAssistantConversations => 'Conversations';

  @override
  String get navDocuments => 'Documents';

  @override
  String get networkTitle => 'Private networks';

  @override
  String get networkSub =>
      'Reach self-hosted GitLab, Jira or package registries inside your networks. A connection goes through the network whose route matches it most closely.';

  @override
  String get networkUnavailable =>
      'Private networks are not set up on this server: the operator runs the gateway service and sets AGNTS_GATEWAY.';

  @override
  String get networkStatus_up => 'Connected';

  @override
  String get networkStatus_connecting => 'Connecting';

  @override
  String get networkStatus_error => 'Error';

  @override
  String get networkStatus_gateway_down => 'Gateway down';

  @override
  String get networkStatus_disabled => 'Off';

  @override
  String get networkHandshake => 'Last handshake';

  @override
  String get networkHeartbeat => 'Last heartbeat';

  @override
  String get networkWebhooksRelay => 'Relayed by agnts-link';

  @override
  String networkWebhooksPolling(String n) {
    return 'No webhooks: trackers reached through it are read every $n min';
  }

  @override
  String get networkKind => 'Connection';

  @override
  String get networkKindConnector => 'agnts-link (recommended)';

  @override
  String get networkKindHelp_connector =>
      'A small agent you run inside your network. It connects out to agnts: no VPN credentials, no inbound firewall rule, and it relays webhooks.';

  @override
  String get networkKindHelp_wireguard => 'agnts connects to your WireGuard peer as a client. The peer must accept UDP from this server.';

  @override
  String get networkKindHelp_openvpn =>
      'agnts runs your OpenVPN client config in an isolated container. Certificates must be inline; logins that need MFA are not supported.';

  @override
  String get networkEnabled => 'Turned on';

  @override
  String get networkConfigWg => 'WireGuard config';

  @override
  String get networkConfigOvpn => 'OpenVPN config (.ovpn)';

  @override
  String networkSavedConfig(String summary) {
    return 'Saved: $summary. Leave empty to keep it.';
  }

  @override
  String get networkConfigWgHelp =>
      'The file you would give wg-quick. Add a DNS line to reach hosts by name. Keys are encrypted and never shown again.';

  @override
  String get networkConfigOvpnHelp => 'A client config with its ca, cert and key blocks inline. Scripts (up, down, plugin…) are refused.';

  @override
  String get networkUsername => 'Username';

  @override
  String get networkPassword => 'Password';

  @override
  String get networkPasswordKeep => 'Saved: leave empty to keep it';

  @override
  String get networkRoutes => 'Routes';

  @override
  String get networkRoutesHelp =>
      'Hosts (gitlab.corp.local), domains (.corp.local) or private ranges (10.20.0.0/16) that go through this network, with ports (80 and 443 when empty). Another network may have a narrower route inside these (10.30.0.0/16 inside 10.0.0.0/8): the more specific one wins. Two networks may not list the same route.';

  @override
  String get networkRouteTarget => 'Host, domain or range';

  @override
  String get networkRoutePorts => 'Ports';

  @override
  String get networkRemoveRoute => 'Remove route';

  @override
  String get networkAddRoute => 'Add route';

  @override
  String get networkBlastRadius =>
      'Code agnts runs for your tickets can reach every host listed here. List exact hosts rather than whole ranges.';

  @override
  String get networkCa => 'Company CA bundle';

  @override
  String networkCaSaved(String subjects, String date) {
    return 'Trusted: $subjects (until $date).';
  }

  @override
  String get networkCaRemove => 'Remove';

  @override
  String get networkCaHelp => 'PEM certificates of your internal CA. agnts and its runs trust them besides the public roots.';

  @override
  String networkSaved(String name) {
    return '$name saved';
  }

  @override
  String get networkRemove => 'Remove';

  @override
  String get networkRemoved => 'Private network removed';

  @override
  String networkRemoveConfirm(String name) {
    return 'Remove $name? agnts will stop reaching the hosts on its routes.';
  }

  @override
  String get networkLinkTitle => 'Run agnts-link';

  @override
  String get networkLinkHelp =>
      'Run this on a machine inside the network that can reach the hosts above. AGNTS_LINK_ALLOW is your own limit: agnts-link never dials anything else. Each network has its own token, so one machine can run several links.';

  @override
  String get networkToken => 'Token';

  @override
  String get networkTokenOnce => 'Copy it now: it is shown only once.';

  @override
  String get networkLinkHooks =>
      'Webhooks: point GitLab and Jira at http://AGNTS-LINK-HOST:8080 with the same /webhooks/… path the Integrations page shows.';

  @override
  String get networkRotate => 'Replace token';

  @override
  String get networkRotateConfirm => 'Make a new token? The running agnts-link disconnects until you restart it with the new one.';

  @override
  String get networkTest => 'Test a connection';

  @override
  String get networkTestRun => 'Test';

  @override
  String get networkTesting => 'Testing…';

  @override
  String networkTestOk(String name, String via, String ip, String ms) {
    return 'Connected through $name ($via) to $ip in $ms ms.';
  }

  @override
  String networkTlsOk(String subject, String issuer) {
    return 'Certificate OK: $subject, issued by $issuer.';
  }

  @override
  String networkTlsBad(String error) {
    return 'Certificate not trusted: $error';
  }

  @override
  String get networkActivity => 'Activity';

  @override
  String networkActivityCounts(String n, String refused) {
    return '$n connections, $refused refused or failed';
  }

  @override
  String get networkActivityShow => 'Show connections';

  @override
  String get networkActivityHide => 'Hide connections';

  @override
  String get networkRefused => 'refused';

  @override
  String networkSecondsAgo(String n) {
    return '$n s ago';
  }

  @override
  String networkMinutesAgo(String n) {
    return '$n min ago';
  }

  @override
  String networkHoursAgo(String n) {
    return '$n h ago';
  }

  @override
  String get networkReconnect => 'Reconnect';

  @override
  String get networkReconnectHelp => 'Restart the tunnel: a fresh OpenVPN client, a new WireGuard handshake, or agnts-link connects again';

  @override
  String get networkReconnecting => 'Reconnecting: the tunnel restarts within 15 seconds';

  @override
  String get networkAdd => 'Add network';

  @override
  String get networkAddTitle => 'New private network';

  @override
  String get networkAddSubmit => 'Add network';

  @override
  String get networkEditorSub => 'A tunnel into one of your networks and the hosts that go through it';

  @override
  String get networkEdit => 'Edit';

  @override
  String get networkDone => 'Done';

  @override
  String get networkName => 'Name';

  @override
  String get networkNamePlaceholder => 'Client A, Office, Data center';

  @override
  String get networkNameHelp => 'Unique in the workspace: the company, office or data center it reaches.';

  @override
  String get networkEmpty => 'No private networks yet. Add one to reach hosts that are only inside your network.';

  @override
  String networkLimit(String n) {
    return 'A workspace keeps at most $n private networks';
  }

  @override
  String networkCaShort(String subjects) {
    return 'Trusts $subjects';
  }

  @override
  String get networkTestHelp => 'Enter host:port. agnts picks the network the routes lead to, connects and checks the certificate.';

  @override
  String get networkTestThrough => 'Through';

  @override
  String get networkTestAuto => 'The network the routes pick';

  @override
  String get networkActivityAll => 'All networks';

  @override
  String get networkActivityNetwork => 'Network';

  @override
  String get networkActivityTime => 'Time';

  @override
  String get networkActivityTarget => 'Target';

  @override
  String get networkActivitySource => 'Ticket or source';

  @override
  String get networkGone => 'removed';

  @override
  String get networkDisconnect => 'Disconnect';

  @override
  String get networkDisconnectHelp => 'Stop the tunnel. Runs reach nothing through it until you connect again; the config is kept';

  @override
  String networkDisconnectConfirm(String name) {
    return 'Disconnect $name? Runs and trackers reached through it stop working until you connect it again. Its config is kept.';
  }

  @override
  String get networkDisconnected => 'Disconnected';

  @override
  String get networkConnect => 'Connect';

  @override
  String get networkConnectHelp => 'Start the tunnel again with the saved config';

  @override
  String get networkConnecting => 'Connecting: the tunnel starts within 15 seconds';

  @override
  String get networkManage => 'Manage';

  @override
  String get platformTitle => 'Admin cabinet';

  @override
  String get platformLede =>
      'Every workspace, run and user on this server. Workspaces show metadata only: their tickets are their members\'.';

  @override
  String get platformCapacity => 'Server';

  @override
  String get platformReserved => 'Memory reserved';

  @override
  String get platformBudgetNone => 'not limited';

  @override
  String get platformRuns => 'Runs';

  @override
  String get platformDisk => 'Disk free';

  @override
  String get platformFull => 'Full: runs are waiting for the server';

  @override
  String get platformRunning => 'Running now';

  @override
  String get platformNoRuns => 'Nothing is running.';

  @override
  String get platformQueue => 'Server queue';

  @override
  String get platformNoQueue => 'No run is waiting for the server.';

  @override
  String get platformWorkspace => 'Workspace';

  @override
  String get platformTicket => 'Ticket';

  @override
  String get platformStage => 'Stage';

  @override
  String get platformStarted => 'Started';

  @override
  String get platformWorkspaces => 'Workspaces';

  @override
  String get platformOwner => 'Owner';

  @override
  String get platformPlan => 'Plan';

  @override
  String get platformSlots => 'Slots';

  @override
  String get platformMembers => 'Members';

  @override
  String get platformMemberLimit => 'Member limit';

  @override
  String get platformCredits => 'Credits';

  @override
  String get platformState => 'State';

  @override
  String get platformActive => 'Active';

  @override
  String get platformSuspended => 'Suspended';

  @override
  String get platformDeleted => 'Deleted';

  @override
  String get platformEdit => 'Edit';

  @override
  String get platformSuspend => 'Suspend';

  @override
  String get platformResume => 'Resume';

  @override
  String get platformGrant => 'Grant credits';

  @override
  String get platformGrantAmount => 'Credits (negative takes back)';

  @override
  String get platformGrantNote => 'Note';

  @override
  String platformGrantDone(String n, String name) {
    return '$n credits granted to $name';
  }

  @override
  String get platformSaved => 'Saved';

  @override
  String get platformUsers => 'Users';

  @override
  String get platformUser => 'User';

  @override
  String get platformEmail => 'Email';

  @override
  String get platformAdmin => 'Admin';

  @override
  String get platformMakeAdmin => 'Make Admin';

  @override
  String get platformRemoveAdmin => 'Remove Admin';

  @override
  String get platformJoined => 'Joined';

  @override
  String get platformNoLimit => 'no limit';

  @override
  String get platformForbidden => 'Only an Admin can open the operator console.';

  @override
  String get platformCabinetBadge => 'Admin cabinet';

  @override
  String get platformNavDashboard => 'Dashboard';

  @override
  String get platformAdmins => 'Admins';

  @override
  String get platformNavMine => 'My work';

  @override
  String get platformBackToWorkspace => 'Back to my workspace';

  @override
  String get platformDashLede => 'Everyone on the platform, how fast it grows, and what the server is running.';

  @override
  String platformNewThisWeek(String n) {
    return '$n new this week';
  }

  @override
  String platformViaGoogle(String n) {
    return '$n via Google';
  }

  @override
  String get platformActiveUsers => 'Active this week';

  @override
  String get platformActiveNote => 'Signed in during the last 7 days';

  @override
  String platformTeams(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n with teams', one: '$n with a team');
    return '$_temp0';
  }

  @override
  String platformRunsNow(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n runs right now', one: '$n run right now');
    return '$_temp0';
  }

  @override
  String get platformGrowthTitle => 'Sign-ups';

  @override
  String platformGrowthSub(String n) {
    return 'New accounts and workspaces per day, last $n days';
  }

  @override
  String get platformLegendUsers => 'Accounts';

  @override
  String get platformLegendWorkspaces => 'Workspaces';

  @override
  String get platformRecentTitle => 'Newest accounts';

  @override
  String get platformSeeAll => 'See all';

  @override
  String get platformNoUsers => 'No users match.';

  @override
  String get platformWsLede =>
      'Every workspace and who is in it. You see metadata only: tickets and code belong to the workspace’s members.';

  @override
  String get platformF_all => 'All';

  @override
  String get platformF_active => 'Active';

  @override
  String get platformF_suspended => 'Suspended';

  @override
  String get platformF_deleted => 'Deleted';

  @override
  String get platformSearchWs => 'Search workspaces or owners';

  @override
  String get platformNoWorkspaces => 'No workspaces match.';

  @override
  String get platformCreated => 'Created';

  @override
  String get platformNoMembers => 'No members.';

  @override
  String platformSuspendTitle(String name) {
    return 'Suspend $name?';
  }

  @override
  String get platformSuspendBody =>
      'Its runs stop being started and its members see that the workspace is suspended. You can resume it at any time.';

  @override
  String get platformUsersLede =>
      'Everyone who signed up with Google: their workspaces, and when they were last here. Admin accounts are on the Admins page.';

  @override
  String get platformU_all => 'All';

  @override
  String get platformU_active => 'Active';

  @override
  String get platformU_new => 'New this week';

  @override
  String get platformU_google => 'Google';

  @override
  String get platformU_admins => 'Admins';

  @override
  String get platformSearchUsers => 'Search by name, email or workspace';

  @override
  String get platformSignIn => 'Sign-in';

  @override
  String get platformLastSeen => 'Last sign-in';

  @override
  String get platformPassword => 'Password';

  @override
  String get platformUnverified => 'unverified';

  @override
  String get platformYou => 'You';

  @override
  String platformMakeAdminTitle(String name) {
    return 'Make $name an Admin?';
  }

  @override
  String get platformMakeAdminBody =>
      'Admins open this cabinet: they see every user and workspace, change plans and credits, suspend workspaces and manage other Admins.';

  @override
  String platformRemoveAdminTitle(String name) {
    return 'Remove $name as Admin?';
  }

  @override
  String get platformRemoveAdminBody => 'They keep their account and workspaces, but lose the Admin cabinet.';

  @override
  String platformAdminAdded(String name) {
    return 'Admin $name created';
  }

  @override
  String platformAdminRemoved(String name) {
    return 'Admin $name deleted';
  }

  @override
  String get platformAdminsLede =>
      'The platform’s operators. Each is its own account, apart from Users: an Admin sees no workspace’s tickets.';

  @override
  String platformAdminsCount(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n Admins', one: '$n Admin');
    return '$_temp0';
  }

  @override
  String get platformAddAdmin => 'Add an Admin';

  @override
  String get platformAddAdminSub =>
      'An Admin is a separate account: it signs in with a password, opens this cabinet and has no workspaces. Users can’t be made Admins.';

  @override
  String get platformFindUser => 'Find a person';

  @override
  String get platformNoMatch => 'No one matches, or they are an Admin already.';

  @override
  String platformLastSeenAgo(String when) {
    return 'last sign-in $when';
  }

  @override
  String get platformAdminName => 'Name';

  @override
  String get platformAdminUsername => 'Username';

  @override
  String platformAdminPasswordHint(String n) {
    return 'At least $n characters. They can turn on two-factor sign-in in their profile.';
  }

  @override
  String get platformCreateAdmin => 'Create Admin';

  @override
  String get platformDeleteAdmin => 'Delete';

  @override
  String platformDeleteAdminTitle(String name) {
    return 'Delete the Admin account $name?';
  }

  @override
  String get platformDeleteAdminBody => 'They can no longer sign in. This cannot be undone.';

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
  String get pullsTab => 'Pull requests';

  @override
  String get pullsTitle => 'Pull requests';

  @override
  String get pullsSub => 'On the git host, most recently updated first. Open one to read and answer its comments.';

  @override
  String get pullsBack => 'Back to the repository';

  @override
  String get pullsState_open => 'Open';

  @override
  String get pullsState_merged => 'Merged';

  @override
  String get pullsState_closed => 'Closed';

  @override
  String get pullsState_all => 'All';

  @override
  String get pullsNone => 'No pull requests here.';

  @override
  String get pullsEnd => 'That is all of them.';

  @override
  String pullsUpdated(String time) {
    return 'updated $time';
  }

  @override
  String get pullsDraft => 'Draft';

  @override
  String pullsOwnTicket(String key) {
    return 'agnts\'s change · $key';
  }

  @override
  String pullsReviewTicket(String key) {
    return 'Review · $key';
  }

  @override
  String get pullsConversation => 'Conversation';

  @override
  String get pullsFiles => 'Files';

  @override
  String pullsUnresolvedN(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n unresolved threads', one: '$n unresolved thread');
    return '$_temp0';
  }

  @override
  String pullsShowResolved(String n) {
    return 'Show resolved ($n)';
  }

  @override
  String get pullsNoComments => 'No comments yet.';

  @override
  String get pullsNoFiles => 'The pull request changes no files.';

  @override
  String get pullsNoPatch => 'No diff to show (a binary file, or too large for the git host to send).';

  @override
  String pullsFilesError(String error) {
    return 'The changed files could not be read: $error';
  }

  @override
  String get pullsEarlierVersion => 'Written on an earlier version of this file:';

  @override
  String pullsThreadsN(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n threads', one: '$n thread');
    return '$_temp0';
  }

  @override
  String pullsCommentOnLine(String line) {
    return 'Comment on line $line';
  }

  @override
  String get pullsAddComment => 'Add a comment';

  @override
  String get pullsComment => 'Comment';

  @override
  String get pullsCommentLabel => 'Comment';

  @override
  String get pullsPlaceholder => 'Markdown. Ctrl+Enter posts.';

  @override
  String get pullsWrite => 'Write';

  @override
  String get pullsPreview => 'Preview';

  @override
  String get pullsReply => 'Reply';

  @override
  String get pullsEdit => 'Edit';

  @override
  String get pullsSave => 'Save';

  @override
  String get pullsEdited => 'edited';

  @override
  String get pullsDelete => 'Delete';

  @override
  String get pullsDeleteTitle => 'Delete the comment?';

  @override
  String get pullsDeleteConfirm => 'It is deleted on the git host for everyone. This cannot be undone.';

  @override
  String get pullsDeleted => 'Comment deleted';

  @override
  String get pullsResolve => 'Resolve';

  @override
  String get pullsUnresolve => 'Reopen';

  @override
  String get pullsResolved => 'Resolved';

  @override
  String get pullsOutdated => 'Outdated';

  @override
  String get pullsSent => 'Sent to agnts';

  @override
  String get pullsAnswered => 'Answered by agnts';

  @override
  String get pullsVerdict_APPROVED => 'Approved';

  @override
  String get pullsVerdict_CHANGES_REQUESTED => 'Changes requested';

  @override
  String get pullsVerdict_COMMENTED => 'Commented';

  @override
  String get pullsVerdict_DISMISSED => 'Dismissed';

  @override
  String pullsPostsAs(String login, String host) {
    return 'Posts as @$login on $host';
  }

  @override
  String pullsPostsAsToken(String host) {
    return 'Posts as the $host token\'s user';
  }

  @override
  String pullsTicketTitle(String number, String host) {
    return 'Comments on #$number ($host)';
  }

  @override
  String get pullsTicketSubOwn => 'Reviewers\' comments on agnts\'s pull request. Answer here, or send them back to agnts.';

  @override
  String get pullsTicketSubReview => 'The pull request\'s conversation on the git host.';

  @override
  String pullsTicketSubIn(String repo) {
    return 'In $repo.';
  }

  @override
  String get pullsOpenWithDiff => 'Open with the diff';

  @override
  String pullsAddressBtn(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'Address $n comments', one: 'Address $n comment');
    return '$_temp0';
  }

  @override
  String pullsAddressConfirm(String key, num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'these $n review threads', one: 'this review thread');
    return 'agnts goes back to $key with $_temp0: it changes the code or answers each. The fix waits for your approval as usual; once it is pushed, agnts replies in each thread.';
  }

  @override
  String pullsAddressed(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n threads went', one: '$n thread went');
    return '$_temp0 back to agnts';
  }

  @override
  String pullsAddressLater(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n new review comments', one: '$n new review comment');
    return '$_temp0: they can go back to agnts while the ticket waits for your review, or once it is done with its pull request open.';
  }

  @override
  String pullsPostTitle(String number) {
    return 'Post the review on #$number';
  }

  @override
  String pullsPostSub(String host) {
    return 'One review on $host, as the token\'s user. Findings on lines of the diff become comments there.';
  }

  @override
  String pullsPostBtn(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Post with $n line comments',
      one: 'Post with $n line comment',
      zero: 'Post',
    );
    return '$_temp0';
  }

  @override
  String get pullsPostSummary => 'The summary (the verdict and every finding)';

  @override
  String get pullsPostFindings => 'On their lines:';

  @override
  String get pullsSummaryOnly => 'summary only: not a line of the diff';

  @override
  String get pullsRequestChanges => 'Request changes';

  @override
  String get pullsNoRequestChanges => 'GitLab has no request for changes here: the comments are posted, approvals stay as they are.';

  @override
  String get pullsSettingsTitle => 'Comments on pull requests';

  @override
  String get pullsSet_attribution => 'Say who wrote it';

  @override
  String get pullsSet_attributionHelp =>
      'Comments written in agnts go out as the git host token\'s user; this adds \"via agnts · your name\" under each.';

  @override
  String get pullsSet_learnFromComments => 'Learn from your comments';

  @override
  String get pullsSet_learnFromCommentsHelp => 'What you write on others\' pull requests on the git host becomes notes on how you review.';

  @override
  String get pullsSet_resolveFixed => 'Resolve fixed threads';

  @override
  String get pullsSet_resolveFixedHelp => 'Once agnts pushed a fix and answered a reviewer\'s thread, it resolves the thread.';

  @override
  String get pullsSet_autoAddress => 'Address requested changes';

  @override
  String get pullsSet_autoAddressHelp =>
      'When a reviewer requests changes on agnts\'s pull request, its unresolved threads go back to the ticket by themselves. The fix still waits for your approval.';

  @override
  String get pullsCommentHint => 'Point at a line and click the comment button to comment on it.';

  @override
  String queueHeader(String running, String slots) {
    return 'Running $running/$slots';
  }

  @override
  String queueQueued(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n queued', one: '$n queued');
    return '$_temp0';
  }

  @override
  String queueWaitingServer(String n) {
    return '$n waiting for the server';
  }

  @override
  String get queueBadge_blocked => 'Waiting · related';

  @override
  String get queueBadge_slots => 'Queued · slots';

  @override
  String get queueBadge_server => 'Queued · server';

  @override
  String get queueBadge_claude => 'Paused · Claude';

  @override
  String get queueTitle_blocked => 'Waiting for related tickets';

  @override
  String get queueTitle_slots => 'Waiting for a free slot';

  @override
  String get queueTitle_server => 'In the server queue';

  @override
  String get queueTitle_claude => 'Waiting for Claude';

  @override
  String queuePosition(String position) {
    return '#$position in the server queue';
  }

  @override
  String queueOthers(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n tickets of other workspaces ahead.',
      one: '$n ticket of another workspace ahead.',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String queueEstimate(num minutes) {
    String _temp0 = intl.Intl.pluralLogic(minutes, locale: localeName, other: '$minutes minutes', one: '$minutes minute');
    return 'Starts in about $_temp0.';
  }

  @override
  String queueServerFull(String runs, String reserved, String budget) {
    return 'The server is at capacity ($runs runs, $reserved of $budget reserved).';
  }

  @override
  String queueSlotsHint(String running, String slots) {
    return '$running of $slots runs in use. It starts when one ends.';
  }

  @override
  String get queueAddSlot => 'Add a slot';

  @override
  String get queueClaudeHint => 'Connect an account or turn on credits in Workspace settings → Claude.';

  @override
  String get queueMember => 'Member';

  @override
  String get queueTakeOver => 'Take over';

  @override
  String get queueTakenOver => 'The ticket is yours: it runs on your Claude account in per-member mode.';

  @override
  String queueCreatedBy(String name) {
    return 'Created by $name';
  }

  @override
  String queueBy(String name) {
    return 'by $name';
  }

  @override
  String redFlagsTitle(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n red flags', one: '$n red flag');
    return '$_temp0';
  }

  @override
  String get redFlagsSub =>
      'agnts\'s scan of the change matched these lines. They often mean the checks were made to pass the wrong way; agnts\'s review checks each one.';

  @override
  String get redFlagsKind_skipped_test => 'Skipped or focused test';

  @override
  String get redFlagsKind_removed_assertion => 'Assertions removed';

  @override
  String get redFlagsKind_deleted_test => 'Test file deleted';

  @override
  String get redFlagsKind_silenced_lint => 'Linter silenced';

  @override
  String get redFlagsKind_swallowed_error => 'Error swallowed';

  @override
  String get redFlagsKind_todo => 'TODO left';

  @override
  String get redFlagsKind_new_dependency => 'New dependency';

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
  String get relationsSource_plane => 'Plane relation';

  @override
  String get replayTitle => 'Replay with today\'s agnts';

  @override
  String get replaySub =>
      'Re-run this ticket from the commit it started from, with the current prompts, brief and rules, and compare the result with what you approved. The replay is never pushed.';

  @override
  String get replayStart => 'Replay';

  @override
  String replayConfirm(String key) {
    return 'agnts creates a new task that re-does $key from where it started. It uses your Claude plan like any ticket.';
  }

  @override
  String replayCreated(String key) {
    return 'Replay $key queued';
  }

  @override
  String get replayBanner => 'This is a replay to evaluate agnts: it is never pushed. Compare it with';

  @override
  String get replayEvalTitle => 'Replay evaluation';

  @override
  String get replayEvalSub =>
      'Done tickets re-run with a newer agnts, compared with the change you approved. Start one with Replay on a done ticket, or `agnts eval replay KEY`.';

  @override
  String get replayNone => 'No replays yet.';

  @override
  String get replayRecent => 'Recent replays';

  @override
  String get replayColReplays => 'Replays';

  @override
  String get replayColChecks => 'Checks';

  @override
  String get replayColLooksGood => 'Review OK';

  @override
  String get replayColOverlap => 'Same files';

  @override
  String get replayColOverlapHint => 'How much the replay\'s changed files match the approved change\'s (Jaccard index)';

  @override
  String get replayColRecall => 'Coverage';

  @override
  String get replayColRecallHint => 'Share of the approved change\'s files the replay changed too';

  @override
  String get replayColTurns => 'Turns (original)';

  @override
  String get replayColCost => 'Cost (original)';

  @override
  String get replayColReplay => 'Replay';

  @override
  String get replayColOf => 'Of';

  @override
  String get replayColState => 'State';

  @override
  String get replayColReview => 'Review';

  @override
  String get replayPass => 'pass';

  @override
  String get replayFail => 'fail';

  @override
  String get replayVerdict_looks_good => 'looks good';

  @override
  String get replayVerdict_has_concerns => 'has concerns';

  @override
  String get replayVerdict_needs_changes => 'needs changes';

  @override
  String get replayBenchmarkTitle => 'Benchmark';

  @override
  String get replayBenchmarkSub =>
      'Merged tickets that every change to agnts is replayed against, and scored against what they merged as. Pick 20–30 of different sizes.';

  @override
  String get replayBenchmarkAdd => 'Add to benchmark';

  @override
  String get replayBenchmarkRemove => 'Remove from benchmark';

  @override
  String get replayBenchmarkIn => 'In the benchmark: changes to agnts are replayed against this ticket.';

  @override
  String get replayBenchmarkNeedsMerge => 'Only merged tickets can be in the benchmark: replays are scored against what they merged as.';

  @override
  String get replayBenchmarkRun => 'Run benchmark';

  @override
  String get replayBenchmarkModel => 'Coding model';

  @override
  String get replayBenchmarkModelDefault => 'as the originals';

  @override
  String replayBenchmarkConfirm(String n) {
    return 'agnts replays the $n benchmark tickets from where each started. They use your Claude plan like any ticket.';
  }

  @override
  String replayBenchmarkStarted(String n) {
    return '$n replays queued';
  }

  @override
  String replayBenchmarkFailed(String n, String why) {
    return '$n could not be replayed: $why';
  }

  @override
  String get replayBenchmarkEmpty => 'The benchmark is empty. Open a merged ticket and press Add to benchmark.';

  @override
  String replayBenchmarkCount(String n) {
    return '$n tickets';
  }

  @override
  String get replayAllReplays => 'All replays';

  @override
  String get replayColModel => 'Model';

  @override
  String get replayColLines => 'Merged lines';

  @override
  String get replayColLinesHint =>
      'Share of the lines the merged pull request added that the replay adds too; in brackets the same for agnts\'s original change. Higher is closer to what people shipped.';

  @override
  String get replayAgainst_merged => 'vs merged';

  @override
  String get replayAgainst_agnts => 'vs agnts';

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
  String get repoBrief => 'Brief';

  @override
  String get repoCi => 'CI';

  @override
  String get repoCode => 'Code';

  @override
  String get repoCodeSub => 'The repository\'s files on the chosen branch, read from the git host.';

  @override
  String get repoCodeBranch => 'Branch';

  @override
  String get repoCodePath => 'Path';

  @override
  String get repoCodeRoot => 'Root';

  @override
  String repoCodeLines(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n lines', one: '$n line');
    return '$_temp0';
  }

  @override
  String get repoCodeView => 'View';

  @override
  String get repoCodePreview => 'Preview';

  @override
  String get repoCodeSource => 'Code';

  @override
  String get repoCodeBinary => 'This is a binary file and can\'t be shown here.';

  @override
  String get repoCodeTooLarge => 'This file is over 1 MB, too large to show here. Open it on the git host.';

  @override
  String get repoCodeEmptyFile => 'This file is empty.';

  @override
  String get repoCodeEmpty => 'This branch has no files yet.';

  @override
  String get repoCodeSubmodule => 'Submodule';

  @override
  String get repoCodeSymlink => 'Link';

  @override
  String repoCodeCapped(String n) {
    return 'Only the first $n entries of this folder are listed.';
  }

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
  String get reposDrawerSub => 'Takes side-project tasks, plus Jira tickets or Plane work items once it is linked to a project';

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
    return 'Side-project tasks are numbered like $prefix-1, $prefix-2. Must differ from the Jira project key and the Plane project.';
  }

  @override
  String get reposBranch => 'Default branch';

  @override
  String get reposBranchHelp => 'Work branches start from here.';

  @override
  String get reposBranchTemplate => 'Branch name format';

  @override
  String reposBranchTemplateHelp(String key, String number, String fallback) {
    return 'How agnts names the branch for each ticket. Must contain $key or $number. Leave empty for $fallback.';
  }

  @override
  String reposBranchTemplateExample(String example) {
    return 'Example: $example';
  }

  @override
  String get reposCommitTemplate => 'Commit message format';

  @override
  String get reposCommitTemplateHelp =>
      'How agnts writes its commit messages. An empty scope drops its parentheses. Leave empty for KEY: Title.';

  @override
  String reposCommitTemplateExample(String example) {
    return 'Example: $example';
  }

  @override
  String get reposPlaceholders => 'Placeholders';

  @override
  String get reposPhPrefix => 'The repository\'s branch prefix, agnts/ by default.';

  @override
  String get reposPhType => 'The kind of work: feature for code, bugfix for a bug, test, swagger-test.';

  @override
  String get reposPhKey => 'The agnts ticket key: VIS-42, or the Jira or Plane issue key.';

  @override
  String get reposPhNumber => 'The task\'s ticket number, such as AMANAT-2288. Falls back to the key when empty.';

  @override
  String get reposPhSlug => 'The ticket title in lowercase with hyphens, up to 40 characters.';

  @override
  String get reposPhUser => 'Username of whoever the ticket is assigned to, or its creator.';

  @override
  String get reposPhCommitType =>
      'The change type the agent picks: feat, fix, chore, refactor, docs, test... Falls back to the ticket kind.';

  @override
  String get reposPhScope => 'The area the agent says it changed, such as deps or auth. May be empty.';

  @override
  String get reposPhSubject => 'The agent\'s one-line summary of the change. Falls back to the ticket title.';

  @override
  String get reposPhTitle => 'The ticket title as written.';

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
  String get reposColStack => 'Toolchains';

  @override
  String get reposToolchains => 'Toolchains';

  @override
  String get reposToolchainsHelp =>
      'Language runtimes and build tools installed into every run, once per version, and kept for later runs.';

  @override
  String get reposToolchainsAuto =>
      'Detected from the repository (go.mod, .nvmrc, .python-version, mise.toml, …) and kept up to date as those files change.';

  @override
  String get reposToolchainsManual => 'Set by hand: detection leaves them as they are.';

  @override
  String get reposToolchainsBackToAuto => 'Detect automatically';

  @override
  String reposToolchainFrom(String source) {
    return 'from $source';
  }

  @override
  String reposToolchainRemove(String tool) {
    return 'Remove $tool';
  }

  @override
  String get reposToolchainAdd => 'Add';

  @override
  String get reposToolchainPh => 'tool@version, e.g. python@3.12';

  @override
  String get reposToolchainBad => 'Write it as tool@version, e.g. node@20 or rust@stable.';

  @override
  String get reposToolchainsNone => 'None yet: they are detected after you save, or press Detect.';

  @override
  String get reposDetect => 'Detect';

  @override
  String get reposDetectDeep => 'Ask Claude';

  @override
  String get reposDetectDeepHelp =>
      'Claude reads the README and CI files when the scan finds no commands. Takes about a minute and uses your Claude plan.';

  @override
  String get reposDetecting => 'Reading the repository…';

  @override
  String reposDetectDone(String list) {
    return 'Found $list.';
  }

  @override
  String get reposDetectNothing => 'No known build files found. Add the toolchains and commands by hand, or ask Claude.';

  @override
  String get reposDetectFilled => 'Empty check commands were filled in; review them before saving.';

  @override
  String get reposDetectByClaude => 'Claude filled in what the scan could not find.';

  @override
  String get reposDetectNeedsUrl => 'Enter the clone URL first.';

  @override
  String get reposCmdAuto => 'detected after saving';

  @override
  String get reposNotes => 'Notes from detection';

  @override
  String get reposAdvanced => 'Advanced';

  @override
  String get reposRunnerImage => 'Runner image';

  @override
  String get reposRunnerImageHelp =>
      'Optional. An image built on the server FROM agnts-runner, for system libraries or SDKs toolchains cannot provide (Android, Flutter). Empty uses the default.';

  @override
  String get reposMemory => 'Memory';

  @override
  String get reposMemoryHelp =>
      'Optional, for heavy builds (JVM, Rust, .NET). Server default unless set; the server caps it (AGNTS_RUN_MEMORY_MAX_MB, 8 GB by default).';

  @override
  String get reposMemoryDefault => 'Server default';

  @override
  String get reposBuildEnv => 'Build environment';

  @override
  String get reposBuildEnvHelp =>
      'KEY=value lines given to every run, such as tokens for private package registries (NPM_TOKEN, PIP_INDEX_URL). Stored encrypted and never shown again. Claude can read them while it works, so use read-only tokens.';

  @override
  String reposBuildEnvSet(String names) {
    return 'Set: $names';
  }

  @override
  String get reposBuildEnvReplace => 'Replace';

  @override
  String get reposBuildEnvClear => 'Clear';

  @override
  String get reposBuildEnvCleared => 'Cleared when you save.';

  @override
  String reposPlane(String project) {
    return 'Plane $project';
  }

  @override
  String get reposPlaneProject => 'Plane project';

  @override
  String get reposPlaneHelp =>
      'Optional. The project identifier (WEB in WEB-123). Work items from this Plane project with the agnts label run here.';

  @override
  String get reposSearch => 'Search by name, stack, project or group';

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
  String get reviewCat_architecture => 'Architecture';

  @override
  String get reviewCat_scope => 'Scope';

  @override
  String get reviewsTitle => 'Pull request reviews';

  @override
  String get reviewsLede =>
      'agnts lists the open pull requests of your repositories on GitHub and GitLab. Open one and press Review to have agnts review it as it is now; review it again whenever you want, after new commits say. Its reviews stay on the pull request.';

  @override
  String get reviewsSyncing => 'Syncing…';

  @override
  String get reviewsSyncErrors => 'Some could not be read:';

  @override
  String get reviewsSettingsTitle => 'How agnts picks them up';

  @override
  String get reviewsReviewRequested => 'Review requests too';

  @override
  String get reviewsReviewRequestedHelp => 'Also take pull requests whose review is requested from you, not only those assigned to you.';

  @override
  String get reviewsAll => 'Every open pull request';

  @override
  String get reviewsAllHelp =>
      'Take every open pull request in your repositories, your own included, not only those assigned to you or asking for your review. Approving one of these does not merge it.';

  @override
  String get reviewsSkipDrafts => 'Skip drafts';

  @override
  String get reviewsSkipDraftsHelp => 'Leave draft pull requests alone until they are ready.';

  @override
  String get reviewsMergeMethod => 'Merge method';

  @override
  String get reviewsMergeMethodHelp => 'How agnts merges a pull request you accept.';

  @override
  String get reviewsMerge_merge => 'Merge commit';

  @override
  String get reviewsMerge_squash => 'Squash';

  @override
  String get reviewsMerge_rebase => 'Rebase';

  @override
  String get reviewsWaiting => 'Waiting for you';

  @override
  String get reviewsInProgress => 'In progress';

  @override
  String get reviewsFinished => 'Finished';

  @override
  String get reviewsEmpty => 'Nothing here.';

  @override
  String get reviewsEmptyAll => 'No open pull requests. Check which ones are taken in the settings, then press Refresh.';

  @override
  String get reviewsWhy_assigned => 'assigned';

  @override
  String get reviewsWhy_review_requested => 'review requested';

  @override
  String get reviewsWhy_open => 'open';

  @override
  String get reviewsWhy_own => 'yours';

  @override
  String get reviewsWhy_manual => 'asked for here';

  @override
  String reviewsBy(String author) {
    return 'by @$author';
  }

  @override
  String get reviewsHowTitle => 'How you review';

  @override
  String get reviewsHowSub =>
      'Notes you leave when you ask for another review or dismiss one are folded into your profile on the next review. Every later review reads it.';

  @override
  String get reviewsNoReviewers =>
      'agnts knows nothing about how you review yet. Leave a note when you ask for another review, or add one below.';

  @override
  String get reviewsProfile => 'Profile';

  @override
  String get reviewsProfileHint => 'Markdown: what you care about, what is noise, how severe you rate things.';

  @override
  String reviewsFolded(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n notes learned', one: '$n note learned');
    return '$_temp0';
  }

  @override
  String get reviewsPending => 'Not learned yet';

  @override
  String get reviewsSaveProfile => 'Save profile';

  @override
  String get reviewsProfileSaved => 'Profile saved';

  @override
  String get reviewsAddNote => 'Add a note';

  @override
  String get reviewsNotePlaceholder => 'For example: naming nits are noise to me; always check that migrations can be rolled back.';

  @override
  String get reviewsNoteAdded => 'Note added';

  @override
  String get reviewsDeleteNote => 'Delete note';

  @override
  String get reviewsNoteKind_rereview => 're-review';

  @override
  String get reviewsNoteKind_dismissed => 'dismissed';

  @override
  String get reviewsNoteKind_manual => 'written here';

  @override
  String get reviewsLogin => 'Git host username';

  @override
  String reviewsPr(String number) {
    return 'Pull request #$number';
  }

  @override
  String reviewsReviewed(String sha) {
    return 'Head at $sha';
  }

  @override
  String get reviewsNewCommits => 'New commits since';

  @override
  String reviewsPostBtn(String host) {
    return 'Post review on $host';
  }

  @override
  String reviewsPostConfirm(String number, String host) {
    return 'Post agnts\'s review of #$number on $host as a comment? It is posted as your $host account and everyone on the pull request sees it.';
  }

  @override
  String reviewsPostedToast(String host) {
    return 'Review posted on $host';
  }

  @override
  String reviewsPosted(String host, String when) {
    return 'agnts\'s review of this commit is on $host · $when';
  }

  @override
  String get reviewsQueuedSub => 'agnts will fetch it and review it.';

  @override
  String get reviewsFetchingTitle => 'Fetching the pull request';

  @override
  String get reviewsReviewingTitle => 'Reviewing the pull request';

  @override
  String get reviewsReviewingSub => 'agnts is reading the change. Its review appears here.';

  @override
  String get reviewsReadyTitle => 'agnts\'s review is ready';

  @override
  String reviewsReadySub(String host) {
    return 'Merge it from here, review again with a note, or dismiss it and review on $host yourself.';
  }

  @override
  String get reviewsNoteLabel => 'Review again with a note';

  @override
  String get reviewsNoteHint => 'Tell agnts what it got wrong or missed. The note also teaches it how you review.';

  @override
  String get reviewsMergeBtn => 'Merge pull request';

  @override
  String reviewsMergeConfirm(String number, String host, String method) {
    return 'agnts merges #$number on $host ($method), at the commit it reviewed.';
  }

  @override
  String get reviewsRereviewBtn => 'Review again';

  @override
  String reviewsDismissBtn(String host) {
    return 'Dismiss, I\'ll review it on $host';
  }

  @override
  String get reviewsDismissReason => 'Why (optional)';

  @override
  String get reviewsDismissReasonHint => 'Optional. It also teaches agnts how you review.';

  @override
  String reviewsDismissConfirm(String number, String host) {
    return 'agnts stops reviewing #$number. The pull request stays open on $host.';
  }

  @override
  String get reviewsMergingTitle => 'Merging the pull request';

  @override
  String get reviewsMergedTitle => 'Merged';

  @override
  String reviewsMergedSub(String number) {
    return '#$number is merged.';
  }

  @override
  String get reviewsDismissedTitle => 'Review dismissed';

  @override
  String reviewsDismissedSub(String host) {
    return 'The pull request is yours on $host.';
  }

  @override
  String reviewsOpenOn(String host) {
    return 'Open on $host';
  }

  @override
  String get reviewsReviewTitle => 'agnts\'s review of the pull request';

  @override
  String get reviewsRefresh => 'Refresh';

  @override
  String get reviewsOpenPulls => 'Open pull requests';

  @override
  String get reviewsNotReviewed => 'Not reviewed';

  @override
  String get reviewsHistory => 'Reviews';

  @override
  String get reviewsHistoryEmpty => 'Not reviewed yet. Press Review with agnts to start one.';

  @override
  String reviewsReviewedAt(String sha) {
    return 'at $sha';
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
  String get rulesStatus_suggested => 'Suggested';

  @override
  String get rulesSuggestedFrom => 'agnts suggests this rule from your feedback on';

  @override
  String get rulesSuggestedHint => 'Tickets don\'t follow it until you adopt it. Edit it to adopt it with your changes.';

  @override
  String rulesSuggestedHelp(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'agnts suggests $n rules learned from your feedback.',
      one: 'agnts suggests $n rule learned from your feedback.',
    );
    return '$_temp0';
  }

  @override
  String get rulesAdopt => 'Adopt';

  @override
  String get rulesAdoptAsWritten => 'Adopt as written';

  @override
  String get rulesDismiss => 'Dismiss';

  @override
  String rulesDismissBody(String title) {
    return 'agnts drops “$title” and won\'t suggest it again.';
  }

  @override
  String get rulesDismissed => 'Suggestion dismissed';

  @override
  String get rulesKind => 'Kind';

  @override
  String get rulesKindRule => 'Rule';

  @override
  String get rulesKindContext => 'Business context';

  @override
  String get rulesKindRuleHelp => 'An instruction agnts follows on every ticket.';

  @override
  String get rulesKindContextHelp =>
      'Knowledge about your product: what its terms mean, invariants the code must keep, who uses what. Every run reads it before it starts.';

  @override
  String get rulesTag_reuse => 'reuse';

  @override
  String get rulesTag_layer => 'layer';

  @override
  String get rulesTag_tests => 'tests';

  @override
  String get rulesTag_style => 'style';

  @override
  String get rulesTag_logic => 'logic';

  @override
  String get rulesTag_other => 'other';

  @override
  String get runsNavRuns => 'Runs';

  @override
  String get runsTitle => 'Run history';

  @override
  String get runsLede =>
      'Every Claude Code and Codex invocation across workspaces: what it cost, how long it took and how it ended. Opening one shows customer content, and every read is logged.';

  @override
  String get runsRunTitle => 'Invocation';

  @override
  String get runsBack => 'All runs';

  @override
  String get runsSettings => 'Settings';

  @override
  String get runsSumCount => 'Invocations';

  @override
  String get runsSumErrors => 'Error rate';

  @override
  String runsSumErrorsNote(String n) {
    return '$n ended in an error, timeout or out of memory';
  }

  @override
  String get runsSumStalls => 'Had stalls';

  @override
  String get runsSumStallsNote => 'invocations with at least one stall';

  @override
  String get runsSumCost => 'Cost';

  @override
  String runsSumCostNote(String cost) {
    return 'background $cost';
  }

  @override
  String get runsSumTokens => 'Tokens in / out';

  @override
  String get runsSumTokensNote => 'without cache reads';

  @override
  String get runsSumDuration => 'Duration p50 / p95';

  @override
  String get runsSumDurationNote => 'of finished invocations';

  @override
  String get runsFWorkspace => 'Workspace';

  @override
  String get runsAllWorkspaces => 'All workspaces';

  @override
  String get runsFPurpose => 'Purpose';

  @override
  String get runsAllPurposes => 'All purposes';

  @override
  String get runsPStages => 'Ticket stages';

  @override
  String get runsPBackground => 'Background calls';

  @override
  String get runsP_analyze => 'Analysis';

  @override
  String get runsP_code => 'Coding';

  @override
  String get runsP_review => 'Review';

  @override
  String get runsP_push => 'Push';

  @override
  String get runsP_learn => 'Learning';

  @override
  String get runsP_preview => 'Preview';

  @override
  String get runsP_second_opinion => 'Second opinion';

  @override
  String get runsP_assistant => 'Assistant';

  @override
  String get runsP_brief => 'Repository brief';

  @override
  String get runsP_detect => 'Toolchain detection';

  @override
  String get runsP_reflect => 'Reflection';

  @override
  String get runsP_rules => 'Rules';

  @override
  String get runsP_translate => 'Translation';

  @override
  String get runsFStatus => 'Status';

  @override
  String get runsAnyStatus => 'Any status';

  @override
  String get runsS_running => 'Running';

  @override
  String get runsS_done => 'Done';

  @override
  String get runsS_error => 'Error';

  @override
  String get runsS_timeout => 'Timed out';

  @override
  String get runsS_cancelled => 'Cancelled';

  @override
  String get runsS_oom => 'Out of memory';

  @override
  String get runsFEngine => 'Engine';

  @override
  String get runsAnyEngine => 'Any engine';

  @override
  String get runsE_claude => 'Claude';

  @override
  String get runsE_codex => 'Codex';

  @override
  String get runsFModel => 'Model';

  @override
  String get runsFTicket => 'Ticket';

  @override
  String get runsFStalled => 'Had stalls';

  @override
  String get runsFPeriod => 'Period';

  @override
  String get runsPer_1d => 'Last 24 hours';

  @override
  String get runsPer_7d => 'Last 7 days';

  @override
  String get runsPer_30d => 'Last 30 days';

  @override
  String get runsPer_all => 'All time';

  @override
  String get runsFMinCost => 'Min. cost';

  @override
  String get runsClear => 'Clear filters';

  @override
  String get runsNone => 'No invocations match these filters.';

  @override
  String get runsLoadMore => 'Load more';

  @override
  String get runsColStarted => 'Started';

  @override
  String get runsColWorkspace => 'Workspace';

  @override
  String get runsColTicket => 'Ticket or subject';

  @override
  String get runsColPurpose => 'Purpose';

  @override
  String get runsColModel => 'Model';

  @override
  String get runsColTurns => 'Turns';

  @override
  String get runsColTools => 'Tools';

  @override
  String get runsColCost => 'Cost';

  @override
  String get runsColDuration => 'Duration';

  @override
  String get runsColOutcome => 'Outcome';

  @override
  String runsToolsTitle(String calls, String errors) {
    return '$calls tool calls, $errors failed';
  }

  @override
  String runsStallsTitle(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n stalls', one: '$n stall');
    return '$_temp0';
  }

  @override
  String get runsSettingsTitle => 'Run history settings';

  @override
  String get runsSettingsSub =>
      'How long transcripts are kept and how much of each is stored. Caps apply to invocations started after saving.';

  @override
  String get runsSet_retentionDays => 'Keep transcripts, days';

  @override
  String get runsSet_retentionDaysHelp => 'Older ones are deleted daily; 0 keeps them';

  @override
  String get runsSet_toolOutputKB => 'Tool output cap, KB';

  @override
  String get runsSet_toolOutputKBHelp => 'One tool\'s output; its start and end are kept';

  @override
  String get runsSet_textKB => 'Text cap, KB';

  @override
  String get runsSet_textKBHelp => 'One text block or tool input';

  @override
  String get runsSet_transcriptMB => 'Transcript cap, MB';

  @override
  String get runsSet_transcriptMBHelp => 'Past it only tool calls and the result are kept';

  @override
  String get runsSettingsSave => 'Save';

  @override
  String get runsSettingsSaved => 'Run history settings saved';

  @override
  String get runsBanner => 'Viewing customer content. This access is logged.';

  @override
  String get runsDownload => 'Download JSONL';

  @override
  String get runsNotFound => 'This transcript no longer exists.';

  @override
  String get runsUnreadable => 'Part of this transcript could not be read; what follows is what could.';

  @override
  String get runsTruncated => 'The size limit was reached; later content was left out.';

  @override
  String get runsAccount => 'Claude account';

  @override
  String get runsSession => 'Session';

  @override
  String get runsStartedAt => 'Started';

  @override
  String get runsFinishedAt => 'Finished';

  @override
  String get runsTokens => 'Tokens';

  @override
  String runsTokensVal(String input, String output) {
    return '$input in · $output out';
  }

  @override
  String runsCacheVal(String read, String write) {
    return 'cache: $read read · $write written';
  }

  @override
  String get runsSize => 'Stored / raw size';

  @override
  String get runsExitReason => 'Exit reason';

  @override
  String get runsRunningNote => 'Still running. Reloading reads the transcript again, which is logged.';

  @override
  String get runsReload => 'Reload';

  @override
  String get runsSiblings => 'This run\'s invocations';

  @override
  String get runsSiblingsSub => 'First pass, fix attempts and second opinion, oldest first';

  @override
  String get runsThisOne => 'this one';

  @override
  String get runsTab_timeline => 'Timeline';

  @override
  String get runsTab_prompt => 'Prompt';

  @override
  String get runsTab_result => 'Result';

  @override
  String runsEventsCount(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n events', one: '$n event');
    return '$_temp0';
  }

  @override
  String runsNextError(String n) {
    return 'Next error ($n)';
  }

  @override
  String get runsNoErrors => 'No errors';

  @override
  String get runsNoEvents => 'Nothing was recorded.';

  @override
  String runsShowMore(String n) {
    return 'Show $n more';
  }

  @override
  String get runsKTool => 'Tool';

  @override
  String get runsKToolResult => 'Tool result';

  @override
  String get runsKInit => 'Start';

  @override
  String get runsKRateLimit => 'Rate limit';

  @override
  String get runsKNote => 'agnts';

  @override
  String get runsKResult => 'Result';

  @override
  String get runsToolOk => 'Succeeded';

  @override
  String get runsToolFailed => 'Failed';

  @override
  String runsExitCode(String code) {
    return 'exit $code';
  }

  @override
  String get runsInput => 'Input';

  @override
  String get runsOutput => 'Output';

  @override
  String get runsNoOutput => '(no output)';

  @override
  String runsCutNote(String kb) {
    return 'cut, original $kb KB';
  }

  @override
  String runsTurnsN(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n turns', one: '$n turn');
    return '$_temp0';
  }

  @override
  String get runsNoPrompt => '(empty prompt)';

  @override
  String get runsNoResult => 'No result was recorded.';

  @override
  String get runsSubtype => 'Subtype';

  @override
  String get runsAuditTitle => 'Audit log';

  @override
  String get runsAuditLede =>
      'Every time an Admin read customer content (a transcript, a prompt, a download) or changed run history settings, newest first.';

  @override
  String get runsAllActions => 'All actions';

  @override
  String get runsA_transcript_view => 'Viewed a transcript';

  @override
  String get runsA_transcript_prompt => 'Viewed a prompt';

  @override
  String get runsA_transcript_download => 'Downloaded a transcript';

  @override
  String get runsA_run_history_settings => 'Changed settings';

  @override
  String get runsColTime => 'Time';

  @override
  String get runsColAdmin => 'Admin';

  @override
  String get runsColAction => 'Action';

  @override
  String get runsColTarget => 'Target';

  @override
  String get runsColIp => 'IP';

  @override
  String get runsNoAudit => 'Nothing in the audit log yet.';

  @override
  String get runsAuditSearch => 'Search admin, target or workspace';

  @override
  String runsAuditTranscript(String id) {
    return 'Transcript #$id';
  }

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
  String get settingsCommits => 'Commits and PR';

  @override
  String get settingsCommitsSub => 'Who commits appear from, and how pull requests open';

  @override
  String get settingsAuthorName => 'Author name';

  @override
  String get settingsAuthorNameHelp => 'Leave empty to commit as each ticket\'s owner, with the name and email of their account';

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
  String get settingsProgress => 'When an agent finishes a step';

  @override
  String get settingsProgressHelp => 'Analysis done, code written. Phone only, silent, one notification per ticket';

  @override
  String get settingsLessons => 'When agnts finds something new to learn';

  @override
  String get settingsReviewDone => 'When agnts\'s code review finishes';

  @override
  String get settingsSecretsHelp => 'Tokens for Jira, GitHub and Claude are stored encrypted on your server. This page never shows them.';

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String settingsParallelSlots(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n runs', one: '$n run');
    return '$_temp0 at once';
  }

  @override
  String get settingsParallelSlotsHelp => 'The workspace\'s slots. Change them in Workspace → Billing.';

  @override
  String get settingsClaudeMoved => 'Claude is connected per workspace now.';

  @override
  String get settingsClaudeOpen => 'Workspace → Claude';

  @override
  String get settingsSelfReview => 'Fix review findings first';

  @override
  String get settingsSelfReviewHelp =>
      'When agnts\'s own code review finds a blocker or major problem, agnts sends it back to the coder once before you review. Needs the code review above.';

  @override
  String get settingsAutoBrief => 'Survey repositories';

  @override
  String get settingsAutoBriefHelp =>
      'Write a repository brief (architecture, recipes, conventions) when a repository\'s first ticket is analysed, and update it after every 10 merges. A brief reaches the agent only after you approve it.';

  @override
  String get settingsReflect => 'Learn from your feedback';

  @override
  String get settingsReflectHelp =>
      'When you ask for changes or reject work with a reason, agnts looks for a convention behind it and suggests a rule on the Rules page. Nothing applies until you adopt it.';

  @override
  String get settingsCiRed => 'When a watched branch goes red';

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
  String get stateReviewAnalyzing => 'Fetching';

  @override
  String get stateReviewCoding => 'Reviewing';

  @override
  String get stateReviewWaiting_for_review => 'Review ready';

  @override
  String get stateReviewPushing => 'Merging';

  @override
  String get stateReviewDone => 'Merged';

  @override
  String get stateReviewRejected => 'Dismissed';

  @override
  String get swaggerFormSub =>
      'Test an HTTP API against its Swagger/OpenAPI spec: agnts plans the cases, sends real requests and reports a verdict per case with the evidence.';

  @override
  String get swaggerSpec => 'Spec';

  @override
  String get swaggerSpecUrl => 'Spec or docs page URL';

  @override
  String get swaggerSpecUrlPh => 'https://staging.example.com/swagger/index.html';

  @override
  String get swaggerSpecRead => 'Read';

  @override
  String get swaggerSpecReading => 'Reading the spec…';

  @override
  String get swaggerSpecUpload => 'Upload a file';

  @override
  String get swaggerSpecHint =>
      'A Swagger UI, Springdoc or Redoc page works too: agnts finds the spec behind it. Swagger 2.0 and OpenAPI 3.x, up to 5 MB.';

  @override
  String swaggerSpecFound(String title, String version, num count, String format) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count endpoints', one: '$count endpoint');
    return '$title $version · $_temp0 · $format';
  }

  @override
  String get swaggerSpecChoose => 'This page offers several specs. Pick one:';

  @override
  String get swaggerBaseUrl => 'Base URL';

  @override
  String get swaggerBaseUrlHint =>
      'Where requests go. It starts as the spec\'s server, which often is production: check it. A host name or an IP, on any port. Internal hosts need a Private network route.';

  @override
  String get swaggerEndpoints => 'Endpoints';

  @override
  String swaggerEndpointsCount(String n, String total) {
    return '$n of $total ticked';
  }

  @override
  String get swaggerSearch => 'Search endpoints';

  @override
  String get swaggerAll => 'All';

  @override
  String get swaggerNone => 'None';

  @override
  String swaggerUntickedSideEffect(String word) {
    return 'Left unticked: its name suggests it changes something ($word)';
  }

  @override
  String get swaggerUntickedDeprecated => 'Left unticked: deprecated';

  @override
  String get swaggerAuth => 'Authentication';

  @override
  String get swaggerAuthKind_none => 'None';

  @override
  String get swaggerAuthKind_bearer => 'Bearer token';

  @override
  String get swaggerAuthKind_header => 'API key in a header';

  @override
  String get swaggerAuthKind_query => 'API key in the query';

  @override
  String get swaggerAuthKind_basic => 'Basic';

  @override
  String get swaggerAuthName => 'Header or parameter name';

  @override
  String get swaggerAuthValue => 'Token';

  @override
  String get swaggerAuthValueBasic => 'user:password, or the Basic token';

  @override
  String get swaggerAuthHint =>
      'Use a test account\'s token, never a personal or production one. It is sealed, never shown again, and deleted when the ticket closes.';

  @override
  String swaggerAuthFromSpec(String schemes) {
    return 'The spec declares: $schemes';
  }

  @override
  String get swaggerWrite => 'Requests';

  @override
  String get swaggerWriteOff => 'Read-only';

  @override
  String get swaggerWriteOffHint => 'Only GET, HEAD and OPTIONS';

  @override
  String get swaggerWriteOn => 'Write requests too';

  @override
  String get swaggerWriteOnHint => 'Also POST, PUT, PATCH and DELETE';

  @override
  String swaggerWriteConfirm(String url) {
    return 'I confirm $url is not production';
  }

  @override
  String get swaggerWriteConfirmNeeded => 'Confirm the base URL is not production to send write requests.';

  @override
  String get swaggerReadOnlyNote =>
      'Read-only means only GET, HEAD and OPTIONS, not harmless: some APIs change things on GET. That is your call.';

  @override
  String get swaggerLockoutNote =>
      'The no-token and wrong-token cases can look like a login attack to a firewall. A test sends at most 3 of them, but it may still lock the test account or get the caller\'s address blocked. Behind a Private network, that address is the workspace\'s VPN connection, which GitLab and other tests also use.';

  @override
  String get swaggerRepository => 'Repository (optional)';

  @override
  String get swaggerRepositoryHint =>
      'With one, agnts reads the handlers to explain failures, and failures can become a Bug or Code ticket.';

  @override
  String get swaggerNoRepo => 'No repository';

  @override
  String get swaggerNotes => 'Notes';

  @override
  String get swaggerNotesPh => 'For example: user 42 is a test account; orders need an existing product id';

  @override
  String get swaggerLimits => 'Limits';

  @override
  String get swaggerRate => 'Requests a second';

  @override
  String get swaggerMaxRequests => 'Requests per run';

  @override
  String get swaggerStart => 'Start';

  @override
  String get swaggerStartNow => 'Now';

  @override
  String get swaggerStartQueue => 'Keep in the queue';

  @override
  String get swaggerCreate => 'Create test';

  @override
  String get swaggerCreateStart => 'Create and start';

  @override
  String swaggerCreated(String key) {
    return '$key created';
  }

  @override
  String get swaggerNeedSpec => 'Read a spec first.';

  @override
  String get swaggerNeedToken => 'Enter the token.';

  @override
  String get swaggerClaudeOnly => 'Swagger tests always run on Claude (Sonnet), whatever model the workspace codes with.';

  @override
  String get swaggerTab => 'API results';

  @override
  String get swaggerRequestsTab => 'Requests';

  @override
  String get swaggerNoRun => 'No results yet: the test is running or has not run.';

  @override
  String get swaggerVerdict_pass => 'Passed';

  @override
  String get swaggerVerdict_fail => 'Failed';

  @override
  String get swaggerVerdict_skipped => 'Skipped';

  @override
  String get swaggerVerdict_blocked => 'Blocked';

  @override
  String swaggerCount_pass(String n) {
    return '$n passed';
  }

  @override
  String swaggerCount_fail(String n) {
    return '$n failed';
  }

  @override
  String swaggerCount_skipped(String n) {
    return '$n skipped';
  }

  @override
  String swaggerCount_blocked(String n) {
    return '$n blocked';
  }

  @override
  String get swaggerColEndpoint => 'Endpoint';

  @override
  String get swaggerColCases => 'Cases';

  @override
  String get swaggerColResult => 'Result';

  @override
  String get swaggerAgntsCheck => 'agnts check';

  @override
  String get swaggerAgntsCheckHint => 'agnts checked this response against the spec\'s schema itself';

  @override
  String swaggerExpected(String text) {
    return 'Expected: $text';
  }

  @override
  String get swaggerRequestLabel => 'Request';

  @override
  String get swaggerResponseLabel => 'Response';

  @override
  String get swaggerNoResponse => 'No response';

  @override
  String get swaggerTruncated => 'The body was cut at 64 KB';

  @override
  String get swaggerCopyCurl => 'Copy as curl';

  @override
  String get swaggerCopied => 'Copied';

  @override
  String get swaggerLoading => 'Loading…';

  @override
  String get swaggerCreateBug => 'Create bug ticket';

  @override
  String swaggerBugTitle(String key) {
    return 'Fix the API failures $key found';
  }

  @override
  String swaggerBugIntro(String key, String base) {
    return 'The Swagger test $key of $base found these failures:';
  }

  @override
  String swaggerBugCreated(String key) {
    return '$key created';
  }

  @override
  String swaggerNewFailures(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n new failures', one: '$n new failure');
    return '$_temp0 since the last run';
  }

  @override
  String get swaggerNoNewFailures => 'No new failures since the last run';

  @override
  String swaggerPrevious(String passed, String failed) {
    return 'Last run: $passed passed, $failed failed';
  }

  @override
  String get swaggerRerun => 'Run again';

  @override
  String get swaggerRerunToken => 'New token (optional)';

  @override
  String get swaggerRerunTokenNeeded => 'New token (required: the old one was deleted when the ticket closed)';

  @override
  String get swaggerRerunStarted => 'Started again';

  @override
  String swaggerRerunNew(String key) {
    return 'Started again as $key';
  }

  @override
  String get swaggerModeRead => 'read-only';

  @override
  String get swaggerModeWrite => 'write requests on';

  @override
  String get swaggerTokenStored => 'token stored';

  @override
  String get swaggerTokenGone => 'no token stored';

  @override
  String get swaggerAgntsNotes => 'What agnts adjusted';

  @override
  String get swaggerAllPassed => 'Every case passed.';

  @override
  String get swaggerRunningTitle => 'Testing the API';

  @override
  String get swaggerRunningSub => 'agnts plans the cases and sends real requests to the base URL. Results appear here when the run ends.';

  @override
  String get swaggerQueuedTitle => 'Swagger test in the queue';

  @override
  String get swaggerQueuedSub => 'Start it when you are ready.';

  @override
  String get swaggerSuites => 'Swagger suites';

  @override
  String get swaggerSuitesLede =>
      'Saved Swagger tests that run again on a schedule or after each deploy. Each run is a new ticket, compared with the suite\'s last run, and reuses its plan, so repeat runs cost fewer turns.';

  @override
  String get swaggerSuitesEmpty => 'No suites yet. Open a finished Swagger test and save it as a suite.';

  @override
  String get swaggerSaveSuite => 'Save as suite';

  @override
  String get swaggerSaveSuiteHint => 'Run this test again on a schedule or after each deploy. The suite keeps its own copy of the token.';

  @override
  String get swaggerSuiteName => 'Name';

  @override
  String get swaggerSchedule => 'Schedule';

  @override
  String get swaggerSchedule_off => 'By hand or deploy hook';

  @override
  String get swaggerSchedule_hourly => 'Every hour';

  @override
  String get swaggerSchedule_daily => 'Every day';

  @override
  String get swaggerSchedule_weekly => 'Every Monday';

  @override
  String get swaggerHourUtc => 'At (UTC hour)';

  @override
  String swaggerSuiteSaved(String name) {
    return 'Saved as the suite $name';
  }

  @override
  String get swaggerRunNow => 'Run now';

  @override
  String swaggerRunStarted(String key) {
    return '$key started';
  }

  @override
  String get swaggerBusy => 'The last run is still going';

  @override
  String get swaggerPause => 'Pause';

  @override
  String get swaggerResume => 'Resume';

  @override
  String get swaggerPaused => 'Paused';

  @override
  String get swaggerDeleteSuite => 'Delete';

  @override
  String swaggerDeleteConfirm(String name) {
    return 'Delete the suite $name? Its past runs stay.';
  }

  @override
  String get swaggerHookCreate => 'Create deploy hook';

  @override
  String get swaggerHookRotate => 'New deploy hook';

  @override
  String get swaggerHookHint =>
      'POST this URL from your deploy pipeline, with no body, to run the suite after each deploy. It is shown once; making a new one stops the old.';

  @override
  String swaggerHookExample(String url) {
    return 'curl -X POST $url';
  }

  @override
  String get swaggerLastRun => 'Last run';

  @override
  String get swaggerNextRun => 'Next run';

  @override
  String get swaggerNever => 'never';

  @override
  String get swaggerColSuite => 'Suite';

  @override
  String get swaggerColSchedule => 'Schedule';

  @override
  String get swaggerColLast => 'Last run';

  @override
  String get swaggerSuiteToken => 'New token (optional)';

  @override
  String get swaggerSetToken => 'Set token';

  @override
  String get swaggerSpecAuth => 'The spec link needs a sign-in';

  @override
  String get swaggerSpecAuthHint => 'Sent with the spec fetch to the spec\'s host only, and not stored.';

  @override
  String get swaggerSpecAuthNeeded => 'The spec URL answered 401/403: give the token it needs, then read it again.';

  @override
  String get swaggerSpecAuthReused => 'The API requests use this token too. Change it here if they need another.';

  @override
  String get swaggerSpecAuthLogin => 'Login and password';

  @override
  String get swaggerSpecAuthToken => 'Token';

  @override
  String get swaggerSpecLogin => 'Login';

  @override
  String get swaggerSpecPassword => 'Password';

  @override
  String get swaggerSpecLoginNeeded => 'The spec link asks for a login and password: enter them, then read it again.';

  @override
  String get swaggerSpecLoginHint =>
      'Opens the spec link only, and is not stored. The agent\'s API requests use the token under Authentication below.';

  @override
  String get swaggerFilterProblems => 'Failures and blocked';

  @override
  String get swaggerFilterAll => 'All cases';

  @override
  String get swaggerNothingToShow => 'Nothing failed or was blocked. Show all cases to see the rest.';

  @override
  String swaggerCasesHidden(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n endpoints', one: '$n endpoint');
    return '$_temp0 without failures hidden';
  }

  @override
  String get swaggerWhatToTest => 'What to test';

  @override
  String get swaggerWhatToTestPh =>
      'For example: only the POST endpoints under /v1/orders and /v1/payments; check validation errors and unknown ids. User 42 is a test account.';

  @override
  String get swaggerWhatToTestHint => 'agnts tests only what you write here. To test exact endpoints instead, tick them below.';

  @override
  String get swaggerWhatToTestNeeded => 'Write what to test, or tick the endpoints to test.';

  @override
  String get swaggerEndpointsOptional => 'Pick endpoints (optional)';

  @override
  String get swaggerEndpointsOptionalHint =>
      'Ticked endpoints are tested exactly as ticked. With none ticked, the text above decides what is tested.';

  @override
  String get swaggerSuggested => 'Suggested';

  @override
  String get swaggerNoneTicked => 'none ticked: the text above decides';

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
  String get tasksTicketNumber => 'Ticket number';

  @override
  String get tasksTicketNumberPh => 'For example: AMANAT-2288';

  @override
  String get tasksTicketNumberHelp =>
      'Optional. Your team\'s number for this work, used in branch and commit names in place of the task key.';

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
  String ticketUpdateTitle(String source) {
    return 'Changed in $source after agnts started';
  }

  @override
  String get ticketUpdateSub =>
      'agnts keeps working on the version it started with. Restart to drop the work so far and start over from the new version, or keep going with the current one.';

  @override
  String ticketUpdateNow(String when) {
    return 'New version, $when';
  }

  @override
  String get ticketUpdateRestart => 'Restart with the new version';

  @override
  String get ticketUpdateKeep => 'Keep the current version';

  @override
  String ticketUpdateRestartConfirm(String key, String source) {
    return 'Restart $key with the new version from $source? The analysis, answers, commits and reviews so far are dropped, and agnts starts over.';
  }

  @override
  String get ticketUpdatePushed =>
      'Pushed already: it cannot restart. Reject it and let agnts take the issue again, or keep the current version.';

  @override
  String ticketUpdateRestarted(String key) {
    return '$key restarts with the new version';
  }

  @override
  String get ticketUpdateKept => 'agnts keeps working on the current version';

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
    return 'Stop all work on $key? You can continue it later.';
  }

  @override
  String ticketRejectPushingConfirm(String key) {
    return 'Stop pushing $key? What already reached the git host stays there. You can continue it later.';
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
  String get ticketDraftSaving => 'Saving draft…';

  @override
  String get ticketDraftSaved => 'Draft saved';

  @override
  String get ticketDraftFailed => 'Draft not saved, will try again';

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
  String get ticketChecksSkipped => 'Skipped for this ticket';

  @override
  String get ticketSkipChecks => 'Skip checks: go to review on the code alone';

  @override
  String get ticketSkipChecksHint =>
      'For checks the run container can\'t run, such as a private dependency it can\'t fetch. Claude won\'t run the build, lint or tests either, so you review the code yourself. It stays on for this ticket until you untick it.';

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
  String get ticketDiffReposLabel => 'Changes by repository';

  @override
  String get ticketDiffOtherRepo => 'Other files';

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
  String get ticketRejectedSubContinue => 'agnts stopped working on this ticket. You can pick it up again where it stopped.';

  @override
  String get ticketContinue => 'Continue';

  @override
  String get ticketContinueNote => 'Note for agnts';

  @override
  String get ticketContinueNoteHint => 'Optional. What to do differently; the next coding run gets it, like requested changes.';

  @override
  String get ticketContinueToNew => 'It goes back to the queue and is analysed again.';

  @override
  String get ticketContinueToAnswers => 'It goes back to its questions; answers given so far are kept.';

  @override
  String get ticketContinueToCoding => 'agnts goes on writing the code where it stopped.';

  @override
  String get ticketContinueToReview => 'It goes back to review. With a note, agnts makes those changes first.';

  @override
  String get ticketContinueToFailed => 'It goes back to the error it stopped with, so you can retry it.';

  @override
  String get ticketContinueToRateLimited => 'It goes back to waiting for the plan limit.';

  @override
  String get ticketStartOver => 'Start over';

  @override
  String ticketStartOverConfirm(String key) {
    return 'Start $key over? The analysis, answers and commits are dropped and agnts analyses it again.';
  }

  @override
  String get ticketFailedTitle => 'agnts stopped';

  @override
  String get ticketFailedUnknown => 'The run stopped. Check the run log for details.';

  @override
  String get ticketRetryNote => 'Note for the retry';

  @override
  String get ticketRetryNoteHint => 'Optional. Tell agnts how to get past the error; the next coding run gets it with the error.';

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
  String get ticketBranchRename => 'Rename';

  @override
  String get ticketBranchRenameHint => 'The pull request opens from this name. Letters, digits, - _ . and /; no spaces.';

  @override
  String get ticketNumberEdit => 'Change';

  @override
  String get ticketNumberSet => 'Set';

  @override
  String get ticketNumberHint =>
      'New branches and commits use it. Existing ones keep their names: rename the branch or re-apply the commit format. Empty uses the key.';

  @override
  String get ticketCommitsTitle => 'Commits';

  @override
  String get ticketCommitsSub => 'agnts pushes these when you approve. Until then you can change their messages.';

  @override
  String get ticketCommitEdit => 'Edit message';

  @override
  String get ticketCommitEditHint =>
      'The subject on the first line, then a blank line and the body. Changing an earlier commit makes the ones after it again with the same changes.';

  @override
  String get ticketCommitsReapply => 'Re-apply format';

  @override
  String get ticketCommitsReapplyHelp =>
      'Writes these messages again from the commit message format (the group\'s, else each repository\'s), with the type, scope and subject of the run that made each commit. Check the preview, then apply.';

  @override
  String ticketCommitsNumber(String number) {
    return 'Ticket number for $number';
  }

  @override
  String get ticketCommitsPreview => 'Preview';

  @override
  String ticketCommitsApply(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'Apply $n changes', one: 'Apply $n change');
    return '$_temp0';
  }

  @override
  String get ticketCommitsUpToDate => 'The messages already match the format.';

  @override
  String get ticketCommitsNotSuggested => 'Not ticked: this message may have been written by hand, and applying would replace it.';

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
  String get ticketDeliveringSub => 'Saving the approved report and posting it to the issue tracker if you asked.';

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
  String get ticketSrcPlane => 'Plane';

  @override
  String ticketReviewSubPlane(String branch) {
    return 'Nothing has left the server yet. Approving pushes $branch, opens a pull request and updates the Plane work item.';
  }

  @override
  String get ticketReviewReportSubPlane =>
      'Approving keeps the report here and closes the ticket. It goes to Plane only if you tick the box below.';

  @override
  String ticketPostReportPlane(String key) {
    return 'Also post the report as a comment on $key in Plane';
  }

  @override
  String ticketApproveReportPostConfirmPlane(String key) {
    return 'Approve the report, close this ticket and post the report to $key in Plane?';
  }

  @override
  String ticketDoneReportPostedPlane(String key) {
    return 'The report is kept here and was posted to $key in Plane.';
  }

  @override
  String get ticketPickAny => 'Pick all that apply';

  @override
  String get ticketCopyQuestions => 'Copy questions';

  @override
  String get ticketOtherAnswer => 'Something else (optional)';

  @override
  String get ticketSrcGit => 'Pull request';

  @override
  String get ticketSrcCi => 'CI failure';

  @override
  String get ticketKvCi => 'CI';

  @override
  String ticketCiFixes(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n times', one: '$n time');
    return 'CI sent the pull request back $_temp0';
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
  String get ticketsRepoLabel => 'Repository';

  @override
  String get ticketsAllRepos => 'All repositories';

  @override
  String get ticketsNoRepo => 'No repository';

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
  String get ticketsListSub => 'Jira and Plane tickets with the agnts label, plus tasks you create for side projects.';

  @override
  String get ticketsNoMatch => 'No tickets match your filters.';

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
  String get ticketsSourcePlane => 'Plane';

  @override
  String get ticketsSourceGit => 'PR';

  @override
  String get ticketsSourceCi => 'CI';

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

  @override
  String get wsTitle => 'Workspace';

  @override
  String get wsSwitcher => 'Switch workspace';

  @override
  String get wsAll => 'All workspaces';

  @override
  String get wsNew => 'New workspace';

  @override
  String get wsRole_owner => 'Owner';

  @override
  String get wsRole_user => 'Member';

  @override
  String get wsTabGeneral => 'General';

  @override
  String get wsTabMembers => 'Members';

  @override
  String get wsTabClaude => 'Claude';

  @override
  String get wsTabBilling => 'Billing';

  @override
  String get wsGeneral => 'Workspace';

  @override
  String get wsGeneralSub => 'Its name and the address in links.';

  @override
  String get wsName => 'Name';

  @override
  String get wsSlug => 'Address';

  @override
  String wsSlugHelp(String slug) {
    return 'Links to this workspace: /w/$slug. Old links stop working when it changes.';
  }

  @override
  String get wsSave => 'Save';

  @override
  String get wsSaved => 'Workspace saved';

  @override
  String get wsReadOnly => 'Only the owner can change this.';

  @override
  String get wsPlan => 'Plan';

  @override
  String get wsSlots => 'Parallel runs';

  @override
  String get wsSlotsHelp => 'How many runs this workspace may have at once. Change it in Billing.';

  @override
  String wsTrialEnds(String date) {
    return 'Trial until $date';
  }

  @override
  String get wsSuspended => 'This workspace is suspended: nothing new starts until it is resumed.';

  @override
  String get wsDanger => 'Danger zone';

  @override
  String get wsDangerSub =>
      'Deleting stops every run and removes the workspace, its repositories\' copies, tickets and history. It is kept 7 days for undo, then purged.';

  @override
  String get wsDelete => 'Delete workspace';

  @override
  String wsDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String wsDeleteBody(String slug) {
    return 'Type the address ($slug) to confirm. Everyone loses access.';
  }

  @override
  String get wsDeleted => 'Workspace deleted';

  @override
  String get wsMembers => 'Members';

  @override
  String get wsMembersSub =>
      'Everyone in the workspace sees its tickets and can create, answer, review and retry them. The owner also manages settings, integrations, Claude, members and billing.';

  @override
  String get wsYou => 'you';

  @override
  String get wsRemove => 'Remove';

  @override
  String wsRemoveTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String get wsRemoveBody => 'They lose access to this workspace. Their tickets stay.';

  @override
  String wsRemoved(String name) {
    return '$name removed';
  }

  @override
  String get wsMakeOwner => 'Make owner';

  @override
  String wsTransferTitle(String name) {
    return 'Make $name the owner?';
  }

  @override
  String get wsTransferBody => 'You stay a member but can no longer change settings, members or billing.';

  @override
  String wsTransferred(String name) {
    return '$name is the owner now';
  }

  @override
  String get wsLeave => 'Leave workspace';

  @override
  String wsLeaveTitle(String name) {
    return 'Leave $name?';
  }

  @override
  String get wsLeaveBody => 'You lose access until someone invites you again.';

  @override
  String get wsOwnerCannotLeave => 'The owner cannot leave: make someone else the owner first.';

  @override
  String get wsClaudeBadge => 'Claude connected';

  @override
  String get wsNoClaudeBadge => 'No Claude';

  @override
  String get wsInvite => 'Invite people';

  @override
  String get wsInviteSub => 'Send a link by email, or make a link to share yourself. Links work for 7 days and once.';

  @override
  String get wsInviteEmail => 'Email (optional)';

  @override
  String get wsInviteSend => 'Create invite';

  @override
  String get wsInviteLink => 'Invite link (shown once)';

  @override
  String wsInviteEmailed(String email) {
    return 'Sent to $email';
  }

  @override
  String get wsInviteCopy => 'Copy';

  @override
  String get wsInvites => 'Open invites';

  @override
  String get wsInviteAnyone => 'Anyone with the link';

  @override
  String wsInviteExpires(String date) {
    return 'expires $date';
  }

  @override
  String get wsRevoke => 'Revoke';

  @override
  String get wsRevoked => 'Invite revoked';

  @override
  String wsMemberLimit(String n, String limit) {
    return '$n of $limit members';
  }

  @override
  String wsMemberLimitNone(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n members', one: '$n member');
    return '$_temp0';
  }

  @override
  String get wsClaude => 'Claude';

  @override
  String get wsClaudeSub => 'Which Claude account this workspace\'s runs use.';

  @override
  String get wsMode => 'Mode';

  @override
  String get wsModeShared => 'Shared';

  @override
  String get wsModeSharedHelp => 'Every run uses the workspace\'s account, set here by the owner.';

  @override
  String get wsModeMember => 'Per member';

  @override
  String get wsModeMemberHelp => 'Each run uses the account of the ticket\'s member. Members connect theirs in their profile.';

  @override
  String get wsConnection => 'Workspace account';

  @override
  String get wsConnectionSub => 'Used by every run in shared mode.';

  @override
  String get wsKind => 'Kind';

  @override
  String get wsKindSubscription => 'Claude subscription';

  @override
  String get wsKindApiKey => 'Anthropic API key';

  @override
  String get wsKindSubscriptionHelp => 'Run `claude setup-token` where you are signed in to your Claude plan, and paste the token.';

  @override
  String get wsKindApiKeyHelp => 'Create a key in the Anthropic Console (sk-ant-api…). Usage is billed by Anthropic to its owner.';

  @override
  String get wsKeyStep1 => 'Sign in to the Claude Console (button below) and open Settings → API keys.';

  @override
  String get wsKeyStep2 => 'Click Create Key, name it (for example agnts) and pick the Console workspace it bills to.';

  @override
  String get wsKeyStep3 => 'Copy the key (it starts with sk-ant-api) and paste it below. The Console shows it only once.';

  @override
  String get wsKeyStep4 => 'Runs are billed per token to that Console account: add credits and set a spend limit under Billing.';

  @override
  String get wsKeyOpen => 'Open the Claude Console';

  @override
  String get wsSubscriptionsOff => 'This server takes Anthropic API keys only.';

  @override
  String get wsToken => 'Token';

  @override
  String get wsConnect => 'Connect';

  @override
  String get wsReplace => 'Replace';

  @override
  String get wsDisconnect => 'Disconnect';

  @override
  String get wsConnected => 'Connected';

  @override
  String get wsNotConnected => 'Not connected';

  @override
  String wsPausedUntil(String time) {
    return 'At its limit until $time';
  }

  @override
  String wsConnectedAs(String account, String hint) {
    return '$account · …$hint';
  }

  @override
  String get wsFallback => 'Continue on credits';

  @override
  String get wsFallbackHelp =>
      'When the chosen account is at its limit or missing, runs continue on agnts\'s API key and spend the workspace\'s credits instead of pausing.';

  @override
  String get wsFallbackOff => 'Credits are not available on this server.';

  @override
  String wsCredits(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n credits', one: '$n credit');
    return '$_temp0';
  }

  @override
  String get wsDefaultMember => 'Tickets without a person';

  @override
  String get wsDefaultMemberHelp => 'Tickets from Jira, Plane, follow-ups and incidents run on this member\'s account in per-member mode.';

  @override
  String get wsDefaultOwner => 'The owner';

  @override
  String get wsMemberAccounts => 'Members\' accounts';

  @override
  String get wsMemberAccountsSub => 'Who has connected their own Claude account (Profile → Claude).';

  @override
  String get wsYourAccount => 'Connect yours in your profile';

  @override
  String get wsClaudeSaved => 'Claude settings saved';

  @override
  String get wsRole_viewer => 'Viewer';

  @override
  String get wsViewerBanner => 'You are a viewer here: you can see everything, but you cannot change anything.';

  @override
  String get wsInviteAs => 'Joins as';

  @override
  String get wsInviteAsHelp => 'Members work on tickets; viewers only look.';

  @override
  String wsRoleChanged(String name, String role) {
    return '$name is now $role';
  }

  @override
  String wsRoleLabel(String name) {
    return 'Role of $name';
  }

  @override
  String get codechatTitle => 'Code';

  @override
  String get codechatModeLabel => 'Chat mode';

  @override
  String get codechatModeChat => 'Chat';

  @override
  String get codechatModeCode => 'Code';

  @override
  String get codechatNewConversation => 'New Code conversation';

  @override
  String get codechatEmptyTitle => 'Change code from the chat';

  @override
  String get codechatEmptyText =>
      'Pick the repositories and say what you want done. agnts works on it as a ticket: follow it here, answer its questions, ask for changes and approve the pull request.';

  @override
  String get codechatViewersOnly => 'Code mode is for people who can change the workspace.';

  @override
  String get codechatRepos => 'Repositories';

  @override
  String get codechatReposNone => 'Pick the repositories to work in';

  @override
  String get codechatReposChange => 'Change';

  @override
  String get codechatReposSave => 'Save repositories';

  @override
  String get codechatReposSaved => 'Repositories changed: the next ticket works in them';

  @override
  String get codechatKind => 'Kind';

  @override
  String get codechatQuick => 'Quick: skip checks';

  @override
  String get codechatQuickHint => 'Build, lint and tests don\'t run, so review comes sooner.';

  @override
  String get codechatTicketPick => 'Or work on an existing ticket';

  @override
  String get codechatTicketPlaceholder => 'Ticket key, e.g. PAY-214';

  @override
  String get codechatTicketAttach => 'Attach';

  @override
  String codechatTicketAttached(String key) {
    return 'Now working on $key';
  }

  @override
  String get codechatPlaceholderNew => 'Describe the change…';

  @override
  String get codechatPlaceholderReview => 'Ask for changes, or approve above…';

  @override
  String get codechatPlaceholderAnswers => 'Answer the question…';

  @override
  String get codechatPlaceholderRunning => 'Add to the request: it is sent when this run ends…';

  @override
  String get codechatPlaceholderStopped => 'Say how to get past this, and it retries…';

  @override
  String get codechatPlaceholderPushing => 'Pushing now…';

  @override
  String get codechatPlaceholderDone => 'Ask for the next change…';

  @override
  String get codechatSend => 'Send';

  @override
  String get codechatSendHint => 'Enter sends, Shift+Enter makes a new line';

  @override
  String codechatCount(String n) {
    return '$n / 4000';
  }

  @override
  String codechatRoutedCreated(String key) {
    return 'Started $key';
  }

  @override
  String codechatRoutedAnswered(String key) {
    return 'Answered $key';
  }

  @override
  String codechatRoutedChanges(String key) {
    return 'Asked $key for changes';
  }

  @override
  String codechatRoutedContinued(String key) {
    return 'Continued $key';
  }

  @override
  String codechatRoutedRetried(String key) {
    return 'Retried $key';
  }

  @override
  String codechatRoutedQueued(String key) {
    return 'Waits for $key\'s run to end';
  }

  @override
  String codechatRoutedSent(String key) {
    return 'Sent to $key';
  }

  @override
  String codechatRoutedFailed(String reason) {
    return 'Not sent: $reason';
  }

  @override
  String get codechatRoutedSteered => 'Delivered to the running agent';

  @override
  String codechatQueuedTitle(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n messages wait', one: '$n message waits');
    return '$_temp0 for this run to end';
  }

  @override
  String get codechatSendNow => 'Stop and send now';

  @override
  String codechatSendNowTitle(String key) {
    return 'Stop $key now?';
  }

  @override
  String get codechatSendNowText => 'The running stage stops, and your messages go to it at once.';

  @override
  String codechatSteps(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n steps', one: '$n step');
    return '$_temp0';
  }

  @override
  String codechatStateLine(String key, String state) {
    return '$key: $state';
  }

  @override
  String codechatCheckPassed(String name) {
    return '$name passed';
  }

  @override
  String codechatCheckFailed(String name) {
    return '$name failed';
  }

  @override
  String get codechatPrOpened => 'Pull request opened';

  @override
  String get codechatPushed => 'Pushed';

  @override
  String get codechatMerged => 'Merged';

  @override
  String get codechatWorking => 'Working…';

  @override
  String codechatResultTitle(String key) {
    return '$key is ready for your review';
  }

  @override
  String codechatReportTitle(String key) {
    return '$key wrote its report';
  }

  @override
  String codechatFilesChanged(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n files changed', one: '$n file changed');
    return '$_temp0';
  }

  @override
  String get codechatChecksPassed => 'Checks passed';

  @override
  String codechatChecksFailed(String failed, String n) {
    return '$failed of $n checks failed';
  }

  @override
  String get codechatChecksSkipped => 'Checks skipped';

  @override
  String get codechatViewDiff => 'View diff';

  @override
  String get codechatHideDiff => 'Hide diff';

  @override
  String get codechatApprove => 'Approve';

  @override
  String codechatApproveTitle(String key) {
    return 'Approve $key?';
  }

  @override
  String codechatApprovePr(String branch) {
    return 'agnts pushes $branch and opens a pull request.';
  }

  @override
  String get codechatApproveMain => 'agnts pushes the change straight to the default branch.';

  @override
  String get codechatApproveReport => 'The ticket closes with this report.';

  @override
  String get codechatReject => 'Reject';

  @override
  String codechatRejectTitle(String key) {
    return 'Reject $key?';
  }

  @override
  String get codechatRejectText => 'All work on it stops. You can continue it from this chat later.';

  @override
  String get codechatOpenTicket => 'Open ticket';

  @override
  String codechatQuestionsTitle(String key) {
    return '$key asks before it goes on';
  }

  @override
  String get codechatAnswersSend => 'Send answers';

  @override
  String codechatStoppedTitle(String key) {
    return '$key stopped';
  }

  @override
  String get codechatStoppedHint => 'Write how to get past it: it retries with your note.';

  @override
  String codechatDoneTitle(String key) {
    return '$key is done';
  }

  @override
  String get codechatDoneHint => 'Your next message starts a new ticket in the same repositories.';

  @override
  String codechatRejectedTitle(String key) {
    return '$key was rejected';
  }

  @override
  String get codechatRejectedHint => 'Write what to do differently and it continues.';

  @override
  String codechatMovedHint(String key) {
    return '$key moved to another of your conversations.';
  }

  @override
  String get codechatApprovalTitle => 'The agent asks to run this';

  @override
  String codechatApprovalReason(String reason) {
    return 'A rule asks about it: $reason';
  }

  @override
  String get codechatApprovalAllow => 'Allow';

  @override
  String get codechatApprovalDeny => 'Deny';

  @override
  String get codechatApprovalAllowed => 'Allowed';

  @override
  String get codechatApprovalDenied => 'Denied';

  @override
  String get codechatApprovalExpired => 'Nobody answered: denied';

  @override
  String codechatApprovalLeft(String seconds) {
    return '${seconds}s left';
  }

  @override
  String get codechatHandoffTitle => 'Do this in Code';

  @override
  String get codechatHandoffOpen => 'Open in Code';

  @override
  String get codechatTicketChat => 'Discussed in chat';

  @override
  String get codechatContinueInChat => 'Continue in chat';

  @override
  String get codechatCodeBadge => 'Code';

  @override
  String get navAssistantCode => 'Code';
}
