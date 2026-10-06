import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('ru'), Locale('uz')];

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTitle;

  /// No description provided for @analyticsLede.
  ///
  /// In en, this message translates to:
  /// **'How well agnts works for you over time: throughput, quality, where time goes, and what it costs your plan.'**
  String get analyticsLede;

  /// No description provided for @analyticsPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get analyticsPeriod;

  /// No description provided for @analyticsDays.
  ///
  /// In en, this message translates to:
  /// **'{n} days'**
  String analyticsDays(num n);

  /// No description provided for @analyticsExportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get analyticsExportCsv;

  /// No description provided for @analyticsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading analytics…'**
  String get analyticsLoading;

  /// No description provided for @analyticsError.
  ///
  /// In en, this message translates to:
  /// **'Could not load analytics. Try again.'**
  String get analyticsError;

  /// No description provided for @analyticsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No data for this period yet'**
  String get analyticsEmptyTitle;

  /// No description provided for @analyticsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Charts fill in as agnts picks up tickets and runs. Label a Jira issue or create a task to get started.'**
  String get analyticsEmpty;

  /// No description provided for @analyticsKpiPushed.
  ///
  /// In en, this message translates to:
  /// **'Tickets pushed'**
  String get analyticsKpiPushed;

  /// No description provided for @analyticsKpiPushedNote.
  ///
  /// In en, this message translates to:
  /// **'of {n} picked up'**
  String analyticsKpiPushedNote(String n);

  /// No description provided for @analyticsKpiSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success rate'**
  String get analyticsKpiSuccess;

  /// No description provided for @analyticsKpiSuccessNote.
  ///
  /// In en, this message translates to:
  /// **'Pushed out of picked up'**
  String get analyticsKpiSuccessNote;

  /// No description provided for @analyticsKpiFirstTry.
  ///
  /// In en, this message translates to:
  /// **'Approved on first try'**
  String get analyticsKpiFirstTry;

  /// No description provided for @analyticsKpiFirstTryNote.
  ///
  /// In en, this message translates to:
  /// **'No changes requested'**
  String get analyticsKpiFirstTryNote;

  /// No description provided for @analyticsKpiAgnts.
  ///
  /// In en, this message translates to:
  /// **'agnts time per ticket'**
  String get analyticsKpiAgnts;

  /// No description provided for @analyticsKpiAgntsNote.
  ///
  /// In en, this message translates to:
  /// **'Analyze, coding and tests'**
  String get analyticsKpiAgntsNote;

  /// No description provided for @analyticsKpiWait.
  ///
  /// In en, this message translates to:
  /// **'Waiting on you'**
  String get analyticsKpiWait;

  /// No description provided for @analyticsKpiWaitNote.
  ///
  /// In en, this message translates to:
  /// **'Average per ticket'**
  String get analyticsKpiWaitNote;

  /// No description provided for @analyticsKpiTurns.
  ///
  /// In en, this message translates to:
  /// **'Average turns'**
  String get analyticsKpiTurns;

  /// No description provided for @analyticsKpiTurnsNote.
  ///
  /// In en, this message translates to:
  /// **'Per ticket'**
  String get analyticsKpiTurnsNote;

  /// No description provided for @analyticsCompared.
  ///
  /// In en, this message translates to:
  /// **'Changes are compared with the previous {n} days. Green means better.'**
  String analyticsCompared(num n);

  /// No description provided for @analyticsThroughput.
  ///
  /// In en, this message translates to:
  /// **'Throughput'**
  String get analyticsThroughput;

  /// No description provided for @analyticsThroughputSub.
  ///
  /// In en, this message translates to:
  /// **'Tickets picked up and how they ended, per day'**
  String get analyticsThroughputSub;

  /// No description provided for @analyticsPushed.
  ///
  /// In en, this message translates to:
  /// **'Pushed'**
  String get analyticsPushed;

  /// No description provided for @analyticsRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get analyticsRejected;

  /// No description provided for @analyticsStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get analyticsStopped;

  /// No description provided for @analyticsOutcomes.
  ///
  /// In en, this message translates to:
  /// **'Outcomes'**
  String get analyticsOutcomes;

  /// No description provided for @analyticsOutcomesSub.
  ///
  /// In en, this message translates to:
  /// **'How finished tickets ended'**
  String get analyticsOutcomesSub;

  /// No description provided for @analyticsFirstTry.
  ///
  /// In en, this message translates to:
  /// **'Approved on first try'**
  String get analyticsFirstTry;

  /// No description provided for @analyticsAfterChanges.
  ///
  /// In en, this message translates to:
  /// **'Approved after changes'**
  String get analyticsAfterChanges;

  /// No description provided for @analyticsDonutSub.
  ///
  /// In en, this message translates to:
  /// **'pushed'**
  String get analyticsDonutSub;

  /// No description provided for @analyticsSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get analyticsSpeed;

  /// No description provided for @analyticsSpeedSub.
  ///
  /// In en, this message translates to:
  /// **'Average minutes per ticket: agnts working versus waiting on you'**
  String get analyticsSpeedSub;

  /// No description provided for @analyticsAgntsWorking.
  ///
  /// In en, this message translates to:
  /// **'agnts working'**
  String get analyticsAgntsWorking;

  /// No description provided for @analyticsWaitingOnYou.
  ///
  /// In en, this message translates to:
  /// **'Waiting on you'**
  String get analyticsWaitingOnYou;

  /// No description provided for @analyticsSteps.
  ///
  /// In en, this message translates to:
  /// **'Where the time goes'**
  String get analyticsSteps;

  /// No description provided for @analyticsStepsSub.
  ///
  /// In en, this message translates to:
  /// **'Average per ticket, by step'**
  String get analyticsStepsSub;

  /// No description provided for @analyticsTurns.
  ///
  /// In en, this message translates to:
  /// **'Turns per ticket'**
  String get analyticsTurns;

  /// No description provided for @analyticsTurnsSub.
  ///
  /// In en, this message translates to:
  /// **'Fewer turns means agnts finds its way faster and uses less of your plan'**
  String get analyticsTurnsSub;

  /// No description provided for @analyticsAvgTurns.
  ///
  /// In en, this message translates to:
  /// **'Average turns'**
  String get analyticsAvgTurns;

  /// No description provided for @analyticsStops.
  ///
  /// In en, this message translates to:
  /// **'Why runs stop'**
  String get analyticsStops;

  /// No description provided for @analyticsStopsSub.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} stopped run in this period} other {{n} stopped runs in this period}}'**
  String analyticsStopsSub(num n);

  /// No description provided for @analyticsStopTests.
  ///
  /// In en, this message translates to:
  /// **'Tests kept failing'**
  String get analyticsStopTests;

  /// No description provided for @analyticsStopLimit.
  ///
  /// In en, this message translates to:
  /// **'Plan limit reached'**
  String get analyticsStopLimit;

  /// No description provided for @analyticsStopYou.
  ///
  /// In en, this message translates to:
  /// **'Stopped by you'**
  String get analyticsStopYou;

  /// No description provided for @analyticsStopTurns.
  ///
  /// In en, this message translates to:
  /// **'Turn limit reached'**
  String get analyticsStopTurns;

  /// No description provided for @analyticsStopOther.
  ///
  /// In en, this message translates to:
  /// **'Other errors'**
  String get analyticsStopOther;

  /// No description provided for @analyticsModels.
  ///
  /// In en, this message translates to:
  /// **'Models'**
  String get analyticsModels;

  /// No description provided for @analyticsModelsSub.
  ///
  /// In en, this message translates to:
  /// **'Runs per model and how they turned out'**
  String get analyticsModelsSub;

  /// No description provided for @analyticsChangeModels.
  ///
  /// In en, this message translates to:
  /// **'Change models'**
  String get analyticsChangeModels;

  /// No description provided for @analyticsColModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get analyticsColModel;

  /// No description provided for @analyticsColRuns.
  ///
  /// In en, this message translates to:
  /// **'Runs'**
  String get analyticsColRuns;

  /// No description provided for @analyticsColShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get analyticsColShare;

  /// No description provided for @analyticsColReview.
  ///
  /// In en, this message translates to:
  /// **'Reached review'**
  String get analyticsColReview;

  /// No description provided for @analyticsColTurns.
  ///
  /// In en, this message translates to:
  /// **'Average turns'**
  String get analyticsColTurns;

  /// No description provided for @analyticsNoRuns.
  ///
  /// In en, this message translates to:
  /// **'No runs in this period.'**
  String get analyticsNoRuns;

  /// No description provided for @analyticsUsage.
  ///
  /// In en, this message translates to:
  /// **'Plan usage'**
  String get analyticsUsage;

  /// No description provided for @analyticsUsageSub.
  ///
  /// In en, this message translates to:
  /// **'Peak session usage per day'**
  String get analyticsUsageSub;

  /// No description provided for @analyticsSession.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get analyticsSession;

  /// No description provided for @analyticsAvgPeak.
  ///
  /// In en, this message translates to:
  /// **'Average peak'**
  String get analyticsAvgPeak;

  /// No description provided for @analyticsDaysAbove.
  ///
  /// In en, this message translates to:
  /// **'Days above 80%'**
  String get analyticsDaysAbove;

  /// No description provided for @analyticsNoUsage.
  ///
  /// In en, this message translates to:
  /// **'No usage readings in this period.'**
  String get analyticsNoUsage;

  /// No description provided for @analyticsSpend.
  ///
  /// In en, this message translates to:
  /// **'Token spend'**
  String get analyticsSpend;

  /// No description provided for @analyticsSpendSub.
  ///
  /// In en, this message translates to:
  /// **'Tokens Claude used per day, input and output'**
  String get analyticsSpendSub;

  /// No description provided for @analyticsSpendTokens.
  ///
  /// In en, this message translates to:
  /// **'Tokens in and out'**
  String get analyticsSpendTokens;

  /// No description provided for @analyticsSpendCost.
  ///
  /// In en, this message translates to:
  /// **'At API prices'**
  String get analyticsSpendCost;

  /// No description provided for @analyticsSpendStages.
  ///
  /// In en, this message translates to:
  /// **'Spend by stage'**
  String get analyticsSpendStages;

  /// No description provided for @analyticsSpendStagesSub.
  ///
  /// In en, this message translates to:
  /// **'Where the tokens went, costliest first'**
  String get analyticsSpendStagesSub;

  /// No description provided for @analyticsNoSpend.
  ///
  /// In en, this message translates to:
  /// **'No Claude runs recorded in this period.'**
  String get analyticsNoSpend;

  /// No description provided for @analyticsRepos.
  ///
  /// In en, this message translates to:
  /// **'By repository'**
  String get analyticsRepos;

  /// No description provided for @analyticsReposSub.
  ///
  /// In en, this message translates to:
  /// **'Where agnts works best, and where it struggles'**
  String get analyticsReposSub;

  /// No description provided for @analyticsColRepo.
  ///
  /// In en, this message translates to:
  /// **'Repository'**
  String get analyticsColRepo;

  /// No description provided for @analyticsColSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get analyticsColSource;

  /// No description provided for @analyticsColTickets.
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get analyticsColTickets;

  /// No description provided for @analyticsColSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success rate'**
  String get analyticsColSuccess;

  /// No description provided for @analyticsColAgnts.
  ///
  /// In en, this message translates to:
  /// **'agnts time'**
  String get analyticsColAgnts;

  /// No description provided for @analyticsColClaudeMd.
  ///
  /// In en, this message translates to:
  /// **'CLAUDE.md'**
  String get analyticsColClaudeMd;

  /// No description provided for @analyticsSrcJira.
  ///
  /// In en, this message translates to:
  /// **'Jira'**
  String get analyticsSrcJira;

  /// No description provided for @analyticsSrcTask.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get analyticsSrcTask;

  /// No description provided for @analyticsMdFound.
  ///
  /// In en, this message translates to:
  /// **'Found'**
  String get analyticsMdFound;

  /// No description provided for @analyticsMdMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get analyticsMdMissing;

  /// No description provided for @analyticsMdUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get analyticsMdUnknown;

  /// No description provided for @analyticsNoRepos.
  ///
  /// In en, this message translates to:
  /// **'No repository had tickets in this period.'**
  String get analyticsNoRepos;

  /// No description provided for @analyticsHours.
  ///
  /// In en, this message translates to:
  /// **'Activity by hour'**
  String get analyticsHours;

  /// No description provided for @analyticsHoursSub.
  ///
  /// In en, this message translates to:
  /// **'When agnts works, summed over the period. Busiest hour: {hour}:00'**
  String analyticsHoursSub(String hour);

  /// No description provided for @analyticsEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get analyticsEvents;

  /// No description provided for @analyticsInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get analyticsInsights;

  /// No description provided for @analyticsInsightsSub.
  ///
  /// In en, this message translates to:
  /// **'What the numbers suggest'**
  String get analyticsInsightsSub;

  /// No description provided for @analyticsNoInsights.
  ///
  /// In en, this message translates to:
  /// **'Not enough data for insights yet.'**
  String get analyticsNoInsights;

  /// No description provided for @analyticsInsightClaudeMd.
  ///
  /// In en, this message translates to:
  /// **'Repositories with a CLAUDE.md finish in {gain}% fewer turns. Adding one to {repos} is the quickest win.'**
  String analyticsInsightClaudeMd(String gain, String repos);

  /// No description provided for @analyticsInsightWaiting.
  ///
  /// In en, this message translates to:
  /// **'{share}% of a ticket\'s total time is spent waiting on you. Reviews take about {review} min on average.'**
  String analyticsInsightWaiting(String share, String review);

  /// No description provided for @analyticsInsightStopsTests.
  ///
  /// In en, this message translates to:
  /// **'Most stopped runs ({n}) end on failing tests. Clearer acceptance criteria in tickets help agnts know when it\'s done.'**
  String analyticsInsightStopsTests(String n);

  /// No description provided for @analyticsInsightStopsLimit.
  ///
  /// In en, this message translates to:
  /// **'Plan limits stop more runs ({n}) than anything else. Fewer parallel runs or Haiku for summaries save usage.'**
  String analyticsInsightStopsLimit(String n);

  /// No description provided for @analyticsInsightNight.
  ///
  /// In en, this message translates to:
  /// **'{pct}% of agnts\'s work happens between 22:00 and 07:00, while you\'re offline.'**
  String analyticsInsightNight(String pct);

  /// No description provided for @analyticsMinutes.
  ///
  /// In en, this message translates to:
  /// **'{n} min'**
  String analyticsMinutes(String n);

  /// No description provided for @analyticsHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{h} h {m} min'**
  String analyticsHoursMinutes(String h, String m);

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'agnts'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your no sleep agent'**
  String get appTagline;

  /// No description provided for @authTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authTitle;

  /// No description provided for @authLede.
  ///
  /// In en, this message translates to:
  /// **'Use your account and the code from your authenticator app.'**
  String get authLede;

  /// No description provided for @authUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get authUsername;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// No description provided for @authCode.
  ///
  /// In en, this message translates to:
  /// **'Authenticator code'**
  String get authCode;

  /// No description provided for @authCodeHint.
  ///
  /// In en, this message translates to:
  /// **'6 digits from your authenticator app'**
  String get authCodeHint;

  /// No description provided for @authSubmit.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSubmit;

  /// No description provided for @authSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Signing in…'**
  String get authSubmitting;

  /// No description provided for @authSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get authSignOut;

  /// No description provided for @authSignOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get authSignOutTitle;

  /// No description provided for @authSignOutBody.
  ///
  /// In en, this message translates to:
  /// **'You’ll need your password and authenticator code to sign back in.'**
  String get authSignOutBody;

  /// No description provided for @authWrongCredentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong username, password or code.'**
  String get authWrongCredentials;

  /// No description provided for @authRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in {seconds, plural, one {{seconds} second} other {{seconds} seconds}}.'**
  String authRateLimited(num seconds);

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get commonError;

  /// No description provided for @commonSignedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {username}'**
  String commonSignedInAs(String username);

  /// No description provided for @commonVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String commonVersion(String version);

  /// No description provided for @dashboardGreetNight.
  ///
  /// In en, this message translates to:
  /// **'Good night, {name}'**
  String dashboardGreetNight(String name);

  /// No description provided for @dashboardGreetMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}'**
  String dashboardGreetMorning(String name);

  /// No description provided for @dashboardGreetAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name}'**
  String dashboardGreetAfternoon(String name);

  /// No description provided for @dashboardGreetEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name}'**
  String dashboardGreetEvening(String name);

  /// No description provided for @dashboardLede.
  ///
  /// In en, this message translates to:
  /// **'{date}. Here\'s what agnts is doing and what\'s waiting on you.'**
  String dashboardLede(String date);

  /// No description provided for @dashboardOpenAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Open analytics'**
  String get dashboardOpenAnalytics;

  /// No description provided for @dashboardNeedsYou.
  ///
  /// In en, this message translates to:
  /// **'Needs you'**
  String get dashboardNeedsYou;

  /// No description provided for @dashboardNeedsNote.
  ///
  /// In en, this message translates to:
  /// **'{answers} answers, {reviews} reviews, {stopped} stopped'**
  String dashboardNeedsNote(String answers, String reviews, String stopped);

  /// No description provided for @dashboardRunningNow.
  ///
  /// In en, this message translates to:
  /// **'Running now'**
  String get dashboardRunningNow;

  /// No description provided for @dashboardRunningNote.
  ///
  /// In en, this message translates to:
  /// **'{n} at a time allowed'**
  String dashboardRunningNote(String n);

  /// No description provided for @dashboardPushedWeek.
  ///
  /// In en, this message translates to:
  /// **'Pushed this week'**
  String get dashboardPushedWeek;

  /// No description provided for @dashboardPushedNote.
  ///
  /// In en, this message translates to:
  /// **'vs {n} last week'**
  String dashboardPushedNote(String n);

  /// No description provided for @dashboardPlanSession.
  ///
  /// In en, this message translates to:
  /// **'Plan session'**
  String get dashboardPlanSession;

  /// No description provided for @dashboardWaitingTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting on you'**
  String get dashboardWaitingTitle;

  /// No description provided for @dashboardWaitingSub.
  ///
  /// In en, this message translates to:
  /// **'Oldest first. Every minute here is a minute agnts can\'t work.'**
  String get dashboardWaitingSub;

  /// No description provided for @dashboardOpenInbox.
  ///
  /// In en, this message translates to:
  /// **'Open inbox'**
  String get dashboardOpenInbox;

  /// No description provided for @dashboardNothingWaiting.
  ///
  /// In en, this message translates to:
  /// **'Nothing is waiting on you. agnts will show tickets here when it needs answers or a review.'**
  String get dashboardNothingWaiting;

  /// No description provided for @dashboardColTicket.
  ///
  /// In en, this message translates to:
  /// **'Ticket'**
  String get dashboardColTicket;

  /// No description provided for @dashboardColStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get dashboardColStatus;

  /// No description provided for @dashboardColWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get dashboardColWaiting;

  /// No description provided for @dashboardActAnswer.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get dashboardActAnswer;

  /// No description provided for @dashboardActReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get dashboardActReview;

  /// No description provided for @dashboardActRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get dashboardActRetry;

  /// No description provided for @dashboardActResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get dashboardActResume;

  /// No description provided for @dashboardUsageTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan usage'**
  String get dashboardUsageTitle;

  /// No description provided for @dashboardUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String dashboardUpdated(String time);

  /// No description provided for @dashboardNotUpdated.
  ///
  /// In en, this message translates to:
  /// **'No reading yet'**
  String get dashboardNotUpdated;

  /// No description provided for @dashboardSession.
  ///
  /// In en, this message translates to:
  /// **'Current session'**
  String get dashboardSession;

  /// No description provided for @dashboardWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get dashboardWeek;

  /// No description provided for @dashboardPaused.
  ///
  /// In en, this message translates to:
  /// **'New runs are paused until the limit resets.'**
  String get dashboardPaused;

  /// No description provided for @dashboardLiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Live runs'**
  String get dashboardLiveTitle;

  /// No description provided for @dashboardLiveSub.
  ///
  /// In en, this message translates to:
  /// **'Tickets in containers right now'**
  String get dashboardLiveSub;

  /// No description provided for @dashboardNoRuns.
  ///
  /// In en, this message translates to:
  /// **'No runs at the moment.'**
  String get dashboardNoRuns;

  /// No description provided for @dashboardTurns.
  ///
  /// In en, this message translates to:
  /// **'{n} / {max} turns'**
  String dashboardTurns(String n, String max);

  /// No description provided for @dashboardPipelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Pipeline'**
  String get dashboardPipelineTitle;

  /// No description provided for @dashboardPipelineSub.
  ///
  /// In en, this message translates to:
  /// **'Open tickets by step'**
  String get dashboardPipelineSub;

  /// No description provided for @dashboardPipeQueue.
  ///
  /// In en, this message translates to:
  /// **'In queue'**
  String get dashboardPipeQueue;

  /// No description provided for @dashboardPipeAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze'**
  String get dashboardPipeAnalyze;

  /// No description provided for @dashboardPipeAnswers.
  ///
  /// In en, this message translates to:
  /// **'Your answers'**
  String get dashboardPipeAnswers;

  /// No description provided for @dashboardPipeCoding.
  ///
  /// In en, this message translates to:
  /// **'Coding'**
  String get dashboardPipeCoding;

  /// No description provided for @dashboardPipeReview.
  ///
  /// In en, this message translates to:
  /// **'Your review'**
  String get dashboardPipeReview;

  /// No description provided for @dashboardPipeStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get dashboardPipeStopped;

  /// No description provided for @dashboardTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Today by hour'**
  String get dashboardTodayTitle;

  /// No description provided for @dashboardTodaySub.
  ///
  /// In en, this message translates to:
  /// **'Events recorded today. agnts keeps working while you sleep.'**
  String get dashboardTodaySub;

  /// No description provided for @dashboardTodayAria.
  ///
  /// In en, this message translates to:
  /// **'Events today by hour'**
  String get dashboardTodayAria;

  /// No description provided for @dashboardLegendAgnts.
  ///
  /// In en, this message translates to:
  /// **'agnts working'**
  String get dashboardLegendAgnts;

  /// No description provided for @dashboardLegendYou.
  ///
  /// In en, this message translates to:
  /// **'Your actions'**
  String get dashboardLegendYou;

  /// No description provided for @dashboardLegendProblems.
  ///
  /// In en, this message translates to:
  /// **'Warnings and errors'**
  String get dashboardLegendProblems;

  /// No description provided for @dashboardWeekTitle.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get dashboardWeekTitle;

  /// No description provided for @dashboardWeekSub.
  ///
  /// In en, this message translates to:
  /// **'Compared with last week'**
  String get dashboardWeekSub;

  /// No description provided for @dashboardPicked.
  ///
  /// In en, this message translates to:
  /// **'Tickets picked up'**
  String get dashboardPicked;

  /// No description provided for @dashboardFirstTry.
  ///
  /// In en, this message translates to:
  /// **'Approved on first try'**
  String get dashboardFirstTry;

  /// No description provided for @dashboardAvgTurns.
  ///
  /// In en, this message translates to:
  /// **'Average turns'**
  String get dashboardAvgTurns;

  /// No description provided for @dashboardAvgWait.
  ///
  /// In en, this message translates to:
  /// **'Waiting on you, average'**
  String get dashboardAvgWait;

  /// No description provided for @dashboardStoppedRuns.
  ///
  /// In en, this message translates to:
  /// **'Stopped runs'**
  String get dashboardStoppedRuns;

  /// No description provided for @dashboardReposTitle.
  ///
  /// In en, this message translates to:
  /// **'Repositories'**
  String get dashboardReposTitle;

  /// No description provided for @dashboardReposSub.
  ///
  /// In en, this message translates to:
  /// **'Open work and the latest ticket in each'**
  String get dashboardReposSub;

  /// No description provided for @dashboardAllRepos.
  ///
  /// In en, this message translates to:
  /// **'All repositories'**
  String get dashboardAllRepos;

  /// No description provided for @dashboardColRepo.
  ///
  /// In en, this message translates to:
  /// **'Repository'**
  String get dashboardColRepo;

  /// No description provided for @dashboardColOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get dashboardColOpen;

  /// No description provided for @dashboardColLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest ticket'**
  String get dashboardColLatest;

  /// No description provided for @dashboardColClaudeMd.
  ///
  /// In en, this message translates to:
  /// **'CLAUDE.md'**
  String get dashboardColClaudeMd;

  /// No description provided for @dashboardFound.
  ///
  /// In en, this message translates to:
  /// **'Found'**
  String get dashboardFound;

  /// No description provided for @dashboardMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get dashboardMissing;

  /// No description provided for @dashboardUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get dashboardUnknown;

  /// No description provided for @dashboardNoRepos.
  ///
  /// In en, this message translates to:
  /// **'No repository has open work.'**
  String get dashboardNoRepos;

  /// No description provided for @dashboardRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get dashboardRecentTitle;

  /// No description provided for @dashboardLogs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get dashboardLogs;

  /// No description provided for @dashboardNoActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity yet.'**
  String get dashboardNoActivity;

  /// No description provided for @followUpsTitle.
  ///
  /// In en, this message translates to:
  /// **'Follow-up tickets'**
  String get followUpsTitle;

  /// No description provided for @followUpsSub.
  ///
  /// In en, this message translates to:
  /// **'What finishing this ticket still needs, as agnts sees it. Pick the ones you want: they are created queued, so nothing runs until you start them.'**
  String get followUpsSub;

  /// No description provided for @followUpsMode.
  ///
  /// In en, this message translates to:
  /// **'Follow-up suggestions'**
  String get followUpsMode;

  /// No description provided for @followUpsModeInherit.
  ///
  /// In en, this message translates to:
  /// **'As in Settings'**
  String get followUpsModeInherit;

  /// No description provided for @followUpsModeOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get followUpsModeOn;

  /// No description provided for @followUpsModeOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get followUpsModeOff;

  /// No description provided for @followUpsModeHint.
  ///
  /// In en, this message translates to:
  /// **'When on, agnts\'s runs suggest tickets this one still needs. It makes every prompt a little longer.'**
  String get followUpsModeHint;

  /// No description provided for @followUpsOffEmpty.
  ///
  /// In en, this message translates to:
  /// **'Follow-up suggestions are off for this ticket. Turn them on to have the next run suggest what finishing it still needs.'**
  String get followUpsOffEmpty;

  /// No description provided for @followUpsOnEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing suggested yet. Most tickets need no follow-up.'**
  String get followUpsOnEmpty;

  /// No description provided for @followUpsType_prerequisite.
  ///
  /// In en, this message translates to:
  /// **'Prerequisite'**
  String get followUpsType_prerequisite;

  /// No description provided for @followUpsType_split.
  ///
  /// In en, this message translates to:
  /// **'Split off'**
  String get followUpsType_split;

  /// No description provided for @followUpsType_unfinished.
  ///
  /// In en, this message translates to:
  /// **'Left undone'**
  String get followUpsType_unfinished;

  /// No description provided for @followUpsType_gap.
  ///
  /// In en, this message translates to:
  /// **'Gap'**
  String get followUpsType_gap;

  /// No description provided for @followUpsSource_analyze.
  ///
  /// In en, this message translates to:
  /// **'from the analysis'**
  String get followUpsSource_analyze;

  /// No description provided for @followUpsSource_work.
  ///
  /// In en, this message translates to:
  /// **'from the work'**
  String get followUpsSource_work;

  /// No description provided for @followUpsSource_review.
  ///
  /// In en, this message translates to:
  /// **'from the code review'**
  String get followUpsSource_review;

  /// No description provided for @followUpsSource_manual.
  ///
  /// In en, this message translates to:
  /// **'from a review finding'**
  String get followUpsSource_manual;

  /// No description provided for @followUpsPick.
  ///
  /// In en, this message translates to:
  /// **'Create “{title}”'**
  String followUpsPick(String title);

  /// No description provided for @followUpsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Ticket title'**
  String get followUpsEditTitle;

  /// No description provided for @followUpsServes.
  ///
  /// In en, this message translates to:
  /// **'Why'**
  String get followUpsServes;

  /// No description provided for @followUpsDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get followUpsDetails;

  /// No description provided for @followUpsWaitsForDone.
  ///
  /// In en, this message translates to:
  /// **'It builds on this ticket\'s work: you can create it once this ticket is done.'**
  String get followUpsWaitsForDone;

  /// No description provided for @followUpsTarget.
  ///
  /// In en, this message translates to:
  /// **'Create as'**
  String get followUpsTarget;

  /// No description provided for @followUpsTargetLocal.
  ///
  /// In en, this message translates to:
  /// **'Local task'**
  String get followUpsTargetLocal;

  /// No description provided for @followUpsTargetJira.
  ///
  /// In en, this message translates to:
  /// **'Jira issue'**
  String get followUpsTargetJira;

  /// No description provided for @followUpsJiraOff.
  ///
  /// In en, this message translates to:
  /// **'Connect Jira to file issues there'**
  String get followUpsJiraOff;

  /// No description provided for @followUpsCreate.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {Create tickets} one {Create {count} ticket} other {Create {count} tickets}}'**
  String followUpsCreate(num count);

  /// No description provided for @followUpsQueuedHint.
  ///
  /// In en, this message translates to:
  /// **'Created tickets wait in the queue until you start them.'**
  String get followUpsQueuedHint;

  /// No description provided for @followUpsDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get followUpsDismiss;

  /// No description provided for @followUpsDismissedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {{count} dismissed suggestion} other {{count} dismissed suggestions}}'**
  String followUpsDismissedCount(num count);

  /// No description provided for @followUpsChildren.
  ///
  /// In en, this message translates to:
  /// **'Created from this ticket'**
  String get followUpsChildren;

  /// No description provided for @followUpsFollowUpOf.
  ///
  /// In en, this message translates to:
  /// **'Follow-up of'**
  String get followUpsFollowUpOf;

  /// No description provided for @followUpsCreatedNotice.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {{count} ticket created} other {{count} tickets created}}, queued until you start them.'**
  String followUpsCreatedNotice(num count);

  /// No description provided for @followUpsFailedItem.
  ///
  /// In en, this message translates to:
  /// **'{title}: {error}'**
  String followUpsFailedItem(String title, String error);

  /// No description provided for @followUpsFromFinding.
  ///
  /// In en, this message translates to:
  /// **'Make follow-up'**
  String get followUpsFromFinding;

  /// No description provided for @followUpsFromFindingDone.
  ///
  /// In en, this message translates to:
  /// **'Suggested as a follow-up'**
  String get followUpsFromFindingDone;

  /// No description provided for @followUpsFromFindingHint.
  ///
  /// In en, this message translates to:
  /// **'For work outside this change: suggest it as a follow-up ticket instead of sending it back'**
  String get followUpsFromFindingHint;

  /// No description provided for @followUpsOpenBadge.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {{count} follow-up} other {{count} follow-ups}}'**
  String followUpsOpenBadge(num count);

  /// No description provided for @followUpsSettingLabel.
  ///
  /// In en, this message translates to:
  /// **'Suggest follow-up tickets'**
  String get followUpsSettingLabel;

  /// No description provided for @followUpsSettingHelp.
  ///
  /// In en, this message translates to:
  /// **'Analysis, work and review runs suggest tickets that finishing a ticket still needs: prerequisites, parts to split off, work left undone, gaps a report found. You pick which to create. Off by default because it makes every prompt a little longer; a ticket can turn it on for itself.'**
  String get followUpsSettingHelp;

  /// No description provided for @followUpsNotifyLabel.
  ///
  /// In en, this message translates to:
  /// **'Follow-up tickets suggested'**
  String get followUpsNotifyLabel;

  /// No description provided for @followUpsJiraIssueType.
  ///
  /// In en, this message translates to:
  /// **'Issue type for follow-ups'**
  String get followUpsJiraIssueType;

  /// No description provided for @followUpsJiraIssueTypeHelp.
  ///
  /// In en, this message translates to:
  /// **'The type of the Jira issues agnts files when you create a follow-up in Jira. Default: Task.'**
  String get followUpsJiraIssueTypeHelp;

  /// No description provided for @formSave.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get formSave;

  /// No description provided for @formSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get formSaving;

  /// No description provided for @formDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get formDiscard;

  /// No description provided for @formCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get formCancel;

  /// No description provided for @formUnsaved.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes'**
  String get formUnsaved;

  /// No description provided for @formClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get formClose;

  /// No description provided for @formAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get formAdd;

  /// No description provided for @formRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String formRemove(String name);

  /// No description provided for @formAddCommand.
  ///
  /// In en, this message translates to:
  /// **'Add command'**
  String get formAddCommand;

  /// No description provided for @formDecrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get formDecrease;

  /// No description provided for @formIncrease.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get formIncrease;

  /// No description provided for @formCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get formCopy;

  /// No description provided for @formCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get formCopied;

  /// No description provided for @formSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get formSaved;

  /// No description provided for @formSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get formSearch;

  /// No description provided for @formNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get formNoMatch;

  /// No description provided for @implementTitle.
  ///
  /// In en, this message translates to:
  /// **'Next step'**
  String get implementTitle;

  /// No description provided for @implementSubPlan.
  ///
  /// In en, this message translates to:
  /// **'Have agnts carry out this plan: a code task linked to this one, with the plan as its brief. You review the diff as usual.'**
  String get implementSubPlan;

  /// No description provided for @implementSubBug.
  ///
  /// In en, this message translates to:
  /// **'Have agnts make the proposed fix: a code task linked to this one, with the investigation as its brief. You review the diff as usual.'**
  String get implementSubBug;

  /// No description provided for @implementImplement.
  ///
  /// In en, this message translates to:
  /// **'Implement this plan'**
  String get implementImplement;

  /// No description provided for @implementFix.
  ///
  /// In en, this message translates to:
  /// **'Fix this bug'**
  String get implementFix;

  /// No description provided for @implementPickRepo.
  ///
  /// In en, this message translates to:
  /// **'Repository to implement it in'**
  String get implementPickRepo;

  /// No description provided for @implementQueue.
  ///
  /// In en, this message translates to:
  /// **'Keep the task in the queue instead of starting it'**
  String get implementQueue;

  /// No description provided for @implementDoneBy.
  ///
  /// In en, this message translates to:
  /// **'Implemented by'**
  String get implementDoneBy;

  /// No description provided for @implementImplements.
  ///
  /// In en, this message translates to:
  /// **'Implements'**
  String get implementImplements;

  /// No description provided for @integrationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Integrations'**
  String get integrationsTitle;

  /// No description provided for @integrationsLede.
  ///
  /// In en, this message translates to:
  /// **'The services agnts works with. Tokens are stored encrypted on your server and only used for the actions listed on each page.'**
  String get integrationsLede;

  /// No description provided for @integrationsName_jira.
  ///
  /// In en, this message translates to:
  /// **'Jira'**
  String get integrationsName_jira;

  /// No description provided for @integrationsName_github.
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get integrationsName_github;

  /// No description provided for @integrationsName_claude.
  ///
  /// In en, this message translates to:
  /// **'Claude'**
  String get integrationsName_claude;

  /// No description provided for @integrationsDesc_jira.
  ///
  /// In en, this message translates to:
  /// **'Pick up tickets with the agnts label and keep their status up to date.'**
  String get integrationsDesc_jira;

  /// No description provided for @integrationsDesc_github.
  ///
  /// In en, this message translates to:
  /// **'Clone code, push branches and open pull requests.'**
  String get integrationsDesc_github;

  /// No description provided for @integrationsDesc_claude.
  ///
  /// In en, this message translates to:
  /// **'Your Claude subscription, which runs Claude Code.'**
  String get integrationsDesc_claude;

  /// No description provided for @integrationsConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get integrationsConnected;

  /// No description provided for @integrationsNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get integrationsNotConnected;

  /// No description provided for @integrationsConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get integrationsConnect;

  /// No description provided for @integrationsManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get integrationsManage;

  /// No description provided for @integrationsTest.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get integrationsTest;

  /// No description provided for @integrationsDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get integrationsDisconnect;

  /// No description provided for @integrationsDisconnectConfirm.
  ///
  /// In en, this message translates to:
  /// **'Disconnect {name}? agnts forgets the token and stops using it.'**
  String integrationsDisconnectConfirm(String name);

  /// No description provided for @integrationsDisconnected.
  ///
  /// In en, this message translates to:
  /// **'{name} disconnected'**
  String integrationsDisconnected(String name);

  /// No description provided for @integrationsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get integrationsAccount;

  /// No description provided for @integrationsToken.
  ///
  /// In en, this message translates to:
  /// **'Token'**
  String get integrationsToken;

  /// No description provided for @integrationsLastChecked.
  ///
  /// In en, this message translates to:
  /// **'Last checked'**
  String get integrationsLastChecked;

  /// No description provided for @integrationsLastError.
  ///
  /// In en, this message translates to:
  /// **'Last error'**
  String get integrationsLastError;

  /// No description provided for @integrationsNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get integrationsNever;

  /// No description provided for @integrationsComing.
  ///
  /// In en, this message translates to:
  /// **'Coming later'**
  String get integrationsComing;

  /// No description provided for @integrationsComingSub.
  ///
  /// In en, this message translates to:
  /// **'Planned integrations'**
  String get integrationsComingSub;

  /// No description provided for @integrationsBack.
  ///
  /// In en, this message translates to:
  /// **'Back to integrations'**
  String get integrationsBack;

  /// No description provided for @integrationsConnectedAs.
  ///
  /// In en, this message translates to:
  /// **'Connected as {account}. Last checked {time}.'**
  String integrationsConnectedAs(String account, String time);

  /// No description provided for @integrationsNotYet.
  ///
  /// In en, this message translates to:
  /// **'Not connected yet.'**
  String get integrationsNotYet;

  /// No description provided for @integrationsConnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect {name}'**
  String integrationsConnectTitle(String name);

  /// No description provided for @integrationsConnectSub_jira.
  ///
  /// In en, this message translates to:
  /// **'Use an API token from your Atlassian account.'**
  String get integrationsConnectSub_jira;

  /// No description provided for @integrationsTokenOpen_jira.
  ///
  /// In en, this message translates to:
  /// **'Open Atlassian API tokens'**
  String get integrationsTokenOpen_jira;

  /// No description provided for @integrationsTokenStep1_jira.
  ///
  /// In en, this message translates to:
  /// **'Sign in to the Atlassian account agnts should act as, and open Account settings → Security → API tokens (or use the button below).'**
  String get integrationsTokenStep1_jira;

  /// No description provided for @integrationsTokenStep2_jira.
  ///
  /// In en, this message translates to:
  /// **'Click Create API token (not the one with scopes), name it (for example agnts) and pick an expiration date.'**
  String get integrationsTokenStep2_jira;

  /// No description provided for @integrationsTokenStep3_jira.
  ///
  /// In en, this message translates to:
  /// **'Copy the token and paste it below. Atlassian shows it only once.'**
  String get integrationsTokenStep3_jira;

  /// No description provided for @integrationsTokenStep4_jira.
  ///
  /// In en, this message translates to:
  /// **'For Site, enter your Jira address (https://your-team.atlassian.net), and for Account email the email of that same account. It needs access to the Jira projects agnts works on.'**
  String get integrationsTokenStep4_jira;

  /// No description provided for @integrationsConnectSub_github.
  ///
  /// In en, this message translates to:
  /// **'Create a fine-grained personal access token with the permissions below, then paste it here.'**
  String get integrationsConnectSub_github;

  /// No description provided for @integrationsTokenHow.
  ///
  /// In en, this message translates to:
  /// **'How to get the token'**
  String get integrationsTokenHow;

  /// No description provided for @integrationsTokenCommand.
  ///
  /// In en, this message translates to:
  /// **'Command'**
  String get integrationsTokenCommand;

  /// No description provided for @integrationsTokenOpen_github.
  ///
  /// In en, this message translates to:
  /// **'Open GitHub token page'**
  String get integrationsTokenOpen_github;

  /// No description provided for @integrationsTokenStep1_github.
  ///
  /// In en, this message translates to:
  /// **'On GitHub, open Settings → Developer settings → Personal access tokens → Fine-grained tokens and click Generate new token (or use the button below).'**
  String get integrationsTokenStep1_github;

  /// No description provided for @integrationsTokenStep2_github.
  ///
  /// In en, this message translates to:
  /// **'Name it (for example agnts), pick an expiration, set Resource owner to the account or organization that owns your repositories, and under Repository access choose the repositories agnts may work on.'**
  String get integrationsTokenStep2_github;

  /// No description provided for @integrationsTokenStep3_github.
  ///
  /// In en, this message translates to:
  /// **'Under Repository permissions set Contents and Pull requests to Read and write. For the Pipelines tab also set Actions to Read (Read and write to use Deploy) and Deployments to Read. Metadata (read) is added automatically.'**
  String get integrationsTokenStep3_github;

  /// No description provided for @integrationsTokenStep4_github.
  ///
  /// In en, this message translates to:
  /// **'Click Generate token, copy it (it starts with github_pat_) and paste it below. GitHub shows it only once. For an organization, an owner may need to approve the token first.'**
  String get integrationsTokenStep4_github;

  /// No description provided for @integrationsConnectSub_claude.
  ///
  /// In en, this message translates to:
  /// **'Run `claude setup-token` on a machine where you are signed in to your Claude plan, then paste the token.'**
  String get integrationsConnectSub_claude;

  /// No description provided for @integrationsTokenStep1_claude.
  ///
  /// In en, this message translates to:
  /// **'You need a Claude Pro or Max plan. On any computer, install Claude Code: npm install -g @anthropic-ai/claude-code'**
  String get integrationsTokenStep1_claude;

  /// No description provided for @integrationsTokenStep2_claude.
  ///
  /// In en, this message translates to:
  /// **'Run claude once in a terminal and sign in with your Claude account.'**
  String get integrationsTokenStep2_claude;

  /// No description provided for @integrationsTokenStep3_claude.
  ///
  /// In en, this message translates to:
  /// **'Run the command below. It opens the browser to approve access and then prints a long-lived token.'**
  String get integrationsTokenStep3_claude;

  /// No description provided for @integrationsTokenStep4_claude.
  ///
  /// In en, this message translates to:
  /// **'Copy the token (it starts with sk-ant-) and paste it below. It lasts about a year, and runs count against your plan\'s usage.'**
  String get integrationsTokenStep4_claude;

  /// No description provided for @integrationsSite.
  ///
  /// In en, this message translates to:
  /// **'Site'**
  String get integrationsSite;

  /// No description provided for @integrationsSiteHelp.
  ///
  /// In en, this message translates to:
  /// **'For example https://your-team.atlassian.net'**
  String get integrationsSiteHelp;

  /// No description provided for @integrationsEmail.
  ///
  /// In en, this message translates to:
  /// **'Account email'**
  String get integrationsEmail;

  /// No description provided for @integrationsApiToken.
  ///
  /// In en, this message translates to:
  /// **'API token'**
  String get integrationsApiToken;

  /// No description provided for @integrationsApiTokenHelp.
  ///
  /// In en, this message translates to:
  /// **'id.atlassian.com → Security → API tokens'**
  String get integrationsApiTokenHelp;

  /// No description provided for @integrationsAccessToken.
  ///
  /// In en, this message translates to:
  /// **'Access token'**
  String get integrationsAccessToken;

  /// No description provided for @integrationsTokenHelp.
  ///
  /// In en, this message translates to:
  /// **'Stored encrypted on your server. agnts never shows it again.'**
  String get integrationsTokenHelp;

  /// No description provided for @integrationsScopes.
  ///
  /// In en, this message translates to:
  /// **'Required permissions'**
  String get integrationsScopes;

  /// No description provided for @integrationsPermContents.
  ///
  /// In en, this message translates to:
  /// **'Read and write. Clone code and push branches.'**
  String get integrationsPermContents;

  /// No description provided for @integrationsPermPulls.
  ///
  /// In en, this message translates to:
  /// **'Read and write. Open pull requests.'**
  String get integrationsPermPulls;

  /// No description provided for @integrationsPermMetadata.
  ///
  /// In en, this message translates to:
  /// **'Read. List repositories and branches.'**
  String get integrationsPermMetadata;

  /// No description provided for @integrationsPermActions.
  ///
  /// In en, this message translates to:
  /// **'Read for the Pipelines tab and environments; Read and write to use Deploy.'**
  String get integrationsPermActions;

  /// No description provided for @integrationsPermDeployments.
  ///
  /// In en, this message translates to:
  /// **'Read. Shows what is deployed to each environment.'**
  String get integrationsPermDeployments;

  /// No description provided for @integrationsRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get integrationsRequired;

  /// No description provided for @integrationsRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get integrationsRecommended;

  /// No description provided for @integrationsConnecting.
  ///
  /// In en, this message translates to:
  /// **'Checking the token…'**
  String get integrationsConnecting;

  /// No description provided for @integrationsConnectedToast.
  ///
  /// In en, this message translates to:
  /// **'{name} connected'**
  String integrationsConnectedToast(String name);

  /// No description provided for @integrationsTestOk.
  ///
  /// In en, this message translates to:
  /// **'{name}: connection works'**
  String integrationsTestOk(String name);

  /// No description provided for @integrationsTestFail.
  ///
  /// In en, this message translates to:
  /// **'{name}: {error}'**
  String integrationsTestFail(String name, String error);

  /// No description provided for @integrationsWebhookTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up the Jira webhook'**
  String get integrationsWebhookTitle;

  /// No description provided for @integrationsWebhookSteps.
  ///
  /// In en, this message translates to:
  /// **'In Jira, open Settings → System → WebHooks → Create, and enter:'**
  String get integrationsWebhookSteps;

  /// No description provided for @integrationsWebhookUrl.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get integrationsWebhookUrl;

  /// No description provided for @integrationsWebhookSecret.
  ///
  /// In en, this message translates to:
  /// **'Secret'**
  String get integrationsWebhookSecret;

  /// No description provided for @integrationsWebhookOnce.
  ///
  /// In en, this message translates to:
  /// **'This secret is shown only once. Paste it into Jira now.'**
  String get integrationsWebhookOnce;

  /// No description provided for @integrationsEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get integrationsEvents;

  /// No description provided for @integrationsEventsValue.
  ///
  /// In en, this message translates to:
  /// **'Issue created, Issue updated'**
  String get integrationsEventsValue;

  /// No description provided for @integrationsConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get integrationsConnection;

  /// No description provided for @integrationsPickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup rules'**
  String get integrationsPickup;

  /// No description provided for @integrationsPickupSub.
  ///
  /// In en, this message translates to:
  /// **'Which tickets agnts takes'**
  String get integrationsPickupSub;

  /// No description provided for @integrationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get integrationsLabel;

  /// No description provided for @integrationsLabelHelp.
  ///
  /// In en, this message translates to:
  /// **'Add this label to a ticket to hand it to agnts'**
  String get integrationsLabelHelp;

  /// No description provided for @integrationsQuery.
  ///
  /// In en, this message translates to:
  /// **'The query agnts runs'**
  String get integrationsQuery;

  /// No description provided for @integrationsStatuses.
  ///
  /// In en, this message translates to:
  /// **'Status updates'**
  String get integrationsStatuses;

  /// No description provided for @integrationsStatusesSub.
  ///
  /// In en, this message translates to:
  /// **'How agnts moves tickets on your board. Leave empty to keep the status.'**
  String get integrationsStatusesSub;

  /// No description provided for @integrationsMapStarted.
  ///
  /// In en, this message translates to:
  /// **'When agnts starts'**
  String get integrationsMapStarted;

  /// No description provided for @integrationsMapReview.
  ///
  /// In en, this message translates to:
  /// **'When changes are pushed'**
  String get integrationsMapReview;

  /// No description provided for @integrationsMapRejected.
  ///
  /// In en, this message translates to:
  /// **'When you reject the changes'**
  String get integrationsMapRejected;

  /// No description provided for @integrationsKeepStatus.
  ///
  /// In en, this message translates to:
  /// **'Keep status'**
  String get integrationsKeepStatus;

  /// No description provided for @integrationsComments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get integrationsComments;

  /// No description provided for @integrationsCommentsSub.
  ///
  /// In en, this message translates to:
  /// **'What agnts writes on the ticket'**
  String get integrationsCommentsSub;

  /// No description provided for @integrationsCQuestions.
  ///
  /// In en, this message translates to:
  /// **'agnts\'s questions'**
  String get integrationsCQuestions;

  /// No description provided for @integrationsCQuestionsHelp.
  ///
  /// In en, this message translates to:
  /// **'So teammates can see what was unclear'**
  String get integrationsCQuestionsHelp;

  /// No description provided for @integrationsCPlan.
  ///
  /// In en, this message translates to:
  /// **'The plan before coding'**
  String get integrationsCPlan;

  /// No description provided for @integrationsCPr.
  ///
  /// In en, this message translates to:
  /// **'Link to the pull request'**
  String get integrationsCPr;

  /// No description provided for @integrationsCSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary of the changes'**
  String get integrationsCSummary;

  /// No description provided for @integrationsCStatus.
  ///
  /// In en, this message translates to:
  /// **'Pauses at the plan limit'**
  String get integrationsCStatus;

  /// No description provided for @integrationsSync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get integrationsSync;

  /// No description provided for @integrationsSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get integrationsSyncNow;

  /// No description provided for @integrationsSynced.
  ///
  /// In en, this message translates to:
  /// **'{found} open issues, {created} new'**
  String integrationsSynced(String found, String created);

  /// No description provided for @integrationsSyncHelp.
  ///
  /// In en, this message translates to:
  /// **'Jira sends new tickets to the webhook right away; agnts also checks every hour in case a delivery was missed.'**
  String get integrationsSyncHelp;

  /// No description provided for @integrationsWebhook.
  ///
  /// In en, this message translates to:
  /// **'Webhook'**
  String get integrationsWebhook;

  /// No description provided for @integrationsSaved.
  ///
  /// In en, this message translates to:
  /// **'{name} settings saved'**
  String integrationsSaved(String name);

  /// No description provided for @integrationsSecretsHelp.
  ///
  /// In en, this message translates to:
  /// **'agnts only reads tickets that match the query, and only writes the status changes and comments you turn on here.'**
  String get integrationsSecretsHelp;

  /// No description provided for @integrationsGithubHelp.
  ///
  /// In en, this message translates to:
  /// **'Use a token from an account that can push to your repositories. Commits are authored with the name and email in Settings.'**
  String get integrationsGithubHelp;

  /// No description provided for @integrationsClaudeHelp.
  ///
  /// In en, this message translates to:
  /// **'The token lasts about a year. Renew it with `claude setup-token` before it expires.'**
  String get integrationsClaudeHelp;

  /// No description provided for @integrationsName_telegram.
  ///
  /// In en, this message translates to:
  /// **'Telegram'**
  String get integrationsName_telegram;

  /// No description provided for @integrationsDesc_telegram.
  ///
  /// In en, this message translates to:
  /// **'Messages when something needs you. Answer questions and approve or request changes right from the chat.'**
  String get integrationsDesc_telegram;

  /// No description provided for @integrationsConnectSub_telegram.
  ///
  /// In en, this message translates to:
  /// **'Create a bot with @BotFather, paste its token, and add your chat id. agnts registers the webhook for you.'**
  String get integrationsConnectSub_telegram;

  /// No description provided for @integrationsTokenOpen_telegram.
  ///
  /// In en, this message translates to:
  /// **'Open @BotFather'**
  String get integrationsTokenOpen_telegram;

  /// No description provided for @integrationsChatIdFind.
  ///
  /// In en, this message translates to:
  /// **'Find my chat id'**
  String get integrationsChatIdFind;

  /// No description provided for @integrationsTokenStep1_telegram.
  ///
  /// In en, this message translates to:
  /// **'In Telegram, open @BotFather (button below), send /newbot and choose a name and a username ending in bot.'**
  String get integrationsTokenStep1_telegram;

  /// No description provided for @integrationsTokenStep2_telegram.
  ///
  /// In en, this message translates to:
  /// **'BotFather replies with the bot token (like 123456789:AA…). Paste it into Access token below.'**
  String get integrationsTokenStep2_telegram;

  /// No description provided for @integrationsTokenStep3_telegram.
  ///
  /// In en, this message translates to:
  /// **'Open your new bot in Telegram and press Start, so it has a message from you.'**
  String get integrationsTokenStep3_telegram;

  /// No description provided for @integrationsTokenStep4_telegram.
  ///
  /// In en, this message translates to:
  /// **'Click Find my chat id (it appears once the token is pasted). In the page that opens, find \"chat\" and copy the number after \"id\" into Your chat id. If the page shows no messages, write to the bot again and reload it.'**
  String get integrationsTokenStep4_telegram;

  /// No description provided for @integrationsChatId.
  ///
  /// In en, this message translates to:
  /// **'Your chat id'**
  String get integrationsChatId;

  /// No description provided for @integrationsChatIdHelp.
  ///
  /// In en, this message translates to:
  /// **'The chat allowed to use the bot. Only this chat can act.'**
  String get integrationsChatIdHelp;

  /// No description provided for @integrationsTelegramHelp.
  ///
  /// In en, this message translates to:
  /// **'Approve and Reject ask for a second tap to confirm, and confirmations expire after 10 minutes.'**
  String get integrationsTelegramHelp;

  /// No description provided for @integrationsTelegramHttps.
  ///
  /// In en, this message translates to:
  /// **'Telegram only sends updates to a public HTTPS address, and this agnts runs on {url}, so connecting will fail here. Connect Telegram on a deployment with HTTPS, where AGNTS_PUBLIC_URL is an https:// address.'**
  String integrationsTelegramHttps(String url);

  /// No description provided for @integrationsName_gitlab.
  ///
  /// In en, this message translates to:
  /// **'GitLab'**
  String get integrationsName_gitlab;

  /// No description provided for @integrationsDesc_gitlab.
  ///
  /// In en, this message translates to:
  /// **'Clone code, push branches and open merge requests on gitlab.com or your own GitLab.'**
  String get integrationsDesc_gitlab;

  /// No description provided for @integrationsConnectSub_gitlab.
  ///
  /// In en, this message translates to:
  /// **'Create a personal access token with the scopes below, then paste it here.'**
  String get integrationsConnectSub_gitlab;

  /// No description provided for @integrationsTokenOpen_gitlab.
  ///
  /// In en, this message translates to:
  /// **'Open GitLab token page'**
  String get integrationsTokenOpen_gitlab;

  /// No description provided for @integrationsTokenStep1_gitlab.
  ///
  /// In en, this message translates to:
  /// **'Fill in the instance URL below first. Then in GitLab open your avatar → Edit profile → Access tokens → Add new token (or use the button below).'**
  String get integrationsTokenStep1_gitlab;

  /// No description provided for @integrationsTokenStep2_gitlab.
  ///
  /// In en, this message translates to:
  /// **'Name it (for example agnts) and set an expiration date. Use an account that can push to your projects.'**
  String get integrationsTokenStep2_gitlab;

  /// No description provided for @integrationsTokenStep3_gitlab.
  ///
  /// In en, this message translates to:
  /// **'Select the scopes api, read_repository and write_repository.'**
  String get integrationsTokenStep3_gitlab;

  /// No description provided for @integrationsTokenStep4_gitlab.
  ///
  /// In en, this message translates to:
  /// **'Click Create token, copy it (it starts with glpat-) and paste it below. GitLab shows it only once.'**
  String get integrationsTokenStep4_gitlab;

  /// No description provided for @integrationsGitlabUrl.
  ///
  /// In en, this message translates to:
  /// **'Instance URL'**
  String get integrationsGitlabUrl;

  /// No description provided for @integrationsGitlabUrlHelp.
  ///
  /// In en, this message translates to:
  /// **'https://gitlab.com or your own GitLab server.'**
  String get integrationsGitlabUrlHelp;

  /// No description provided for @integrationsGlApi.
  ///
  /// In en, this message translates to:
  /// **'Full API access. Open merge requests and read pipelines.'**
  String get integrationsGlApi;

  /// No description provided for @integrationsGlRead.
  ///
  /// In en, this message translates to:
  /// **'Clone code.'**
  String get integrationsGlRead;

  /// No description provided for @integrationsGlWrite.
  ///
  /// In en, this message translates to:
  /// **'Push branches.'**
  String get integrationsGlWrite;

  /// No description provided for @integrationsGitlabHelp.
  ///
  /// In en, this message translates to:
  /// **'Use a token from an account that can push to your projects. Run containers never see it; pushes happen on the server after you approve.'**
  String get integrationsGitlabHelp;

  /// No description provided for @integrationsMapMerged.
  ///
  /// In en, this message translates to:
  /// **'When the pull request is merged'**
  String get integrationsMapMerged;

  /// No description provided for @integrationsGitWebhookSteps_github.
  ///
  /// In en, this message translates to:
  /// **'In the repository (or organisation) go to Settings → Webhooks → Add webhook. Content type application/json, paste the URL and secret below.'**
  String get integrationsGitWebhookSteps_github;

  /// No description provided for @integrationsGitWebhookSteps_gitlab.
  ///
  /// In en, this message translates to:
  /// **'In the project go to Settings → Webhooks. Paste the URL, put the secret below in Secret token.'**
  String get integrationsGitWebhookSteps_gitlab;

  /// No description provided for @integrationsGitEvents_github.
  ///
  /// In en, this message translates to:
  /// **'Pull requests, Workflow runs'**
  String get integrationsGitEvents_github;

  /// No description provided for @integrationsGitEvents_gitlab.
  ///
  /// In en, this message translates to:
  /// **'Merge request events, Pipeline events'**
  String get integrationsGitEvents_gitlab;

  /// No description provided for @integrationsGitWebhookWhy.
  ///
  /// In en, this message translates to:
  /// **'When a pull or merge request is merged, agnts marks the ticket merged and moves the Jira issue to the merged status set on the Jira page. Pipeline events keep the repository page current.'**
  String get integrationsGitWebhookWhy;

  /// No description provided for @kindTitle.
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get kindTitle;

  /// No description provided for @kindAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get kindAuto;

  /// No description provided for @kindAutoHint.
  ///
  /// In en, this message translates to:
  /// **'agnts picks the kind while reading the ticket'**
  String get kindAutoHint;

  /// No description provided for @kindCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get kindCode;

  /// No description provided for @kindCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Implement a change. Needs a repository; ends in a pull request.'**
  String get kindCodeHint;

  /// No description provided for @kindTest.
  ///
  /// In en, this message translates to:
  /// **'Tests'**
  String get kindTest;

  /// No description provided for @kindTestHint.
  ///
  /// In en, this message translates to:
  /// **'Write or fix automated tests. Needs a repository; ends in a pull request.'**
  String get kindTestHint;

  /// No description provided for @kindPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get kindPlan;

  /// No description provided for @kindPlanHint.
  ///
  /// In en, this message translates to:
  /// **'Write an implementation plan. Changes no code; ends in a report.'**
  String get kindPlanHint;

  /// No description provided for @kindAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get kindAnalysis;

  /// No description provided for @kindAnalysisHint.
  ///
  /// In en, this message translates to:
  /// **'Research a question and report the findings. Changes no code.'**
  String get kindAnalysisHint;

  /// No description provided for @kindBug.
  ///
  /// In en, this message translates to:
  /// **'Bug investigation'**
  String get kindBug;

  /// No description provided for @kindBugHint.
  ///
  /// In en, this message translates to:
  /// **'Find the root cause of a bug and propose a fix. Changes no code.'**
  String get kindBugHint;

  /// No description provided for @kindPickerHint.
  ///
  /// In en, this message translates to:
  /// **'What agnts produces. Choosing a kind makes it final; Auto lets agnts decide while reading the ticket.'**
  String get kindPickerHint;

  /// No description provided for @kindSwitchTo.
  ///
  /// In en, this message translates to:
  /// **'Switch to {kind}'**
  String kindSwitchTo(String kind);

  /// No description provided for @learnTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learnTitle;

  /// No description provided for @learnLede.
  ///
  /// In en, this message translates to:
  /// **'When a change agnts ships does something this codebase never did before, agnts explains it here: what it is, why the change needed it, where to look, and a short quiz.'**
  String get learnLede;

  /// No description provided for @learnViewNew.
  ///
  /// In en, this message translates to:
  /// **'New ({n})'**
  String learnViewNew(String n);

  /// No description provided for @learnViewLearned.
  ///
  /// In en, this message translates to:
  /// **'Learned'**
  String get learnViewLearned;

  /// No description provided for @learnViewAll.
  ///
  /// In en, this message translates to:
  /// **'All ({n})'**
  String learnViewAll(String n);

  /// No description provided for @learnViewLabel.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get learnViewLabel;

  /// No description provided for @learnAllRepos.
  ///
  /// In en, this message translates to:
  /// **'All repositories'**
  String get learnAllRepos;

  /// No description provided for @learnRepoLabel.
  ///
  /// In en, this message translates to:
  /// **'Repository'**
  String get learnRepoLabel;

  /// No description provided for @learnNone.
  ///
  /// In en, this message translates to:
  /// **'No lessons yet. When agnts pushes a change that does something new for its repository, the lesson appears here.'**
  String get learnNone;

  /// No description provided for @learnNoneNew.
  ///
  /// In en, this message translates to:
  /// **'You\'re up to date: every lesson is marked learned.'**
  String get learnNoneNew;

  /// No description provided for @learnNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No lessons match the search.'**
  String get learnNoMatch;

  /// No description provided for @learnFromTicket.
  ///
  /// In en, this message translates to:
  /// **'From {key}'**
  String learnFromTicket(String key);

  /// No description provided for @learnQuizCount.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} quiz question} other {{n} quiz questions}}'**
  String learnQuizCount(num n);

  /// No description provided for @learnNewBadge.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get learnNewBadge;

  /// No description provided for @learnLearned.
  ///
  /// In en, this message translates to:
  /// **'Learned'**
  String get learnLearned;

  /// No description provided for @learnMarkLearned.
  ///
  /// In en, this message translates to:
  /// **'Mark as learned'**
  String get learnMarkLearned;

  /// No description provided for @learnMarkUnlearned.
  ///
  /// In en, this message translates to:
  /// **'Mark as not learned'**
  String get learnMarkUnlearned;

  /// No description provided for @learnMarkedLearned.
  ///
  /// In en, this message translates to:
  /// **'Marked as learned'**
  String get learnMarkedLearned;

  /// No description provided for @learnBack.
  ///
  /// In en, this message translates to:
  /// **'Back to lessons'**
  String get learnBack;

  /// No description provided for @learnNotFound.
  ///
  /// In en, this message translates to:
  /// **'This lesson does not exist.'**
  String get learnNotFound;

  /// No description provided for @learnWhatTitle.
  ///
  /// In en, this message translates to:
  /// **'What it is'**
  String get learnWhatTitle;

  /// No description provided for @learnWhyTitle.
  ///
  /// In en, this message translates to:
  /// **'Why this change needed it'**
  String get learnWhyTitle;

  /// No description provided for @learnWhereTitle.
  ///
  /// In en, this message translates to:
  /// **'Where to look'**
  String get learnWhereTitle;

  /// No description provided for @learnWhereSub.
  ///
  /// In en, this message translates to:
  /// **'Files in {repo} at the time of {key}.'**
  String learnWhereSub(String repo, String key);

  /// No description provided for @learnQuizTitle.
  ///
  /// In en, this message translates to:
  /// **'Check yourself'**
  String get learnQuizTitle;

  /// No description provided for @learnQuizSub.
  ///
  /// In en, this message translates to:
  /// **'Pick an answer to see whether it\'s right.'**
  String get learnQuizSub;

  /// No description provided for @learnCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct.'**
  String get learnCorrect;

  /// No description provided for @learnWrong.
  ///
  /// In en, this message translates to:
  /// **'Not quite.'**
  String get learnWrong;

  /// No description provided for @learnScore.
  ///
  /// In en, this message translates to:
  /// **'{right} of {total} right'**
  String learnScore(String right, String total);

  /// No description provided for @learnRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get learnRetry;

  /// No description provided for @learnReadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Further reading'**
  String get learnReadingTitle;

  /// No description provided for @learnReadingNote.
  ///
  /// In en, this message translates to:
  /// **'Claude suggested these links. Check them before relying on them.'**
  String get learnReadingNote;

  /// No description provided for @learnCategory_pattern.
  ///
  /// In en, this message translates to:
  /// **'Pattern'**
  String get learnCategory_pattern;

  /// No description provided for @learnCategory_architecture.
  ///
  /// In en, this message translates to:
  /// **'Architecture'**
  String get learnCategory_architecture;

  /// No description provided for @learnCategory_algorithm.
  ///
  /// In en, this message translates to:
  /// **'Algorithm'**
  String get learnCategory_algorithm;

  /// No description provided for @learnCategory_library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get learnCategory_library;

  /// No description provided for @learnCategory_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get learnCategory_language;

  /// No description provided for @learnCategory_testing.
  ///
  /// In en, this message translates to:
  /// **'Testing'**
  String get learnCategory_testing;

  /// No description provided for @learnCategory_security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get learnCategory_security;

  /// No description provided for @learnCategory_performance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get learnCategory_performance;

  /// No description provided for @learnCategory_tooling.
  ///
  /// In en, this message translates to:
  /// **'Tooling'**
  String get learnCategory_tooling;

  /// No description provided for @learnCategory_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get learnCategory_other;

  /// No description provided for @learnLevel_beginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get learnLevel_beginner;

  /// No description provided for @learnLevel_intermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get learnLevel_intermediate;

  /// No description provided for @learnLevel_advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get learnLevel_advanced;

  /// No description provided for @learnTicketTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s new in this change'**
  String get learnTicketTitle;

  /// No description provided for @learnTicketSub.
  ///
  /// In en, this message translates to:
  /// **'Techniques this change brought to the repository for the first time.'**
  String get learnTicketSub;

  /// No description provided for @learnTicketPending.
  ///
  /// In en, this message translates to:
  /// **'agnts is reading this change for anything the repository never did before.'**
  String get learnTicketPending;

  /// No description provided for @learnTicketNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing new: this change only used techniques the repository already had.'**
  String get learnTicketNone;

  /// No description provided for @learnTicketFailed.
  ///
  /// In en, this message translates to:
  /// **'agnts could not finish reading this change. The log shows why.'**
  String get learnTicketFailed;

  /// No description provided for @learnTicketIdle.
  ///
  /// In en, this message translates to:
  /// **'agnts has not looked at this change for lessons yet.'**
  String get learnTicketIdle;

  /// No description provided for @learnLearnNow.
  ///
  /// In en, this message translates to:
  /// **'Find what\'s new'**
  String get learnLearnNow;

  /// No description provided for @learnLearnAgain.
  ///
  /// In en, this message translates to:
  /// **'Look again'**
  String get learnLearnAgain;

  /// No description provided for @learnQueued.
  ///
  /// In en, this message translates to:
  /// **'Queued: agnts will look at this change for something new.'**
  String get learnQueued;

  /// No description provided for @learnQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'Learning queue'**
  String get learnQueueTitle;

  /// No description provided for @learnQueueSub.
  ///
  /// In en, this message translates to:
  /// **'Pushed tickets agnts reads for new techniques, one at a time when no ticket needs a worker.'**
  String get learnQueueSub;

  /// No description provided for @learnStatus_running.
  ///
  /// In en, this message translates to:
  /// **'Learning now'**
  String get learnStatus_running;

  /// No description provided for @learnStatus_pending.
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get learnStatus_pending;

  /// No description provided for @learnStatus_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get learnStatus_failed;

  /// No description provided for @learnStatus_none.
  ///
  /// In en, this message translates to:
  /// **'Not learned yet'**
  String get learnStatus_none;

  /// No description provided for @learnQueuePosition.
  ///
  /// In en, this message translates to:
  /// **'#{n} in queue'**
  String learnQueuePosition(String n);

  /// No description provided for @learnQueueBtn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learnQueueBtn;

  /// No description provided for @learnRetryBtn.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get learnRetryBtn;

  /// No description provided for @learnQueueAll.
  ///
  /// In en, this message translates to:
  /// **'Learn from all ({n})'**
  String learnQueueAll(String n);

  /// No description provided for @learnQueuedAll.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} ticket queued} other {{n} tickets queued}}'**
  String learnQueuedAll(num n);

  /// No description provided for @learnReadTime.
  ///
  /// In en, this message translates to:
  /// **'{n} min read'**
  String learnReadTime(num n);

  /// No description provided for @learnQueueLede.
  ///
  /// In en, this message translates to:
  /// **'Pushed tickets agnts reads for techniques the codebase never used before. Queue any done ticket, or retry one that failed.'**
  String get learnQueueLede;

  /// No description provided for @learnQueueEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to learn from right now: every pushed ticket has been read.'**
  String get learnQueueEmpty;

  /// No description provided for @logsTitle.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logsTitle;

  /// No description provided for @logsLede.
  ///
  /// In en, this message translates to:
  /// **'Every step agnts takes, recorded as it happens. Use it to see where time goes and why runs stop.'**
  String get logsLede;

  /// No description provided for @logsLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get logsLive;

  /// No description provided for @logsExportJson.
  ///
  /// In en, this message translates to:
  /// **'Export JSON'**
  String get logsExportJson;

  /// No description provided for @logsExportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get logsExportCsv;

  /// No description provided for @logsRunsStarted.
  ///
  /// In en, this message translates to:
  /// **'Runs started'**
  String get logsRunsStarted;

  /// No description provided for @logsRunsNote.
  ///
  /// In en, this message translates to:
  /// **'Coding sessions, including retries'**
  String get logsRunsNote;

  /// No description provided for @logsReached.
  ///
  /// In en, this message translates to:
  /// **'Reached your review'**
  String get logsReached;

  /// No description provided for @logsReachedNote.
  ///
  /// In en, this message translates to:
  /// **'{n} of {total} runs passed tests'**
  String logsReachedNote(String n, String total);

  /// No description provided for @logsAvgTurns.
  ///
  /// In en, this message translates to:
  /// **'Average turns'**
  String get logsAvgTurns;

  /// No description provided for @logsAvgTurnsNote.
  ///
  /// In en, this message translates to:
  /// **'Per ticket'**
  String get logsAvgTurnsNote;

  /// No description provided for @logsStops.
  ///
  /// In en, this message translates to:
  /// **'Stops and pauses'**
  String get logsStops;

  /// No description provided for @logsStopsNote.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} error event in total} other {{n} error events in total}}'**
  String logsStopsNote(num n);

  /// No description provided for @logsPeriod.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get logsPeriod;

  /// No description provided for @logsWhereTime.
  ///
  /// In en, this message translates to:
  /// **'Where the time goes'**
  String get logsWhereTime;

  /// No description provided for @logsWhereTimeSub.
  ///
  /// In en, this message translates to:
  /// **'Average time spent in each step, across all tickets and tasks'**
  String get logsWhereTimeSub;

  /// No description provided for @logsNoData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get logsNoData;

  /// No description provided for @logsLegendAgnts.
  ///
  /// In en, this message translates to:
  /// **'agnts working'**
  String get logsLegendAgnts;

  /// No description provided for @logsLegendYou.
  ///
  /// In en, this message translates to:
  /// **'Waiting on you'**
  String get logsLegendYou;

  /// No description provided for @logsEventsTitle.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get logsEventsTitle;

  /// No description provided for @logsEventsSub.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} event shown} other {{n} events shown}}, newest first. Select a row to see its raw data.'**
  String logsEventsSub(num n);

  /// No description provided for @logsTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get logsTabAll;

  /// No description provided for @logsTabState.
  ///
  /// In en, this message translates to:
  /// **'State changes'**
  String get logsTabState;

  /// No description provided for @logsTabTool.
  ///
  /// In en, this message translates to:
  /// **'Tool calls'**
  String get logsTabTool;

  /// No description provided for @logsTabCommand.
  ///
  /// In en, this message translates to:
  /// **'Commands'**
  String get logsTabCommand;

  /// No description provided for @logsTabUser.
  ///
  /// In en, this message translates to:
  /// **'Your actions'**
  String get logsTabUser;

  /// No description provided for @logsTabLimit.
  ///
  /// In en, this message translates to:
  /// **'Plan limits'**
  String get logsTabLimit;

  /// No description provided for @logsTabProblems.
  ///
  /// In en, this message translates to:
  /// **'Warnings and errors'**
  String get logsTabProblems;

  /// No description provided for @logsKeyFilter.
  ///
  /// In en, this message translates to:
  /// **'Ticket key, e.g. PAY-214'**
  String get logsKeyFilter;

  /// No description provided for @logsKeyFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Filter by ticket key'**
  String get logsKeyFilterLabel;

  /// No description provided for @logsErrorsOnly.
  ///
  /// In en, this message translates to:
  /// **'Errors only'**
  String get logsErrorsOnly;

  /// No description provided for @logsClear.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get logsClear;

  /// No description provided for @logsColTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get logsColTime;

  /// No description provided for @logsColTicket.
  ///
  /// In en, this message translates to:
  /// **'Ticket'**
  String get logsColTicket;

  /// No description provided for @logsColStep.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get logsColStep;

  /// No description provided for @logsColType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get logsColType;

  /// No description provided for @logsColEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get logsColEvent;

  /// No description provided for @logsColDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get logsColDuration;

  /// No description provided for @logsNoEvents.
  ///
  /// In en, this message translates to:
  /// **'No events match these filters.'**
  String get logsNoEvents;

  /// No description provided for @logsNoDetail.
  ///
  /// In en, this message translates to:
  /// **'No extra data for this event.'**
  String get logsNoDetail;

  /// No description provided for @logsShowMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get logsShowMore;

  /// No description provided for @logsTypeState.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get logsTypeState;

  /// No description provided for @logsTypeTool.
  ///
  /// In en, this message translates to:
  /// **'Tool'**
  String get logsTypeTool;

  /// No description provided for @logsTypeCommand.
  ///
  /// In en, this message translates to:
  /// **'Command'**
  String get logsTypeCommand;

  /// No description provided for @logsTypeYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get logsTypeYou;

  /// No description provided for @logsTypeLimit.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get logsTypeLimit;

  /// No description provided for @logsTypeError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get logsTypeError;

  /// No description provided for @logsTypeEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get logsTypeEvent;

  /// No description provided for @manalyticsTickets.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} ticket} other {{n} tickets}}'**
  String manalyticsTickets(num n);

  /// No description provided for @manalyticsTurns.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} turn} other {{n} turns}}'**
  String manalyticsTurns(num n);

  /// No description provided for @manalyticsShareOfRuns.
  ///
  /// In en, this message translates to:
  /// **'{n}% of runs'**
  String manalyticsShareOfRuns(String n);

  /// No description provided for @manalyticsReachedReview.
  ///
  /// In en, this message translates to:
  /// **'{n}% reached review'**
  String manalyticsReachedReview(String n);

  /// No description provided for @manalyticsAbout.
  ///
  /// In en, this message translates to:
  /// **'About analytics'**
  String get manalyticsAbout;

  /// No description provided for @manalyticsStopped.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} stopped run in this period} other {{n} stopped runs in this period}}'**
  String manalyticsStopped(num n);

  /// No description provided for @manalyticsDays.
  ///
  /// In en, this message translates to:
  /// **'{n} days'**
  String manalyticsDays(num n);

  /// No description provided for @manalyticsCompared.
  ///
  /// In en, this message translates to:
  /// **'Changes are compared with the previous {n} days. Green means better.'**
  String manalyticsCompared(num n);

  /// No description provided for @mcpTitle.
  ///
  /// In en, this message translates to:
  /// **'Claude chat (MCP)'**
  String get mcpTitle;

  /// No description provided for @mcpSub.
  ///
  /// In en, this message translates to:
  /// **'Manage agnts from Claude on the web, desktop and phone'**
  String get mcpSub;

  /// No description provided for @mcpUrl.
  ///
  /// In en, this message translates to:
  /// **'Connector URL'**
  String get mcpUrl;

  /// No description provided for @mcpConnections.
  ///
  /// In en, this message translates to:
  /// **'Connected Claude apps'**
  String get mcpConnections;

  /// No description provided for @mcpStaticToken.
  ///
  /// In en, this message translates to:
  /// **'Static token'**
  String get mcpStaticToken;

  /// No description provided for @mcpSet.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get mcpSet;

  /// No description provided for @mcpNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get mcpNotSet;

  /// No description provided for @mcpHowTo.
  ///
  /// In en, this message translates to:
  /// **'In Claude, open Settings → Connectors → Add custom connector and paste the URL. Claude sends you here to approve the connection. In chat, every change (answers, approve, reject, new tasks) is prepared first and only runs after you confirm it. For Claude Code or Claude Desktop you can use a static token instead: send it as Authorization: Bearer.'**
  String get mcpHowTo;

  /// No description provided for @mcpNewToken.
  ///
  /// In en, this message translates to:
  /// **'New token'**
  String get mcpNewToken;

  /// No description provided for @mcpShownOnce.
  ///
  /// In en, this message translates to:
  /// **'Copy it now: it is shown only once. The previous token no longer works.'**
  String get mcpShownOnce;

  /// No description provided for @mcpCreate.
  ///
  /// In en, this message translates to:
  /// **'Create static token'**
  String get mcpCreate;

  /// No description provided for @mcpRotate.
  ///
  /// In en, this message translates to:
  /// **'Replace static token'**
  String get mcpRotate;

  /// No description provided for @mcpRevoke.
  ///
  /// In en, this message translates to:
  /// **'Disconnect all'**
  String get mcpRevoke;

  /// No description provided for @mcpRevokeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Disconnect every Claude app and delete the static token?'**
  String get mcpRevokeConfirm;

  /// No description provided for @mcpRevoked.
  ///
  /// In en, this message translates to:
  /// **'All Claude connections removed'**
  String get mcpRevoked;

  /// No description provided for @mcpConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect Claude to agnts'**
  String get mcpConsentTitle;

  /// No description provided for @mcpConsentAsk.
  ///
  /// In en, this message translates to:
  /// **'{client} wants to use agnts as {user}.'**
  String mcpConsentAsk(String client, String user);

  /// No description provided for @mcpConsentWhat.
  ///
  /// In en, this message translates to:
  /// **'It can read your tickets, logs, usage and repositories, and prepare actions. Nothing changes until you confirm each action in the chat. Deploys, settings and integrations are not available to it.'**
  String get mcpConsentWhat;

  /// No description provided for @mcpConsentRedirect.
  ///
  /// In en, this message translates to:
  /// **'You will return to {host}.'**
  String mcpConsentRedirect(String host);

  /// No description provided for @mcpAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get mcpAllow;

  /// No description provided for @mcpDeny.
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get mcpDeny;

  /// No description provided for @mdetailApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get mdetailApprove;

  /// No description provided for @mdetailWorking.
  ///
  /// In en, this message translates to:
  /// **'agnts is working. You\'ll get a notification when it needs you.'**
  String get mdetailWorking;

  /// No description provided for @mdetailCopyPr.
  ///
  /// In en, this message translates to:
  /// **'Copy pull request link'**
  String get mdetailCopyPr;

  /// No description provided for @mdetailCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get mdetailCopied;

  /// No description provided for @mdetailFactTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get mdetailFactTime;

  /// No description provided for @mhomeRunningNote.
  ///
  /// In en, this message translates to:
  /// **'{parallel} at a time allowed, {queued} in queue'**
  String mhomeRunningNote(String parallel, String queued);

  /// No description provided for @mhomeWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting {time}'**
  String mhomeWaiting(String time);

  /// No description provided for @mhomeActAnswers.
  ///
  /// In en, this message translates to:
  /// **'Answer agnts\'s questions'**
  String get mhomeActAnswers;

  /// No description provided for @mhomeActReview.
  ///
  /// In en, this message translates to:
  /// **'Review the changes'**
  String get mhomeActReview;

  /// No description provided for @mhomeActStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped. Tell agnts what to try'**
  String get mhomeActStopped;

  /// No description provided for @mhomeActResume.
  ///
  /// In en, this message translates to:
  /// **'Resume when you\'re ready'**
  String get mhomeActResume;

  /// No description provided for @mhomeActStart.
  ///
  /// In en, this message translates to:
  /// **'Kept in queue. Tap to start'**
  String get mhomeActStart;

  /// No description provided for @mhomeLiveFallback.
  ///
  /// In en, this message translates to:
  /// **'Working…'**
  String get mhomeLiveFallback;

  /// No description provided for @mhomeSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tickets match your search.'**
  String get mhomeSearchEmpty;

  /// No description provided for @mmoreAgo.
  ///
  /// In en, this message translates to:
  /// **'{time} ago'**
  String mmoreAgo(String time);

  /// No description provided for @mmoreJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get mmoreJustNow;

  /// No description provided for @mmoreLangPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone language'**
  String get mmoreLangPhone;

  /// No description provided for @mmoreSignedInTo.
  ///
  /// In en, this message translates to:
  /// **'Signed in to {server}'**
  String mmoreSignedInTo(String server);

  /// No description provided for @mmorePipelineRuns.
  ///
  /// In en, this message translates to:
  /// **'Pipeline runs'**
  String get mmorePipelineRuns;

  /// No description provided for @mmoreLoginLede.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your agnts server to answer questions, review changes and follow runs.'**
  String get mmoreLoginLede;

  /// No description provided for @mobileServer.
  ///
  /// In en, this message translates to:
  /// **'Server address'**
  String get mobileServer;

  /// No description provided for @mobileServerHint.
  ///
  /// In en, this message translates to:
  /// **'https://agnts.example.com'**
  String get mobileServerHint;

  /// No description provided for @mobileServerInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter the https address of your agnts server.'**
  String get mobileServerInvalid;

  /// No description provided for @mobileHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get mobileHome;

  /// No description provided for @mobileActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get mobileActivity;

  /// No description provided for @mobileMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get mobileMore;

  /// No description provided for @mobileGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String mobileGreeting(String name);

  /// No description provided for @mobileNeedsYou.
  ///
  /// In en, this message translates to:
  /// **'Needs you'**
  String get mobileNeedsYou;

  /// No description provided for @mobileRunningNow.
  ///
  /// In en, this message translates to:
  /// **'Running now'**
  String get mobileRunningNow;

  /// No description provided for @mobileInQueue.
  ///
  /// In en, this message translates to:
  /// **'In queue'**
  String get mobileInQueue;

  /// No description provided for @mobileNothingWaiting.
  ///
  /// In en, this message translates to:
  /// **'Nothing is waiting on you.'**
  String get mobileNothingWaiting;

  /// No description provided for @mobileNoRuns.
  ///
  /// In en, this message translates to:
  /// **'No runs at the moment.'**
  String get mobileNoRuns;

  /// No description provided for @mobileLiveRuns.
  ///
  /// In en, this message translates to:
  /// **'Live runs'**
  String get mobileLiveRuns;

  /// No description provided for @mobileTurnsOf.
  ///
  /// In en, this message translates to:
  /// **'{turns} of {max} turns'**
  String mobileTurnsOf(String turns, String max);

  /// No description provided for @mobileWaitingFor.
  ///
  /// In en, this message translates to:
  /// **'waiting {time}'**
  String mobileWaitingFor(String time);

  /// No description provided for @mobileUsage.
  ///
  /// In en, this message translates to:
  /// **'Plan usage'**
  String get mobileUsage;

  /// No description provided for @mobileSession.
  ///
  /// In en, this message translates to:
  /// **'Current session'**
  String get mobileSession;

  /// No description provided for @mobileWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get mobileWeek;

  /// No description provided for @mobileRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get mobileRefresh;

  /// No description provided for @mobilePaused.
  ///
  /// In en, this message translates to:
  /// **'New runs are paused until the limit resets.'**
  String get mobilePaused;

  /// No description provided for @mobileAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get mobileAppearance;

  /// No description provided for @mobileTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get mobileTheme;

  /// No description provided for @mobileThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get mobileThemeSystem;

  /// No description provided for @mobileThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get mobileThemeLight;

  /// No description provided for @mobileThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get mobileThemeDark;

  /// No description provided for @mobileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get mobileLanguage;

  /// No description provided for @mobileDefaultModels.
  ///
  /// In en, this message translates to:
  /// **'Default models'**
  String get mobileDefaultModels;

  /// No description provided for @mobilePush.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get mobilePush;

  /// No description provided for @mobilePushOn.
  ///
  /// In en, this message translates to:
  /// **'Send to this phone'**
  String get mobilePushOn;

  /// No description provided for @mobilePushNeeds.
  ///
  /// In en, this message translates to:
  /// **'When something needs you'**
  String get mobilePushNeeds;

  /// No description provided for @mobilePushStopped.
  ///
  /// In en, this message translates to:
  /// **'When a run stops or pauses'**
  String get mobilePushStopped;

  /// No description provided for @mobilePushDone.
  ///
  /// In en, this message translates to:
  /// **'When changes are pushed'**
  String get mobilePushDone;

  /// No description provided for @mobilePushUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Push is not set up on this server.'**
  String get mobilePushUnavailable;

  /// No description provided for @mobileIntegrations.
  ///
  /// In en, this message translates to:
  /// **'Integrations'**
  String get mobileIntegrations;

  /// No description provided for @mobileRepositories.
  ///
  /// In en, this message translates to:
  /// **'Repositories'**
  String get mobileRepositories;

  /// No description provided for @mobileConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get mobileConnected;

  /// No description provided for @mobileNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get mobileNotConnected;

  /// No description provided for @mobileSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get mobileSaved;

  /// No description provided for @mobileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get mobileSignOut;

  /// No description provided for @mobileNewTask.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get mobileNewTask;

  /// No description provided for @mobileTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get mobileTaskTitle;

  /// No description provided for @mobileTaskDescription.
  ///
  /// In en, this message translates to:
  /// **'What should be done'**
  String get mobileTaskDescription;

  /// No description provided for @mobileTaskRepo.
  ///
  /// In en, this message translates to:
  /// **'Repository'**
  String get mobileTaskRepo;

  /// No description provided for @mobileTaskPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get mobileTaskPriority;

  /// No description provided for @mobilePriorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get mobilePriorityLow;

  /// No description provided for @mobilePriorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get mobilePriorityMedium;

  /// No description provided for @mobilePriorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get mobilePriorityHigh;

  /// No description provided for @mobileAfterApprove.
  ///
  /// In en, this message translates to:
  /// **'After you approve'**
  String get mobileAfterApprove;

  /// No description provided for @mobileAfterMain.
  ///
  /// In en, this message translates to:
  /// **'Push to main'**
  String get mobileAfterMain;

  /// No description provided for @mobileAfterPr.
  ///
  /// In en, this message translates to:
  /// **'Open pull request'**
  String get mobileAfterPr;

  /// No description provided for @mobileStart.
  ///
  /// In en, this message translates to:
  /// **'How to start'**
  String get mobileStart;

  /// No description provided for @mobileStartAsk.
  ///
  /// In en, this message translates to:
  /// **'Ask questions first'**
  String get mobileStartAsk;

  /// No description provided for @mobileStartCode.
  ///
  /// In en, this message translates to:
  /// **'Start coding right away'**
  String get mobileStartCode;

  /// No description provided for @mobileStartQueue.
  ///
  /// In en, this message translates to:
  /// **'Keep in queue'**
  String get mobileStartQueue;

  /// No description provided for @mobileCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get mobileCreate;

  /// No description provided for @mobileNoSideRepos.
  ///
  /// In en, this message translates to:
  /// **'Add a side-project repository in the admin panel first.'**
  String get mobileNoSideRepos;

  /// No description provided for @mobileNoTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet.'**
  String get mobileNoTasks;

  /// No description provided for @mobileNoEvents.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get mobileNoEvents;

  /// No description provided for @mobileFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get mobileFilterAll;

  /// No description provided for @mobileFilterProblems.
  ///
  /// In en, this message translates to:
  /// **'Problems'**
  String get mobileFilterProblems;

  /// No description provided for @mobileFilterYou.
  ///
  /// In en, this message translates to:
  /// **'Your actions'**
  String get mobileFilterYou;

  /// No description provided for @mobileAnswer.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get mobileAnswer;

  /// No description provided for @mobileReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get mobileReview;

  /// No description provided for @mobileConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get mobileConfirm;

  /// No description provided for @mobileCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get mobileCancel;

  /// No description provided for @mobileRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get mobileRetry;

  /// No description provided for @mobileStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get mobileStop;

  /// No description provided for @mobileOffline.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server. Pull to retry.'**
  String get mobileOffline;

  /// No description provided for @mobileOpenInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in browser'**
  String get mobileOpenInBrowser;

  /// No description provided for @mobileVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String mobileVersion(String version);

  /// No description provided for @mobileBranches.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get mobileBranches;

  /// No description provided for @mobileCommits.
  ///
  /// In en, this message translates to:
  /// **'Commits'**
  String get mobileCommits;

  /// No description provided for @mobilePipelines.
  ///
  /// In en, this message translates to:
  /// **'Pipelines'**
  String get mobilePipelines;

  /// No description provided for @mobileDeploy.
  ///
  /// In en, this message translates to:
  /// **'Deploy'**
  String get mobileDeploy;

  /// No description provided for @mobileDeployConfirm.
  ///
  /// In en, this message translates to:
  /// **'Start {stage}? This deploys to a live environment.'**
  String mobileDeployConfirm(String stage);

  /// No description provided for @mobileDeployStarted.
  ///
  /// In en, this message translates to:
  /// **'Deploy started'**
  String get mobileDeployStarted;

  /// No description provided for @mobileAheadBehind.
  ///
  /// In en, this message translates to:
  /// **'↑{ahead} ↓{behind}'**
  String mobileAheadBehind(String ahead, String behind);

  /// No description provided for @mobileCiOk.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get mobileCiOk;

  /// No description provided for @mobileCiFail.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get mobileCiFail;

  /// No description provided for @mobileCiRun.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get mobileCiRun;

  /// No description provided for @mobileCiWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get mobileCiWaiting;

  /// No description provided for @mobileCiManual.
  ///
  /// In en, this message translates to:
  /// **'Waiting for you'**
  String get mobileCiManual;

  /// No description provided for @mobileCiNone.
  ///
  /// In en, this message translates to:
  /// **'No pipeline'**
  String get mobileCiNone;

  /// No description provided for @mobileGitHostError.
  ///
  /// In en, this message translates to:
  /// **'The git host returned an error. Check the integration.'**
  String get mobileGitHostError;

  /// No description provided for @mobileLastDays.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get mobileLastDays;

  /// No description provided for @mobilePushed.
  ///
  /// In en, this message translates to:
  /// **'Pushed'**
  String get mobilePushed;

  /// No description provided for @mobileFirstTry.
  ///
  /// In en, this message translates to:
  /// **'First try'**
  String get mobileFirstTry;

  /// No description provided for @mobileWaitingAvg.
  ///
  /// In en, this message translates to:
  /// **'Waiting on you'**
  String get mobileWaitingAvg;

  /// No description provided for @mobileMinutes.
  ///
  /// In en, this message translates to:
  /// **'{n} min'**
  String mobileMinutes(String n);

  /// No description provided for @mpreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'agnts\'s preview'**
  String get mpreviewTitle;

  /// No description provided for @mpreviewSub.
  ///
  /// In en, this message translates to:
  /// **'Screenshots of the app with this change. Advice beside your review: it never blocks approval.'**
  String get mpreviewSub;

  /// No description provided for @mpreviewPending.
  ///
  /// In en, this message translates to:
  /// **'Queued: agnts starts the app and takes screenshots as soon as a worker is free.'**
  String get mpreviewPending;

  /// No description provided for @mpreviewRunning.
  ///
  /// In en, this message translates to:
  /// **'agnts is starting the app and taking screenshots…'**
  String get mpreviewRunning;

  /// No description provided for @mpreviewFailed.
  ///
  /// In en, this message translates to:
  /// **'The preview failed. Check the app yourself, or run it again.'**
  String get mpreviewFailed;

  /// No description provided for @mpreviewAppFailed.
  ///
  /// In en, this message translates to:
  /// **'The app did not start, so there are no screenshots. The end of its log:'**
  String get mpreviewAppFailed;

  /// No description provided for @mpreviewStale.
  ///
  /// In en, this message translates to:
  /// **'These screenshots are of revision {n}; the work changed since.'**
  String mpreviewStale(String n);

  /// No description provided for @mpreviewRun.
  ///
  /// In en, this message translates to:
  /// **'Take screenshots'**
  String get mpreviewRun;

  /// No description provided for @mpreviewRunAgain.
  ///
  /// In en, this message translates to:
  /// **'Run again'**
  String get mpreviewRunAgain;

  /// No description provided for @mpreviewCompare.
  ///
  /// In en, this message translates to:
  /// **'Compare with the default branch'**
  String get mpreviewCompare;

  /// No description provided for @mpreviewCompareHelp.
  ///
  /// In en, this message translates to:
  /// **'Also takes the same screenshots without this change.'**
  String get mpreviewCompareHelp;

  /// No description provided for @mpreviewStatus_ok.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get mpreviewStatus_ok;

  /// No description provided for @mpreviewStatus_partial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get mpreviewStatus_partial;

  /// No description provided for @mpreviewStatus_failed.
  ///
  /// In en, this message translates to:
  /// **'Did not start'**
  String get mpreviewStatus_failed;

  /// No description provided for @mpreviewModel.
  ///
  /// In en, this message translates to:
  /// **'Checked by {model}'**
  String mpreviewModel(String model);

  /// No description provided for @mpreviewIssues.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {No issues} one {{count} issue} other {{count} issues}}'**
  String mpreviewIssues(num count);

  /// No description provided for @mpreviewNoIssues.
  ///
  /// In en, this message translates to:
  /// **'agnts saw no visual problems.'**
  String get mpreviewNoIssues;

  /// No description provided for @mpreviewSev_high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get mpreviewSev_high;

  /// No description provided for @mpreviewSev_medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get mpreviewSev_medium;

  /// No description provided for @mpreviewSev_low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get mpreviewSev_low;

  /// No description provided for @mpreviewShowShot.
  ///
  /// In en, this message translates to:
  /// **'Show screenshot'**
  String get mpreviewShowShot;

  /// No description provided for @mpreviewDesktop.
  ///
  /// In en, this message translates to:
  /// **'Desktop'**
  String get mpreviewDesktop;

  /// No description provided for @mpreviewPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get mpreviewPhone;

  /// No description provided for @mpreviewBefore.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get mpreviewBefore;

  /// No description provided for @mpreviewAfter.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get mpreviewAfter;

  /// No description provided for @mpreviewNoShots.
  ///
  /// In en, this message translates to:
  /// **'No screenshots at this width.'**
  String get mpreviewNoShots;

  /// No description provided for @mpreviewConsoleErrors.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {{count} console error} other {{count} console errors}}'**
  String mpreviewConsoleErrors(num count);

  /// No description provided for @mpreviewLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the screenshot.'**
  String get mpreviewLoadFailed;

  /// No description provided for @mpreviewAddToFeedback.
  ///
  /// In en, this message translates to:
  /// **'Add to feedback'**
  String get mpreviewAddToFeedback;

  /// No description provided for @mpreviewAdded.
  ///
  /// In en, this message translates to:
  /// **'In feedback'**
  String get mpreviewAdded;

  /// No description provided for @mpreviewAttached.
  ///
  /// In en, this message translates to:
  /// **'Screenshots sent with the feedback'**
  String get mpreviewAttached;

  /// No description provided for @mpreviewAttachLimit.
  ///
  /// In en, this message translates to:
  /// **'Up to {max} screenshots can go with the feedback.'**
  String mpreviewAttachLimit(String max);

  /// No description provided for @mpreviewRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get mpreviewRemove;

  /// No description provided for @mpreviewSettingsModel.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get mpreviewSettingsModel;

  /// No description provided for @mpreviewSettingsModelHelp.
  ///
  /// In en, this message translates to:
  /// **'Looks at screenshots of the running app'**
  String get mpreviewSettingsModelHelp;

  /// No description provided for @mpreviewNotify.
  ///
  /// In en, this message translates to:
  /// **'Preview screenshots are ready'**
  String get mpreviewNotify;

  /// No description provided for @mtasksActAnswers.
  ///
  /// In en, this message translates to:
  /// **'Answer agnts\'s questions'**
  String get mtasksActAnswers;

  /// No description provided for @mtasksActReview.
  ///
  /// In en, this message translates to:
  /// **'Review the changes'**
  String get mtasksActReview;

  /// No description provided for @mtasksActFailed.
  ///
  /// In en, this message translates to:
  /// **'Stopped. Tell agnts what to try'**
  String get mtasksActFailed;

  /// No description provided for @mtasksActResume.
  ///
  /// In en, this message translates to:
  /// **'Resume when you\'re ready'**
  String get mtasksActResume;

  /// No description provided for @mtasksActAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Tap to analyze'**
  String get mtasksActAnalyze;

  /// No description provided for @mtasksActHeld.
  ///
  /// In en, this message translates to:
  /// **'Kept in queue. Tap to start'**
  String get mtasksActHeld;

  /// No description provided for @mtasksYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get mtasksYesterday;

  /// No description provided for @navOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get navOverview;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get navAnalytics;

  /// No description provided for @navTickets.
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get navTickets;

  /// No description provided for @navNeeds.
  ///
  /// In en, this message translates to:
  /// **'Needs you'**
  String get navNeeds;

  /// No description provided for @navRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get navRunning;

  /// No description provided for @navQueue.
  ///
  /// In en, this message translates to:
  /// **'In queue'**
  String get navQueue;

  /// No description provided for @navDone.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get navDone;

  /// No description provided for @navAll.
  ///
  /// In en, this message translates to:
  /// **'All tickets'**
  String get navAll;

  /// No description provided for @navSideProjects.
  ///
  /// In en, this message translates to:
  /// **'Side projects'**
  String get navSideProjects;

  /// No description provided for @navTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get navTasks;

  /// No description provided for @navMonitor.
  ///
  /// In en, this message translates to:
  /// **'Monitor'**
  String get navMonitor;

  /// No description provided for @navLogs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get navLogs;

  /// No description provided for @navUsage.
  ///
  /// In en, this message translates to:
  /// **'Plan usage'**
  String get navUsage;

  /// No description provided for @navSetup.
  ///
  /// In en, this message translates to:
  /// **'Setup'**
  String get navSetup;

  /// No description provided for @navIntegrations.
  ///
  /// In en, this message translates to:
  /// **'Integrations'**
  String get navIntegrations;

  /// No description provided for @navRepos.
  ///
  /// In en, this message translates to:
  /// **'Repositories'**
  String get navRepos;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search tickets and tasks'**
  String get navSearch;

  /// No description provided for @navSyncJira.
  ///
  /// In en, this message translates to:
  /// **'Sync Jira'**
  String get navSyncJira;

  /// No description provided for @navSynced.
  ///
  /// In en, this message translates to:
  /// **'Jira synced: {found} open, {created} new'**
  String navSynced(String found, String created);

  /// No description provided for @navSession.
  ///
  /// In en, this message translates to:
  /// **'Current session'**
  String get navSession;

  /// No description provided for @navWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get navWeek;

  /// No description provided for @navDayMode.
  ///
  /// In en, this message translates to:
  /// **'Switch to day mode'**
  String get navDayMode;

  /// No description provided for @navNightMode.
  ///
  /// In en, this message translates to:
  /// **'Switch to night mode'**
  String get navNightMode;

  /// No description provided for @navCollapseSidebar.
  ///
  /// In en, this message translates to:
  /// **'Collapse sidebar'**
  String get navCollapseSidebar;

  /// No description provided for @navExpandSidebar.
  ///
  /// In en, this message translates to:
  /// **'Expand sidebar'**
  String get navExpandSidebar;

  /// No description provided for @navLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get navLanguage;

  /// No description provided for @navGuide.
  ///
  /// In en, this message translates to:
  /// **'How this page works'**
  String get navGuide;

  /// No description provided for @navClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get navClose;

  /// No description provided for @navMain.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get navMain;

  /// No description provided for @navLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get navLive;

  /// No description provided for @navOffline.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting…'**
  String get navOffline;

  /// No description provided for @navResetsIn.
  ///
  /// In en, this message translates to:
  /// **'Resets in {time}'**
  String navResetsIn(String time);

  /// No description provided for @navResettingNow.
  ///
  /// In en, this message translates to:
  /// **'Resetting now'**
  String get navResettingNow;

  /// No description provided for @navUsageUnknown.
  ///
  /// In en, this message translates to:
  /// **'Usage unknown'**
  String get navUsageUnknown;

  /// No description provided for @navBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get navBack;

  /// No description provided for @navLedeNeeds.
  ///
  /// In en, this message translates to:
  /// **'Tickets waiting on your answers or your review, plus runs that stopped.'**
  String get navLedeNeeds;

  /// No description provided for @navLedeRunning.
  ///
  /// In en, this message translates to:
  /// **'Tickets agnts is working on right now.'**
  String get navLedeRunning;

  /// No description provided for @navLedeQueue.
  ///
  /// In en, this message translates to:
  /// **'Tickets with the agnts label that haven\'t been analyzed yet.'**
  String get navLedeQueue;

  /// No description provided for @navLedeDone.
  ///
  /// In en, this message translates to:
  /// **'Pushed or rejected tickets.'**
  String get navLedeDone;

  /// No description provided for @navLedeAll.
  ///
  /// In en, this message translates to:
  /// **'Every ticket agnts has picked up from Jira.'**
  String get navLedeAll;

  /// No description provided for @navKnowledge.
  ///
  /// In en, this message translates to:
  /// **'Knowledge'**
  String get navKnowledge;

  /// No description provided for @navLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get navLearn;

  /// No description provided for @navLearnQueue.
  ///
  /// In en, this message translates to:
  /// **'Learning queue'**
  String get navLearnQueue;

  /// No description provided for @navRules.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get navRules;

  /// No description provided for @previewTab.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewTab;

  /// No description provided for @previewTitle.
  ///
  /// In en, this message translates to:
  /// **'Screenshots of the app'**
  String get previewTitle;

  /// No description provided for @previewSub.
  ///
  /// In en, this message translates to:
  /// **'agnts started the app with this change and took screenshots. Advice only: it never blocks approval.'**
  String get previewSub;

  /// No description provided for @previewPending.
  ///
  /// In en, this message translates to:
  /// **'Queued: agnts takes screenshots as soon as a worker is free.'**
  String get previewPending;

  /// No description provided for @previewRunning.
  ///
  /// In en, this message translates to:
  /// **'agnts is starting the app and taking screenshots…'**
  String get previewRunning;

  /// No description provided for @previewFailed.
  ///
  /// In en, this message translates to:
  /// **'The preview run failed. Check the run log, or run it again.'**
  String get previewFailed;

  /// No description provided for @previewStale.
  ///
  /// In en, this message translates to:
  /// **'These screenshots are of revision {n}; the change moved on since.'**
  String previewStale(String n);

  /// No description provided for @previewNone.
  ///
  /// In en, this message translates to:
  /// **'No screenshots yet.'**
  String get previewNone;

  /// No description provided for @previewStatus_ok.
  ///
  /// In en, this message translates to:
  /// **'Captured'**
  String get previewStatus_ok;

  /// No description provided for @previewStatus_partial.
  ///
  /// In en, this message translates to:
  /// **'Partly captured'**
  String get previewStatus_partial;

  /// No description provided for @previewStatus_failed.
  ///
  /// In en, this message translates to:
  /// **'App did not start'**
  String get previewStatus_failed;

  /// No description provided for @previewModel.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =0 {No screenshots} one {{n} screenshot} other {{n} screenshots}} by {model}'**
  String previewModel(num n, String model);

  /// No description provided for @previewWithBase.
  ///
  /// In en, this message translates to:
  /// **'with the default branch for comparison'**
  String get previewWithBase;

  /// No description provided for @previewSev_high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get previewSev_high;

  /// No description provided for @previewSev_medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get previewSev_medium;

  /// No description provided for @previewSev_low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get previewSev_low;

  /// No description provided for @previewNoIssues.
  ///
  /// In en, this message translates to:
  /// **'agnts saw no visual problems.'**
  String get previewNoIssues;

  /// No description provided for @previewViewport.
  ///
  /// In en, this message translates to:
  /// **'Screen size'**
  String get previewViewport;

  /// No description provided for @previewVp_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get previewVp_all;

  /// No description provided for @previewVp_desktop.
  ///
  /// In en, this message translates to:
  /// **'Desktop'**
  String get previewVp_desktop;

  /// No description provided for @previewVp_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get previewVp_phone;

  /// No description provided for @previewMode.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get previewMode;

  /// No description provided for @previewMode_after.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get previewMode_after;

  /// No description provided for @previewMode_before.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get previewMode_before;

  /// No description provided for @previewMode_side.
  ///
  /// In en, this message translates to:
  /// **'Side by side'**
  String get previewMode_side;

  /// No description provided for @previewMode_slider.
  ///
  /// In en, this message translates to:
  /// **'Slider'**
  String get previewMode_slider;

  /// No description provided for @previewSlider.
  ///
  /// In en, this message translates to:
  /// **'Drag to compare before and after'**
  String get previewSlider;

  /// No description provided for @previewConsoleErrors.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {{count} console error} other {{count} console errors}}'**
  String previewConsoleErrors(num count);

  /// No description provided for @previewNoBefore.
  ///
  /// In en, this message translates to:
  /// **'No before screenshot: this page is new or could not open on the default branch.'**
  String get previewNoBefore;

  /// No description provided for @previewAddToFeedback.
  ///
  /// In en, this message translates to:
  /// **'Add to feedback'**
  String get previewAddToFeedback;

  /// No description provided for @previewAdded.
  ///
  /// In en, this message translates to:
  /// **'In feedback'**
  String get previewAdded;

  /// No description provided for @previewCompare.
  ///
  /// In en, this message translates to:
  /// **'Compare with the default branch'**
  String get previewCompare;

  /// No description provided for @previewRun.
  ///
  /// In en, this message translates to:
  /// **'Take screenshots'**
  String get previewRun;

  /// No description provided for @previewRunAgain.
  ///
  /// In en, this message translates to:
  /// **'Take screenshots again'**
  String get previewRunAgain;

  /// No description provided for @previewTooMany.
  ///
  /// In en, this message translates to:
  /// **'Feedback can carry {n} screenshots at most.'**
  String previewTooMany(String n);

  /// No description provided for @previewAttached.
  ///
  /// In en, this message translates to:
  /// **'Screenshots sent with the feedback'**
  String get previewAttached;

  /// No description provided for @previewDetach.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String previewDetach(String name);

  /// No description provided for @previewRepoTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewRepoTitle;

  /// No description provided for @previewRepoHelp.
  ///
  /// In en, this message translates to:
  /// **'How agnts starts the app to take screenshots of UI changes before you review them. Leave the command empty to turn previews off.'**
  String get previewRepoHelp;

  /// No description provided for @previewRepoCommand.
  ///
  /// In en, this message translates to:
  /// **'Start command'**
  String get previewRepoCommand;

  /// No description provided for @previewRepoCommandHelp.
  ///
  /// In en, this message translates to:
  /// **'Runs in /workspace inside the run container: install, build and start the dev server. It must listen on the port below.'**
  String get previewRepoCommandHelp;

  /// No description provided for @previewRepoPort.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get previewRepoPort;

  /// No description provided for @previewRepoReady.
  ///
  /// In en, this message translates to:
  /// **'Ready path'**
  String get previewRepoReady;

  /// No description provided for @previewRepoUiPaths.
  ///
  /// In en, this message translates to:
  /// **'UI files'**
  String get previewRepoUiPaths;

  /// No description provided for @previewRepoUiPathsHelp.
  ///
  /// In en, this message translates to:
  /// **'One glob per line, relative to the repository root. A change touching one gets screenshots. Empty: every change.'**
  String get previewRepoUiPathsHelp;

  /// No description provided for @previewRepoRoutes.
  ///
  /// In en, this message translates to:
  /// **'Always capture'**
  String get previewRepoRoutes;

  /// No description provided for @previewRepoRoutesHelp.
  ///
  /// In en, this message translates to:
  /// **'Routes captured on every preview, one per line, besides the ones agnts picks from the diff.'**
  String get previewRepoRoutesHelp;

  /// No description provided for @previewRepoLogin.
  ///
  /// In en, this message translates to:
  /// **'Signing in'**
  String get previewRepoLogin;

  /// No description provided for @previewRepoLoginPh.
  ///
  /// In en, this message translates to:
  /// **'Sign in as demo@acme.test; the password is in PREVIEW_PASSWORD.'**
  String get previewRepoLoginPh;

  /// No description provided for @previewRepoLoginHelp.
  ///
  /// In en, this message translates to:
  /// **'Tell agnts how to get past a login, if the app has one. Refer to secrets by variable name.'**
  String get previewRepoLoginHelp;

  /// No description provided for @previewRepoEnv.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get previewRepoEnv;

  /// No description provided for @previewRepoEnvSet.
  ///
  /// In en, this message translates to:
  /// **'Set: {names}. The values are never shown.'**
  String previewRepoEnvSet(String names);

  /// No description provided for @previewRepoEnvReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get previewRepoEnvReplace;

  /// No description provided for @previewRepoEnvClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get previewRepoEnvClear;

  /// No description provided for @previewRepoEnvCleared.
  ///
  /// In en, this message translates to:
  /// **'The environment will be cleared when you save.'**
  String get previewRepoEnvCleared;

  /// No description provided for @previewRepoEnvHelp.
  ///
  /// In en, this message translates to:
  /// **'KEY=value lines given to the app, such as a staging API URL. Stored encrypted and never shown again. Use staging-only credentials: the app and agnts can read them. Add any host the app calls to Settings → Previews → Allowed hosts.'**
  String get previewRepoEnvHelp;

  /// No description provided for @previewSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Previews'**
  String get previewSettingsTitle;

  /// No description provided for @previewSettingsSub.
  ///
  /// In en, this message translates to:
  /// **'Screenshots of UI changes, for repositories with a preview command.'**
  String get previewSettingsSub;

  /// No description provided for @previewAutoPreview.
  ///
  /// In en, this message translates to:
  /// **'Take screenshots of every UI change'**
  String get previewAutoPreview;

  /// No description provided for @previewAutoPreviewHelp.
  ///
  /// In en, this message translates to:
  /// **'While a change waits for you, agnts starts the app, opens the pages it touches and shows screenshots next to the diff. It never blocks approval.'**
  String get previewAutoPreviewHelp;

  /// No description provided for @previewVisualCheck.
  ///
  /// In en, this message translates to:
  /// **'Let coding runs look at the app'**
  String get previewVisualCheck;

  /// No description provided for @previewVisualCheckHelp.
  ///
  /// In en, this message translates to:
  /// **'Claude may start the app and look at the pages it changed before it finishes, and fix what looks broken. Costs a few more turns.'**
  String get previewVisualCheckHelp;

  /// No description provided for @previewModel_.
  ///
  /// In en, this message translates to:
  /// **'Preview model'**
  String get previewModel_;

  /// No description provided for @previewModelHelp.
  ///
  /// In en, this message translates to:
  /// **'Picks the pages and judges the screenshots.'**
  String get previewModelHelp;

  /// No description provided for @previewEgress.
  ///
  /// In en, this message translates to:
  /// **'Allowed hosts'**
  String get previewEgress;

  /// No description provided for @previewEgressHelp.
  ///
  /// In en, this message translates to:
  /// **'Hosts run containers may reach besides the built-in list (Claude, git hosts, package registries), such as a staging API your app calls in a preview. .example.com allows its subdomains.'**
  String get previewEgressHelp;

  /// No description provided for @previewNotify.
  ///
  /// In en, this message translates to:
  /// **'When preview screenshots are ready'**
  String get previewNotify;

  /// No description provided for @previewNotifyPhotos.
  ///
  /// In en, this message translates to:
  /// **'Send phone screenshots to Telegram'**
  String get previewNotifyPhotos;

  /// No description provided for @previewNotifyPhotosHelp.
  ///
  /// In en, this message translates to:
  /// **'Up to four screenshots go with the Telegram message.'**
  String get previewNotifyPhotosHelp;

  /// No description provided for @relationsTab.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get relationsTab;

  /// No description provided for @relationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Order and conflicts'**
  String get relationsTitle;

  /// No description provided for @relationsSub.
  ///
  /// In en, this message translates to:
  /// **'agnts codes several tickets at once and merges them one by one. A ticket waits for the tickets it depends on to be merged, and two tickets that change the same code never code side by side.'**
  String get relationsSub;

  /// No description provided for @relationsWaitingTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for other tickets'**
  String get relationsWaitingTitle;

  /// No description provided for @relationsWaitingSub.
  ///
  /// In en, this message translates to:
  /// **'Coding starts by itself once these are merged or rejected.'**
  String get relationsWaitingSub;

  /// No description provided for @relationsWaitingBadge.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get relationsWaitingBadge;

  /// No description provided for @relationsWaitsFor.
  ///
  /// In en, this message translates to:
  /// **'Waits for'**
  String get relationsWaitsFor;

  /// No description provided for @relationsWaitedBy.
  ///
  /// In en, this message translates to:
  /// **'Holds back'**
  String get relationsWaitedBy;

  /// No description provided for @relationsConflicts.
  ///
  /// In en, this message translates to:
  /// **'Not alongside'**
  String get relationsConflicts;

  /// No description provided for @relationsProposedTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggested by agnts'**
  String get relationsProposedTitle;

  /// No description provided for @relationsProposedSub.
  ///
  /// In en, this message translates to:
  /// **'agnts is not sure about these. Accepted ones hold the queue; dismissed ones are never suggested again.'**
  String get relationsProposedSub;

  /// No description provided for @relationsActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'In effect'**
  String get relationsActiveTitle;

  /// No description provided for @relationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No relations. This ticket runs as soon as a slot is free.'**
  String get relationsEmpty;

  /// No description provided for @relationsAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get relationsAccept;

  /// No description provided for @relationsDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get relationsDismiss;

  /// No description provided for @relationsRemove.
  ///
  /// In en, this message translates to:
  /// **'Run anyway'**
  String get relationsRemove;

  /// No description provided for @relationsRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'{key} and {other} will no longer wait for each other. Continue?'**
  String relationsRemoveConfirm(String key, String other);

  /// No description provided for @relationsConfidence.
  ///
  /// In en, this message translates to:
  /// **'{pct}% sure'**
  String relationsConfidence(String pct);

  /// No description provided for @relationsLanded.
  ///
  /// In en, this message translates to:
  /// **'merged'**
  String get relationsLanded;

  /// No description provided for @relationsSource_jira.
  ///
  /// In en, this message translates to:
  /// **'Jira link'**
  String get relationsSource_jira;

  /// No description provided for @relationsSource_user.
  ///
  /// In en, this message translates to:
  /// **'Added by you'**
  String get relationsSource_user;

  /// No description provided for @relationsSource_agnts.
  ///
  /// In en, this message translates to:
  /// **'agnts'**
  String get relationsSource_agnts;

  /// No description provided for @relationsSource_rule.
  ///
  /// In en, this message translates to:
  /// **'Predicted overlap'**
  String get relationsSource_rule;

  /// No description provided for @relationsSource_git.
  ///
  /// In en, this message translates to:
  /// **'Found in the diffs'**
  String get relationsSource_git;

  /// No description provided for @relationsBasis_files.
  ///
  /// In en, this message translates to:
  /// **'Both change {files}'**
  String relationsBasis_files(String files);

  /// No description provided for @relationsBasis_migrations.
  ///
  /// In en, this message translates to:
  /// **'Both add a database migration'**
  String get relationsBasis_migrations;

  /// No description provided for @relationsBasis_lockfile.
  ///
  /// In en, this message translates to:
  /// **'Both change dependency lockfiles'**
  String get relationsBasis_lockfile;

  /// No description provided for @relationsBasis_codegen.
  ///
  /// In en, this message translates to:
  /// **'Both change the API spec or generated code'**
  String get relationsBasis_codegen;

  /// No description provided for @relationsBasis_i18n.
  ///
  /// In en, this message translates to:
  /// **'Both change translation files'**
  String get relationsBasis_i18n;

  /// No description provided for @relationsBasis_diff.
  ///
  /// In en, this message translates to:
  /// **'The finished changes touch the same lines in {files}'**
  String relationsBasis_diff(String files);

  /// No description provided for @relationsConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed by the diffs'**
  String get relationsConfirmed;

  /// No description provided for @relationsDismissedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {{count} dismissed} other {{count} dismissed}}'**
  String relationsDismissedCount(num count);

  /// No description provided for @relationsAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a relation'**
  String get relationsAddTitle;

  /// No description provided for @relationsAddType.
  ///
  /// In en, this message translates to:
  /// **'Relation'**
  String get relationsAddType;

  /// No description provided for @relationsAddOther.
  ///
  /// In en, this message translates to:
  /// **'Ticket key'**
  String get relationsAddOther;

  /// No description provided for @relationsAddOtherPh.
  ///
  /// In en, this message translates to:
  /// **'PAY-12'**
  String get relationsAddOtherPh;

  /// No description provided for @relationsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get relationsAdd;

  /// No description provided for @relationsAddHint.
  ///
  /// In en, this message translates to:
  /// **'Waits for: this ticket starts coding once the other is merged. Not alongside: whichever starts second waits until the first is merged.'**
  String get relationsAddHint;

  /// No description provided for @relationsAdded.
  ///
  /// In en, this message translates to:
  /// **'Relation added'**
  String get relationsAdded;

  /// No description provided for @relationsFootprintTitle.
  ///
  /// In en, this message translates to:
  /// **'Predicted footprint'**
  String get relationsFootprintTitle;

  /// No description provided for @relationsFootprintSub.
  ///
  /// In en, this message translates to:
  /// **'What the analysis expects this ticket to change. agnts compares footprints to keep colliding tickets apart.'**
  String get relationsFootprintSub;

  /// No description provided for @relationsFootprintFiles.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get relationsFootprintFiles;

  /// No description provided for @relationsFootprintProvides.
  ///
  /// In en, this message translates to:
  /// **'Adds'**
  String get relationsFootprintProvides;

  /// No description provided for @relationsFootprintConsumes.
  ///
  /// In en, this message translates to:
  /// **'Needs'**
  String get relationsFootprintConsumes;

  /// No description provided for @relationsFootprintMigrations.
  ///
  /// In en, this message translates to:
  /// **'Adds a database migration'**
  String get relationsFootprintMigrations;

  /// No description provided for @relationsMarkMerged.
  ///
  /// In en, this message translates to:
  /// **'Mark merged'**
  String get relationsMarkMerged;

  /// No description provided for @relationsMarkMergedHint.
  ///
  /// In en, this message translates to:
  /// **'No merge webhook? Mark the pull request merged so tickets waiting for it can start.'**
  String get relationsMarkMergedHint;

  /// No description provided for @repoBack.
  ///
  /// In en, this message translates to:
  /// **'Back to repositories'**
  String get repoBack;

  /// No description provided for @repoNotFound.
  ///
  /// In en, this message translates to:
  /// **'No such repository.'**
  String get repoNotFound;

  /// No description provided for @repoEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit settings'**
  String get repoEdit;

  /// No description provided for @repoBranches.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get repoBranches;

  /// No description provided for @repoCommits.
  ///
  /// In en, this message translates to:
  /// **'Commits'**
  String get repoCommits;

  /// No description provided for @repoPipelines.
  ///
  /// In en, this message translates to:
  /// **'Pipelines'**
  String get repoPipelines;

  /// No description provided for @repoMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get repoMembers;

  /// No description provided for @repoMembersSub_github.
  ///
  /// In en, this message translates to:
  /// **'Collaborators on GitHub. Pull requests can be assigned to them when you approve a review.'**
  String get repoMembersSub_github;

  /// No description provided for @repoMembersSub_gitlab.
  ///
  /// In en, this message translates to:
  /// **'Project members on GitLab, including those from groups. Merge requests can be assigned to them when you approve a review.'**
  String get repoMembersSub_gitlab;

  /// No description provided for @repoMembersSearch.
  ///
  /// In en, this message translates to:
  /// **'Search members'**
  String get repoMembersSearch;

  /// No description provided for @repoMembersNone.
  ///
  /// In en, this message translates to:
  /// **'No members found. The token may not be allowed to list them.'**
  String get repoMembersNone;

  /// No description provided for @repoBranchesSub.
  ///
  /// In en, this message translates to:
  /// **'agnts works on its own branch for every ticket and never commits to {branch}.'**
  String repoBranchesSub(String branch);

  /// No description provided for @repoArchivedBanner.
  ///
  /// In en, this message translates to:
  /// **'Archived {time}. agnts takes no new tickets or tasks for this repository until you restore it.'**
  String repoArchivedBanner(String time);

  /// No description provided for @repoSrcLabel.
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get repoSrcLabel;

  /// No description provided for @repoSrcOrigin.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get repoSrcOrigin;

  /// No description provided for @repoSrcLocal.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get repoSrcLocal;

  /// No description provided for @repoSrcLocalN.
  ///
  /// In en, this message translates to:
  /// **'Local ({n})'**
  String repoSrcLocalN(String n);

  /// No description provided for @repoLocalSub.
  ///
  /// In en, this message translates to:
  /// **'Branches in agnts\'s own clones on your server. agnts commits here first and pushes only after you approve; it never commits to {branch}.'**
  String repoLocalSub(String branch);

  /// No description provided for @repoColPush.
  ///
  /// In en, this message translates to:
  /// **'On origin'**
  String get repoColPush;

  /// No description provided for @repoPush_local.
  ///
  /// In en, this message translates to:
  /// **'Not pushed'**
  String get repoPush_local;

  /// No description provided for @repoPush_pushed.
  ///
  /// In en, this message translates to:
  /// **'Pushed'**
  String get repoPush_pushed;

  /// No description provided for @repoPush_unpushed.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} commit not pushed} other {{n} commits not pushed}}'**
  String repoPush_unpushed(num n);

  /// No description provided for @repoPush_differs.
  ///
  /// In en, this message translates to:
  /// **'Origin changed'**
  String get repoPush_differs;

  /// No description provided for @repoPush_local_help.
  ///
  /// In en, this message translates to:
  /// **'Only on the server. agnts pushes it when you approve the review.'**
  String get repoPush_local_help;

  /// No description provided for @repoPush_pushed_help.
  ///
  /// In en, this message translates to:
  /// **'Origin has the same commit.'**
  String get repoPush_pushed_help;

  /// No description provided for @repoPush_unpushed_help.
  ///
  /// In en, this message translates to:
  /// **'Origin has the branch, but not the newest commits.'**
  String get repoPush_unpushed_help;

  /// No description provided for @repoPush_differs_help.
  ///
  /// In en, this message translates to:
  /// **'Someone pushed commits to this branch that agnts\'s copy does not have.'**
  String get repoPush_differs_help;

  /// No description provided for @repoLocalNone.
  ///
  /// In en, this message translates to:
  /// **'No local branches yet. agnts creates one when it starts work on a ticket.'**
  String get repoLocalNone;

  /// No description provided for @repoCommitsSub.
  ///
  /// In en, this message translates to:
  /// **'Recent commits on the default branch, newest first.'**
  String get repoCommitsSub;

  /// No description provided for @repoLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get repoLoadMore;

  /// No description provided for @repoMoreError.
  ///
  /// In en, this message translates to:
  /// **'Could not load more.'**
  String get repoMoreError;

  /// No description provided for @repoCommitsEnd.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} commit} other {All {n} commits}} shown'**
  String repoCommitsEnd(num n);

  /// No description provided for @repoPipelinesSub.
  ///
  /// In en, this message translates to:
  /// **'Build, test and deploy runs on the git host.'**
  String get repoPipelinesSub;

  /// No description provided for @repoPipelinesEnd.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} run} other {All {n} runs}} shown'**
  String repoPipelinesEnd(num n);

  /// No description provided for @repoFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get repoFilterAll;

  /// No description provided for @repoFilterOthers.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get repoFilterOthers;

  /// No description provided for @repoColBranch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get repoColBranch;

  /// No description provided for @repoColCommit.
  ///
  /// In en, this message translates to:
  /// **'Latest commit'**
  String get repoColCommit;

  /// No description provided for @repoColAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get repoColAuthor;

  /// No description provided for @repoColAheadBehind.
  ///
  /// In en, this message translates to:
  /// **'Ahead / behind'**
  String get repoColAheadBehind;

  /// No description provided for @repoColChecks.
  ///
  /// In en, this message translates to:
  /// **'Checks'**
  String get repoColChecks;

  /// No description provided for @repoColUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get repoColUpdated;

  /// No description provided for @repoDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get repoDefault;

  /// No description provided for @repoNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get repoNone;

  /// No description provided for @repoCi_ok.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get repoCi_ok;

  /// No description provided for @repoCi_fail.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get repoCi_fail;

  /// No description provided for @repoCi_run.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get repoCi_run;

  /// No description provided for @repoCi_pending.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get repoCi_pending;

  /// No description provided for @repoCi_manual.
  ///
  /// In en, this message translates to:
  /// **'Waiting for you'**
  String get repoCi_manual;

  /// No description provided for @repoCi_skip.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get repoCi_skip;

  /// No description provided for @repoCi_canceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get repoCi_canceled;

  /// No description provided for @repoCi_none.
  ///
  /// In en, this message translates to:
  /// **'No pipeline'**
  String get repoCi_none;

  /// No description provided for @repoKpiBranches.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get repoKpiBranches;

  /// No description provided for @repoKpiBranchesNote.
  ///
  /// In en, this message translates to:
  /// **'{n} by agnts'**
  String repoKpiBranchesNote(String n);

  /// No description provided for @repoKpiCommits.
  ///
  /// In en, this message translates to:
  /// **'Commits this week'**
  String get repoKpiCommits;

  /// No description provided for @repoKpiCommitsNote.
  ///
  /// In en, this message translates to:
  /// **'{n} written by agnts'**
  String repoKpiCommitsNote(String n);

  /// No description provided for @repoKpiPipelines.
  ///
  /// In en, this message translates to:
  /// **'Pipeline success'**
  String get repoKpiPipelines;

  /// No description provided for @repoKpiPipelinesNote.
  ///
  /// In en, this message translates to:
  /// **'Last {n} finished runs'**
  String repoKpiPipelinesNote(String n);

  /// No description provided for @repoKpiProd.
  ///
  /// In en, this message translates to:
  /// **'Production'**
  String get repoKpiProd;

  /// No description provided for @repoDeployedAgo.
  ///
  /// In en, this message translates to:
  /// **'Deployed {time}'**
  String repoDeployedAgo(String time);

  /// No description provided for @repoNotDeployed.
  ///
  /// In en, this message translates to:
  /// **'Not deployed yet'**
  String get repoNotDeployed;

  /// No description provided for @repoDeployed.
  ///
  /// In en, this message translates to:
  /// **'Deployed'**
  String get repoDeployed;

  /// No description provided for @repoEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get repoEmpty;

  /// No description provided for @repoCommit.
  ///
  /// In en, this message translates to:
  /// **'Commit'**
  String get repoCommit;

  /// No description provided for @repoOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get repoOpen;

  /// No description provided for @repoNoEnvironments.
  ///
  /// In en, this message translates to:
  /// **'No deployment environments on the git host.'**
  String get repoNoEnvironments;

  /// No description provided for @repoDeployHelp.
  ///
  /// In en, this message translates to:
  /// **'agnts waits for checks before a ticket reaches your review. Deploying is always your decision, and it is never available from Claude chat.'**
  String get repoDeployHelp;

  /// No description provided for @repoDeployBranch.
  ///
  /// In en, this message translates to:
  /// **'Deploy {branch}'**
  String repoDeployBranch(String branch);

  /// No description provided for @repoDeploy.
  ///
  /// In en, this message translates to:
  /// **'Deploy'**
  String get repoDeploy;

  /// No description provided for @repoDeployConfirm.
  ///
  /// In en, this message translates to:
  /// **'Start {stage} for {sha}?'**
  String repoDeployConfirm(String stage, String sha);

  /// No description provided for @repoDeployWorkflowConfirm.
  ///
  /// In en, this message translates to:
  /// **'Run {workflow} on {branch}?'**
  String repoDeployWorkflowConfirm(String workflow, String branch);

  /// No description provided for @repoDeployStarted.
  ///
  /// In en, this message translates to:
  /// **'Deploy started'**
  String get repoDeployStarted;

  /// No description provided for @repoStage.
  ///
  /// In en, this message translates to:
  /// **'Stage'**
  String get repoStage;

  /// No description provided for @repoStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get repoStatus;

  /// No description provided for @repoDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get repoDuration;

  /// No description provided for @repoOpenRun.
  ///
  /// In en, this message translates to:
  /// **'Open on the git host'**
  String get repoOpenRun;

  /// No description provided for @reposTitle.
  ///
  /// In en, this message translates to:
  /// **'Repositories'**
  String get reposTitle;

  /// No description provided for @reposLede.
  ///
  /// In en, this message translates to:
  /// **'Code agnts can work in. Each run clones the repository into a fresh container on your server, then runs these checks before anything reaches your review.'**
  String get reposLede;

  /// No description provided for @reposAdd.
  ///
  /// In en, this message translates to:
  /// **'Add repository'**
  String get reposAdd;

  /// No description provided for @reposViewLabel.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get reposViewLabel;

  /// No description provided for @reposViewActive.
  ///
  /// In en, this message translates to:
  /// **'Active ({n})'**
  String reposViewActive(String n);

  /// No description provided for @reposViewArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived ({n})'**
  String reposViewArchived(String n);

  /// No description provided for @reposArchivedSub.
  ///
  /// In en, this message translates to:
  /// **'Archived repositories keep their history but take no new tickets or tasks. Restore one to work on it again.'**
  String get reposArchivedSub;

  /// No description provided for @reposArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get reposArchive;

  /// No description provided for @reposRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get reposRestore;

  /// No description provided for @reposArchived.
  ///
  /// In en, this message translates to:
  /// **'{name} archived'**
  String reposArchived(String name);

  /// No description provided for @reposRestored.
  ///
  /// In en, this message translates to:
  /// **'{name} restored'**
  String reposRestored(String name);

  /// No description provided for @reposArchiveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Archive {name}? It moves to the archive and keeps its tickets and history, but agnts stops picking up new Jira tickets and tasks for it. Work already started still finishes. You can restore it any time.'**
  String reposArchiveConfirm(String name);

  /// No description provided for @reposNoArchived.
  ///
  /// In en, this message translates to:
  /// **'No archived repositories.'**
  String get reposNoArchived;

  /// No description provided for @reposImport.
  ///
  /// In en, this message translates to:
  /// **'Import from GitHub/GitLab'**
  String get reposImport;

  /// No description provided for @reposImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import a repository'**
  String get reposImportTitle;

  /// No description provided for @reposImportSub.
  ///
  /// In en, this message translates to:
  /// **'Repositories your GitHub or GitLab token can reach. Pick one, then set its checks.'**
  String get reposImportSub;

  /// No description provided for @reposImportFrom.
  ///
  /// In en, this message translates to:
  /// **'Import from'**
  String get reposImportFrom;

  /// No description provided for @reposImportSearch.
  ///
  /// In en, this message translates to:
  /// **'Search repositories'**
  String get reposImportSearch;

  /// No description provided for @reposImportLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading repositories…'**
  String get reposImportLoading;

  /// No description provided for @reposImportEmpty.
  ///
  /// In en, this message translates to:
  /// **'The token cannot reach any repositories. Check which repositories it was given access to.'**
  String get reposImportEmpty;

  /// No description provided for @reposImportNone.
  ///
  /// In en, this message translates to:
  /// **'Connect GitHub or GitLab first.'**
  String get reposImportNone;

  /// No description provided for @reposImportConnect.
  ///
  /// In en, this message translates to:
  /// **'Open Integrations'**
  String get reposImportConnect;

  /// No description provided for @reposImportPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get reposImportPrivate;

  /// No description provided for @reposImportUpdated.
  ///
  /// In en, this message translates to:
  /// **'updated {time}'**
  String reposImportUpdated(String time);

  /// No description provided for @reposImportAdded.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get reposImportAdded;

  /// No description provided for @reposImportPick.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get reposImportPick;

  /// No description provided for @reposMissingHelp.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {{count} repository has} other {{count} repositories have}} no CLAUDE.md. agnts still works, but spends more turns finding its way around. Add one with the project\'s structure, conventions and test commands.'**
  String reposMissingHelp(num count);

  /// No description provided for @reposColRepo.
  ///
  /// In en, this message translates to:
  /// **'Repository'**
  String get reposColRepo;

  /// No description provided for @reposColSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get reposColSource;

  /// No description provided for @reposColBranch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get reposColBranch;

  /// No description provided for @reposColTest.
  ///
  /// In en, this message translates to:
  /// **'Test command'**
  String get reposColTest;

  /// No description provided for @reposColClaude.
  ///
  /// In en, this message translates to:
  /// **'CLAUDE.md'**
  String get reposColClaude;

  /// No description provided for @reposColOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get reposColOpen;

  /// No description provided for @reposJira.
  ///
  /// In en, this message translates to:
  /// **'Jira {project}'**
  String reposJira(String project);

  /// No description provided for @reposSide.
  ///
  /// In en, this message translates to:
  /// **'Side project'**
  String get reposSide;

  /// No description provided for @reposFound.
  ///
  /// In en, this message translates to:
  /// **'Found'**
  String get reposFound;

  /// No description provided for @reposMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get reposMissing;

  /// No description provided for @reposUnknown.
  ///
  /// In en, this message translates to:
  /// **'Not checked'**
  String get reposUnknown;

  /// No description provided for @reposNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No repositories match your search.'**
  String get reposNoMatch;

  /// No description provided for @reposNone.
  ///
  /// In en, this message translates to:
  /// **'No repositories yet. Add the first one to let agnts work on it.'**
  String get reposNone;

  /// No description provided for @reposDrawerSub.
  ///
  /// In en, this message translates to:
  /// **'Takes side-project tasks, and Jira tickets once it has a Jira project key'**
  String get reposDrawerSub;

  /// No description provided for @reposName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get reposName;

  /// No description provided for @reposCloneUrl.
  ///
  /// In en, this message translates to:
  /// **'Clone URL'**
  String get reposCloneUrl;

  /// No description provided for @reposCloneHelp.
  ///
  /// In en, this message translates to:
  /// **'An https URL on github.com or your connected GitLab. agnts uses that host\'s token to clone and push.'**
  String get reposCloneHelp;

  /// No description provided for @reposJiraProject.
  ///
  /// In en, this message translates to:
  /// **'Jira project key'**
  String get reposJiraProject;

  /// No description provided for @reposJiraHelp.
  ///
  /// In en, this message translates to:
  /// **'Optional. Tickets from this Jira project with the agnts label run here.'**
  String get reposJiraHelp;

  /// No description provided for @reposTaskPrefix.
  ///
  /// In en, this message translates to:
  /// **'Task key prefix'**
  String get reposTaskPrefix;

  /// No description provided for @reposTaskPrefixHelp.
  ///
  /// In en, this message translates to:
  /// **'Side-project tasks are numbered like {prefix}-1, {prefix}-2. Must differ from the Jira project key.'**
  String reposTaskPrefixHelp(String prefix);

  /// No description provided for @reposBranch.
  ///
  /// In en, this message translates to:
  /// **'Default branch'**
  String get reposBranch;

  /// No description provided for @reposBranchHelp.
  ///
  /// In en, this message translates to:
  /// **'Work branches start from here.'**
  String get reposBranchHelp;

  /// No description provided for @reposBuild.
  ///
  /// In en, this message translates to:
  /// **'Build command'**
  String get reposBuild;

  /// No description provided for @reposLint.
  ///
  /// In en, this message translates to:
  /// **'Lint command'**
  String get reposLint;

  /// No description provided for @reposTest.
  ///
  /// In en, this message translates to:
  /// **'Test command'**
  String get reposTest;

  /// No description provided for @reposTestHelp.
  ///
  /// In en, this message translates to:
  /// **'Must pass before a ticket reaches your review.'**
  String get reposTestHelp;

  /// No description provided for @reposInstructions.
  ///
  /// In en, this message translates to:
  /// **'Extra instructions'**
  String get reposInstructions;

  /// No description provided for @reposInstructionsHelp.
  ///
  /// In en, this message translates to:
  /// **'Added to every prompt for this repository, on top of its CLAUDE.md.'**
  String get reposInstructionsHelp;

  /// No description provided for @reposClaudeFound.
  ///
  /// In en, this message translates to:
  /// **'Found in the repository root'**
  String get reposClaudeFound;

  /// No description provided for @reposClaudeMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing. agnts still works, but a CLAUDE.md saves turns.'**
  String get reposClaudeMissing;

  /// No description provided for @reposClaudeUnknown.
  ///
  /// In en, this message translates to:
  /// **'Checked after saving'**
  String get reposClaudeUnknown;

  /// No description provided for @reposSaved.
  ///
  /// In en, this message translates to:
  /// **'Repository saved'**
  String get reposSaved;

  /// No description provided for @reposEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get reposEdit;

  /// No description provided for @reposDeployWorkflow.
  ///
  /// In en, this message translates to:
  /// **'Deploy workflow'**
  String get reposDeployWorkflow;

  /// No description provided for @reposDeployWorkflowHelp.
  ///
  /// In en, this message translates to:
  /// **'GitHub Actions workflow file with workflow_dispatch, e.g. deploy.yml. Deploy on the repository page runs it.'**
  String get reposDeployWorkflowHelp;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'agnts\'s code review'**
  String get reviewTitle;

  /// No description provided for @reviewReportTitle.
  ///
  /// In en, this message translates to:
  /// **'agnts\'s review of the report'**
  String get reviewReportTitle;

  /// No description provided for @reviewSub.
  ///
  /// In en, this message translates to:
  /// **'A second opinion while you review. It never blocks approval: you decide.'**
  String get reviewSub;

  /// No description provided for @reviewPending.
  ///
  /// In en, this message translates to:
  /// **'Queued: agnts reviews this as soon as a worker is free. You can review it yourself meanwhile.'**
  String get reviewPending;

  /// No description provided for @reviewRunning.
  ///
  /// In en, this message translates to:
  /// **'agnts is reviewing this now…'**
  String get reviewRunning;

  /// No description provided for @reviewFailed.
  ///
  /// In en, this message translates to:
  /// **'The review failed. Review it yourself, or run it again.'**
  String get reviewFailed;

  /// No description provided for @reviewNone.
  ///
  /// In en, this message translates to:
  /// **'Not reviewed by agnts.'**
  String get reviewNone;

  /// No description provided for @reviewStale.
  ///
  /// In en, this message translates to:
  /// **'This review is of revision {n}; the work changed since.'**
  String reviewStale(String n);

  /// No description provided for @reviewRun.
  ///
  /// In en, this message translates to:
  /// **'Review with agnts'**
  String get reviewRun;

  /// No description provided for @reviewRunAgain.
  ///
  /// In en, this message translates to:
  /// **'Review again'**
  String get reviewRunAgain;

  /// No description provided for @reviewVerdict_looks_good.
  ///
  /// In en, this message translates to:
  /// **'Looks good'**
  String get reviewVerdict_looks_good;

  /// No description provided for @reviewVerdict_has_concerns.
  ///
  /// In en, this message translates to:
  /// **'Has concerns'**
  String get reviewVerdict_has_concerns;

  /// No description provided for @reviewVerdict_needs_changes.
  ///
  /// In en, this message translates to:
  /// **'Needs changes'**
  String get reviewVerdict_needs_changes;

  /// No description provided for @reviewSev_blocker.
  ///
  /// In en, this message translates to:
  /// **'Blocker'**
  String get reviewSev_blocker;

  /// No description provided for @reviewSev_major.
  ///
  /// In en, this message translates to:
  /// **'Major'**
  String get reviewSev_major;

  /// No description provided for @reviewSev_minor.
  ///
  /// In en, this message translates to:
  /// **'Minor'**
  String get reviewSev_minor;

  /// No description provided for @reviewSev_nit.
  ///
  /// In en, this message translates to:
  /// **'Nit'**
  String get reviewSev_nit;

  /// No description provided for @reviewCat_correctness.
  ///
  /// In en, this message translates to:
  /// **'Correctness'**
  String get reviewCat_correctness;

  /// No description provided for @reviewCat_security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get reviewCat_security;

  /// No description provided for @reviewCat_performance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get reviewCat_performance;

  /// No description provided for @reviewCat_tests.
  ///
  /// In en, this message translates to:
  /// **'Tests'**
  String get reviewCat_tests;

  /// No description provided for @reviewCat_rules.
  ///
  /// In en, this message translates to:
  /// **'Team rules'**
  String get reviewCat_rules;

  /// No description provided for @reviewCat_maintainability.
  ///
  /// In en, this message translates to:
  /// **'Maintainability'**
  String get reviewCat_maintainability;

  /// No description provided for @reviewCat_accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get reviewCat_accuracy;

  /// No description provided for @reviewCat_completeness.
  ///
  /// In en, this message translates to:
  /// **'Completeness'**
  String get reviewCat_completeness;

  /// No description provided for @reviewCat_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reviewCat_other;

  /// No description provided for @reviewFindings.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {No findings} one {{count} finding} other {{count} findings}}'**
  String reviewFindings(num count);

  /// No description provided for @reviewNoFindings.
  ///
  /// In en, this message translates to:
  /// **'agnts found no problems.'**
  String get reviewNoFindings;

  /// No description provided for @reviewStrengths.
  ///
  /// In en, this message translates to:
  /// **'Done well'**
  String get reviewStrengths;

  /// No description provided for @reviewSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Suggestion'**
  String get reviewSuggestion;

  /// No description provided for @reviewAddToFeedback.
  ///
  /// In en, this message translates to:
  /// **'Add to feedback'**
  String get reviewAddToFeedback;

  /// No description provided for @reviewAdded.
  ///
  /// In en, this message translates to:
  /// **'In feedback'**
  String get reviewAdded;

  /// No description provided for @reviewAddAll.
  ///
  /// In en, this message translates to:
  /// **'Add all to feedback'**
  String get reviewAddAll;

  /// No description provided for @reviewShowInDiff.
  ///
  /// In en, this message translates to:
  /// **'Show in diff'**
  String get reviewShowInDiff;

  /// No description provided for @reviewModel.
  ///
  /// In en, this message translates to:
  /// **'Reviewed by {model}: {reason}'**
  String reviewModel(String model, String reason);

  /// No description provided for @rulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get rulesTitle;

  /// No description provided for @rulesLede.
  ///
  /// In en, this message translates to:
  /// **'Instructions agnts follows on every ticket: global rules for all repositories and rules for one repository. Claude reviews each rule and asks about anything unclear before it applies.'**
  String get rulesLede;

  /// No description provided for @rulesAdd.
  ///
  /// In en, this message translates to:
  /// **'Add rule'**
  String get rulesAdd;

  /// No description provided for @rulesAddSubmit.
  ///
  /// In en, this message translates to:
  /// **'Add and review'**
  String get rulesAddSubmit;

  /// No description provided for @rulesDrawerSub.
  ///
  /// In en, this message translates to:
  /// **'Write it the way you would brief a new teammate. Claude checks it before any ticket follows it.'**
  String get rulesDrawerSub;

  /// No description provided for @rulesRuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get rulesRuleTitle;

  /// No description provided for @rulesTitlePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Tests for new endpoints'**
  String get rulesTitlePlaceholder;

  /// No description provided for @rulesScope.
  ///
  /// In en, this message translates to:
  /// **'Applies to'**
  String get rulesScope;

  /// No description provided for @rulesScopeHelp.
  ///
  /// In en, this message translates to:
  /// **'Global rules apply in every repository. A repository rule wins where the two disagree.'**
  String get rulesScopeHelp;

  /// No description provided for @rulesGlobal.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get rulesGlobal;

  /// No description provided for @rulesGlobalHint.
  ///
  /// In en, this message translates to:
  /// **'Every repository'**
  String get rulesGlobalHint;

  /// No description provided for @rulesBody.
  ///
  /// In en, this message translates to:
  /// **'Rule'**
  String get rulesBody;

  /// No description provided for @rulesBodyPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Every new HTTP endpoint gets an integration test next to its handler.'**
  String get rulesBodyPlaceholder;

  /// No description provided for @rulesBodyHelp.
  ///
  /// In en, this message translates to:
  /// **'Say what to do, where, and what to do when it cannot be followed.'**
  String get rulesBodyHelp;

  /// No description provided for @rulesEnabled.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get rulesEnabled;

  /// No description provided for @rulesEnabledFor.
  ///
  /// In en, this message translates to:
  /// **'Rule {title} on'**
  String rulesEnabledFor(String title);

  /// No description provided for @rulesRereviewHelp.
  ///
  /// In en, this message translates to:
  /// **'You changed what the rule says, so Claude reviews it again. Tickets stop getting it until the review is done.'**
  String get rulesRereviewHelp;

  /// No description provided for @rulesSaved.
  ///
  /// In en, this message translates to:
  /// **'Rule saved'**
  String get rulesSaved;

  /// No description provided for @rulesSavedReview.
  ///
  /// In en, this message translates to:
  /// **'Rule saved; Claude is reviewing it'**
  String get rulesSavedReview;

  /// No description provided for @rulesScopeLabel.
  ///
  /// In en, this message translates to:
  /// **'Show rules for'**
  String get rulesScopeLabel;

  /// No description provided for @rulesScopeAll.
  ///
  /// In en, this message translates to:
  /// **'All rules ({n})'**
  String rulesScopeAll(String n);

  /// No description provided for @rulesScopeGlobal.
  ///
  /// In en, this message translates to:
  /// **'Global ({n})'**
  String rulesScopeGlobal(String n);

  /// No description provided for @rulesNone.
  ///
  /// In en, this message translates to:
  /// **'No rules yet. Add one to tell agnts how your team works: testing, naming, logging, what never to touch.'**
  String get rulesNone;

  /// No description provided for @rulesNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No rules match.'**
  String get rulesNoMatch;

  /// No description provided for @rulesWaitingHelp.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} rule is waiting for your answers. It does not apply to tickets until it is answered.} other {{n} rules are waiting for your answers. They do not apply to tickets until they are answered.}}'**
  String rulesWaitingHelp(num n);

  /// No description provided for @rulesStatus_pending.
  ///
  /// In en, this message translates to:
  /// **'Queued for review'**
  String get rulesStatus_pending;

  /// No description provided for @rulesStatus_analyzing.
  ///
  /// In en, this message translates to:
  /// **'Reviewing'**
  String get rulesStatus_analyzing;

  /// No description provided for @rulesStatus_questions.
  ///
  /// In en, this message translates to:
  /// **'Needs answers'**
  String get rulesStatus_questions;

  /// No description provided for @rulesStatus_ready.
  ///
  /// In en, this message translates to:
  /// **'Applies'**
  String get rulesStatus_ready;

  /// No description provided for @rulesStatus_failed.
  ///
  /// In en, this message translates to:
  /// **'Review failed'**
  String get rulesStatus_failed;

  /// No description provided for @rulesOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get rulesOff;

  /// No description provided for @rulesEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get rulesEdit;

  /// No description provided for @rulesDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get rulesDelete;

  /// No description provided for @rulesDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Delete the rule “{title}”? Tickets that start after this no longer follow it.'**
  String rulesDeleteBody(String title);

  /// No description provided for @rulesPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for a free worker. Claude reviews rules before the next ticket starts.'**
  String get rulesPending;

  /// No description provided for @rulesAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Claude is reading the rule and checking it for anything unclear or conflicting.'**
  String get rulesAnalyzing;

  /// No description provided for @rulesQuestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} question before this rule applies} other {{n} questions before this rule applies}}'**
  String rulesQuestionsTitle(num n);

  /// No description provided for @rulesQuestionsSub.
  ///
  /// In en, this message translates to:
  /// **'Claude found something unclear. Your answers become part of the rule.'**
  String get rulesQuestionsSub;

  /// No description provided for @rulesYourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get rulesYourAnswer;

  /// No description provided for @rulesAddDetails.
  ///
  /// In en, this message translates to:
  /// **'Add details (optional)'**
  String get rulesAddDetails;

  /// No description provided for @rulesAnswerFor.
  ///
  /// In en, this message translates to:
  /// **'Answer to question {n}'**
  String rulesAnswerFor(String n);

  /// No description provided for @rulesDetailsFor.
  ///
  /// In en, this message translates to:
  /// **'Details for question {n}'**
  String rulesDetailsFor(String n);

  /// No description provided for @rulesSendAnswers.
  ///
  /// In en, this message translates to:
  /// **'Send answers'**
  String get rulesSendAnswers;

  /// No description provided for @rulesQuestionsLeft.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} question left to answer} other {{n} questions left to answer}}'**
  String rulesQuestionsLeft(num n);

  /// No description provided for @rulesAllAnswered.
  ///
  /// In en, this message translates to:
  /// **'All questions answered'**
  String get rulesAllAnswered;

  /// No description provided for @rulesAccept.
  ///
  /// In en, this message translates to:
  /// **'Use as written'**
  String get rulesAccept;

  /// No description provided for @rulesAcceptTitle.
  ///
  /// In en, this message translates to:
  /// **'Use the rule as written?'**
  String get rulesAcceptTitle;

  /// No description provided for @rulesAcceptBody.
  ///
  /// In en, this message translates to:
  /// **'Tickets get the rule as you wrote it, with the answers given so far. Open questions are dropped.'**
  String get rulesAcceptBody;

  /// No description provided for @rulesFailed.
  ///
  /// In en, this message translates to:
  /// **'Claude could not review this rule: {error}'**
  String rulesFailed(String error);

  /// No description provided for @rulesReviewAgain.
  ///
  /// In en, this message translates to:
  /// **'Review again'**
  String get rulesReviewAgain;

  /// No description provided for @rulesInterpretation.
  ///
  /// In en, this message translates to:
  /// **'How agnts reads it'**
  String get rulesInterpretation;

  /// No description provided for @rulesClarified.
  ///
  /// In en, this message translates to:
  /// **'What tickets get'**
  String get rulesClarified;

  /// No description provided for @rulesAsWritten.
  ///
  /// In en, this message translates to:
  /// **'Used as written.'**
  String get rulesAsWritten;

  /// No description provided for @rulesAnswersTitle.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} answered question} other {{n} answered questions}}'**
  String rulesAnswersTitle(num n);

  /// No description provided for @rulesReviewedAgo.
  ///
  /// In en, this message translates to:
  /// **'Reviewed {ago}'**
  String rulesReviewedAgo(String ago);

  /// No description provided for @rulesAddedAgo.
  ///
  /// In en, this message translates to:
  /// **'Added {ago}'**
  String rulesAddedAgo(String ago);

  /// No description provided for @rulesAnswered.
  ///
  /// In en, this message translates to:
  /// **'Answers sent; Claude is reviewing the rule again'**
  String get rulesAnswered;

  /// No description provided for @rulesAccepted.
  ///
  /// In en, this message translates to:
  /// **'The rule applies as written'**
  String get rulesAccepted;

  /// No description provided for @rulesQueued.
  ///
  /// In en, this message translates to:
  /// **'Queued for review'**
  String get rulesQueued;

  /// No description provided for @rulesDeleted.
  ///
  /// In en, this message translates to:
  /// **'Rule deleted'**
  String get rulesDeleted;

  /// No description provided for @rulesTurnedOn.
  ///
  /// In en, this message translates to:
  /// **'Rule turned on'**
  String get rulesTurnedOn;

  /// No description provided for @rulesTurnedOff.
  ///
  /// In en, this message translates to:
  /// **'Rule turned off'**
  String get rulesTurnedOff;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLede.
  ///
  /// In en, this message translates to:
  /// **'How agnts connects to your tools and how it behaves during runs.'**
  String get settingsLede;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsAppearanceSub.
  ///
  /// In en, this message translates to:
  /// **'Saved in this browser, applied right away'**
  String get settingsAppearanceSub;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeHelp.
  ///
  /// In en, this message translates to:
  /// **'System follows your device\'s day or night setting'**
  String get settingsThemeHelp;

  /// No description provided for @settingsSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsSystem;

  /// No description provided for @settingsDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get settingsDay;

  /// No description provided for @settingsNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get settingsNight;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsIntegrations.
  ///
  /// In en, this message translates to:
  /// **'Integrations'**
  String get settingsIntegrations;

  /// No description provided for @settingsIntegrationsSub.
  ///
  /// In en, this message translates to:
  /// **'Where tickets come from and where code is pushed'**
  String get settingsIntegrationsSub;

  /// No description provided for @settingsManageAll.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get settingsManageAll;

  /// No description provided for @settingsManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get settingsManage;

  /// No description provided for @settingsConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get settingsConnect;

  /// No description provided for @settingsConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get settingsConnected;

  /// No description provided for @settingsNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get settingsNotConnected;

  /// No description provided for @settingsClaude.
  ///
  /// In en, this message translates to:
  /// **'Claude Code'**
  String get settingsClaude;

  /// No description provided for @settingsClaudeSub.
  ///
  /// In en, this message translates to:
  /// **'The engine that does the coding'**
  String get settingsClaudeSub;

  /// No description provided for @settingsModels.
  ///
  /// In en, this message translates to:
  /// **'Models by stage'**
  String get settingsModels;

  /// No description provided for @settingsModelsHelp.
  ///
  /// In en, this message translates to:
  /// **'Pick which model runs each step. Haiku uses the least of your plan, Opus the most.'**
  String get settingsModelsHelp;

  /// No description provided for @settingsStageAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Reading the ticket and asking questions'**
  String get settingsStageAnalyze;

  /// No description provided for @settingsStageAnalyzeHelp.
  ///
  /// In en, this message translates to:
  /// **'Read-only. Runs once per ticket.'**
  String get settingsStageAnalyzeHelp;

  /// No description provided for @settingsStageCoding.
  ///
  /// In en, this message translates to:
  /// **'Coding'**
  String get settingsStageCoding;

  /// No description provided for @settingsStageCodingHelp.
  ///
  /// In en, this message translates to:
  /// **'The main run. Uses most of your plan.'**
  String get settingsStageCodingHelp;

  /// No description provided for @settingsStageRetry.
  ///
  /// In en, this message translates to:
  /// **'Retries and requested changes'**
  String get settingsStageRetry;

  /// No description provided for @settingsStageRetryHelp.
  ///
  /// In en, this message translates to:
  /// **'After failed tests, your feedback or a stopped run.'**
  String get settingsStageRetryHelp;

  /// No description provided for @settingsStageHelper.
  ///
  /// In en, this message translates to:
  /// **'Usage refresh and short writing'**
  String get settingsStageHelper;

  /// No description provided for @settingsStageHelperHelp.
  ///
  /// In en, this message translates to:
  /// **'Small tasks like the idle usage refresh.'**
  String get settingsStageHelperHelp;

  /// No description provided for @settingsStageLearn.
  ///
  /// In en, this message translates to:
  /// **'Lessons from finished work'**
  String get settingsStageLearn;

  /// No description provided for @settingsStageLearnHelp.
  ///
  /// In en, this message translates to:
  /// **'Reads each pushed change and writes lessons about what is new to the repository.'**
  String get settingsStageLearnHelp;

  /// No description provided for @settingsStageReview.
  ///
  /// In en, this message translates to:
  /// **'Code review'**
  String get settingsStageReview;

  /// No description provided for @settingsStageReviewHelp.
  ///
  /// In en, this message translates to:
  /// **'Reviews each result while you review it. Auto uses Opus for complex tickets and Sonnet for the rest.'**
  String get settingsStageReviewHelp;

  /// No description provided for @settingsModelAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get settingsModelAuto;

  /// No description provided for @settingsMaxTurns.
  ///
  /// In en, this message translates to:
  /// **'Turn limit per run'**
  String get settingsMaxTurns;

  /// No description provided for @settingsMaxTurnsHelp.
  ///
  /// In en, this message translates to:
  /// **'The run stops and reports when it reaches this'**
  String get settingsMaxTurnsHelp;

  /// No description provided for @settingsTimeout.
  ///
  /// In en, this message translates to:
  /// **'Run timeout'**
  String get settingsTimeout;

  /// No description provided for @settingsMinutes.
  ///
  /// In en, this message translates to:
  /// **'{n} min'**
  String settingsMinutes(String n);

  /// No description provided for @settingsAllow.
  ///
  /// In en, this message translates to:
  /// **'Allowed commands'**
  String get settingsAllow;

  /// No description provided for @settingsAllowHelp.
  ///
  /// In en, this message translates to:
  /// **'Claude Code can run these without asking'**
  String get settingsAllowHelp;

  /// No description provided for @settingsDeny.
  ///
  /// In en, this message translates to:
  /// **'Blocked commands'**
  String get settingsDeny;

  /// No description provided for @settingsDenyHelp.
  ///
  /// In en, this message translates to:
  /// **'Always refused, even if a ticket asks for them. Pushing is done by agnts, never by Claude Code.'**
  String get settingsDenyHelp;

  /// No description provided for @settingsCommits.
  ///
  /// In en, this message translates to:
  /// **'Commits and pull requests'**
  String get settingsCommits;

  /// No description provided for @settingsCommitsSub.
  ///
  /// In en, this message translates to:
  /// **'Who commits appear from, and how pull requests open'**
  String get settingsCommitsSub;

  /// No description provided for @settingsAuthorName.
  ///
  /// In en, this message translates to:
  /// **'Author name'**
  String get settingsAuthorName;

  /// No description provided for @settingsAuthorNameHelp.
  ///
  /// In en, this message translates to:
  /// **'Commits are made as you'**
  String get settingsAuthorNameHelp;

  /// No description provided for @settingsAuthorEmail.
  ///
  /// In en, this message translates to:
  /// **'Author email'**
  String get settingsAuthorEmail;

  /// No description provided for @settingsAuthorEmailHelp.
  ///
  /// In en, this message translates to:
  /// **'Must match your GitHub account to show as yours'**
  String get settingsAuthorEmailHelp;

  /// No description provided for @settingsCoAuthor.
  ///
  /// In en, this message translates to:
  /// **'Add a Co-authored-by: agnts line'**
  String get settingsCoAuthor;

  /// No description provided for @settingsCoAuthorHelp.
  ///
  /// In en, this message translates to:
  /// **'Teammates can see which commits agnts wrote'**
  String get settingsCoAuthorHelp;

  /// No description provided for @settingsPrTitle.
  ///
  /// In en, this message translates to:
  /// **'Pull request title'**
  String get settingsPrTitle;

  /// No description provided for @settingsPrTitleHelp.
  ///
  /// In en, this message translates to:
  /// **'\'{key}\' and \'{title}\' are replaced with the ticket\'s key and title'**
  String settingsPrTitleHelp(String key, String title);

  /// No description provided for @settingsDraft.
  ///
  /// In en, this message translates to:
  /// **'Open as draft'**
  String get settingsDraft;

  /// No description provided for @settingsRuns.
  ///
  /// In en, this message translates to:
  /// **'Runs'**
  String get settingsRuns;

  /// No description provided for @settingsRunsSub.
  ///
  /// In en, this message translates to:
  /// **'Defaults for every ticket and task'**
  String get settingsRunsSub;

  /// No description provided for @settingsAskFirst.
  ///
  /// In en, this message translates to:
  /// **'Ask questions before coding'**
  String get settingsAskFirst;

  /// No description provided for @settingsAskFirstHelp.
  ///
  /// In en, this message translates to:
  /// **'Default for new Jira tickets. Tasks choose this when you create them.'**
  String get settingsAskFirstHelp;

  /// No description provided for @settingsAutoResume.
  ///
  /// In en, this message translates to:
  /// **'Resume paused runs after the limit resets'**
  String get settingsAutoResume;

  /// No description provided for @settingsAutoLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn from every pushed change'**
  String get settingsAutoLearn;

  /// No description provided for @settingsAutoLearnHelp.
  ///
  /// In en, this message translates to:
  /// **'After a push, agnts looks for techniques the repository never used before and writes lessons under Learn. Uses plan usage only when no ticket is waiting.'**
  String get settingsAutoLearnHelp;

  /// No description provided for @settingsAutoReview.
  ///
  /// In en, this message translates to:
  /// **'Review every result'**
  String get settingsAutoReview;

  /// No description provided for @settingsAutoReviewHelp.
  ///
  /// In en, this message translates to:
  /// **'While a change or report waits for you, agnts reviews it and shows its findings next to it. It never blocks approval.'**
  String get settingsAutoReviewHelp;

  /// No description provided for @settingsPauseAbove.
  ///
  /// In en, this message translates to:
  /// **'Don\'t start new runs above'**
  String get settingsPauseAbove;

  /// No description provided for @settingsPauseAboveHelp.
  ///
  /// In en, this message translates to:
  /// **'Session usage. Runs already going keep going.'**
  String get settingsPauseAboveHelp;

  /// No description provided for @settingsParallel.
  ///
  /// In en, this message translates to:
  /// **'Runs at the same time'**
  String get settingsParallel;

  /// No description provided for @settingsParallelHelp.
  ///
  /// In en, this message translates to:
  /// **'More runs finish sooner but use your plan limit faster'**
  String get settingsParallelHelp;

  /// No description provided for @settingsNotify.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotify;

  /// No description provided for @settingsNotifySub.
  ///
  /// In en, this message translates to:
  /// **'Push to your phone and Telegram messages'**
  String get settingsNotifySub;

  /// No description provided for @settingsPush.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get settingsPush;

  /// No description provided for @settingsPushHelp.
  ///
  /// In en, this message translates to:
  /// **'To the agnts app on your phone'**
  String get settingsPushHelp;

  /// No description provided for @settingsTelegram.
  ///
  /// In en, this message translates to:
  /// **'Telegram messages'**
  String get settingsTelegram;

  /// No description provided for @settingsTelegramHelp.
  ///
  /// In en, this message translates to:
  /// **'Only sent once Telegram is connected on the Integrations page'**
  String get settingsTelegramHelp;

  /// No description provided for @settingsNeedsYou.
  ///
  /// In en, this message translates to:
  /// **'When something needs you'**
  String get settingsNeedsYou;

  /// No description provided for @settingsNeedsYouHelp.
  ///
  /// In en, this message translates to:
  /// **'Questions to answer or changes to review'**
  String get settingsNeedsYouHelp;

  /// No description provided for @settingsStopped.
  ///
  /// In en, this message translates to:
  /// **'When a run stops or pauses'**
  String get settingsStopped;

  /// No description provided for @settingsDone.
  ///
  /// In en, this message translates to:
  /// **'When changes are pushed'**
  String get settingsDone;

  /// No description provided for @settingsLessons.
  ///
  /// In en, this message translates to:
  /// **'When agnts finds something new to learn'**
  String get settingsLessons;

  /// No description provided for @settingsReviewDone.
  ///
  /// In en, this message translates to:
  /// **'When agnts\'s code review finishes'**
  String get settingsReviewDone;

  /// No description provided for @settingsOnThisPage.
  ///
  /// In en, this message translates to:
  /// **'On this page'**
  String get settingsOnThisPage;

  /// No description provided for @settingsSecretsHelp.
  ///
  /// In en, this message translates to:
  /// **'Tokens for Jira, GitHub and Claude are stored encrypted on your server. This page never shows them.'**
  String get settingsSecretsHelp;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// No description provided for @spendTitle.
  ///
  /// In en, this message translates to:
  /// **'Token spend'**
  String get spendTitle;

  /// No description provided for @spendSub.
  ///
  /// In en, this message translates to:
  /// **'{tokens} tokens in and out · about {cost} at API prices'**
  String spendSub(String tokens, String cost);

  /// No description provided for @spendEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded yet. Spend appears after agnts\'s first Claude run on this ticket.'**
  String get spendEmpty;

  /// No description provided for @spendInput.
  ///
  /// In en, this message translates to:
  /// **'Input'**
  String get spendInput;

  /// No description provided for @spendOutput.
  ///
  /// In en, this message translates to:
  /// **'Output'**
  String get spendOutput;

  /// No description provided for @spendCache.
  ///
  /// In en, this message translates to:
  /// **'Cache: {read} read, {write} written'**
  String spendCache(String read, String write);

  /// No description provided for @spendCalls.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} run} other {{n} runs}}'**
  String spendCalls(num n);

  /// No description provided for @spendPartial.
  ///
  /// In en, this message translates to:
  /// **'A run was cut off, so its cost is unknown'**
  String get spendPartial;

  /// No description provided for @spendCostNote.
  ///
  /// In en, this message translates to:
  /// **'Cost is Claude Code\'s estimate of the same work at API prices. On a Claude plan you are not charged it; it shows the relative weight of each stage.'**
  String get spendCostNote;

  /// No description provided for @spendTokens.
  ///
  /// In en, this message translates to:
  /// **'{n} tokens'**
  String spendTokens(String n);

  /// No description provided for @spendColTokens.
  ///
  /// In en, this message translates to:
  /// **'Tokens'**
  String get spendColTokens;

  /// No description provided for @spendStageAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get spendStageAnalyze;

  /// No description provided for @spendStageCoding.
  ///
  /// In en, this message translates to:
  /// **'Coding'**
  String get spendStageCoding;

  /// No description provided for @spendStageWriting.
  ///
  /// In en, this message translates to:
  /// **'Writing'**
  String get spendStageWriting;

  /// No description provided for @spendStageRetry.
  ///
  /// In en, this message translates to:
  /// **'Fixes and changes'**
  String get spendStageRetry;

  /// No description provided for @spendStageReview.
  ///
  /// In en, this message translates to:
  /// **'Code review'**
  String get spendStageReview;

  /// No description provided for @spendStagePreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get spendStagePreview;

  /// No description provided for @spendStageLearn.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get spendStageLearn;

  /// No description provided for @spendStageHelper.
  ///
  /// In en, this message translates to:
  /// **'Helper'**
  String get spendStageHelper;

  /// No description provided for @spendTopTitle.
  ///
  /// In en, this message translates to:
  /// **'Tickets by spend'**
  String get spendTopTitle;

  /// No description provided for @spendTopSub.
  ///
  /// In en, this message translates to:
  /// **'{tokens} tokens in and out · about {cost} at API prices'**
  String spendTopSub(String tokens, String cost);

  /// No description provided for @spendTopSubEmpty.
  ///
  /// In en, this message translates to:
  /// **'Which tickets used the most of your plan'**
  String get spendTopSubEmpty;

  /// No description provided for @spendTopEmpty.
  ///
  /// In en, this message translates to:
  /// **'No Claude runs recorded in this period.'**
  String get spendTopEmpty;

  /// No description provided for @spendTopNote.
  ///
  /// In en, this message translates to:
  /// **'Ranked by Claude Code\'s cost estimate, which weighs cache traffic properly. Share is of the period\'s estimated cost. Only spend inside the period counts.'**
  String get spendTopNote;

  /// No description provided for @spendColStage.
  ///
  /// In en, this message translates to:
  /// **'Costliest stage'**
  String get spendColStage;

  /// No description provided for @spendColCost.
  ///
  /// In en, this message translates to:
  /// **'Est. cost'**
  String get spendColCost;

  /// No description provided for @spendColShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get spendColShare;

  /// No description provided for @stateNew.
  ///
  /// In en, this message translates to:
  /// **'In queue'**
  String get stateNew;

  /// No description provided for @stateAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Reading the code'**
  String get stateAnalyzing;

  /// No description provided for @stateWaiting_for_answers.
  ///
  /// In en, this message translates to:
  /// **'Needs your answers'**
  String get stateWaiting_for_answers;

  /// No description provided for @stateCoding.
  ///
  /// In en, this message translates to:
  /// **'Coding'**
  String get stateCoding;

  /// No description provided for @stateTesting.
  ///
  /// In en, this message translates to:
  /// **'Running tests'**
  String get stateTesting;

  /// No description provided for @stateWaiting_for_review.
  ///
  /// In en, this message translates to:
  /// **'Ready for review'**
  String get stateWaiting_for_review;

  /// No description provided for @statePushing.
  ///
  /// In en, this message translates to:
  /// **'Pushing'**
  String get statePushing;

  /// No description provided for @stateDone.
  ///
  /// In en, this message translates to:
  /// **'Pushed'**
  String get stateDone;

  /// No description provided for @stateRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get stateRejected;

  /// No description provided for @stateFailed.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get stateFailed;

  /// No description provided for @stateRate_limited.
  ///
  /// In en, this message translates to:
  /// **'Paused at plan limit'**
  String get stateRate_limited;

  /// No description provided for @stateReportCoding.
  ///
  /// In en, this message translates to:
  /// **'Writing'**
  String get stateReportCoding;

  /// No description provided for @stateReportPushing.
  ///
  /// In en, this message translates to:
  /// **'Delivering'**
  String get stateReportPushing;

  /// No description provided for @stateReportDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get stateReportDone;

  /// No description provided for @tasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksTitle;

  /// No description provided for @tasksLede.
  ///
  /// In en, this message translates to:
  /// **'Work for your side projects. Tasks stay in agnts and never touch Jira. Everything else works the same: questions, coding, your review.'**
  String get tasksLede;

  /// No description provided for @tasksNew.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get tasksNew;

  /// No description provided for @tasksAllRepos.
  ///
  /// In en, this message translates to:
  /// **'All repositories {count}'**
  String tasksAllRepos(String count);

  /// No description provided for @tasksFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Filter by repository'**
  String get tasksFilterLabel;

  /// No description provided for @tasksColTask.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get tasksColTask;

  /// No description provided for @tasksColRepo.
  ///
  /// In en, this message translates to:
  /// **'Repository'**
  String get tasksColRepo;

  /// No description provided for @tasksColStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get tasksColStatus;

  /// No description provided for @tasksColUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get tasksColUpdated;

  /// No description provided for @tasksNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No tasks match your search.'**
  String get tasksNoMatch;

  /// No description provided for @tasksEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tasks in this repository yet.'**
  String get tasksEmpty;

  /// No description provided for @tasksRepos.
  ///
  /// In en, this message translates to:
  /// **'Repositories'**
  String get tasksRepos;

  /// No description provided for @tasksReposSub.
  ///
  /// In en, this message translates to:
  /// **'Your side-project repositories on this server'**
  String get tasksReposSub;

  /// No description provided for @tasksRepoLine.
  ///
  /// In en, this message translates to:
  /// **'tests: {test}, {open} open'**
  String tasksRepoLine(String test, String open);

  /// No description provided for @tasksNoTest.
  ///
  /// In en, this message translates to:
  /// **'none'**
  String get tasksNoTest;

  /// No description provided for @tasksNoRepos.
  ///
  /// In en, this message translates to:
  /// **'No side-project repositories yet.'**
  String get tasksNoRepos;

  /// No description provided for @tasksHelp.
  ///
  /// In en, this message translates to:
  /// **'For repositories only you work on, you can let agnts push straight to main after you approve. It still never pushes without your review.'**
  String get tasksHelp;

  /// No description provided for @tasksDrawerSub.
  ///
  /// In en, this message translates to:
  /// **'For your side projects. Not synced to Jira.'**
  String get tasksDrawerSub;

  /// No description provided for @tasksRepository.
  ///
  /// In en, this message translates to:
  /// **'Repository'**
  String get tasksRepository;

  /// No description provided for @tasksFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get tasksFieldTitle;

  /// No description provided for @tasksTitlePh.
  ///
  /// In en, this message translates to:
  /// **'For example: Add a rest timer between sets'**
  String get tasksTitlePh;

  /// No description provided for @tasksFieldDesc.
  ///
  /// In en, this message translates to:
  /// **'What should be done'**
  String get tasksFieldDesc;

  /// No description provided for @tasksDescPh.
  ///
  /// In en, this message translates to:
  /// **'Describe the result you want. The clearer this is, the fewer questions agnts asks.'**
  String get tasksDescPh;

  /// No description provided for @tasksPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get tasksPriority;

  /// No description provided for @tasksLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get tasksLow;

  /// No description provided for @tasksMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get tasksMedium;

  /// No description provided for @tasksHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get tasksHigh;

  /// No description provided for @tasksAfter.
  ///
  /// In en, this message translates to:
  /// **'After you approve'**
  String get tasksAfter;

  /// No description provided for @tasksAfterMain.
  ///
  /// In en, this message translates to:
  /// **'Push to main'**
  String get tasksAfterMain;

  /// No description provided for @tasksAfterPr.
  ///
  /// In en, this message translates to:
  /// **'Open pull request'**
  String get tasksAfterPr;

  /// No description provided for @tasksStart.
  ///
  /// In en, this message translates to:
  /// **'How to start'**
  String get tasksStart;

  /// No description provided for @tasksStartAsk.
  ///
  /// In en, this message translates to:
  /// **'Ask questions first'**
  String get tasksStartAsk;

  /// No description provided for @tasksStartAskHint.
  ///
  /// In en, this message translates to:
  /// **'agnts reads the code and asks before coding. Best for anything unclear.'**
  String get tasksStartAskHint;

  /// No description provided for @tasksStartCode.
  ///
  /// In en, this message translates to:
  /// **'Start coding right away'**
  String get tasksStartCode;

  /// No description provided for @tasksStartCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Skip questions. Good for small, well-described tasks.'**
  String get tasksStartCodeHint;

  /// No description provided for @tasksStartQueue.
  ///
  /// In en, this message translates to:
  /// **'Keep in queue'**
  String get tasksStartQueue;

  /// No description provided for @tasksStartQueueHint.
  ///
  /// In en, this message translates to:
  /// **'Save it and start later.'**
  String get tasksStartQueueHint;

  /// No description provided for @tasksCreate.
  ///
  /// In en, this message translates to:
  /// **'Create task'**
  String get tasksCreate;

  /// No description provided for @tasksCreateStart.
  ///
  /// In en, this message translates to:
  /// **'Create and start'**
  String get tasksCreateStart;

  /// No description provided for @tasksAddRepoFirst.
  ///
  /// In en, this message translates to:
  /// **'Add a side-project repository first.'**
  String get tasksAddRepoFirst;

  /// No description provided for @tasksTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a title.'**
  String get tasksTitleRequired;

  /// No description provided for @tasksCreated.
  ///
  /// In en, this message translates to:
  /// **'Task {key} created'**
  String tasksCreated(String key);

  /// No description provided for @tasksCount.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} task} other {{n} tasks}}'**
  String tasksCount(num n);

  /// No description provided for @tasksNoRepo.
  ///
  /// In en, this message translates to:
  /// **'No repository'**
  String get tasksNoRepo;

  /// No description provided for @tasksRepoNeeded.
  ///
  /// In en, this message translates to:
  /// **'Code and tests need a repository: pick one, or choose another kind.'**
  String get tasksRepoNeeded;

  /// No description provided for @ticketBack.
  ///
  /// In en, this message translates to:
  /// **'All tickets'**
  String get ticketBack;

  /// No description provided for @ticketPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get ticketPlan;

  /// No description provided for @ticketAnalysis.
  ///
  /// In en, this message translates to:
  /// **'What agnts found'**
  String get ticketAnalysis;

  /// No description provided for @ticketQuestions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get ticketQuestions;

  /// No description provided for @ticketYourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get ticketYourAnswer;

  /// No description provided for @ticketNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get ticketNote;

  /// No description provided for @ticketSendAnswers.
  ///
  /// In en, this message translates to:
  /// **'Send answers and start coding'**
  String get ticketSendAnswers;

  /// No description provided for @ticketChanges.
  ///
  /// In en, this message translates to:
  /// **'Changes'**
  String get ticketChanges;

  /// No description provided for @ticketFilesChanged.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {{count} file changed} other {{count} files changed}}'**
  String ticketFilesChanged(num count);

  /// No description provided for @ticketChecks.
  ///
  /// In en, this message translates to:
  /// **'Checks'**
  String get ticketChecks;

  /// No description provided for @ticketPassed.
  ///
  /// In en, this message translates to:
  /// **'passed'**
  String get ticketPassed;

  /// No description provided for @ticketFailedCheck.
  ///
  /// In en, this message translates to:
  /// **'failed'**
  String get ticketFailedCheck;

  /// No description provided for @ticketNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes for the reviewer'**
  String get ticketNotes;

  /// No description provided for @ticketApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve and push'**
  String get ticketApprove;

  /// No description provided for @ticketApproveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Push {branch} and open a pull request?'**
  String ticketApproveConfirm(String branch);

  /// No description provided for @ticketRequestChanges.
  ///
  /// In en, this message translates to:
  /// **'Request changes'**
  String get ticketRequestChanges;

  /// No description provided for @ticketFeedbackPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'What should change?'**
  String get ticketFeedbackPlaceholder;

  /// No description provided for @ticketSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get ticketSend;

  /// No description provided for @ticketCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get ticketCancel;

  /// No description provided for @ticketReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get ticketReject;

  /// No description provided for @ticketRejectConfirm.
  ///
  /// In en, this message translates to:
  /// **'Stop all work on {key}? This cannot be undone.'**
  String ticketRejectConfirm(String key);

  /// No description provided for @ticketRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get ticketRetry;

  /// No description provided for @ticketPullRequest.
  ///
  /// In en, this message translates to:
  /// **'Pull request #{number}'**
  String ticketPullRequest(String number);

  /// No description provided for @ticketBranch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get ticketBranch;

  /// No description provided for @ticketRevision.
  ///
  /// In en, this message translates to:
  /// **'Revision {n}'**
  String ticketRevision(String n);

  /// No description provided for @ticketLog.
  ///
  /// In en, this message translates to:
  /// **'Live log'**
  String get ticketLog;

  /// No description provided for @ticketLogEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet.'**
  String get ticketLogEmpty;

  /// No description provided for @ticketNotFound.
  ///
  /// In en, this message translates to:
  /// **'No ticket {key}.'**
  String ticketNotFound(String key);

  /// No description provided for @ticketConflict.
  ///
  /// In en, this message translates to:
  /// **'The ticket moved on; refreshed.'**
  String get ticketConflict;

  /// No description provided for @ticketStopAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze'**
  String get ticketStopAnalyze;

  /// No description provided for @ticketStopAnswers.
  ///
  /// In en, this message translates to:
  /// **'Your answers'**
  String get ticketStopAnswers;

  /// No description provided for @ticketStopCoding.
  ///
  /// In en, this message translates to:
  /// **'Coding'**
  String get ticketStopCoding;

  /// No description provided for @ticketStopTests.
  ///
  /// In en, this message translates to:
  /// **'Tests'**
  String get ticketStopTests;

  /// No description provided for @ticketStopReview.
  ///
  /// In en, this message translates to:
  /// **'Your review'**
  String get ticketStopReview;

  /// No description provided for @ticketStopPushed.
  ///
  /// In en, this message translates to:
  /// **'Pushed'**
  String get ticketStopPushed;

  /// No description provided for @ticketProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get ticketProgress;

  /// No description provided for @ticketBackTo.
  ///
  /// In en, this message translates to:
  /// **'Back to {page}'**
  String ticketBackTo(String page);

  /// No description provided for @ticketQueuedTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting in queue'**
  String get ticketQueuedTitle;

  /// No description provided for @ticketQueuedSub.
  ///
  /// In en, this message translates to:
  /// **'agnts reads the ticket and the related code, then comes back with a plan and questions. Nothing is changed in this step.'**
  String get ticketQueuedSub;

  /// No description provided for @ticketHeldSub.
  ///
  /// In en, this message translates to:
  /// **'This task is kept in the queue until you start it.'**
  String get ticketHeldSub;

  /// No description provided for @ticketStart.
  ///
  /// In en, this message translates to:
  /// **'Start now'**
  String get ticketStart;

  /// No description provided for @ticketStartHint.
  ///
  /// In en, this message translates to:
  /// **'Starts when a run slot is free'**
  String get ticketStartHint;

  /// No description provided for @ticketAnalyzingTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading the code'**
  String get ticketAnalyzingTitle;

  /// No description provided for @ticketAnalyzingSub.
  ///
  /// In en, this message translates to:
  /// **'Looking through {repo} to build a plan.'**
  String ticketAnalyzingSub(String repo);

  /// No description provided for @ticketQuestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} question before coding} other {{n} questions before coding}}'**
  String ticketQuestionsTitle(num n);

  /// No description provided for @ticketQuestionsSub.
  ///
  /// In en, this message translates to:
  /// **'Pick an option or write your own answer. Answers go into the coding prompt with the plan.'**
  String get ticketQuestionsSub;

  /// No description provided for @ticketAddDetails.
  ///
  /// In en, this message translates to:
  /// **'Add details (optional)'**
  String get ticketAddDetails;

  /// No description provided for @ticketDetailsFor.
  ///
  /// In en, this message translates to:
  /// **'Details for question {n}'**
  String ticketDetailsFor(String n);

  /// No description provided for @ticketAnswerFor.
  ///
  /// In en, this message translates to:
  /// **'Answer to question {n}'**
  String ticketAnswerFor(String n);

  /// No description provided for @ticketStartCoding.
  ///
  /// In en, this message translates to:
  /// **'Start coding'**
  String get ticketStartCoding;

  /// No description provided for @ticketQuestionsLeft.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} question left to answer} other {{n} questions left to answer}}'**
  String ticketQuestionsLeft(num n);

  /// No description provided for @ticketAllAnswered.
  ///
  /// In en, this message translates to:
  /// **'All questions answered'**
  String get ticketAllAnswered;

  /// No description provided for @ticketCodingTitle.
  ///
  /// In en, this message translates to:
  /// **'Coding'**
  String get ticketCodingTitle;

  /// No description provided for @ticketTestingTitle.
  ///
  /// In en, this message translates to:
  /// **'Running tests'**
  String get ticketTestingTitle;

  /// No description provided for @ticketRevisionSuffix.
  ///
  /// In en, this message translates to:
  /// **'{title}, revision {n}'**
  String ticketRevisionSuffix(String title, String n);

  /// No description provided for @ticketCodingSub.
  ///
  /// In en, this message translates to:
  /// **'Working in a fresh container on {branch}. You review the diff before anything is pushed.'**
  String ticketCodingSub(String branch);

  /// No description provided for @ticketFactModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get ticketFactModel;

  /// No description provided for @ticketFactTurns.
  ///
  /// In en, this message translates to:
  /// **'Turns'**
  String get ticketFactTurns;

  /// No description provided for @ticketFactTurnLimit.
  ///
  /// In en, this message translates to:
  /// **'Turn limit'**
  String get ticketFactTurnLimit;

  /// No description provided for @ticketFactSession.
  ///
  /// In en, this message translates to:
  /// **'Session usage'**
  String get ticketFactSession;

  /// No description provided for @ticketFactTests.
  ///
  /// In en, this message translates to:
  /// **'Tests'**
  String get ticketFactTests;

  /// No description provided for @ticketFactChanged.
  ///
  /// In en, this message translates to:
  /// **'Changed'**
  String get ticketFactChanged;

  /// No description provided for @ticketChangedValue.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} file} other {{n} files}}, +{add} −{del}'**
  String ticketChangedValue(num n, String add, String del);

  /// No description provided for @ticketChecksPassed.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} check passed} other {{n} checks passed}}'**
  String ticketChecksPassed(num n);

  /// No description provided for @ticketNoChecks.
  ///
  /// In en, this message translates to:
  /// **'No checks configured'**
  String get ticketNoChecks;

  /// No description provided for @ticketStopRun.
  ///
  /// In en, this message translates to:
  /// **'Stop run'**
  String get ticketStopRun;

  /// No description provided for @ticketStopConfirm.
  ///
  /// In en, this message translates to:
  /// **'Stop the run on {key}? You can retry it later.'**
  String ticketStopConfirm(String key);

  /// No description provided for @ticketReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review the changes'**
  String get ticketReviewTitle;

  /// No description provided for @ticketReviewSubPr.
  ///
  /// In en, this message translates to:
  /// **'Nothing has left the server yet. Approving pushes {branch} and opens a pull request.'**
  String ticketReviewSubPr(String branch);

  /// No description provided for @ticketReviewSubJira.
  ///
  /// In en, this message translates to:
  /// **'Nothing has left the server yet. Approving pushes {branch}, opens a pull request and updates the Jira ticket.'**
  String ticketReviewSubJira(String branch);

  /// No description provided for @ticketReviewSubMain.
  ///
  /// In en, this message translates to:
  /// **'Nothing has left the server yet. Approving pushes straight to the default branch.'**
  String get ticketReviewSubMain;

  /// No description provided for @ticketWhatAgntsDid.
  ///
  /// In en, this message translates to:
  /// **'What agnts did'**
  String get ticketWhatAgntsDid;

  /// No description provided for @ticketDiff.
  ///
  /// In en, this message translates to:
  /// **'Diff'**
  String get ticketDiff;

  /// No description provided for @ticketFeedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get ticketFeedback;

  /// No description provided for @ticketAssignTitle.
  ///
  /// In en, this message translates to:
  /// **'Assign the pull request'**
  String get ticketAssignTitle;

  /// No description provided for @ticketAssignSub.
  ///
  /// In en, this message translates to:
  /// **'Optional. Pick who it is assigned to on the git host when agnts opens it.'**
  String get ticketAssignSub;

  /// No description provided for @ticketAssignError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the repository members: {error}. You can still approve without assignees.'**
  String ticketAssignError(String error);

  /// No description provided for @ticketAssignNone.
  ///
  /// In en, this message translates to:
  /// **'No repository members to pick from.'**
  String get ticketAssignNone;

  /// No description provided for @ticketApproveAssignees.
  ///
  /// In en, this message translates to:
  /// **'Assign it to {names}.'**
  String ticketApproveAssignees(String names);

  /// No description provided for @ticketKvAssignees.
  ///
  /// In en, this message translates to:
  /// **'Assignees'**
  String get ticketKvAssignees;

  /// No description provided for @ticketFeedbackHint.
  ///
  /// In en, this message translates to:
  /// **'Describe what to change. Required for Request changes.'**
  String get ticketFeedbackHint;

  /// No description provided for @ticketApproveMainConfirm.
  ///
  /// In en, this message translates to:
  /// **'Push the changes straight to the default branch?'**
  String get ticketApproveMainConfirm;

  /// No description provided for @ticketPushingTitle.
  ///
  /// In en, this message translates to:
  /// **'Pushing'**
  String get ticketPushingTitle;

  /// No description provided for @ticketPushingSub.
  ///
  /// In en, this message translates to:
  /// **'Committing as you and opening the pull request.'**
  String get ticketPushingSub;

  /// No description provided for @ticketDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Pushed'**
  String get ticketDoneTitle;

  /// No description provided for @ticketDoneMain.
  ///
  /// In en, this message translates to:
  /// **'Committed as you and pushed to the default branch of {repo}.'**
  String ticketDoneMain(String repo);

  /// No description provided for @ticketDonePr.
  ///
  /// In en, this message translates to:
  /// **'Pull request #{number} is open on {branch}.'**
  String ticketDonePr(String number, String branch);

  /// No description provided for @ticketOpenPr.
  ///
  /// In en, this message translates to:
  /// **'Open pull request #{number}'**
  String ticketOpenPr(String number);

  /// No description provided for @ticketRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get ticketRejectedTitle;

  /// No description provided for @ticketRejectedSub.
  ///
  /// In en, this message translates to:
  /// **'agnts stopped working on this ticket. The branch was not pushed.'**
  String get ticketRejectedSub;

  /// No description provided for @ticketFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'agnts stopped'**
  String get ticketFailedTitle;

  /// No description provided for @ticketFailedUnknown.
  ///
  /// In en, this message translates to:
  /// **'The run stopped. Check the run log for details.'**
  String get ticketFailedUnknown;

  /// No description provided for @ticketTakeItMyself.
  ///
  /// In en, this message translates to:
  /// **'Take it myself'**
  String get ticketTakeItMyself;

  /// No description provided for @ticketRateTitle.
  ///
  /// In en, this message translates to:
  /// **'Paused at plan limit'**
  String get ticketRateTitle;

  /// No description provided for @ticketResume.
  ///
  /// In en, this message translates to:
  /// **'Resume run'**
  String get ticketResume;

  /// No description provided for @ticketRateHint.
  ///
  /// In en, this message translates to:
  /// **'Session usage is {pct}% now.'**
  String ticketRateHint(String pct);

  /// No description provided for @ticketModelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Models for this ticket'**
  String get ticketModelsTitle;

  /// No description provided for @ticketModelsHint.
  ///
  /// In en, this message translates to:
  /// **'Override the defaults from Settings for this ticket only.'**
  String get ticketModelsHint;

  /// No description provided for @ticketModelDefault.
  ///
  /// In en, this message translates to:
  /// **'Default ({model})'**
  String ticketModelDefault(String model);

  /// No description provided for @ticketStageAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Reading the ticket and asking questions'**
  String get ticketStageAnalyze;

  /// No description provided for @ticketStageCoding.
  ///
  /// In en, this message translates to:
  /// **'Coding'**
  String get ticketStageCoding;

  /// No description provided for @ticketStageRetry.
  ///
  /// In en, this message translates to:
  /// **'Retries and requested changes'**
  String get ticketStageRetry;

  /// No description provided for @ticketStageReview.
  ///
  /// In en, this message translates to:
  /// **'Code review by agnts'**
  String get ticketStageReview;

  /// No description provided for @ticketStagePreview.
  ///
  /// In en, this message translates to:
  /// **'Screenshots (preview)'**
  String get ticketStagePreview;

  /// No description provided for @ticketModelAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto ({model})'**
  String ticketModelAuto(String model);

  /// No description provided for @ticketSideTicket.
  ///
  /// In en, this message translates to:
  /// **'Ticket'**
  String get ticketSideTicket;

  /// No description provided for @ticketSideTask.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get ticketSideTask;

  /// No description provided for @ticketKvKey.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get ticketKvKey;

  /// No description provided for @ticketKvSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get ticketKvSource;

  /// No description provided for @ticketKvRepo.
  ///
  /// In en, this message translates to:
  /// **'Repository'**
  String get ticketKvRepo;

  /// No description provided for @ticketKvAfter.
  ///
  /// In en, this message translates to:
  /// **'After approval'**
  String get ticketKvAfter;

  /// No description provided for @ticketKvPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get ticketKvPriority;

  /// No description provided for @ticketKvBranch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get ticketKvBranch;

  /// No description provided for @ticketKvRevision.
  ///
  /// In en, this message translates to:
  /// **'Revision'**
  String get ticketKvRevision;

  /// No description provided for @ticketKvTurns.
  ///
  /// In en, this message translates to:
  /// **'Turns used'**
  String get ticketKvTurns;

  /// No description provided for @ticketKvCodingModel.
  ///
  /// In en, this message translates to:
  /// **'Coding model'**
  String get ticketKvCodingModel;

  /// No description provided for @ticketKvRetryModel.
  ///
  /// In en, this message translates to:
  /// **'Retry model'**
  String get ticketKvRetryModel;

  /// No description provided for @ticketSrcJira.
  ///
  /// In en, this message translates to:
  /// **'Jira'**
  String get ticketSrcJira;

  /// No description provided for @ticketSrcTask.
  ///
  /// In en, this message translates to:
  /// **'agnts task'**
  String get ticketSrcTask;

  /// No description provided for @ticketAfterMain.
  ///
  /// In en, this message translates to:
  /// **'Push to main'**
  String get ticketAfterMain;

  /// No description provided for @ticketAfterPr.
  ///
  /// In en, this message translates to:
  /// **'Open pull request'**
  String get ticketAfterPr;

  /// No description provided for @ticketHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get ticketHistoryTitle;

  /// No description provided for @ticketHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No history yet.'**
  String get ticketHistoryEmpty;

  /// No description provided for @ticketAnswersTitle.
  ///
  /// In en, this message translates to:
  /// **'Your answers'**
  String get ticketAnswersTitle;

  /// No description provided for @ticketAnswersSub.
  ///
  /// In en, this message translates to:
  /// **'Sent with the coding prompt'**
  String get ticketAnswersSub;

  /// No description provided for @ticketRunLog.
  ///
  /// In en, this message translates to:
  /// **'Run log'**
  String get ticketRunLog;

  /// No description provided for @ticketRunLogSub.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} event} other {{n} events}}, grouped by step'**
  String ticketRunLogSub(num n);

  /// No description provided for @ticketGroupEvents.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} event} other {{n} events}}'**
  String ticketGroupEvents(num n);

  /// No description provided for @ticketGroupErrors.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} error} other {{n} errors}}'**
  String ticketGroupErrors(num n);

  /// No description provided for @ticketOpenInLogs.
  ///
  /// In en, this message translates to:
  /// **'Open in Logs'**
  String get ticketOpenInLogs;

  /// No description provided for @ticketStepOther.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get ticketStepOther;

  /// No description provided for @ticketDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get ticketDelete;

  /// No description provided for @ticketDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete task {key}?'**
  String ticketDeleteConfirm(String key);

  /// No description provided for @ticketUsageTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan usage'**
  String get ticketUsageTitle;

  /// No description provided for @ticketUsageSession.
  ///
  /// In en, this message translates to:
  /// **'Current session'**
  String get ticketUsageSession;

  /// No description provided for @ticketUsageWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get ticketUsageWeek;

  /// No description provided for @ticketMerged.
  ///
  /// In en, this message translates to:
  /// **'Merged'**
  String get ticketMerged;

  /// No description provided for @ticketMergedAt.
  ///
  /// In en, this message translates to:
  /// **'Merged {time}.'**
  String ticketMergedAt(String time);

  /// No description provided for @ticketRepoTitle.
  ///
  /// In en, this message translates to:
  /// **'Repository'**
  String get ticketRepoTitle;

  /// No description provided for @ticketRepoHint.
  ///
  /// In en, this message translates to:
  /// **'Where agnts analyzes and codes this ticket.'**
  String get ticketRepoHint;

  /// No description provided for @ticketRepoNone.
  ///
  /// In en, this message translates to:
  /// **'Choose a repository…'**
  String get ticketRepoNone;

  /// No description provided for @ticketRepoMissing.
  ///
  /// In en, this message translates to:
  /// **'No repository is linked to this ticket. Choose one, then retry.'**
  String get ticketRepoMissing;

  /// No description provided for @ticketRepoRestartTitle.
  ///
  /// In en, this message translates to:
  /// **'Change repository?'**
  String get ticketRepoRestartTitle;

  /// No description provided for @ticketRepoRestart.
  ///
  /// In en, this message translates to:
  /// **'This ticket made progress in {repo}. In {next} it starts over from analysis when you retry.'**
  String ticketRepoRestart(String repo, String next);

  /// No description provided for @ticketRepoChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get ticketRepoChange;

  /// No description provided for @ticketRepoChanged.
  ///
  /// In en, this message translates to:
  /// **'Repository set to {repo}'**
  String ticketRepoChanged(String repo);

  /// No description provided for @ticketQueuedSubReport.
  ///
  /// In en, this message translates to:
  /// **'agnts reads the ticket (and the code, if there is a repository) and comes back with a plan and questions. Nothing is changed.'**
  String get ticketQueuedSubReport;

  /// No description provided for @ticketAnalyzingTitleNoRepo.
  ///
  /// In en, this message translates to:
  /// **'Reading the ticket'**
  String get ticketAnalyzingTitleNoRepo;

  /// No description provided for @ticketAnalyzingSubNoRepo.
  ///
  /// In en, this message translates to:
  /// **'No repository: agnts works from the ticket text.'**
  String get ticketAnalyzingSubNoRepo;

  /// No description provided for @ticketStartWriting.
  ///
  /// In en, this message translates to:
  /// **'Start writing'**
  String get ticketStartWriting;

  /// No description provided for @ticketWritingTitle.
  ///
  /// In en, this message translates to:
  /// **'Writing the report'**
  String get ticketWritingTitle;

  /// No description provided for @ticketWritingSub.
  ///
  /// In en, this message translates to:
  /// **'Working in a fresh container. Nothing in the code changes; you review the report first.'**
  String get ticketWritingSub;

  /// No description provided for @ticketReviewReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Review the report'**
  String get ticketReviewReportTitle;

  /// No description provided for @ticketReviewReportSub.
  ///
  /// In en, this message translates to:
  /// **'Approving keeps the report here and closes the task.'**
  String get ticketReviewReportSub;

  /// No description provided for @ticketReviewReportSubJira.
  ///
  /// In en, this message translates to:
  /// **'Approving keeps the report here and closes the ticket. It goes to Jira only if you tick the box below.'**
  String get ticketReviewReportSubJira;

  /// No description provided for @ticketReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get ticketReport;

  /// No description provided for @ticketReportMissing.
  ///
  /// In en, this message translates to:
  /// **'No report was stored.'**
  String get ticketReportMissing;

  /// No description provided for @ticketPostReport.
  ///
  /// In en, this message translates to:
  /// **'Also post the report as a comment on {key} in Jira'**
  String ticketPostReport(String key);

  /// No description provided for @ticketFeedbackReportHint.
  ///
  /// In en, this message translates to:
  /// **'What should the report change or cover?'**
  String get ticketFeedbackReportHint;

  /// No description provided for @ticketApproveReport.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get ticketApproveReport;

  /// No description provided for @ticketApproveReportConfirm.
  ///
  /// In en, this message translates to:
  /// **'Approve the report and close this ticket?'**
  String get ticketApproveReportConfirm;

  /// No description provided for @ticketApproveReportPostConfirm.
  ///
  /// In en, this message translates to:
  /// **'Approve the report, close this ticket and post the report to {key} in Jira?'**
  String ticketApproveReportPostConfirm(String key);

  /// No description provided for @ticketDeliveringTitle.
  ///
  /// In en, this message translates to:
  /// **'Finishing up'**
  String get ticketDeliveringTitle;

  /// No description provided for @ticketDeliveringSub.
  ///
  /// In en, this message translates to:
  /// **'Saving the approved report and posting it to Jira if you asked.'**
  String get ticketDeliveringSub;

  /// No description provided for @ticketDoneReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report approved'**
  String get ticketDoneReportTitle;

  /// No description provided for @ticketDoneReport.
  ///
  /// In en, this message translates to:
  /// **'The report is kept here.'**
  String get ticketDoneReport;

  /// No description provided for @ticketDoneReportPosted.
  ///
  /// In en, this message translates to:
  /// **'The report is kept here and was posted to {key} in Jira.'**
  String ticketDoneReportPosted(String key);

  /// No description provided for @ticketStopWriting.
  ///
  /// In en, this message translates to:
  /// **'Writing'**
  String get ticketStopWriting;

  /// No description provided for @ticketStopDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get ticketStopDone;

  /// No description provided for @ticketTabsLabel.
  ///
  /// In en, this message translates to:
  /// **'Ticket details'**
  String get ticketTabsLabel;

  /// No description provided for @ticketTabReview.
  ///
  /// In en, this message translates to:
  /// **'Code review'**
  String get ticketTabReview;

  /// No description provided for @ticketTabFollowUps.
  ///
  /// In en, this message translates to:
  /// **'Follow-ups'**
  String get ticketTabFollowUps;

  /// No description provided for @ticketTabAnswers.
  ///
  /// In en, this message translates to:
  /// **'Answers'**
  String get ticketTabAnswers;

  /// No description provided for @ticketTabLessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get ticketTabLessons;

  /// No description provided for @ticketShowMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get ticketShowMore;

  /// No description provided for @ticketShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get ticketShowLess;

  /// No description provided for @ticketTranslate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get ticketTranslate;

  /// No description provided for @ticketTranslateOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original language'**
  String get ticketTranslateOriginal;

  /// No description provided for @ticketTranslating.
  ///
  /// In en, this message translates to:
  /// **'Translating… the first time takes up to a minute; after that it is saved.'**
  String get ticketTranslating;

  /// No description provided for @ticketTranslateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not translate: {error}'**
  String ticketTranslateFailed(String error);

  /// No description provided for @ticketsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get ticketsTitle;

  /// No description provided for @ticketsNeedsYou.
  ///
  /// In en, this message translates to:
  /// **'Needs you'**
  String get ticketsNeedsYou;

  /// No description provided for @ticketsRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get ticketsRunning;

  /// No description provided for @ticketsFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get ticketsFinished;

  /// No description provided for @ticketsAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get ticketsAll;

  /// No description provided for @ticketsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tickets here.'**
  String get ticketsEmpty;

  /// No description provided for @ticketsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Label a Jira issue “{label}” and agnts picks it up.'**
  String ticketsEmptyHint(String label);

  /// No description provided for @ticketsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String ticketsUpdated(String time);

  /// No description provided for @ticketsColTicket.
  ///
  /// In en, this message translates to:
  /// **'Ticket'**
  String get ticketsColTicket;

  /// No description provided for @ticketsColSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get ticketsColSource;

  /// No description provided for @ticketsColRepo.
  ///
  /// In en, this message translates to:
  /// **'Repository'**
  String get ticketsColRepo;

  /// No description provided for @ticketsColStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get ticketsColStatus;

  /// No description provided for @ticketsColUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get ticketsColUpdated;

  /// No description provided for @ticketsSourceJira.
  ///
  /// In en, this message translates to:
  /// **'Jira'**
  String get ticketsSourceJira;

  /// No description provided for @ticketsSourceTask.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get ticketsSourceTask;

  /// No description provided for @ticketsRev.
  ///
  /// In en, this message translates to:
  /// **'rev {n}'**
  String ticketsRev(String n);

  /// No description provided for @ticketsCount.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} ticket} other {{n} tickets}}'**
  String ticketsCount(num n);

  /// No description provided for @ticketsViewLabel.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get ticketsViewLabel;

  /// No description provided for @ticketsViewTable.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get ticketsViewTable;

  /// No description provided for @ticketsViewBoard.
  ///
  /// In en, this message translates to:
  /// **'Board'**
  String get ticketsViewBoard;

  /// No description provided for @ticketsBoardEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here'**
  String get ticketsBoardEmpty;

  /// No description provided for @ticketsListSub.
  ///
  /// In en, this message translates to:
  /// **'Jira tickets with the agnts label, plus tasks you create for side projects.'**
  String get ticketsListSub;

  /// No description provided for @ticketsNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No tickets match your search.'**
  String get ticketsNoMatch;

  /// No description provided for @ticketsEmptyNeeds.
  ///
  /// In en, this message translates to:
  /// **'Nothing is waiting on you. Tickets show up here when agnts has questions or changes to review.'**
  String get ticketsEmptyNeeds;

  /// No description provided for @ticketsEmptyOther.
  ///
  /// In en, this message translates to:
  /// **'No tickets here yet.'**
  String get ticketsEmptyOther;

  /// No description provided for @ticketsStatNeeds.
  ///
  /// In en, this message translates to:
  /// **'Needs you'**
  String get ticketsStatNeeds;

  /// No description provided for @ticketsStatNeedsNote.
  ///
  /// In en, this message translates to:
  /// **'Answers or reviews waiting'**
  String get ticketsStatNeedsNote;

  /// No description provided for @ticketsStatRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get ticketsStatRunning;

  /// No description provided for @ticketsStatRunningNote.
  ///
  /// In en, this message translates to:
  /// **'In containers right now'**
  String get ticketsStatRunningNote;

  /// No description provided for @ticketsStatPushed.
  ///
  /// In en, this message translates to:
  /// **'Pushed this week'**
  String get ticketsStatPushed;

  /// No description provided for @ticketsStatPushedNote.
  ///
  /// In en, this message translates to:
  /// **'Pull requests opened'**
  String get ticketsStatPushedNote;

  /// No description provided for @ticketsStatSession.
  ///
  /// In en, this message translates to:
  /// **'Plan session'**
  String get ticketsStatSession;

  /// No description provided for @usageTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan usage'**
  String get usageTitle;

  /// No description provided for @usageLede.
  ///
  /// In en, this message translates to:
  /// **'agnts runs on your Claude subscription. These limits are shared with your own Claude and Claude Code use.'**
  String get usageLede;

  /// No description provided for @usageCard.
  ///
  /// In en, this message translates to:
  /// **'Plan usage'**
  String get usageCard;

  /// No description provided for @usageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String usageUpdated(String time);

  /// No description provided for @usageNoReading.
  ///
  /// In en, this message translates to:
  /// **'No reading yet'**
  String get usageNoReading;

  /// No description provided for @usageRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get usageRefresh;

  /// No description provided for @usageRefreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing…'**
  String get usageRefreshing;

  /// No description provided for @usageRefreshStarted.
  ///
  /// In en, this message translates to:
  /// **'Refresh started. New numbers arrive in a minute.'**
  String get usageRefreshStarted;

  /// No description provided for @usageSession.
  ///
  /// In en, this message translates to:
  /// **'Current session'**
  String get usageSession;

  /// No description provided for @usageWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get usageWeek;

  /// No description provided for @usageUnknown.
  ///
  /// In en, this message translates to:
  /// **'Usage unknown'**
  String get usageUnknown;

  /// No description provided for @usageResetsIn.
  ///
  /// In en, this message translates to:
  /// **'Resets in {time}'**
  String usageResetsIn(String time);

  /// No description provided for @usageResetsAt.
  ///
  /// In en, this message translates to:
  /// **'Resets {time}'**
  String usageResetsAt(String time);

  /// No description provided for @usageResettingNow.
  ///
  /// In en, this message translates to:
  /// **'Resetting now'**
  String get usageResettingNow;

  /// No description provided for @usageNoReset.
  ///
  /// In en, this message translates to:
  /// **'Reset time unknown'**
  String get usageNoReset;

  /// No description provided for @usageWarn80.
  ///
  /// In en, this message translates to:
  /// **'Session usage is above 80%. New runs may pause before they finish.'**
  String get usageWarn80;

  /// No description provided for @usagePaused.
  ///
  /// In en, this message translates to:
  /// **'New runs are paused at the plan limit until {time}.'**
  String usagePaused(String time);

  /// No description provided for @usagePausedNoTime.
  ///
  /// In en, this message translates to:
  /// **'New runs are paused at the plan limit.'**
  String get usagePausedNoTime;

  /// No description provided for @usageStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get usageStatus;

  /// No description provided for @usageStatus_allowed.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get usageStatus_allowed;

  /// No description provided for @usageStatus_allowed_warning.
  ///
  /// In en, this message translates to:
  /// **'Close to the limit'**
  String get usageStatus_allowed_warning;

  /// No description provided for @usageStatus_rejected.
  ///
  /// In en, this message translates to:
  /// **'Limit reached'**
  String get usageStatus_rejected;

  /// No description provided for @usageStatus_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get usageStatus_unknown;

  /// No description provided for @usageSource.
  ///
  /// In en, this message translates to:
  /// **'Read from Claude Code\'s rate limit events. Includes your own Claude use on this account.'**
  String get usageSource;

  /// No description provided for @usageLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'When a limit is reached'**
  String get usageLimitTitle;

  /// No description provided for @usageLimitSub.
  ///
  /// In en, this message translates to:
  /// **'How agnts behaves near the limit'**
  String get usageLimitSub;

  /// No description provided for @usageAbove.
  ///
  /// In en, this message translates to:
  /// **'Above {pct}% of the session'**
  String usageAbove(String pct);

  /// No description provided for @usageAboveDo.
  ///
  /// In en, this message translates to:
  /// **'Don\'t start new runs; runs already going keep going'**
  String get usageAboveDo;

  /// No description provided for @usageMidRun.
  ///
  /// In en, this message translates to:
  /// **'Limit reached mid-run'**
  String get usageMidRun;

  /// No description provided for @usageMidRunDo.
  ///
  /// In en, this message translates to:
  /// **'Pause, keep the branch'**
  String get usageMidRunDo;

  /// No description provided for @usageAfterReset.
  ///
  /// In en, this message translates to:
  /// **'After reset'**
  String get usageAfterReset;

  /// No description provided for @usageResumeAuto.
  ///
  /// In en, this message translates to:
  /// **'Resume paused runs automatically'**
  String get usageResumeAuto;

  /// No description provided for @usageResumeManual.
  ///
  /// In en, this message translates to:
  /// **'Wait for you to resume'**
  String get usageResumeManual;

  /// No description provided for @usageIdle.
  ///
  /// In en, this message translates to:
  /// **'Idle refresh'**
  String get usageIdle;

  /// No description provided for @usageIdleDo.
  ///
  /// In en, this message translates to:
  /// **'Every 30 min'**
  String get usageIdleDo;

  /// No description provided for @usageHelp.
  ///
  /// In en, this message translates to:
  /// **'Numbers come from the rate limit events Claude Code emits during each run. When agnts is idle, a tiny refresh run keeps them current.'**
  String get usageHelp;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
