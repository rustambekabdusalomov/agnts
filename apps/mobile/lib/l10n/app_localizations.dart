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

  /// No description provided for @accountSignupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get accountSignupTitle;

  /// No description provided for @accountSignupLede.
  ///
  /// In en, this message translates to:
  /// **'You get a workspace of your own to start in.'**
  String get accountSignupLede;

  /// No description provided for @accountSignupInviteLede.
  ///
  /// In en, this message translates to:
  /// **'Create an account to join {workspace}.'**
  String accountSignupInviteLede(String workspace);

  /// No description provided for @accountSignupClosed.
  ///
  /// In en, this message translates to:
  /// **'Sign-up is by invitation on this server. Ask a workspace owner for an invite link.'**
  String get accountSignupClosed;

  /// No description provided for @accountFirstUser.
  ///
  /// In en, this message translates to:
  /// **'This is the first account: it becomes the platform\'s Admin.'**
  String get accountFirstUser;

  /// No description provided for @accountEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get accountEmail;

  /// No description provided for @accountDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get accountDisplayName;

  /// No description provided for @accountUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get accountUsername;

  /// No description provided for @accountUsernameHelp.
  ///
  /// In en, this message translates to:
  /// **'Optional; made from your email when empty.'**
  String get accountUsernameHelp;

  /// No description provided for @accountPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get accountPassword;

  /// No description provided for @accountPasswordHelp.
  ///
  /// In en, this message translates to:
  /// **'At least 12 characters.'**
  String get accountPasswordHelp;

  /// No description provided for @accountPasswordAgain.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get accountPasswordAgain;

  /// No description provided for @accountPasswordsDiffer.
  ///
  /// In en, this message translates to:
  /// **'The passwords differ.'**
  String get accountPasswordsDiffer;

  /// No description provided for @accountWorkspaceName.
  ///
  /// In en, this message translates to:
  /// **'Workspace name'**
  String get accountWorkspaceName;

  /// No description provided for @accountWorkspaceNameHelp.
  ///
  /// In en, this message translates to:
  /// **'Your first workspace, e.g. your project\'s name. You can rename it.'**
  String get accountWorkspaceNameHelp;

  /// No description provided for @accountCreate.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get accountCreate;

  /// No description provided for @accountCreating.
  ///
  /// In en, this message translates to:
  /// **'Creating…'**
  String get accountCreating;

  /// No description provided for @accountHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get accountHaveAccount;

  /// No description provided for @accountSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get accountSignIn;

  /// No description provided for @accountNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No account yet?'**
  String get accountNoAccount;

  /// No description provided for @accountSignUp.
  ///
  /// In en, this message translates to:
  /// **'Create one'**
  String get accountSignUp;

  /// No description provided for @accountForgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get accountForgot;

  /// No description provided for @accountForgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get accountForgotTitle;

  /// No description provided for @accountForgotLede.
  ///
  /// In en, this message translates to:
  /// **'We\'ll email you a link to choose a new one.'**
  String get accountForgotLede;

  /// No description provided for @accountForgotSend.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get accountForgotSend;

  /// No description provided for @accountForgotSent.
  ///
  /// In en, this message translates to:
  /// **'If an account uses that address, a link is on its way. It works for an hour.'**
  String get accountForgotSent;

  /// No description provided for @accountResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password'**
  String get accountResetTitle;

  /// No description provided for @accountResetSave.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get accountResetSave;

  /// No description provided for @accountResetDone.
  ///
  /// In en, this message translates to:
  /// **'Password changed. Every session was signed out.'**
  String get accountResetDone;

  /// No description provided for @accountVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email'**
  String get accountVerifyTitle;

  /// No description provided for @accountVerifying.
  ///
  /// In en, this message translates to:
  /// **'Confirming…'**
  String get accountVerifying;

  /// No description provided for @accountVerified.
  ///
  /// In en, this message translates to:
  /// **'Your email is confirmed.'**
  String get accountVerified;

  /// No description provided for @accountVerifyFailed.
  ///
  /// In en, this message translates to:
  /// **'This link is invalid or expired.'**
  String get accountVerifyFailed;

  /// No description provided for @accountContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get accountContinue;

  /// No description provided for @accountInviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Join {workspace}'**
  String accountInviteTitle(String workspace);

  /// No description provided for @accountInviteBy.
  ///
  /// In en, this message translates to:
  /// **'{name} invited you.'**
  String accountInviteBy(String name);

  /// No description provided for @accountInviteFor.
  ///
  /// In en, this message translates to:
  /// **'The invite is for {email}.'**
  String accountInviteFor(String email);

  /// No description provided for @accountInviteJoin.
  ///
  /// In en, this message translates to:
  /// **'Join workspace'**
  String get accountInviteJoin;

  /// No description provided for @accountInviteJoining.
  ///
  /// In en, this message translates to:
  /// **'Joining…'**
  String get accountInviteJoining;

  /// No description provided for @accountInviteInvalid.
  ///
  /// In en, this message translates to:
  /// **'This invite link is invalid or expired. Ask for a new one.'**
  String get accountInviteInvalid;

  /// No description provided for @accountInviteSignInFirst.
  ///
  /// In en, this message translates to:
  /// **'Sign in or create an account to join.'**
  String get accountInviteSignInFirst;

  /// No description provided for @accountWorkspacesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your workspaces'**
  String get accountWorkspacesTitle;

  /// No description provided for @accountWorkspacesLede.
  ///
  /// In en, this message translates to:
  /// **'A workspace is one project: its repositories, tickets, members and settings.'**
  String get accountWorkspacesLede;

  /// No description provided for @accountNoWorkspaces.
  ///
  /// In en, this message translates to:
  /// **'You are not in any workspace yet. Create one, or open an invite link someone sent you.'**
  String get accountNoWorkspaces;

  /// No description provided for @accountOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get accountOpen;

  /// No description provided for @accountCreateWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Create a workspace'**
  String get accountCreateWorkspace;

  /// No description provided for @accountCreateWorkspaceSub.
  ///
  /// In en, this message translates to:
  /// **'You become its owner.'**
  String get accountCreateWorkspaceSub;

  /// No description provided for @accountWorkspaceSlug.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get accountWorkspaceSlug;

  /// No description provided for @accountWorkspaceSlugHelp.
  ///
  /// In en, this message translates to:
  /// **'Used in links; made from the name when empty.'**
  String get accountWorkspaceSlugHelp;

  /// No description provided for @accountCreateWs.
  ///
  /// In en, this message translates to:
  /// **'Create workspace'**
  String get accountCreateWs;

  /// No description provided for @accountProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get accountProfileTitle;

  /// No description provided for @accountProfile.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get accountProfile;

  /// No description provided for @accountProfileSub.
  ///
  /// In en, this message translates to:
  /// **'How you appear to the members of your workspaces.'**
  String get accountProfileSub;

  /// No description provided for @accountSaveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get accountSaveProfile;

  /// No description provided for @accountProfileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get accountProfileSaved;

  /// No description provided for @accountEmailUnverified.
  ///
  /// In en, this message translates to:
  /// **'Not confirmed yet'**
  String get accountEmailUnverified;

  /// No description provided for @accountEmailVerified.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get accountEmailVerified;

  /// No description provided for @accountResend.
  ///
  /// In en, this message translates to:
  /// **'Send the link again'**
  String get accountResend;

  /// No description provided for @accountResent.
  ///
  /// In en, this message translates to:
  /// **'Confirmation link sent'**
  String get accountResent;

  /// No description provided for @accountPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get accountPasswordTitle;

  /// No description provided for @accountPasswordSub.
  ///
  /// In en, this message translates to:
  /// **'Changing it signs out your other sessions.'**
  String get accountPasswordSub;

  /// No description provided for @accountCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get accountCurrentPassword;

  /// No description provided for @accountNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get accountNewPassword;

  /// No description provided for @accountChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get accountChangePassword;

  /// No description provided for @accountPasswordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get accountPasswordChanged;

  /// No description provided for @accountTotpTitle.
  ///
  /// In en, this message translates to:
  /// **'Two-factor sign-in'**
  String get accountTotpTitle;

  /// No description provided for @accountTotpSub.
  ///
  /// In en, this message translates to:
  /// **'A code from an authenticator app at every sign-in.'**
  String get accountTotpSub;

  /// No description provided for @accountTotpOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get accountTotpOn;

  /// No description provided for @accountTotpOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get accountTotpOff;

  /// No description provided for @accountTotpSetup.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get accountTotpSetup;

  /// No description provided for @accountTotpScan.
  ///
  /// In en, this message translates to:
  /// **'Add this account to your authenticator app with the secret (or open the link on your phone), then enter the code it shows.'**
  String get accountTotpScan;

  /// No description provided for @accountTotpSecret.
  ///
  /// In en, this message translates to:
  /// **'Secret'**
  String get accountTotpSecret;

  /// No description provided for @accountTotpLink.
  ///
  /// In en, this message translates to:
  /// **'Setup link'**
  String get accountTotpLink;

  /// No description provided for @accountTotpCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get accountTotpCode;

  /// No description provided for @accountTotpConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get accountTotpConfirm;

  /// No description provided for @accountTotpEnabled.
  ///
  /// In en, this message translates to:
  /// **'Two-factor sign-in is on'**
  String get accountTotpEnabled;

  /// No description provided for @accountTotpDisable.
  ///
  /// In en, this message translates to:
  /// **'Turn off'**
  String get accountTotpDisable;

  /// No description provided for @accountTotpDisabled.
  ///
  /// In en, this message translates to:
  /// **'Two-factor sign-in is off'**
  String get accountTotpDisabled;

  /// No description provided for @accountMyClaude.
  ///
  /// In en, this message translates to:
  /// **'Your Claude account'**
  String get accountMyClaude;

  /// No description provided for @accountMyClaudeSub.
  ///
  /// In en, this message translates to:
  /// **'Runs of your tickets use it in workspaces set to per-member mode.'**
  String get accountMyClaudeSub;

  /// No description provided for @accountClaudeSaved.
  ///
  /// In en, this message translates to:
  /// **'Claude account connected'**
  String get accountClaudeSaved;

  /// No description provided for @accountClaudeRemoved.
  ///
  /// In en, this message translates to:
  /// **'Claude account disconnected'**
  String get accountClaudeRemoved;

  /// No description provided for @accountAdmin.
  ///
  /// In en, this message translates to:
  /// **'Platform Admin'**
  String get accountAdmin;

  /// No description provided for @accountAdminConsole.
  ///
  /// In en, this message translates to:
  /// **'Open the operator console'**
  String get accountAdminConsole;

  /// No description provided for @accountReturnTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get accountReturnTitle;

  /// No description provided for @accountReturnLede.
  ///
  /// In en, this message translates to:
  /// **'Thanks. Credits show in Billing as soon as the payment provider confirms the payment (usually within a minute).'**
  String get accountReturnLede;

  /// No description provided for @accountReturnBack.
  ///
  /// In en, this message translates to:
  /// **'Back to Billing'**
  String get accountReturnBack;

  /// No description provided for @accountLastOpened.
  ///
  /// In en, this message translates to:
  /// **'Last opened'**
  String get accountLastOpened;

  /// No description provided for @accountMemberCount.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} member} other {{n} members}}'**
  String accountMemberCount(num n);

  /// No description provided for @accountSlotCount.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} parallel run} other {{n} parallel runs}}'**
  String accountSlotCount(num n);

  /// No description provided for @accountSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get accountSuspended;

  /// No description provided for @accountNoWorkspacesTitle.
  ///
  /// In en, this message translates to:
  /// **'No workspaces yet'**
  String get accountNoWorkspacesTitle;

  /// No description provided for @accountCreateFirst.
  ///
  /// In en, this message translates to:
  /// **'Create your first workspace'**
  String get accountCreateFirst;

  /// No description provided for @accountInviteGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google to join. New here? Your account is created on the spot.'**
  String get accountInviteGoogle;

  /// No description provided for @accountTotpRequiredAdmin.
  ///
  /// In en, this message translates to:
  /// **'Two-factor sign-in is required for Admin accounts, so it stays on.'**
  String get accountTotpRequiredAdmin;

  /// No description provided for @accountGoHome.
  ///
  /// In en, this message translates to:
  /// **'Back to dashboard'**
  String get accountGoHome;

  /// No description provided for @accountBackToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Back to the {name} dashboard'**
  String accountBackToDashboard(String name);

  /// No description provided for @accountMyClaudeMuse.
  ///
  /// In en, this message translates to:
  /// **'Your Muse account'**
  String get accountMyClaudeMuse;

  /// No description provided for @accountClaudeSavedMuse.
  ///
  /// In en, this message translates to:
  /// **'Muse account connected'**
  String get accountClaudeSavedMuse;

  /// No description provided for @accountClaudeRemovedMuse.
  ///
  /// In en, this message translates to:
  /// **'Muse account disconnected'**
  String get accountClaudeRemovedMuse;

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
  /// **'Tokens Muse used per day, input and output'**
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
  /// **'No Muse runs recorded in this period.'**
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

  /// No description provided for @analyticsSrcPlane.
  ///
  /// In en, this message translates to:
  /// **'Plane'**
  String get analyticsSrcPlane;

  /// No description provided for @analyticsQuality.
  ///
  /// In en, this message translates to:
  /// **'Agent quality'**
  String get analyticsQuality;

  /// No description provided for @analyticsQualitySub.
  ///
  /// In en, this message translates to:
  /// **'Tickets grouped by the prompt version of their first coding run. Compare versions to see whether a change to the agent helped.'**
  String get analyticsQualitySub;

  /// No description provided for @analyticsNoQuality.
  ///
  /// In en, this message translates to:
  /// **'No coding runs in this period.'**
  String get analyticsNoQuality;

  /// No description provided for @analyticsColVersion.
  ///
  /// In en, this message translates to:
  /// **'Prompt version'**
  String get analyticsColVersion;

  /// No description provided for @analyticsVersionUnknown.
  ///
  /// In en, this message translates to:
  /// **'before tracking'**
  String get analyticsVersionUnknown;

  /// No description provided for @analyticsColFirstPass.
  ///
  /// In en, this message translates to:
  /// **'First pass'**
  String get analyticsColFirstPass;

  /// No description provided for @analyticsColFirstPassHint.
  ///
  /// In en, this message translates to:
  /// **'Done tickets approved without a person asking for changes'**
  String get analyticsColFirstPassHint;

  /// No description provided for @analyticsColRounds.
  ///
  /// In en, this message translates to:
  /// **'Change rounds'**
  String get analyticsColRounds;

  /// No description provided for @analyticsColRoundsHint.
  ///
  /// In en, this message translates to:
  /// **'Average change requests by a person per ticket that reached review'**
  String get analyticsColRoundsHint;

  /// No description provided for @analyticsColCIRounds.
  ///
  /// In en, this message translates to:
  /// **'CI rounds'**
  String get analyticsColCIRounds;

  /// No description provided for @analyticsColCIRoundsHint.
  ///
  /// In en, this message translates to:
  /// **'Average times red CI on the pull request sent the work back, per ticket that reached review (not counted in change rounds)'**
  String get analyticsColCIRoundsHint;

  /// No description provided for @analyticsColFixes.
  ///
  /// In en, this message translates to:
  /// **'Check fixes'**
  String get analyticsColFixes;

  /// No description provided for @analyticsColFixesHint.
  ///
  /// In en, this message translates to:
  /// **'Average times failing checks were sent back to Muse'**
  String get analyticsColFixesHint;

  /// No description provided for @analyticsColSerious.
  ///
  /// In en, this message translates to:
  /// **'Serious findings'**
  String get analyticsColSerious;

  /// No description provided for @analyticsColSeriousHint.
  ///
  /// In en, this message translates to:
  /// **'Share of reviewed tickets where agnts\'s review found a blocker or major problem'**
  String get analyticsColSeriousHint;

  /// No description provided for @analyticsColFootprint.
  ///
  /// In en, this message translates to:
  /// **'Plan accuracy'**
  String get analyticsColFootprint;

  /// No description provided for @analyticsColFootprintHint.
  ///
  /// In en, this message translates to:
  /// **'Share of changed files the analysis predicted'**
  String get analyticsColFootprintHint;

  /// No description provided for @analyticsColRedFlags.
  ///
  /// In en, this message translates to:
  /// **'Red flags'**
  String get analyticsColRedFlags;

  /// No description provided for @analyticsColRedFlagsHint.
  ///
  /// In en, this message translates to:
  /// **'Skipped tests, removed assertions, silenced linters and the like found in the diffs'**
  String get analyticsColRedFlagsHint;

  /// No description provided for @analyticsColSelfFixes.
  ///
  /// In en, this message translates to:
  /// **'Self-fixes'**
  String get analyticsColSelfFixes;

  /// No description provided for @analyticsColSelfFixesHint.
  ///
  /// In en, this message translates to:
  /// **'Times agnts\'s own review sent findings back to the coder before a person looked'**
  String get analyticsColSelfFixesHint;

  /// No description provided for @analyticsTabOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get analyticsTabOverview;

  /// No description provided for @analyticsTabDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get analyticsTabDelivery;

  /// No description provided for @analyticsTabQuality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get analyticsTabQuality;

  /// No description provided for @analyticsTabLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get analyticsTabLearning;

  /// No description provided for @analyticsTabCost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get analyticsTabCost;

  /// No description provided for @analyticsTabRepos.
  ///
  /// In en, this message translates to:
  /// **'Repositories'**
  String get analyticsTabRepos;

  /// No description provided for @analyticsDaysHours.
  ///
  /// In en, this message translates to:
  /// **'{d} d {h} h'**
  String analyticsDaysHours(String d, String h);

  /// No description provided for @analyticsKpiMerged.
  ///
  /// In en, this message translates to:
  /// **'Pull requests merged'**
  String get analyticsKpiMerged;

  /// No description provided for @analyticsKpiMergedNote.
  ///
  /// In en, this message translates to:
  /// **'{n} closed without merging'**
  String analyticsKpiMergedNote(String n);

  /// No description provided for @analyticsKpiCostPerTicket.
  ///
  /// In en, this message translates to:
  /// **'Cost per pushed ticket'**
  String get analyticsKpiCostPerTicket;

  /// No description provided for @analyticsKpiCostPerTicketNote.
  ///
  /// In en, this message translates to:
  /// **'At API prices, all stages'**
  String get analyticsKpiCostPerTicketNote;

  /// No description provided for @analyticsInsightMergeRate.
  ///
  /// In en, this message translates to:
  /// **'Only {pct}% of agnts\'s pull requests were merged; {closed} were closed without merging. Check the Delivery tab for why.'**
  String analyticsInsightMergeRate(String pct, String closed);

  /// No description provided for @analyticsInsightSlowAnswers.
  ///
  /// In en, this message translates to:
  /// **'Tickets wait about {hours} h for your answers to agnts\'s questions. Answering sooner is the quickest way to speed delivery up.'**
  String analyticsInsightSlowAnswers(String hours);

  /// No description provided for @analyticsInsightFollowUpsNoise.
  ///
  /// In en, this message translates to:
  /// **'Only {pct}% of suggested follow-ups were accepted. Most of them are being dismissed.'**
  String analyticsInsightFollowUpsNoise(String pct);

  /// No description provided for @analyticsInsightFlakyJob.
  ///
  /// In en, this message translates to:
  /// **'{job} in {repo} passed on re-run {n} times: it looks flaky. Fixing or quarantining it saves CI time.'**
  String analyticsInsightFlakyJob(String job, String repo, String n);

  /// No description provided for @analyticsPrMerged.
  ///
  /// In en, this message translates to:
  /// **'Merged'**
  String get analyticsPrMerged;

  /// No description provided for @analyticsPrClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed without merging'**
  String get analyticsPrClosed;

  /// No description provided for @analyticsPrOpened.
  ///
  /// In en, this message translates to:
  /// **'Opened'**
  String get analyticsPrOpened;

  /// No description provided for @analyticsPrOpen.
  ///
  /// In en, this message translates to:
  /// **'Still open'**
  String get analyticsPrOpen;

  /// No description provided for @analyticsCyclePushed.
  ///
  /// In en, this message translates to:
  /// **'Picked up → pushed'**
  String get analyticsCyclePushed;

  /// No description provided for @analyticsCycleMerged.
  ///
  /// In en, this message translates to:
  /// **'Picked up → merged'**
  String get analyticsCycleMerged;

  /// No description provided for @analyticsSplitAnswers.
  ///
  /// In en, this message translates to:
  /// **'Waiting for answers'**
  String get analyticsSplitAnswers;

  /// No description provided for @analyticsSplitReview.
  ///
  /// In en, this message translates to:
  /// **'Waiting for review'**
  String get analyticsSplitReview;

  /// No description provided for @analyticsSplitQueue.
  ///
  /// In en, this message translates to:
  /// **'Queued or paused'**
  String get analyticsSplitQueue;

  /// No description provided for @analyticsKpiMergeRate.
  ///
  /// In en, this message translates to:
  /// **'Merge rate'**
  String get analyticsKpiMergeRate;

  /// No description provided for @analyticsKpiMergeRateNote.
  ///
  /// In en, this message translates to:
  /// **'{merged} merged, {closed} closed'**
  String analyticsKpiMergeRateNote(String merged, String closed);

  /// No description provided for @analyticsKpiTimeToMerge.
  ///
  /// In en, this message translates to:
  /// **'Time to merge'**
  String get analyticsKpiTimeToMerge;

  /// No description provided for @analyticsKpiTimeToMergeNote.
  ///
  /// In en, this message translates to:
  /// **'From pull request to merge'**
  String get analyticsKpiTimeToMergeNote;

  /// No description provided for @analyticsKpiCyclePushed.
  ///
  /// In en, this message translates to:
  /// **'Picked up → pushed'**
  String get analyticsKpiCyclePushed;

  /// No description provided for @analyticsKpiCyclePushedNote.
  ///
  /// In en, this message translates to:
  /// **'agnts\'s part of the work'**
  String get analyticsKpiCyclePushedNote;

  /// No description provided for @analyticsKpiCycleMerged.
  ///
  /// In en, this message translates to:
  /// **'Picked up → merged'**
  String get analyticsKpiCycleMerged;

  /// No description provided for @analyticsKpiCycleMergedNote.
  ///
  /// In en, this message translates to:
  /// **'Real delivery time'**
  String get analyticsKpiCycleMergedNote;

  /// No description provided for @analyticsKpiAnswer.
  ///
  /// In en, this message translates to:
  /// **'Time to answer'**
  String get analyticsKpiAnswer;

  /// No description provided for @analyticsKpiAnswerNote.
  ///
  /// In en, this message translates to:
  /// **'Until you answer agnts\'s questions'**
  String get analyticsKpiAnswerNote;

  /// No description provided for @analyticsTypicalNote.
  ///
  /// In en, this message translates to:
  /// **'Times are typical values (median): half the tickets were faster, half slower.'**
  String get analyticsTypicalNote;

  /// No description provided for @analyticsPrOutcomes.
  ///
  /// In en, this message translates to:
  /// **'Pull request outcomes'**
  String get analyticsPrOutcomes;

  /// No description provided for @analyticsPrOutcomesSub.
  ///
  /// In en, this message translates to:
  /// **'agnts\'s pull requests opened in the period and what happened to them, merges and closes per day'**
  String get analyticsPrOutcomesSub;

  /// No description provided for @analyticsMergeSpread.
  ///
  /// In en, this message translates to:
  /// **'A typical pull request is merged in {p50}; the slowest one in ten takes {p90} or more.'**
  String analyticsMergeSpread(String p50, String p90);

  /// No description provided for @analyticsStale.
  ///
  /// In en, this message translates to:
  /// **'Open for over a week'**
  String get analyticsStale;

  /// No description provided for @analyticsStaleSub.
  ///
  /// In en, this message translates to:
  /// **'Pull requests nobody has merged or closed yet'**
  String get analyticsStaleSub;

  /// No description provided for @analyticsNoStale.
  ///
  /// In en, this message translates to:
  /// **'No pull request has been open for more than a week.'**
  String get analyticsNoStale;

  /// No description provided for @analyticsOpenDays.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {open {n} day} other {open {n} days}}'**
  String analyticsOpenDays(num n);

  /// No description provided for @analyticsOpenPr.
  ///
  /// In en, this message translates to:
  /// **'Open pull request'**
  String get analyticsOpenPr;

  /// No description provided for @analyticsCycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle time'**
  String get analyticsCycle;

  /// No description provided for @analyticsCycleSub.
  ///
  /// In en, this message translates to:
  /// **'Typical time from picking a ticket up to pushing and to merging, per day'**
  String get analyticsCycleSub;

  /// No description provided for @analyticsCycleSpread.
  ///
  /// In en, this message translates to:
  /// **'Pushed in {pushed} typically ({pushed90} for the slowest one in ten); merged in {merged} ({merged90}).'**
  String analyticsCycleSpread(String pushed, String pushed90, String merged, String merged90);

  /// No description provided for @analyticsQuestions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get analyticsQuestions;

  /// No description provided for @analyticsQuestionsSub.
  ///
  /// In en, this message translates to:
  /// **'What agnts asked before coding, and how fast it got answers'**
  String get analyticsQuestionsSub;

  /// No description provided for @analyticsQuestionsAsked.
  ///
  /// In en, this message translates to:
  /// **'Questions asked'**
  String get analyticsQuestionsAsked;

  /// No description provided for @analyticsQuestionsShare.
  ///
  /// In en, this message translates to:
  /// **'Tickets with questions'**
  String get analyticsQuestionsShare;

  /// No description provided for @analyticsAnswerTypical.
  ///
  /// In en, this message translates to:
  /// **'Typical time to answer'**
  String get analyticsAnswerTypical;

  /// No description provided for @analyticsAnswerSlow.
  ///
  /// In en, this message translates to:
  /// **'Slowest one in ten'**
  String get analyticsAnswerSlow;

  /// No description provided for @analyticsUnanswered.
  ///
  /// In en, this message translates to:
  /// **'Waiting for an answer now'**
  String get analyticsUnanswered;

  /// No description provided for @analyticsSlowest.
  ///
  /// In en, this message translates to:
  /// **'Slowest tickets'**
  String get analyticsSlowest;

  /// No description provided for @analyticsSlowestSub.
  ///
  /// In en, this message translates to:
  /// **'The tickets that took longest from pick-up to push in this period, and where their time went'**
  String get analyticsSlowestSub;

  /// No description provided for @analyticsNoSlowest.
  ///
  /// In en, this message translates to:
  /// **'No ticket was pushed in this period.'**
  String get analyticsNoSlowest;

  /// No description provided for @analyticsKpiCiSeen.
  ///
  /// In en, this message translates to:
  /// **'CI failures'**
  String get analyticsKpiCiSeen;

  /// No description provided for @analyticsKpiCiSeenNote.
  ///
  /// In en, this message translates to:
  /// **'{n} new in this period'**
  String analyticsKpiCiSeenNote(String n);

  /// No description provided for @analyticsKpiCiAuto.
  ///
  /// In en, this message translates to:
  /// **'Fixed by agnts'**
  String get analyticsKpiCiAuto;

  /// No description provided for @analyticsKpiCiAutoNote.
  ///
  /// In en, this message translates to:
  /// **'{auto} of {fixed} fixed failures'**
  String analyticsKpiCiAutoNote(String auto, String fixed);

  /// No description provided for @analyticsKpiCiFix.
  ///
  /// In en, this message translates to:
  /// **'Time to fix'**
  String get analyticsKpiCiFix;

  /// No description provided for @analyticsKpiCiFixNote.
  ///
  /// In en, this message translates to:
  /// **'From first failure to merged fix'**
  String get analyticsKpiCiFixNote;

  /// No description provided for @analyticsKpiCiFlaky.
  ///
  /// In en, this message translates to:
  /// **'Flaky failures'**
  String get analyticsKpiCiFlaky;

  /// No description provided for @analyticsKpiCiFlakyNote.
  ///
  /// In en, this message translates to:
  /// **'Passed when re-run'**
  String get analyticsKpiCiFlakyNote;

  /// No description provided for @analyticsKpiCiOwn.
  ///
  /// In en, this message translates to:
  /// **'Own PRs fixed'**
  String get analyticsKpiCiOwn;

  /// No description provided for @analyticsKpiCiOwnNote.
  ///
  /// In en, this message translates to:
  /// **'Red checks on agnts\'s PRs fixed before review'**
  String get analyticsKpiCiOwnNote;

  /// No description provided for @analyticsCiUnknown.
  ///
  /// In en, this message translates to:
  /// **'Not classified'**
  String get analyticsCiUnknown;

  /// No description provided for @analyticsCiNew.
  ///
  /// In en, this message translates to:
  /// **'New failures'**
  String get analyticsCiNew;

  /// No description provided for @analyticsCiFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get analyticsCiFixed;

  /// No description provided for @analyticsCiTitle.
  ///
  /// In en, this message translates to:
  /// **'CI health'**
  String get analyticsCiTitle;

  /// No description provided for @analyticsCiSub.
  ///
  /// In en, this message translates to:
  /// **'New and fixed CI failures per day. {n} need attention now.'**
  String analyticsCiSub(String n);

  /// No description provided for @analyticsCiOffSub.
  ///
  /// In en, this message translates to:
  /// **'CI watching is not set up. Turn it on for a repository and agnts triages red builds and fixes the ones caused by code.'**
  String get analyticsCiOffSub;

  /// No description provided for @analyticsCiSetUp.
  ///
  /// In en, this message translates to:
  /// **'Set up CI watching'**
  String get analyticsCiSetUp;

  /// No description provided for @analyticsCiOpen.
  ///
  /// In en, this message translates to:
  /// **'Open CI'**
  String get analyticsCiOpen;

  /// No description provided for @analyticsCiClasses.
  ///
  /// In en, this message translates to:
  /// **'Failures by cause'**
  String get analyticsCiClasses;

  /// No description provided for @analyticsCiClassesSub.
  ///
  /// In en, this message translates to:
  /// **'What triage decided each failure was'**
  String get analyticsCiClassesSub;

  /// No description provided for @analyticsCiNone.
  ///
  /// In en, this message translates to:
  /// **'No CI failures in this period.'**
  String get analyticsCiNone;

  /// No description provided for @analyticsCiFlakiest.
  ///
  /// In en, this message translates to:
  /// **'Flakiest jobs'**
  String get analyticsCiFlakiest;

  /// No description provided for @analyticsCiFlakiestSub.
  ///
  /// In en, this message translates to:
  /// **'Jobs that failed and then passed on re-run most often'**
  String get analyticsCiFlakiestSub;

  /// No description provided for @analyticsCiNoFlaky.
  ///
  /// In en, this message translates to:
  /// **'No flaky jobs in this period.'**
  String get analyticsCiNoFlaky;

  /// No description provided for @analyticsColJob.
  ///
  /// In en, this message translates to:
  /// **'Job'**
  String get analyticsColJob;

  /// No description provided for @analyticsColFailure.
  ///
  /// In en, this message translates to:
  /// **'Failure'**
  String get analyticsColFailure;

  /// No description provided for @analyticsColFlaky.
  ///
  /// In en, this message translates to:
  /// **'Passed on re-run'**
  String get analyticsColFlaky;

  /// No description provided for @analyticsColFailures.
  ///
  /// In en, this message translates to:
  /// **'Failures'**
  String get analyticsColFailures;

  /// No description provided for @analyticsKpiLessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get analyticsKpiLessons;

  /// No description provided for @analyticsKpiLessonsNote.
  ///
  /// In en, this message translates to:
  /// **'{n} marked learned'**
  String analyticsKpiLessonsNote(String n);

  /// No description provided for @analyticsKpiRulesLearned.
  ///
  /// In en, this message translates to:
  /// **'Rules learned'**
  String get analyticsKpiRulesLearned;

  /// No description provided for @analyticsKpiRulesLearnedNote.
  ///
  /// In en, this message translates to:
  /// **'In use, of {n} suggested from tickets'**
  String analyticsKpiRulesLearnedNote(String n);

  /// No description provided for @analyticsKpiRulesManual.
  ///
  /// In en, this message translates to:
  /// **'Rules written'**
  String get analyticsKpiRulesManual;

  /// No description provided for @analyticsKpiRulesManualNote.
  ///
  /// In en, this message translates to:
  /// **'Added by people'**
  String get analyticsKpiRulesManualNote;

  /// No description provided for @analyticsKpiReflections.
  ///
  /// In en, this message translates to:
  /// **'Reflections'**
  String get analyticsKpiReflections;

  /// No description provided for @analyticsKpiReflectionsNote.
  ///
  /// In en, this message translates to:
  /// **'On changed or rejected tickets; {n} rules suggested'**
  String analyticsKpiReflectionsNote(String n);

  /// No description provided for @analyticsKpiFollowUps.
  ///
  /// In en, this message translates to:
  /// **'Follow-ups accepted'**
  String get analyticsKpiFollowUps;

  /// No description provided for @analyticsKpiFollowUpsNote.
  ///
  /// In en, this message translates to:
  /// **'{n} suggested in this period'**
  String analyticsKpiFollowUpsNote(String n);

  /// No description provided for @analyticsKpiReviewerNotes.
  ///
  /// In en, this message translates to:
  /// **'Reviewer notes'**
  String get analyticsKpiReviewerNotes;

  /// No description provided for @analyticsKpiReviewerNotesNote.
  ///
  /// In en, this message translates to:
  /// **'Re-reviews, dismissed findings and notes'**
  String get analyticsKpiReviewerNotesNote;

  /// No description provided for @analyticsLearningNote.
  ///
  /// In en, this message translates to:
  /// **'How agnts learns from your feedback: fewer reviewer notes and more adopted rules over time mean it is working.'**
  String get analyticsLearningNote;

  /// No description provided for @analyticsFollowUps.
  ///
  /// In en, this message translates to:
  /// **'Follow-ups by type'**
  String get analyticsFollowUps;

  /// No description provided for @analyticsFollowUpsSub.
  ///
  /// In en, this message translates to:
  /// **'Follow-up tickets agnts suggested in this period and what you decided'**
  String get analyticsFollowUpsSub;

  /// No description provided for @analyticsNoFollowUps.
  ///
  /// In en, this message translates to:
  /// **'No follow-ups were suggested in this period.'**
  String get analyticsNoFollowUps;

  /// No description provided for @analyticsColType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get analyticsColType;

  /// No description provided for @analyticsColSuggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get analyticsColSuggested;

  /// No description provided for @analyticsColAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get analyticsColAccepted;

  /// No description provided for @analyticsColDismissed.
  ///
  /// In en, this message translates to:
  /// **'Dismissed'**
  String get analyticsColDismissed;

  /// No description provided for @analyticsColOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get analyticsColOpen;

  /// No description provided for @analyticsColAcceptRate.
  ///
  /// In en, this message translates to:
  /// **'Accept rate'**
  String get analyticsColAcceptRate;

  /// No description provided for @analyticsFollowUpSources.
  ///
  /// In en, this message translates to:
  /// **'Where follow-ups come from'**
  String get analyticsFollowUpSources;

  /// No description provided for @analyticsFollowUpSourcesSub.
  ///
  /// In en, this message translates to:
  /// **'Suggested follow-ups by the step that found them'**
  String get analyticsFollowUpSourcesSub;

  /// No description provided for @analyticsLessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons by topic'**
  String get analyticsLessons;

  /// No description provided for @analyticsLessonsSub.
  ///
  /// In en, this message translates to:
  /// **'Lessons written in this period; {n} were marked learned'**
  String analyticsLessonsSub(String n);

  /// No description provided for @analyticsOpenLearn.
  ///
  /// In en, this message translates to:
  /// **'Open Learn'**
  String get analyticsOpenLearn;

  /// No description provided for @analyticsNoLessons.
  ///
  /// In en, this message translates to:
  /// **'No lessons in this period.'**
  String get analyticsNoLessons;

  /// No description provided for @analyticsReviewers.
  ///
  /// In en, this message translates to:
  /// **'Reviewers'**
  String get analyticsReviewers;

  /// No description provided for @analyticsReviewersSub.
  ///
  /// In en, this message translates to:
  /// **'Who sends agnts the most feedback on code reviews'**
  String get analyticsReviewersSub;

  /// No description provided for @analyticsOpenRules.
  ///
  /// In en, this message translates to:
  /// **'Open Rules'**
  String get analyticsOpenRules;

  /// No description provided for @analyticsNoReviewers.
  ///
  /// In en, this message translates to:
  /// **'No reviewer notes in this period.'**
  String get analyticsNoReviewers;

  /// No description provided for @analyticsColReviewer.
  ///
  /// In en, this message translates to:
  /// **'Reviewer'**
  String get analyticsColReviewer;

  /// No description provided for @analyticsColRereview.
  ///
  /// In en, this message translates to:
  /// **'Re-reviews'**
  String get analyticsColRereview;

  /// No description provided for @analyticsColRereviewHint.
  ///
  /// In en, this message translates to:
  /// **'Times the reviewer asked agnts to review again'**
  String get analyticsColRereviewHint;

  /// No description provided for @analyticsColDismissedNotes.
  ///
  /// In en, this message translates to:
  /// **'Dismissed'**
  String get analyticsColDismissedNotes;

  /// No description provided for @analyticsColDismissedNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Findings of agnts\'s review the reviewer dismissed'**
  String get analyticsColDismissedNotesHint;

  /// No description provided for @analyticsColManual.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get analyticsColManual;

  /// No description provided for @analyticsColManualHint.
  ///
  /// In en, this message translates to:
  /// **'Notes the reviewer wrote by hand'**
  String get analyticsColManualHint;

  /// No description provided for @analyticsColRepos.
  ///
  /// In en, this message translates to:
  /// **'Repositories'**
  String get analyticsColRepos;

  /// No description provided for @analyticsKpiCostNote.
  ///
  /// In en, this message translates to:
  /// **'All Muse calls in the period'**
  String get analyticsKpiCostNote;

  /// No description provided for @analyticsKpiDaysAboveNote.
  ///
  /// In en, this message translates to:
  /// **'{n} days above 80% of the session limit'**
  String analyticsKpiDaysAboveNote(String n);

  /// No description provided for @analyticsColCost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get analyticsColCost;

  /// No description provided for @analyticsColMergeRate.
  ///
  /// In en, this message translates to:
  /// **'Merge rate'**
  String get analyticsColMergeRate;

  /// No description provided for @analyticsColMergeRateHint.
  ///
  /// In en, this message translates to:
  /// **'Pull requests merged, out of those merged or closed in the period'**
  String get analyticsColMergeRateHint;

  /// No description provided for @analyticsColQuestions.
  ///
  /// In en, this message translates to:
  /// **'Questions per ticket'**
  String get analyticsColQuestions;

  /// No description provided for @analyticsColQuestionsHint.
  ///
  /// In en, this message translates to:
  /// **'Questions agnts asked per analysed ticket. Many questions point to a missing CLAUDE.md or rules.'**
  String get analyticsColQuestionsHint;

  /// No description provided for @analyticsColCi.
  ///
  /// In en, this message translates to:
  /// **'CI failures'**
  String get analyticsColCi;

  /// No description provided for @analyticsColCiHint.
  ///
  /// In en, this message translates to:
  /// **'CI failure groups that failed in the period'**
  String get analyticsColCiHint;

  /// No description provided for @analyticsTabAssistant.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get analyticsTabAssistant;

  /// No description provided for @analyticsColScore.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get analyticsColScore;

  /// No description provided for @analyticsColScoreHint.
  ///
  /// In en, this message translates to:
  /// **'0–100: done first time 35%, merged 25%, no serious review finding 20%, few change rounds 20%. Recent versions score lower until their pull requests merge.'**
  String get analyticsColScoreHint;

  /// No description provided for @analyticsColCostMerged.
  ///
  /// In en, this message translates to:
  /// **'\$/merged'**
  String get analyticsColCostMerged;

  /// No description provided for @analyticsColCostMergedHint.
  ///
  /// In en, this message translates to:
  /// **'What all the version\'s tickets cost, over the ones that merged'**
  String get analyticsColCostMergedHint;

  /// No description provided for @analyticsFewTickets.
  ///
  /// In en, this message translates to:
  /// **'under 10 tickets: too few to compare'**
  String get analyticsFewTickets;

  /// No description provided for @analyticsColPeopleEdited.
  ///
  /// In en, this message translates to:
  /// **'People edits'**
  String get analyticsColPeopleEdited;

  /// No description provided for @analyticsColPeopleEditedHint.
  ///
  /// In en, this message translates to:
  /// **'Average share of agnts\'s lines people changed or removed before merging. Lower is better.'**
  String get analyticsColPeopleEditedHint;

  /// No description provided for @analyticsColReverted.
  ///
  /// In en, this message translates to:
  /// **'Reverted'**
  String get analyticsColReverted;

  /// No description provided for @analyticsColRevertedHint.
  ///
  /// In en, this message translates to:
  /// **'Tickets whose merged work people reverted'**
  String get analyticsColRevertedHint;

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
  /// **'Use your email or username and your password.'**
  String get authLede;

  /// No description provided for @authUsername.
  ///
  /// In en, this message translates to:
  /// **'Email or username'**
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

  /// No description provided for @authCodeLede.
  ///
  /// In en, this message translates to:
  /// **'Enter the code from your authenticator app.'**
  String get authCodeLede;

  /// No description provided for @authBack.
  ///
  /// In en, this message translates to:
  /// **'Use another account'**
  String get authBack;

  /// No description provided for @authOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get authOr;

  /// No description provided for @authGoogleRedirecting.
  ///
  /// In en, this message translates to:
  /// **'Signing you in…'**
  String get authGoogleRedirecting;

  /// No description provided for @authGoogleUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in could not load. Check your connection or ad blocker.'**
  String get authGoogleUnavailable;

  /// No description provided for @authGoogleFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in did not go through. Try again.'**
  String get authGoogleFailed;

  /// No description provided for @authGoogleClosed.
  ///
  /// In en, this message translates to:
  /// **'Sign-up is by invitation on this server: ask a workspace owner for an invite link.'**
  String get authGoogleClosed;

  /// No description provided for @authGoogleRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait a minute and try again.'**
  String get authGoogleRateLimited;

  /// No description provided for @authGoogleError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong signing you in with Google. Try again in a moment.'**
  String get authGoogleError;

  /// No description provided for @authUseGoogle.
  ///
  /// In en, this message translates to:
  /// **'Passwords are for Admins only here. Continue with Google instead.'**
  String get authUseGoogle;

  /// No description provided for @authAdminsLede.
  ///
  /// In en, this message translates to:
  /// **'Admins sign in with their password. Everyone else continues with Google.'**
  String get authAdminsLede;

  /// No description provided for @authGoogleInvite.
  ///
  /// In en, this message translates to:
  /// **'This invite link is invalid, already used, expired, or meant for another Google account.'**
  String get authGoogleInvite;

  /// No description provided for @authGoogleAdmin.
  ///
  /// In en, this message translates to:
  /// **'This is an Admin account: Admins sign in with their username and password.'**
  String get authGoogleAdmin;

  /// No description provided for @authSetupLede.
  ///
  /// In en, this message translates to:
  /// **'Admins sign in with two factors. Scan this code with an authenticator app (Google Authenticator, 1Password, Authy), then enter the 6-digit code it shows.'**
  String get authSetupLede;

  /// No description provided for @authSignOutBodyGoogle.
  ///
  /// In en, this message translates to:
  /// **'You can sign back in any time with Continue with Google.'**
  String get authSignOutBodyGoogle;

  /// No description provided for @billingTitle.
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get billingTitle;

  /// No description provided for @billingSelfHosted.
  ///
  /// In en, this message translates to:
  /// **'This server is self-hosted: there is nothing to pay. Set parallel runs below; the Admin sets member limits.'**
  String get billingSelfHosted;

  /// No description provided for @billingPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get billingPlan;

  /// No description provided for @billingPlanSub.
  ///
  /// In en, this message translates to:
  /// **'The base plan includes 1 parallel run and {members} members.'**
  String billingPlanSub(String members);

  /// No description provided for @billingMonthly.
  ///
  /// In en, this message translates to:
  /// **'{amount} a month'**
  String billingMonthly(String amount);

  /// No description provided for @billingPaidUntil.
  ///
  /// In en, this message translates to:
  /// **'Paid until {date}'**
  String billingPaidUntil(String date);

  /// No description provided for @billingTrialUntil.
  ///
  /// In en, this message translates to:
  /// **'Free trial until {date}'**
  String billingTrialUntil(String date);

  /// No description provided for @billingSlots.
  ///
  /// In en, this message translates to:
  /// **'Parallel runs'**
  String get billingSlots;

  /// No description provided for @billingSlotsHelp.
  ///
  /// In en, this message translates to:
  /// **'Each extra run at once costs {price} a month. Adding one now charges the rest of this month from credits.'**
  String billingSlotsHelp(String price);

  /// No description provided for @billingSlotsHelpSelfHosted.
  ///
  /// In en, this message translates to:
  /// **'How many runs this workspace has at once, free on this server. Up to {max}; the server\'s AGNTS_MAX_SLOTS sets the limit.'**
  String billingSlotsHelpSelfHosted(String max);

  /// No description provided for @billingSlotsSave.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get billingSlotsSave;

  /// No description provided for @billingSlotsSaved.
  ///
  /// In en, this message translates to:
  /// **'Parallel runs set to {n}'**
  String billingSlotsSaved(String n);

  /// No description provided for @billingMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get billingMembers;

  /// No description provided for @billingMembersHelp.
  ///
  /// In en, this message translates to:
  /// **'{included} included; each one more costs {price} a month.'**
  String billingMembersHelp(String included, String price);

  /// No description provided for @billingCredits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get billingCredits;

  /// No description provided for @billingCreditsSub.
  ///
  /// In en, this message translates to:
  /// **'Runs on agnts\'s API key (the fallback) spend credits: 1 credit is \$0.01 of Anthropic API cost. The month\'s plan is paid from them too.'**
  String get billingCreditsSub;

  /// No description provided for @billingBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get billingBalance;

  /// No description provided for @billingCreditPrice.
  ///
  /// In en, this message translates to:
  /// **'1 credit = {price}'**
  String billingCreditPrice(String price);

  /// No description provided for @billingBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy credits'**
  String get billingBuy;

  /// No description provided for @billingAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount (so\'m)'**
  String get billingAmount;

  /// No description provided for @billingYouGet.
  ///
  /// In en, this message translates to:
  /// **'≈ {n} credits'**
  String billingYouGet(String n);

  /// No description provided for @billingPayWith.
  ///
  /// In en, this message translates to:
  /// **'Pay with {provider}'**
  String billingPayWith(String provider);

  /// No description provided for @billingPaymentsOff.
  ///
  /// In en, this message translates to:
  /// **'Payments are not set up on this server yet; ask the Admin to grant credits.'**
  String get billingPaymentsOff;

  /// No description provided for @billingHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get billingHistory;

  /// No description provided for @billingNoHistory.
  ///
  /// In en, this message translates to:
  /// **'Nothing yet.'**
  String get billingNoHistory;

  /// No description provided for @billingReason_purchase.
  ///
  /// In en, this message translates to:
  /// **'Bought'**
  String get billingReason_purchase;

  /// No description provided for @billingReason_run.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get billingReason_run;

  /// No description provided for @billingReason_refund.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get billingReason_refund;

  /// No description provided for @billingReason_grant.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get billingReason_grant;

  /// No description provided for @billingReason_document.
  ///
  /// In en, this message translates to:
  /// **'Spent on a document'**
  String get billingReason_document;

  /// No description provided for @billingFreeCredits.
  ///
  /// In en, this message translates to:
  /// **'Your free credits'**
  String get billingFreeCredits;

  /// No description provided for @billingFreeCreditsSub.
  ///
  /// In en, this message translates to:
  /// **'From agnts. Runs on agnts\'s Muse key spend them before the workspace\'s credits.'**
  String get billingFreeCreditsSub;

  /// No description provided for @billingFreeCreditsLeft.
  ///
  /// In en, this message translates to:
  /// **'{n} of {limit} credits left'**
  String billingFreeCreditsLeft(String n, String limit);

  /// No description provided for @billingFreeCreditsWorth.
  ///
  /// In en, this message translates to:
  /// **'{amount} of {total}'**
  String billingFreeCreditsWorth(String amount, String total);

  /// No description provided for @billingFreeCreditsNone.
  ///
  /// In en, this message translates to:
  /// **'None yet. An Admin can give you free credits for runs on agnts\'s Muse key.'**
  String get billingFreeCreditsNone;

  /// No description provided for @billingLimitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your limits this month'**
  String get billingLimitsTitle;

  /// No description provided for @billingLimitsSub.
  ///
  /// In en, this message translates to:
  /// **'Set by an Admin for runs on agnts\'s Muse key. They reset on the 1st of each month.'**
  String get billingLimitsSub;

  /// No description provided for @billingMonthLimit.
  ///
  /// In en, this message translates to:
  /// **'{used} of {limit} credits used'**
  String billingMonthLimit(String used, String limit);

  /// No description provided for @briefTitle.
  ///
  /// In en, this message translates to:
  /// **'Repository brief'**
  String get briefTitle;

  /// No description provided for @briefSub.
  ///
  /// In en, this message translates to:
  /// **'How this code base works: architecture, recipes for common changes, files to copy, conventions and pitfalls. Every run of this repository\'s tickets reads it, so agnts builds things the way your team does.'**
  String get briefSub;

  /// No description provided for @briefSurvey.
  ///
  /// In en, this message translates to:
  /// **'Survey'**
  String get briefSurvey;

  /// No description provided for @briefUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get briefUpdate;

  /// No description provided for @briefEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get briefEdit;

  /// No description provided for @briefWrite.
  ///
  /// In en, this message translates to:
  /// **'Write it yourself'**
  String get briefWrite;

  /// No description provided for @briefSave.
  ///
  /// In en, this message translates to:
  /// **'Save brief'**
  String get briefSave;

  /// No description provided for @briefCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get briefCancel;

  /// No description provided for @briefEditHint.
  ///
  /// In en, this message translates to:
  /// **'Markdown. What you save is what runs read from now on; leave it empty to give runs no brief.'**
  String get briefEditHint;

  /// No description provided for @briefNone.
  ///
  /// In en, this message translates to:
  /// **'No brief yet. Survey the repository to have Muse write a draft, or write one yourself.'**
  String get briefNone;

  /// No description provided for @briefSurveying.
  ///
  /// In en, this message translates to:
  /// **'Muse is surveying the repository. The draft appears here for your approval.'**
  String get briefSurveying;

  /// No description provided for @briefFailed.
  ///
  /// In en, this message translates to:
  /// **'The last survey failed: {error}'**
  String briefFailed(String error);

  /// No description provided for @briefApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved {time}'**
  String briefApproved(String time);

  /// No description provided for @briefAtCommit.
  ///
  /// In en, this message translates to:
  /// **'at {sha}'**
  String briefAtCommit(String sha);

  /// No description provided for @briefMerges.
  ///
  /// In en, this message translates to:
  /// **'{n} of {of} merges before the next update'**
  String briefMerges(String n, String of);

  /// No description provided for @briefDraftTitle.
  ///
  /// In en, this message translates to:
  /// **'Draft from the survey'**
  String get briefDraftTitle;

  /// No description provided for @briefDraftSub.
  ///
  /// In en, this message translates to:
  /// **'Written {time}. Runs read it only after you approve it.'**
  String briefDraftSub(String time);

  /// No description provided for @briefApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get briefApprove;

  /// No description provided for @briefDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard draft'**
  String get briefDiscard;

  /// No description provided for @briefDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'The draft is deleted; the approved brief stays as it is.'**
  String get briefDiscardBody;

  /// No description provided for @briefStatus_pending.
  ///
  /// In en, this message translates to:
  /// **'Survey queued'**
  String get briefStatus_pending;

  /// No description provided for @briefStatus_surveying.
  ///
  /// In en, this message translates to:
  /// **'Surveying…'**
  String get briefStatus_surveying;

  /// No description provided for @briefDone_survey.
  ///
  /// In en, this message translates to:
  /// **'Survey queued'**
  String get briefDone_survey;

  /// No description provided for @briefDone_approve.
  ///
  /// In en, this message translates to:
  /// **'Brief approved: new runs read it'**
  String get briefDone_approve;

  /// No description provided for @briefDone_discard.
  ///
  /// In en, this message translates to:
  /// **'Draft discarded'**
  String get briefDone_discard;

  /// No description provided for @briefDone_save.
  ///
  /// In en, this message translates to:
  /// **'Brief saved'**
  String get briefDone_save;

  /// No description provided for @briefArchTitle.
  ///
  /// In en, this message translates to:
  /// **'Architecture'**
  String get briefArchTitle;

  /// No description provided for @briefArchSub.
  ///
  /// In en, this message translates to:
  /// **'The part of the brief agnts checks work against: layers and the imports each may make, shared helpers to reuse, recipes with files to copy. Runs read it as architecture.json; a change that imports across layers it should not is flagged.'**
  String get briefArchSub;

  /// No description provided for @briefArchNone.
  ///
  /// In en, this message translates to:
  /// **'No architecture yet. The next survey writes one with the brief, or write it yourself.'**
  String get briefArchNone;

  /// No description provided for @briefArchCounts.
  ///
  /// In en, this message translates to:
  /// **'{layers} layers · {helpers} helpers · {recipes} recipes'**
  String briefArchCounts(String layers, String helpers, String recipes);

  /// No description provided for @briefArchEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit JSON'**
  String get briefArchEdit;

  /// No description provided for @briefArchEditHint.
  ///
  /// In en, this message translates to:
  /// **'Empty removes it. Paths are relative to the repository; layer paths are globs (** for any depth); leave out mayImport for a layer that may import anything.'**
  String get briefArchEditHint;

  /// No description provided for @briefArchDraft.
  ///
  /// In en, this message translates to:
  /// **'The draft brief comes with this architecture; approving the brief approves it too.'**
  String get briefArchDraft;

  /// No description provided for @briefDone_saveArch.
  ///
  /// In en, this message translates to:
  /// **'Architecture saved'**
  String get briefDone_saveArch;

  /// No description provided for @ciTitle.
  ///
  /// In en, this message translates to:
  /// **'CI'**
  String get ciTitle;

  /// No description provided for @ciLede.
  ///
  /// In en, this message translates to:
  /// **'Failing pipelines on your watched branches, grouped by job and error. agnts re-runs new failures once, then fixes the real ones.'**
  String get ciLede;

  /// No description provided for @ciBack.
  ///
  /// In en, this message translates to:
  /// **'CI'**
  String get ciBack;

  /// No description provided for @ciRepo.
  ///
  /// In en, this message translates to:
  /// **'Repository'**
  String get ciRepo;

  /// No description provided for @ciAllRepos.
  ///
  /// In en, this message translates to:
  /// **'All repositories'**
  String get ciAllRepos;

  /// No description provided for @ciFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get ciFilterLabel;

  /// No description provided for @ciFilter_red.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get ciFilter_red;

  /// No description provided for @ciFilter_flaky.
  ///
  /// In en, this message translates to:
  /// **'Flaky'**
  String get ciFilter_flaky;

  /// No description provided for @ciFilter_infra.
  ///
  /// In en, this message translates to:
  /// **'Infra'**
  String get ciFilter_infra;

  /// No description provided for @ciFilter_fixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get ciFilter_fixed;

  /// No description provided for @ciFilter_muted.
  ///
  /// In en, this message translates to:
  /// **'Muted'**
  String get ciFilter_muted;

  /// No description provided for @ciFilter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get ciFilter_all;

  /// No description provided for @ciStatus_triage.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get ciStatus_triage;

  /// No description provided for @ciStatus_open.
  ///
  /// In en, this message translates to:
  /// **'Failing'**
  String get ciStatus_open;

  /// No description provided for @ciStatus_fixing.
  ///
  /// In en, this message translates to:
  /// **'Fixing'**
  String get ciStatus_fixing;

  /// No description provided for @ciStatus_fixed.
  ///
  /// In en, this message translates to:
  /// **'Fix merged'**
  String get ciStatus_fixed;

  /// No description provided for @ciStatus_resolved.
  ///
  /// In en, this message translates to:
  /// **'Green again'**
  String get ciStatus_resolved;

  /// No description provided for @ciStatus_flaky.
  ///
  /// In en, this message translates to:
  /// **'Flaky'**
  String get ciStatus_flaky;

  /// No description provided for @ciStatus_infra.
  ///
  /// In en, this message translates to:
  /// **'Infra'**
  String get ciStatus_infra;

  /// No description provided for @ciStatus_muted.
  ///
  /// In en, this message translates to:
  /// **'Muted'**
  String get ciStatus_muted;

  /// No description provided for @ciStatus_regression.
  ///
  /// In en, this message translates to:
  /// **'Regression'**
  String get ciStatus_regression;

  /// No description provided for @ciStatusHelp_triage.
  ///
  /// In en, this message translates to:
  /// **'New failure, waiting for a re-run to confirm it'**
  String get ciStatusHelp_triage;

  /// No description provided for @ciStatusHelp_open.
  ///
  /// In en, this message translates to:
  /// **'Confirmed; no ticket is working on it'**
  String get ciStatusHelp_open;

  /// No description provided for @ciStatusHelp_fixing.
  ///
  /// In en, this message translates to:
  /// **'A ticket is working on it'**
  String get ciStatusHelp_fixing;

  /// No description provided for @ciStatusHelp_fixed.
  ///
  /// In en, this message translates to:
  /// **'The fix is merged; waiting for a green run'**
  String get ciStatusHelp_fixed;

  /// No description provided for @ciStatusHelp_resolved.
  ///
  /// In en, this message translates to:
  /// **'The branch is green again'**
  String get ciStatusHelp_resolved;

  /// No description provided for @ciStatusHelp_flaky.
  ///
  /// In en, this message translates to:
  /// **'Passed when re-run'**
  String get ciStatusHelp_flaky;

  /// No description provided for @ciStatusHelp_infra.
  ///
  /// In en, this message translates to:
  /// **'The runner or the network failed, not the code'**
  String get ciStatusHelp_infra;

  /// No description provided for @ciStatusHelp_muted.
  ///
  /// In en, this message translates to:
  /// **'Ignored until unmuted'**
  String get ciStatusHelp_muted;

  /// No description provided for @ciStatusHelp_regression.
  ///
  /// In en, this message translates to:
  /// **'Failed again after the fix was merged'**
  String get ciStatusHelp_regression;

  /// No description provided for @ciClass_code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get ciClass_code;

  /// No description provided for @ciClass_test.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get ciClass_test;

  /// No description provided for @ciClass_config.
  ///
  /// In en, this message translates to:
  /// **'Config'**
  String get ciClass_config;

  /// No description provided for @ciClass_dependency.
  ///
  /// In en, this message translates to:
  /// **'Dependency'**
  String get ciClass_dependency;

  /// No description provided for @ciClass_infra.
  ///
  /// In en, this message translates to:
  /// **'Infra'**
  String get ciClass_infra;

  /// No description provided for @ciClass_flaky.
  ///
  /// In en, this message translates to:
  /// **'Flaky'**
  String get ciClass_flaky;

  /// No description provided for @ciClass_report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get ciClass_report;

  /// No description provided for @ciColStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get ciColStatus;

  /// No description provided for @ciColFailure.
  ///
  /// In en, this message translates to:
  /// **'Failure'**
  String get ciColFailure;

  /// No description provided for @ciColCount.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get ciColCount;

  /// No description provided for @ciColLastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen'**
  String get ciColLastSeen;

  /// No description provided for @ciColTicket.
  ///
  /// In en, this message translates to:
  /// **'Ticket'**
  String get ciColTicket;

  /// No description provided for @ciColTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get ciColTime;

  /// No description provided for @ciColCommit.
  ///
  /// In en, this message translates to:
  /// **'Commit'**
  String get ciColCommit;

  /// No description provided for @ciColJob.
  ///
  /// In en, this message translates to:
  /// **'Job'**
  String get ciColJob;

  /// No description provided for @ciTimes.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} time} other {{n} times}}'**
  String ciTimes(num n);

  /// No description provided for @ciFix.
  ///
  /// In en, this message translates to:
  /// **'Fix it'**
  String get ciFix;

  /// No description provided for @ciFixStarted.
  ///
  /// In en, this message translates to:
  /// **'Ticket {key} opened'**
  String ciFixStarted(String key);

  /// No description provided for @ciMute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get ciMute;

  /// No description provided for @ciUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get ciUnmute;

  /// No description provided for @ciMuted.
  ///
  /// In en, this message translates to:
  /// **'Muted: agnts ignores this failure now'**
  String get ciMuted;

  /// No description provided for @ciUnmuted.
  ///
  /// In en, this message translates to:
  /// **'Unmuted'**
  String get ciUnmuted;

  /// No description provided for @ciRerun.
  ///
  /// In en, this message translates to:
  /// **'Re-run'**
  String get ciRerun;

  /// No description provided for @ciRerunStarted.
  ///
  /// In en, this message translates to:
  /// **'Re-run started'**
  String get ciRerunStarted;

  /// No description provided for @ciCommentOnly.
  ///
  /// In en, this message translates to:
  /// **'Comment only'**
  String get ciCommentOnly;

  /// No description provided for @ciEmptyRed.
  ///
  /// In en, this message translates to:
  /// **'Nothing is red. Every watched branch passes.'**
  String get ciEmptyRed;

  /// No description provided for @ciEmptyFilter.
  ///
  /// In en, this message translates to:
  /// **'No failures here.'**
  String get ciEmptyFilter;

  /// No description provided for @ciHowTitle.
  ///
  /// In en, this message translates to:
  /// **'How to start watching'**
  String get ciHowTitle;

  /// No description provided for @ciHowWatch.
  ///
  /// In en, this message translates to:
  /// **'Open a repository, go to its CI tab and turn on watching. The default branch is always watched; add others like release/*.'**
  String get ciHowWatch;

  /// No description provided for @ciHowWebhook.
  ///
  /// In en, this message translates to:
  /// **'For news within seconds, add the git host webhook for workflow_run (GitHub) or Pipeline events (GitLab). Without it agnts checks every 5 minutes.'**
  String get ciHowWebhook;

  /// No description provided for @ciNotFound.
  ///
  /// In en, this message translates to:
  /// **'This CI failure was not found.'**
  String get ciNotFound;

  /// No description provided for @ciOpenTicket.
  ///
  /// In en, this message translates to:
  /// **'Open {key}'**
  String ciOpenTicket(String key);

  /// No description provided for @ciPrNote.
  ///
  /// In en, this message translates to:
  /// **'This failure is on someone else\'s pull request #{n}. agnts never opens a ticket or pushes there; with comments on, it posts one diagnosis comment.'**
  String ciPrNote(String n);

  /// No description provided for @ciRegressionNote.
  ///
  /// In en, this message translates to:
  /// **'This failed again on a commit that contains the fix {sha}. The original ticket gets a follow-up suggestion.'**
  String ciRegressionNote(String sha);

  /// No description provided for @ciLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get ciLogTitle;

  /// No description provided for @ciLogSub.
  ///
  /// In en, this message translates to:
  /// **'Redacted excerpt of the newest failing run'**
  String get ciLogSub;

  /// No description provided for @ciLogAnnotations.
  ///
  /// In en, this message translates to:
  /// **'Annotations'**
  String get ciLogAnnotations;

  /// No description provided for @ciLogFirstError.
  ///
  /// In en, this message translates to:
  /// **'First error'**
  String get ciLogFirstError;

  /// No description provided for @ciLogEnd.
  ///
  /// In en, this message translates to:
  /// **'End of the log'**
  String get ciLogEnd;

  /// No description provided for @ciLogTail.
  ///
  /// In en, this message translates to:
  /// **'Last lines'**
  String get ciLogTail;

  /// No description provided for @ciNoLog.
  ///
  /// In en, this message translates to:
  /// **'No log was saved for this failure.'**
  String get ciNoLog;

  /// No description provided for @ciOccurrences.
  ///
  /// In en, this message translates to:
  /// **'Failing runs'**
  String get ciOccurrences;

  /// No description provided for @ciOccurrencesSub.
  ///
  /// In en, this message translates to:
  /// **'The last 20 runs this failure appeared in'**
  String get ciOccurrencesSub;

  /// No description provided for @ciNoOccurrences.
  ///
  /// In en, this message translates to:
  /// **'No runs recorded.'**
  String get ciNoOccurrences;

  /// No description provided for @ciPassedOnRerun.
  ///
  /// In en, this message translates to:
  /// **'Passed on re-run'**
  String get ciPassedOnRerun;

  /// No description provided for @ciOpenRun.
  ///
  /// In en, this message translates to:
  /// **'Open run'**
  String get ciOpenRun;

  /// No description provided for @ciFacts.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get ciFacts;

  /// No description provided for @ciCount.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get ciCount;

  /// No description provided for @ciFlakyCount.
  ///
  /// In en, this message translates to:
  /// **'Passed on re-run'**
  String get ciFlakyCount;

  /// No description provided for @ciFirstSeen.
  ///
  /// In en, this message translates to:
  /// **'First seen'**
  String get ciFirstSeen;

  /// No description provided for @ciLastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen'**
  String get ciLastSeen;

  /// No description provided for @ciFirstSha.
  ///
  /// In en, this message translates to:
  /// **'First failing commit'**
  String get ciFirstSha;

  /// No description provided for @ciLastSha.
  ///
  /// In en, this message translates to:
  /// **'Last commit'**
  String get ciLastSha;

  /// No description provided for @ciFixedSha.
  ///
  /// In en, this message translates to:
  /// **'Fix commit'**
  String get ciFixedSha;

  /// No description provided for @ciFixedAt.
  ///
  /// In en, this message translates to:
  /// **'Fix merged'**
  String get ciFixedAt;

  /// No description provided for @ciTicket.
  ///
  /// In en, this message translates to:
  /// **'Ticket'**
  String get ciTicket;

  /// No description provided for @ciBranch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get ciBranch;

  /// No description provided for @ciWatchTitle.
  ///
  /// In en, this message translates to:
  /// **'CI watching'**
  String get ciWatchTitle;

  /// No description provided for @ciWatchSub.
  ///
  /// In en, this message translates to:
  /// **'agnts reads this repository\'s pipelines and fixes what fails'**
  String get ciWatchSub;

  /// No description provided for @ciWatchEnabled.
  ///
  /// In en, this message translates to:
  /// **'Watch CI'**
  String get ciWatchEnabled;

  /// No description provided for @ciWatchEnabledHelp.
  ///
  /// In en, this message translates to:
  /// **'Off by default. Failures on watched branches are grouped and fixed.'**
  String get ciWatchEnabledHelp;

  /// No description provided for @ciBranches.
  ///
  /// In en, this message translates to:
  /// **'Extra branches'**
  String get ciBranches;

  /// No description provided for @ciBranchesHelp.
  ///
  /// In en, this message translates to:
  /// **'Globs, one per line. The default branch ({branch}) is always watched.'**
  String ciBranchesHelp(String branch);

  /// No description provided for @ciIgnore.
  ///
  /// In en, this message translates to:
  /// **'Ignored workflows and jobs'**
  String get ciIgnore;

  /// No description provided for @ciIgnoreHelp.
  ///
  /// In en, this message translates to:
  /// **'Globs, one per line, matched against workflow and job names. Empty uses *deploy*, *release* and *publish*.'**
  String get ciIgnoreHelp;

  /// No description provided for @ciPrs.
  ///
  /// In en, this message translates to:
  /// **'Other people\'s pull requests'**
  String get ciPrs;

  /// No description provided for @ciPrsHelp.
  ///
  /// In en, this message translates to:
  /// **'agnts never pushes to a colleague\'s branch. With comments on, it posts one diagnosis comment on the pull request.'**
  String get ciPrsHelp;

  /// No description provided for @ciPrs_off.
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get ciPrs_off;

  /// No description provided for @ciPrs_comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get ciPrs_comment;

  /// No description provided for @ciAutoFix.
  ///
  /// In en, this message translates to:
  /// **'Fix automatically'**
  String get ciAutoFix;

  /// No description provided for @ciAutoFixRepoHelp.
  ///
  /// In en, this message translates to:
  /// **'Open a ticket for every confirmed failure, or wait for Fix it'**
  String get ciAutoFixRepoHelp;

  /// No description provided for @ciAutoFix_inherit.
  ///
  /// In en, this message translates to:
  /// **'Workspace setting'**
  String get ciAutoFix_inherit;

  /// No description provided for @ciAutoFix_on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get ciAutoFix_on;

  /// No description provided for @ciAutoFix_off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get ciAutoFix_off;

  /// No description provided for @ciSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get ciSave;

  /// No description provided for @ciWatchSaved.
  ///
  /// In en, this message translates to:
  /// **'CI watching saved'**
  String get ciWatchSaved;

  /// No description provided for @ciFailuresTitle.
  ///
  /// In en, this message translates to:
  /// **'Failures'**
  String get ciFailuresTitle;

  /// No description provided for @ciFailuresSub.
  ///
  /// In en, this message translates to:
  /// **'This repository\'s failing jobs, newest first'**
  String get ciFailuresSub;

  /// No description provided for @ciFlakyTitle.
  ///
  /// In en, this message translates to:
  /// **'Flaky tests'**
  String get ciFlakyTitle;

  /// No description provided for @ciFlakySub.
  ///
  /// In en, this message translates to:
  /// **'Failures that passed when re-run'**
  String get ciFlakySub;

  /// No description provided for @ciFlakyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No flaky tests found.'**
  String get ciFlakyEmpty;

  /// No description provided for @ciCardTitle.
  ///
  /// In en, this message translates to:
  /// **'CI failure'**
  String get ciCardTitle;

  /// No description provided for @ciFailingRuns.
  ///
  /// In en, this message translates to:
  /// **'Failing runs'**
  String get ciFailingRuns;

  /// No description provided for @ciLastRun.
  ///
  /// In en, this message translates to:
  /// **'Last failing run'**
  String get ciLastRun;

  /// No description provided for @ciStillFailing.
  ///
  /// In en, this message translates to:
  /// **'Still failing'**
  String get ciStillFailing;

  /// No description provided for @ciWaitingGreen.
  ///
  /// In en, this message translates to:
  /// **'Fix merged, waiting for a green run'**
  String get ciWaitingGreen;

  /// No description provided for @ciGreenAgain.
  ///
  /// In en, this message translates to:
  /// **'Green again'**
  String get ciGreenAgain;

  /// No description provided for @ciOpenFailure.
  ///
  /// In en, this message translates to:
  /// **'Open the failure'**
  String get ciOpenFailure;

  /// No description provided for @ciSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'CI'**
  String get ciSettingsTitle;

  /// No description provided for @ciSettingsSub.
  ///
  /// In en, this message translates to:
  /// **'What agnts does when a watched pipeline goes red. Watching is turned on per repository.'**
  String get ciSettingsSub;

  /// No description provided for @ciAutoFixHelp.
  ///
  /// In en, this message translates to:
  /// **'Open a ticket for every confirmed failure. Off, failures wait for Fix it.'**
  String get ciAutoFixHelp;

  /// No description provided for @ciMaxAutoPerDay.
  ///
  /// In en, this message translates to:
  /// **'Automatic tickets a day'**
  String get ciMaxAutoPerDay;

  /// No description provided for @ciMaxAutoPerDayHelp.
  ///
  /// In en, this message translates to:
  /// **'Over the limit, failures wait for Fix it. Feedback rounds on agnts\'s own pull requests don\'t count.'**
  String get ciMaxAutoPerDayHelp;

  /// No description provided for @ciPerDay.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =0 {None} one {{n} a day} other {{n} a day}}'**
  String ciPerDay(num n);

  /// No description provided for @ciRetryFlaky.
  ///
  /// In en, this message translates to:
  /// **'Re-run new failures once'**
  String get ciRetryFlaky;

  /// No description provided for @ciRetryFlakyHelp.
  ///
  /// In en, this message translates to:
  /// **'A new failure\'s jobs run again before agnts believes it. Passing marks it flaky.'**
  String get ciRetryFlakyHelp;

  /// No description provided for @ciFeedbackRounds.
  ///
  /// In en, this message translates to:
  /// **'Rounds on agnts\'s pull requests'**
  String get ciFeedbackRounds;

  /// No description provided for @ciFeedbackRoundsHelp.
  ///
  /// In en, this message translates to:
  /// **'How many times a red check sends agnts\'s own pull request back to coding. 0 turns it off.'**
  String get ciFeedbackRoundsHelp;

  /// No description provided for @ciInfraPatterns.
  ///
  /// In en, this message translates to:
  /// **'Infra patterns'**
  String get ciInfraPatterns;

  /// No description provided for @ciInfraPatternsHelp.
  ///
  /// In en, this message translates to:
  /// **'Regular expressions, one per line. A matching log is an infra failure: shown and counted, never a ticket. Added to the built-in ones.'**
  String get ciInfraPatternsHelp;

  /// No description provided for @codechatTitle.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get codechatTitle;

  /// No description provided for @codechatModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Chat mode'**
  String get codechatModeLabel;

  /// No description provided for @codechatModeChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get codechatModeChat;

  /// No description provided for @codechatModeCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get codechatModeCode;

  /// No description provided for @codechatNewConversation.
  ///
  /// In en, this message translates to:
  /// **'New Code conversation'**
  String get codechatNewConversation;

  /// No description provided for @codechatEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Change code from the chat'**
  String get codechatEmptyTitle;

  /// No description provided for @codechatEmptyText.
  ///
  /// In en, this message translates to:
  /// **'Pick the repositories and say what you want done. agnts works on it as a ticket: follow it here, answer its questions, ask for changes and approve the pull request.'**
  String get codechatEmptyText;

  /// No description provided for @codechatViewersOnly.
  ///
  /// In en, this message translates to:
  /// **'Code mode is for people who can change the workspace.'**
  String get codechatViewersOnly;

  /// No description provided for @codechatRepos.
  ///
  /// In en, this message translates to:
  /// **'Repositories'**
  String get codechatRepos;

  /// No description provided for @codechatReposNone.
  ///
  /// In en, this message translates to:
  /// **'Pick the repositories to work in, or name them in the message with @'**
  String get codechatReposNone;

  /// No description provided for @codechatReposChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get codechatReposChange;

  /// No description provided for @codechatReposSave.
  ///
  /// In en, this message translates to:
  /// **'Save repositories'**
  String get codechatReposSave;

  /// No description provided for @codechatReposSaved.
  ///
  /// In en, this message translates to:
  /// **'Repositories changed: the next ticket works in them'**
  String get codechatReposSaved;

  /// No description provided for @codechatKind.
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get codechatKind;

  /// No description provided for @codechatQuick.
  ///
  /// In en, this message translates to:
  /// **'Quick: skip checks'**
  String get codechatQuick;

  /// No description provided for @codechatQuickHint.
  ///
  /// In en, this message translates to:
  /// **'Build, lint and tests don\'t run, so review comes sooner.'**
  String get codechatQuickHint;

  /// No description provided for @codechatTicketPick.
  ///
  /// In en, this message translates to:
  /// **'Or work on an existing ticket'**
  String get codechatTicketPick;

  /// No description provided for @codechatTicketPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Ticket key, e.g. PAY-214'**
  String get codechatTicketPlaceholder;

  /// No description provided for @codechatTicketAttach.
  ///
  /// In en, this message translates to:
  /// **'Attach'**
  String get codechatTicketAttach;

  /// No description provided for @codechatTicketAttached.
  ///
  /// In en, this message translates to:
  /// **'Now working on {key}'**
  String codechatTicketAttached(String key);

  /// No description provided for @codechatPlaceholderNew.
  ///
  /// In en, this message translates to:
  /// **'Describe the change…'**
  String get codechatPlaceholderNew;

  /// No description provided for @codechatPlaceholderReview.
  ///
  /// In en, this message translates to:
  /// **'Ask for changes, or approve above…'**
  String get codechatPlaceholderReview;

  /// No description provided for @codechatPlaceholderAnswers.
  ///
  /// In en, this message translates to:
  /// **'Answer the question…'**
  String get codechatPlaceholderAnswers;

  /// No description provided for @codechatPlaceholderRunning.
  ///
  /// In en, this message translates to:
  /// **'Add to the request: it is sent when this run ends…'**
  String get codechatPlaceholderRunning;

  /// No description provided for @codechatPlaceholderStopped.
  ///
  /// In en, this message translates to:
  /// **'Say how to get past this, and it retries…'**
  String get codechatPlaceholderStopped;

  /// No description provided for @codechatPlaceholderPushing.
  ///
  /// In en, this message translates to:
  /// **'Pushing now…'**
  String get codechatPlaceholderPushing;

  /// No description provided for @codechatPlaceholderDone.
  ///
  /// In en, this message translates to:
  /// **'Ask for the next change…'**
  String get codechatPlaceholderDone;

  /// No description provided for @codechatSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get codechatSend;

  /// No description provided for @codechatSendHint.
  ///
  /// In en, this message translates to:
  /// **'Enter sends, Shift+Enter makes a new line, @ names a repository'**
  String get codechatSendHint;

  /// No description provided for @codechatCount.
  ///
  /// In en, this message translates to:
  /// **'{n} / 4000'**
  String codechatCount(String n);

  /// No description provided for @codechatRoutedCreated.
  ///
  /// In en, this message translates to:
  /// **'Started {key}'**
  String codechatRoutedCreated(String key);

  /// No description provided for @codechatRoutedAnswered.
  ///
  /// In en, this message translates to:
  /// **'Answered {key}'**
  String codechatRoutedAnswered(String key);

  /// No description provided for @codechatRoutedChanges.
  ///
  /// In en, this message translates to:
  /// **'Asked {key} for changes'**
  String codechatRoutedChanges(String key);

  /// No description provided for @codechatRoutedContinued.
  ///
  /// In en, this message translates to:
  /// **'Continued {key}'**
  String codechatRoutedContinued(String key);

  /// No description provided for @codechatRoutedRetried.
  ///
  /// In en, this message translates to:
  /// **'Retried {key}'**
  String codechatRoutedRetried(String key);

  /// No description provided for @codechatRoutedQueued.
  ///
  /// In en, this message translates to:
  /// **'Waits for {key}\'s run to end'**
  String codechatRoutedQueued(String key);

  /// No description provided for @codechatRoutedSent.
  ///
  /// In en, this message translates to:
  /// **'Sent to {key}'**
  String codechatRoutedSent(String key);

  /// No description provided for @codechatRoutedFailed.
  ///
  /// In en, this message translates to:
  /// **'Not sent: {reason}'**
  String codechatRoutedFailed(String reason);

  /// No description provided for @codechatRoutedSteered.
  ///
  /// In en, this message translates to:
  /// **'Delivered to the running agent'**
  String get codechatRoutedSteered;

  /// No description provided for @codechatQueuedTitle.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} message waits} other {{n} messages wait}} for this run to end'**
  String codechatQueuedTitle(num n);

  /// No description provided for @codechatSendNow.
  ///
  /// In en, this message translates to:
  /// **'Stop and send now'**
  String get codechatSendNow;

  /// No description provided for @codechatSendNowTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop {key} now?'**
  String codechatSendNowTitle(String key);

  /// No description provided for @codechatSendNowText.
  ///
  /// In en, this message translates to:
  /// **'The running stage stops, and your messages go to it at once.'**
  String get codechatSendNowText;

  /// No description provided for @codechatSteps.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} step} other {{n} steps}}'**
  String codechatSteps(num n);

  /// No description provided for @codechatStateLine.
  ///
  /// In en, this message translates to:
  /// **'{key}: {state}'**
  String codechatStateLine(String key, String state);

  /// No description provided for @codechatCheckPassed.
  ///
  /// In en, this message translates to:
  /// **'{name} passed'**
  String codechatCheckPassed(String name);

  /// No description provided for @codechatCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'{name} failed'**
  String codechatCheckFailed(String name);

  /// No description provided for @codechatPrOpened.
  ///
  /// In en, this message translates to:
  /// **'Pull request opened'**
  String get codechatPrOpened;

  /// No description provided for @codechatPushed.
  ///
  /// In en, this message translates to:
  /// **'Pushed'**
  String get codechatPushed;

  /// No description provided for @codechatMerged.
  ///
  /// In en, this message translates to:
  /// **'Merged'**
  String get codechatMerged;

  /// No description provided for @codechatWorking.
  ///
  /// In en, this message translates to:
  /// **'Working…'**
  String get codechatWorking;

  /// No description provided for @codechatResultTitle.
  ///
  /// In en, this message translates to:
  /// **'{key} is ready for your review'**
  String codechatResultTitle(String key);

  /// No description provided for @codechatReportTitle.
  ///
  /// In en, this message translates to:
  /// **'{key} wrote its report'**
  String codechatReportTitle(String key);

  /// No description provided for @codechatFilesChanged.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} file changed} other {{n} files changed}}'**
  String codechatFilesChanged(num n);

  /// No description provided for @codechatChecksPassed.
  ///
  /// In en, this message translates to:
  /// **'Checks passed'**
  String get codechatChecksPassed;

  /// No description provided for @codechatChecksFailed.
  ///
  /// In en, this message translates to:
  /// **'{failed} of {n} checks failed'**
  String codechatChecksFailed(String failed, String n);

  /// No description provided for @codechatChecksSkipped.
  ///
  /// In en, this message translates to:
  /// **'Checks skipped'**
  String get codechatChecksSkipped;

  /// No description provided for @codechatViewDiff.
  ///
  /// In en, this message translates to:
  /// **'View diff'**
  String get codechatViewDiff;

  /// No description provided for @codechatHideDiff.
  ///
  /// In en, this message translates to:
  /// **'Hide diff'**
  String get codechatHideDiff;

  /// No description provided for @codechatApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get codechatApprove;

  /// No description provided for @codechatApproveTitle.
  ///
  /// In en, this message translates to:
  /// **'Approve {key}?'**
  String codechatApproveTitle(String key);

  /// No description provided for @codechatApprovePr.
  ///
  /// In en, this message translates to:
  /// **'agnts pushes {branch} and opens a pull request.'**
  String codechatApprovePr(String branch);

  /// No description provided for @codechatApproveMain.
  ///
  /// In en, this message translates to:
  /// **'agnts pushes the change straight to the default branch.'**
  String get codechatApproveMain;

  /// No description provided for @codechatApproveReport.
  ///
  /// In en, this message translates to:
  /// **'The ticket closes with this report.'**
  String get codechatApproveReport;

  /// No description provided for @codechatReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get codechatReject;

  /// No description provided for @codechatRejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject {key}?'**
  String codechatRejectTitle(String key);

  /// No description provided for @codechatRejectText.
  ///
  /// In en, this message translates to:
  /// **'All work on it stops. You can continue it from this chat later.'**
  String get codechatRejectText;

  /// No description provided for @codechatOpenTicket.
  ///
  /// In en, this message translates to:
  /// **'Open ticket'**
  String get codechatOpenTicket;

  /// No description provided for @codechatQuestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'{key} asks before it goes on'**
  String codechatQuestionsTitle(String key);

  /// No description provided for @codechatAnswersSend.
  ///
  /// In en, this message translates to:
  /// **'Send answers'**
  String get codechatAnswersSend;

  /// No description provided for @codechatStoppedTitle.
  ///
  /// In en, this message translates to:
  /// **'{key} stopped'**
  String codechatStoppedTitle(String key);

  /// No description provided for @codechatStoppedHint.
  ///
  /// In en, this message translates to:
  /// **'Write how to get past it: it retries with your note.'**
  String get codechatStoppedHint;

  /// No description provided for @codechatDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'{key} is done'**
  String codechatDoneTitle(String key);

  /// No description provided for @codechatDoneHint.
  ///
  /// In en, this message translates to:
  /// **'Your next message starts a new ticket in the same repositories.'**
  String get codechatDoneHint;

  /// No description provided for @codechatRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'{key} was rejected'**
  String codechatRejectedTitle(String key);

  /// No description provided for @codechatRejectedHint.
  ///
  /// In en, this message translates to:
  /// **'Write what to do differently and it continues.'**
  String get codechatRejectedHint;

  /// No description provided for @codechatMovedHint.
  ///
  /// In en, this message translates to:
  /// **'{key} moved to another of your conversations.'**
  String codechatMovedHint(String key);

  /// No description provided for @codechatApprovalTitle.
  ///
  /// In en, this message translates to:
  /// **'The agent asks to run this'**
  String get codechatApprovalTitle;

  /// No description provided for @codechatApprovalReason.
  ///
  /// In en, this message translates to:
  /// **'A rule asks about it: {reason}'**
  String codechatApprovalReason(String reason);

  /// No description provided for @codechatApprovalAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get codechatApprovalAllow;

  /// No description provided for @codechatApprovalDeny.
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get codechatApprovalDeny;

  /// No description provided for @codechatApprovalAllowed.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get codechatApprovalAllowed;

  /// No description provided for @codechatApprovalDenied.
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get codechatApprovalDenied;

  /// No description provided for @codechatApprovalExpired.
  ///
  /// In en, this message translates to:
  /// **'Nobody answered: denied'**
  String get codechatApprovalExpired;

  /// No description provided for @codechatApprovalLeft.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s left'**
  String codechatApprovalLeft(String seconds);

  /// No description provided for @codechatHandoffTitle.
  ///
  /// In en, this message translates to:
  /// **'Do this in Code'**
  String get codechatHandoffTitle;

  /// No description provided for @codechatHandoffOpen.
  ///
  /// In en, this message translates to:
  /// **'Open in Code'**
  String get codechatHandoffOpen;

  /// No description provided for @codechatTicketChat.
  ///
  /// In en, this message translates to:
  /// **'Discussed in chat'**
  String get codechatTicketChat;

  /// No description provided for @codechatContinueInChat.
  ///
  /// In en, this message translates to:
  /// **'Continue in chat'**
  String get codechatContinueInChat;

  /// No description provided for @codechatCodeBadge.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get codechatCodeBadge;

  /// No description provided for @codechatMentioned.
  ///
  /// In en, this message translates to:
  /// **'Works in {names}'**
  String codechatMentioned(String names);

  /// No description provided for @codechatMentionLabel.
  ///
  /// In en, this message translates to:
  /// **'Repositories'**
  String get codechatMentionLabel;

  /// No description provided for @commitBack.
  ///
  /// In en, this message translates to:
  /// **'Back to commits'**
  String get commitBack;

  /// No description provided for @commitBackTo.
  ///
  /// In en, this message translates to:
  /// **'Back to {repo}'**
  String commitBackTo(String repo);

  /// No description provided for @commitAuthoredAgo.
  ///
  /// In en, this message translates to:
  /// **'{name} committed {time}'**
  String commitAuthoredAgo(String name, String time);

  /// No description provided for @commitFilesN.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} file} other {{n} files}}'**
  String commitFilesN(num n);

  /// No description provided for @commitAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get commitAuthor;

  /// No description provided for @commitAuthored.
  ///
  /// In en, this message translates to:
  /// **'Authored'**
  String get commitAuthored;

  /// No description provided for @commitCommitter.
  ///
  /// In en, this message translates to:
  /// **'Committed by'**
  String get commitCommitter;

  /// No description provided for @commitCommitted.
  ///
  /// In en, this message translates to:
  /// **'Committed'**
  String get commitCommitted;

  /// No description provided for @commitParents.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {Parent} other {Parents}}'**
  String commitParents(num n);

  /// No description provided for @commitPulls.
  ///
  /// In en, this message translates to:
  /// **'Pull requests'**
  String get commitPulls;

  /// No description provided for @commitPullsSub.
  ///
  /// In en, this message translates to:
  /// **'Pull requests (merge requests on GitLab) that contain this commit.'**
  String get commitPullsSub;

  /// No description provided for @commitNoPulls.
  ///
  /// In en, this message translates to:
  /// **'This commit is not in any pull request.'**
  String get commitNoPulls;

  /// No description provided for @commitMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get commitMessage;

  /// No description provided for @commitPipelinesSub.
  ///
  /// In en, this message translates to:
  /// **'CI runs on this commit, newest first.'**
  String get commitPipelinesSub;

  /// No description provided for @commitNoPipelines.
  ///
  /// In en, this message translates to:
  /// **'No CI runs on this commit.'**
  String get commitNoPipelines;

  /// No description provided for @commitChanges.
  ///
  /// In en, this message translates to:
  /// **'Changes'**
  String get commitChanges;

  /// No description provided for @commitChangesSub.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} file} other {{n} files}} changed, {add} additions, {del} deletions.'**
  String commitChangesSub(num n, String add, String del);

  /// No description provided for @commitNoFiles.
  ///
  /// In en, this message translates to:
  /// **'This commit changes no files.'**
  String get commitNoFiles;

  /// No description provided for @commitFilesCapped.
  ///
  /// In en, this message translates to:
  /// **'This commit changes more files than can be shown here. The first {n} are listed; open it on the git host to see all of them.'**
  String commitFilesCapped(String n);

  /// No description provided for @commonPagePrev.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get commonPagePrev;

  /// No description provided for @commonPageNext.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get commonPageNext;

  /// No description provided for @commonPageRange.
  ///
  /// In en, this message translates to:
  /// **'{from}–{to} of {n}'**
  String commonPageRange(String from, String to, String n);

  /// No description provided for @commonPerPage.
  ///
  /// In en, this message translates to:
  /// **'Per page'**
  String get commonPerPage;

  /// No description provided for @commonPager.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get commonPager;

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

  /// No description provided for @designApproach.
  ///
  /// In en, this message translates to:
  /// **'Approach'**
  String get designApproach;

  /// No description provided for @designFit.
  ///
  /// In en, this message translates to:
  /// **'Fit with the code base'**
  String get designFit;

  /// No description provided for @designAlternatives.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} alternative considered} other {{n} alternatives considered}}'**
  String designAlternatives(num n);

  /// No description provided for @designWhyNot.
  ///
  /// In en, this message translates to:
  /// **'Why not'**
  String get designWhyNot;

  /// No description provided for @designOutOfScope.
  ///
  /// In en, this message translates to:
  /// **'Out of scope'**
  String get designOutOfScope;

  /// No description provided for @designShipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get designShipping;

  /// No description provided for @designShip_migrations.
  ///
  /// In en, this message translates to:
  /// **'Migrations'**
  String get designShip_migrations;

  /// No description provided for @designShip_compatibility.
  ///
  /// In en, this message translates to:
  /// **'Compatibility'**
  String get designShip_compatibility;

  /// No description provided for @designShip_rollout.
  ///
  /// In en, this message translates to:
  /// **'Rollout'**
  String get designShip_rollout;

  /// No description provided for @designShip_rollback.
  ///
  /// In en, this message translates to:
  /// **'Rollback'**
  String get designShip_rollback;

  /// No description provided for @designDeviations.
  ///
  /// In en, this message translates to:
  /// **'Departed from the plan'**
  String get designDeviations;

  /// No description provided for @designFitTitle.
  ///
  /// In en, this message translates to:
  /// **'Following the existing code'**
  String get designFitTitle;

  /// No description provided for @designKind_copy.
  ///
  /// In en, this message translates to:
  /// **'copy'**
  String get designKind_copy;

  /// No description provided for @designKind_adapt.
  ///
  /// In en, this message translates to:
  /// **'adapt'**
  String get designKind_adapt;

  /// No description provided for @designKind_new.
  ///
  /// In en, this message translates to:
  /// **'new pattern'**
  String get designKind_new;

  /// No description provided for @designLike.
  ///
  /// In en, this message translates to:
  /// **'like'**
  String get designLike;

  /// No description provided for @designConventionsFrom.
  ///
  /// In en, this message translates to:
  /// **'conventions from'**
  String get designConventionsFrom;

  /// No description provided for @designGoesIn.
  ///
  /// In en, this message translates to:
  /// **'goes in'**
  String get designGoesIn;

  /// No description provided for @designPrecedent.
  ///
  /// In en, this message translates to:
  /// **'sets a precedent: later work will copy it'**
  String get designPrecedent;

  /// No description provided for @designReuseTitle.
  ///
  /// In en, this message translates to:
  /// **'Existing helpers to use'**
  String get designReuseTitle;

  /// No description provided for @designTestPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Tests to add or change'**
  String get designTestPlanTitle;

  /// No description provided for @designEdgeCasesTitle.
  ///
  /// In en, this message translates to:
  /// **'Edge cases to handle'**
  String get designEdgeCasesTitle;

  /// No description provided for @designReproTitle.
  ///
  /// In en, this message translates to:
  /// **'The bug, reproduced'**
  String get designReproTitle;

  /// No description provided for @designReproNot.
  ///
  /// In en, this message translates to:
  /// **'The analysis could not reproduce it'**
  String get designReproNot;

  /// No description provided for @documentsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documentsPageTitle;

  /// No description provided for @documentsLede.
  ///
  /// In en, this message translates to:
  /// **'Reports and notes for the team: written by you, or by agnts from tickets, commits, pull requests and repositories.'**
  String get documentsLede;

  /// No description provided for @documentsNew.
  ///
  /// In en, this message translates to:
  /// **'New document'**
  String get documentsNew;

  /// No description provided for @documentsNewLinked.
  ///
  /// In en, this message translates to:
  /// **'New document'**
  String get documentsNewLinked;

  /// No description provided for @documentsScope.
  ///
  /// In en, this message translates to:
  /// **'Which documents'**
  String get documentsScope;

  /// No description provided for @documentsScope_all.
  ///
  /// In en, this message translates to:
  /// **'All I can open'**
  String get documentsScope_all;

  /// No description provided for @documentsScope_mine.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get documentsScope_mine;

  /// No description provided for @documentsScope_shared.
  ///
  /// In en, this message translates to:
  /// **'Shared with me'**
  String get documentsScope_shared;

  /// No description provided for @documentsScope_deleted.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get documentsScope_deleted;

  /// No description provided for @documentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No documents yet. Create one, or ask agnts to write a report.'**
  String get documentsEmpty;

  /// No description provided for @documentsTrashEmpty.
  ///
  /// In en, this message translates to:
  /// **'The trash is empty.'**
  String get documentsTrashEmpty;

  /// No description provided for @documentsColTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get documentsColTitle;

  /// No description provided for @documentsColOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get documentsColOwner;

  /// No description provided for @documentsColTickets.
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get documentsColTickets;

  /// No description provided for @documentsColUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get documentsColUpdated;

  /// No description provided for @documentsColDeleted.
  ///
  /// In en, this message translates to:
  /// **'Restorable for'**
  String get documentsColDeleted;

  /// No description provided for @documentsDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} day left} other {{n} days left}}'**
  String documentsDaysLeft(num n);

  /// No description provided for @documentsRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get documentsRestore;

  /// No description provided for @documentsRestored.
  ///
  /// In en, this message translates to:
  /// **'Document restored'**
  String get documentsRestored;

  /// No description provided for @documentsPublic.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get documentsPublic;

  /// No description provided for @documentsPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get documentsPrivate;

  /// No description provided for @documentsWriting.
  ///
  /// In en, this message translates to:
  /// **'agnts is writing'**
  String get documentsWriting;

  /// No description provided for @documentsGenFailed.
  ///
  /// In en, this message translates to:
  /// **'Generation failed'**
  String get documentsGenFailed;

  /// No description provided for @documentsAccess_none.
  ///
  /// In en, this message translates to:
  /// **'No access'**
  String get documentsAccess_none;

  /// No description provided for @documentsAccess_view.
  ///
  /// In en, this message translates to:
  /// **'Can view'**
  String get documentsAccess_view;

  /// No description provided for @documentsAccess_edit.
  ///
  /// In en, this message translates to:
  /// **'Can edit'**
  String get documentsAccess_edit;

  /// No description provided for @documentsAccess_owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get documentsAccess_owner;

  /// No description provided for @documentsYouCan_view.
  ///
  /// In en, this message translates to:
  /// **'You can view'**
  String get documentsYouCan_view;

  /// No description provided for @documentsYouCan_edit.
  ///
  /// In en, this message translates to:
  /// **'You can edit'**
  String get documentsYouCan_edit;

  /// No description provided for @documentsRole_owner.
  ///
  /// In en, this message translates to:
  /// **'Workspace owner'**
  String get documentsRole_owner;

  /// No description provided for @documentsRole_user.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get documentsRole_user;

  /// No description provided for @documentsRole_viewer.
  ///
  /// In en, this message translates to:
  /// **'Viewer'**
  String get documentsRole_viewer;

  /// No description provided for @documentsNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New document'**
  String get documentsNewTitle;

  /// No description provided for @documentsNewSub.
  ///
  /// In en, this message translates to:
  /// **'Write it yourself, or have agnts write it from what the workspace knows.'**
  String get documentsNewSub;

  /// No description provided for @documentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get documentsTitle;

  /// No description provided for @documentsTitlePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Sprint 42 status report'**
  String get documentsTitlePlaceholder;

  /// No description provided for @documentsWhoWrites.
  ///
  /// In en, this message translates to:
  /// **'Who writes it'**
  String get documentsWhoWrites;

  /// No description provided for @documentsByAgnts.
  ///
  /// In en, this message translates to:
  /// **'agnts'**
  String get documentsByAgnts;

  /// No description provided for @documentsByMe.
  ///
  /// In en, this message translates to:
  /// **'I write it'**
  String get documentsByMe;

  /// No description provided for @documentsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get documentsLanguage;

  /// No description provided for @documentsSource.
  ///
  /// In en, this message translates to:
  /// **'Made from'**
  String get documentsSource;

  /// No description provided for @documentsKind_report.
  ///
  /// In en, this message translates to:
  /// **'A ticket’s report'**
  String get documentsKind_report;

  /// No description provided for @documentsKind_tickets.
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get documentsKind_tickets;

  /// No description provided for @documentsKind_commits.
  ///
  /// In en, this message translates to:
  /// **'Commits'**
  String get documentsKind_commits;

  /// No description provided for @documentsKind_pulls.
  ///
  /// In en, this message translates to:
  /// **'Pull requests'**
  String get documentsKind_pulls;

  /// No description provided for @documentsKind_repo.
  ///
  /// In en, this message translates to:
  /// **'Repository'**
  String get documentsKind_repo;

  /// No description provided for @documentsKindHelp_report.
  ///
  /// In en, this message translates to:
  /// **'The approved report of a plan, analysis, bug or review ticket, rewritten for its readers.'**
  String get documentsKindHelp_report;

  /// No description provided for @documentsKindHelp_tickets.
  ///
  /// In en, this message translates to:
  /// **'Chosen tickets, or tickets by state and period: their state, dates, reports and commits.'**
  String get documentsKindHelp_tickets;

  /// No description provided for @documentsKindHelp_commits.
  ///
  /// In en, this message translates to:
  /// **'Commits of repositories in a period, with the tickets they are linked to.'**
  String get documentsKindHelp_commits;

  /// No description provided for @documentsKindHelp_pulls.
  ///
  /// In en, this message translates to:
  /// **'Pull requests with their descriptions and diffs: a review digest or release notes.'**
  String get documentsKindHelp_pulls;

  /// No description provided for @documentsKindHelp_repo.
  ///
  /// In en, this message translates to:
  /// **'agnts reads the whole repository in a sandbox: architecture, quality, tests, risks.'**
  String get documentsKindHelp_repo;

  /// No description provided for @documentsTicket.
  ///
  /// In en, this message translates to:
  /// **'Ticket'**
  String get documentsTicket;

  /// No description provided for @documentsTickets.
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get documentsTickets;

  /// No description provided for @documentsTicketsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'AMANAT-12, AMANAT-15'**
  String get documentsTicketsPlaceholder;

  /// No description provided for @documentsByFilter.
  ///
  /// In en, this message translates to:
  /// **'By state and period'**
  String get documentsByFilter;

  /// No description provided for @documentsChosen.
  ///
  /// In en, this message translates to:
  /// **'Chosen tickets'**
  String get documentsChosen;

  /// No description provided for @documentsStates.
  ///
  /// In en, this message translates to:
  /// **'States'**
  String get documentsStates;

  /// No description provided for @documentsStatesHelp.
  ///
  /// In en, this message translates to:
  /// **'None ticked: every state. The period limits by last update.'**
  String get documentsStatesHelp;

  /// No description provided for @documentsRepos.
  ///
  /// In en, this message translates to:
  /// **'Repositories'**
  String get documentsRepos;

  /// No description provided for @documentsRepo.
  ///
  /// In en, this message translates to:
  /// **'Repository'**
  String get documentsRepo;

  /// No description provided for @documentsChooseRepo.
  ///
  /// In en, this message translates to:
  /// **'Choose a repository'**
  String get documentsChooseRepo;

  /// No description provided for @documentsBranch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get documentsBranch;

  /// No description provided for @documentsBranchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'The default branch'**
  String get documentsBranchPlaceholder;

  /// No description provided for @documentsAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get documentsAuthor;

  /// No description provided for @documentsAuthorPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get documentsAuthorPlaceholder;

  /// No description provided for @documentsPrState.
  ///
  /// In en, this message translates to:
  /// **'Pull requests'**
  String get documentsPrState;

  /// No description provided for @documentsPr_merged.
  ///
  /// In en, this message translates to:
  /// **'Merged'**
  String get documentsPr_merged;

  /// No description provided for @documentsPr_open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get documentsPr_open;

  /// No description provided for @documentsPr_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get documentsPr_all;

  /// No description provided for @documentsPrNumbers.
  ///
  /// In en, this message translates to:
  /// **'Numbers'**
  String get documentsPrNumbers;

  /// No description provided for @documentsPrNumbersHelp.
  ///
  /// In en, this message translates to:
  /// **'Optional, in one repository. Empty: by state and period.'**
  String get documentsPrNumbersHelp;

  /// No description provided for @documentsFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get documentsFrom;

  /// No description provided for @documentsTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get documentsTo;

  /// No description provided for @documentsTemplate.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get documentsTemplate;

  /// No description provided for @documentsTemplate_status.
  ///
  /// In en, this message translates to:
  /// **'Status report'**
  String get documentsTemplate_status;

  /// No description provided for @documentsTemplate_release_notes.
  ///
  /// In en, this message translates to:
  /// **'Release notes'**
  String get documentsTemplate_release_notes;

  /// No description provided for @documentsTemplate_pr_review.
  ///
  /// In en, this message translates to:
  /// **'Pull request review'**
  String get documentsTemplate_pr_review;

  /// No description provided for @documentsTemplate_repo_review.
  ///
  /// In en, this message translates to:
  /// **'Repository review'**
  String get documentsTemplate_repo_review;

  /// No description provided for @documentsTemplate_ticket_summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get documentsTemplate_ticket_summary;

  /// No description provided for @documentsTemplate_blank.
  ///
  /// In en, this message translates to:
  /// **'Your instruction only'**
  String get documentsTemplate_blank;

  /// No description provided for @documentsTemplateHint_status.
  ///
  /// In en, this message translates to:
  /// **'Done, in progress, blocked, risks, next steps'**
  String get documentsTemplateHint_status;

  /// No description provided for @documentsTemplateHint_release_notes.
  ///
  /// In en, this message translates to:
  /// **'New, improved, fixed, internal'**
  String get documentsTemplateHint_release_notes;

  /// No description provided for @documentsTemplateHint_pr_review.
  ///
  /// In en, this message translates to:
  /// **'Each change, its risk, what to look at'**
  String get documentsTemplateHint_pr_review;

  /// No description provided for @documentsTemplateHint_repo_review.
  ///
  /// In en, this message translates to:
  /// **'Architecture, quality, tests, debt, recommendations'**
  String get documentsTemplateHint_repo_review;

  /// No description provided for @documentsTemplateHint_ticket_summary.
  ///
  /// In en, this message translates to:
  /// **'Goal, findings, changes, open questions'**
  String get documentsTemplateHint_ticket_summary;

  /// No description provided for @documentsTemplateHint_blank.
  ///
  /// In en, this message translates to:
  /// **'The shape your instruction asks for'**
  String get documentsTemplateHint_blank;

  /// No description provided for @documentsInstruction.
  ///
  /// In en, this message translates to:
  /// **'Instruction'**
  String get documentsInstruction;

  /// No description provided for @documentsInstructionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'For the client, no technical detail. Focus on risks.'**
  String get documentsInstructionPlaceholder;

  /// No description provided for @documentsGenerate.
  ///
  /// In en, this message translates to:
  /// **'Ask agnts to write it'**
  String get documentsGenerate;

  /// No description provided for @documentsCreate.
  ///
  /// In en, this message translates to:
  /// **'Create and edit'**
  String get documentsCreate;

  /// No description provided for @documentsBack.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documentsBack;

  /// No description provided for @documentsNotFound.
  ///
  /// In en, this message translates to:
  /// **'This document does not exist, or you cannot open it.'**
  String get documentsNotFound;

  /// No description provided for @documentsEditing.
  ///
  /// In en, this message translates to:
  /// **'Editing'**
  String get documentsEditing;

  /// No description provided for @documentsVersionN.
  ///
  /// In en, this message translates to:
  /// **'Version {n}'**
  String documentsVersionN(String n);

  /// No description provided for @documentsOwnedBy.
  ///
  /// In en, this message translates to:
  /// **'Owner: {name}'**
  String documentsOwnedBy(String name);

  /// No description provided for @documentsDataAsOf.
  ///
  /// In en, this message translates to:
  /// **'Based on data up to {when}'**
  String documentsDataAsOf(String when);

  /// No description provided for @documentsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get documentsEdit;

  /// No description provided for @documentsRegenerate.
  ///
  /// In en, this message translates to:
  /// **'Write again'**
  String get documentsRegenerate;

  /// No description provided for @documentsRegenerateSub.
  ///
  /// In en, this message translates to:
  /// **'agnts writes it again from the same source. The result is a new version; nothing is lost.'**
  String get documentsRegenerateSub;

  /// No description provided for @documentsShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get documentsShare;

  /// No description provided for @documentsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get documentsDelete;

  /// No description provided for @documentsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Move “{title}” to the trash? It can be restored for 30 days.'**
  String documentsDeleteConfirm(String title);

  /// No description provided for @documentsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Moved to the trash'**
  String get documentsDeleted;

  /// No description provided for @documentsQueued.
  ///
  /// In en, this message translates to:
  /// **'Waiting for agnts to start writing…'**
  String get documentsQueued;

  /// No description provided for @documentsWritingNow.
  ///
  /// In en, this message translates to:
  /// **'agnts is writing this document. It appears here when it is done.'**
  String get documentsWritingNow;

  /// No description provided for @documentsGenFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'agnts could not write it:'**
  String get documentsGenFailedTitle;

  /// No description provided for @documentsTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get documentsTryAgain;

  /// No description provided for @documentsOverwrote.
  ///
  /// In en, this message translates to:
  /// **'agnts wrote a new version over edits by {name} from {when}.'**
  String documentsOverwrote(String name, String when);

  /// No description provided for @documentsRestoreVersion.
  ///
  /// In en, this message translates to:
  /// **'Restore version {n}'**
  String documentsRestoreVersion(String n);

  /// No description provided for @documentsMarkdown.
  ///
  /// In en, this message translates to:
  /// **'Markdown'**
  String get documentsMarkdown;

  /// No description provided for @documentsPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get documentsPreview;

  /// No description provided for @documentsConflictTitle.
  ///
  /// In en, this message translates to:
  /// **'Someone saved in between.'**
  String get documentsConflictTitle;

  /// No description provided for @documentsConflictHelp.
  ///
  /// In en, this message translates to:
  /// **'The document is at version {n} now. Keep your text on top of it, or start again from theirs.'**
  String documentsConflictHelp(String n);

  /// No description provided for @documentsTheirText.
  ///
  /// In en, this message translates to:
  /// **'Their text'**
  String get documentsTheirText;

  /// No description provided for @documentsKeepMine.
  ///
  /// In en, this message translates to:
  /// **'Keep mine'**
  String get documentsKeepMine;

  /// No description provided for @documentsTakeTheirs.
  ///
  /// In en, this message translates to:
  /// **'Use theirs'**
  String get documentsTakeTheirs;

  /// No description provided for @documentsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get documentsSave;

  /// No description provided for @documentsSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved as a new version'**
  String get documentsSaved;

  /// No description provided for @documentsLeaveUnsaved.
  ///
  /// In en, this message translates to:
  /// **'Leave without saving your edits?'**
  String get documentsLeaveUnsaved;

  /// No description provided for @documentsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing written yet.'**
  String get documentsEmptyBody;

  /// No description provided for @documentsPublicLink.
  ///
  /// In en, this message translates to:
  /// **'Public link'**
  String get documentsPublicLink;

  /// No description provided for @documentsDownloadMd.
  ///
  /// In en, this message translates to:
  /// **'Markdown'**
  String get documentsDownloadMd;

  /// No description provided for @documentsDownloadPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get documentsDownloadPdf;

  /// No description provided for @documentsPreparingPdf.
  ///
  /// In en, this message translates to:
  /// **'Preparing PDF…'**
  String get documentsPreparingPdf;

  /// No description provided for @documentsPdfFailed.
  ///
  /// In en, this message translates to:
  /// **'The PDF could not be made. Try again in a few minutes, or download Markdown.'**
  String get documentsPdfFailed;

  /// No description provided for @documentsPdfSlow.
  ///
  /// In en, this message translates to:
  /// **'The PDF is taking long. Try again in a minute.'**
  String get documentsPdfSlow;

  /// No description provided for @documentsLinkedTickets.
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get documentsLinkedTickets;

  /// No description provided for @documentsLinkedTicketsSub.
  ///
  /// In en, this message translates to:
  /// **'Tickets this document is about'**
  String get documentsLinkedTicketsSub;

  /// No description provided for @documentsNoTickets.
  ///
  /// In en, this message translates to:
  /// **'Not linked to any ticket.'**
  String get documentsNoTickets;

  /// No description provided for @documentsLinkedByAgnts.
  ///
  /// In en, this message translates to:
  /// **'linked by agnts'**
  String get documentsLinkedByAgnts;

  /// No description provided for @documentsLinkedByAgntsHint.
  ///
  /// In en, this message translates to:
  /// **'agnts linked the tickets the document was made from'**
  String get documentsLinkedByAgntsHint;

  /// No description provided for @documentsUnlink.
  ///
  /// In en, this message translates to:
  /// **'Unlink'**
  String get documentsUnlink;

  /// No description provided for @documentsLinkTicket.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get documentsLinkTicket;

  /// No description provided for @documentsLinkPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Ticket number'**
  String get documentsLinkPlaceholder;

  /// No description provided for @documentsBadKey.
  ///
  /// In en, this message translates to:
  /// **'That is not a ticket number.'**
  String get documentsBadKey;

  /// No description provided for @documentsVersions.
  ///
  /// In en, this message translates to:
  /// **'Versions'**
  String get documentsVersions;

  /// No description provided for @documentsNoVersions.
  ///
  /// In en, this message translates to:
  /// **'No versions yet.'**
  String get documentsNoVersions;

  /// No description provided for @documentsCurrent.
  ///
  /// In en, this message translates to:
  /// **'current'**
  String get documentsCurrent;

  /// No description provided for @documentsByAgntsFor.
  ///
  /// In en, this message translates to:
  /// **'agnts, for {name}'**
  String documentsByAgntsFor(String name);

  /// No description provided for @documentsRestoredBy.
  ///
  /// In en, this message translates to:
  /// **'{name} restored it'**
  String documentsRestoredBy(String name);

  /// No description provided for @documentsVersionTitle.
  ///
  /// In en, this message translates to:
  /// **'Version {n}'**
  String documentsVersionTitle(String n);

  /// No description provided for @documentsIsCurrent.
  ///
  /// In en, this message translates to:
  /// **'This is the current version.'**
  String get documentsIsCurrent;

  /// No description provided for @documentsDiffHelp.
  ///
  /// In en, this message translates to:
  /// **'What changed from version {n} to the current text: removed lines are struck through, added ones green.'**
  String documentsDiffHelp(String n);

  /// No description provided for @documentsSameText.
  ///
  /// In en, this message translates to:
  /// **'The text is the same as now.'**
  String get documentsSameText;

  /// No description provided for @documentsShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get documentsShareTitle;

  /// No description provided for @documentsType.
  ///
  /// In en, this message translates to:
  /// **'Who can read it'**
  String get documentsType;

  /// No description provided for @documentsPrivateHelp.
  ///
  /// In en, this message translates to:
  /// **'Only you, the people below and the workspace owner.'**
  String get documentsPrivateHelp;

  /// No description provided for @documentsPublicHelp.
  ///
  /// In en, this message translates to:
  /// **'Anyone with the link can read and download it, without signing in. It shows no names or tickets.'**
  String get documentsPublicHelp;

  /// No description provided for @documentsPublicOff.
  ///
  /// In en, this message translates to:
  /// **'Public documents are turned off in this workspace’s Settings.'**
  String get documentsPublicOff;

  /// No description provided for @documentsSecretsTitle.
  ///
  /// In en, this message translates to:
  /// **'This text looks like it holds secrets.'**
  String get documentsSecretsTitle;

  /// No description provided for @documentsSecretsHelp.
  ///
  /// In en, this message translates to:
  /// **'Remove them from these lines, save, then make the document public.'**
  String get documentsSecretsHelp;

  /// No description provided for @documentsLine.
  ///
  /// In en, this message translates to:
  /// **'Line {n}'**
  String documentsLine(String n);

  /// No description provided for @documentsResetLink.
  ///
  /// In en, this message translates to:
  /// **'Reset the link'**
  String get documentsResetLink;

  /// No description provided for @documentsResetHelp.
  ///
  /// In en, this message translates to:
  /// **'The old link stops working at once.'**
  String get documentsResetHelp;

  /// No description provided for @documentsWorkspaceAccess.
  ///
  /// In en, this message translates to:
  /// **'Everyone in the workspace'**
  String get documentsWorkspaceAccess;

  /// No description provided for @documentsWorkspaceAccessHelp.
  ///
  /// In en, this message translates to:
  /// **'At least this for every member. Viewers can only read.'**
  String get documentsWorkspaceAccessHelp;

  /// No description provided for @documentsPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get documentsPeople;

  /// No description provided for @documentsAddPerson.
  ///
  /// In en, this message translates to:
  /// **'Add a person'**
  String get documentsAddPerson;

  /// No description provided for @documentsRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get documentsRemove;

  /// No description provided for @documentsOwnerNote.
  ///
  /// In en, this message translates to:
  /// **'The workspace owner can always open this document.'**
  String get documentsOwnerNote;

  /// No description provided for @documentsSaveSharing.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get documentsSaveSharing;

  /// No description provided for @documentsTransfer.
  ///
  /// In en, this message translates to:
  /// **'Give to another member'**
  String get documentsTransfer;

  /// No description provided for @documentsTransferTo.
  ///
  /// In en, this message translates to:
  /// **'New owner'**
  String get documentsTransferTo;

  /// No description provided for @documentsTransferConfirm.
  ///
  /// In en, this message translates to:
  /// **'Make {name} the owner? You keep edit access.'**
  String documentsTransferConfirm(String name);

  /// No description provided for @documentsTicketTitle.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documentsTicketTitle;

  /// No description provided for @documentsTicketSub.
  ///
  /// In en, this message translates to:
  /// **'Documents about this ticket that you can open'**
  String get documentsTicketSub;

  /// No description provided for @documentsTicketEmpty.
  ///
  /// In en, this message translates to:
  /// **'No documents yet.'**
  String get documentsTicketEmpty;

  /// No description provided for @documentsFromReport.
  ///
  /// In en, this message translates to:
  /// **'Make a document from the report'**
  String get documentsFromReport;

  /// No description provided for @documentsPublicGoneTitle.
  ///
  /// In en, this message translates to:
  /// **'This link does not work'**
  String get documentsPublicGoneTitle;

  /// No description provided for @documentsPublicGone.
  ///
  /// In en, this message translates to:
  /// **'The document was made private or deleted, or its link was changed.'**
  String get documentsPublicGone;

  /// No description provided for @documentsPublicUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated {when}'**
  String documentsPublicUpdated(String when);

  /// No description provided for @documentsSettingLabel.
  ///
  /// In en, this message translates to:
  /// **'Public documents'**
  String get documentsSettingLabel;

  /// No description provided for @documentsSettingHelp.
  ///
  /// In en, this message translates to:
  /// **'Let document owners share a public link that anyone can open. Off: every public link of this workspace stops working at once.'**
  String get documentsSettingHelp;

  /// No description provided for @documentsNewForTicket.
  ///
  /// In en, this message translates to:
  /// **'Linked to {number}. Write it yourself, or have agnts write it.'**
  String documentsNewForTicket(String number);

  /// No description provided for @documentsDocKind.
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get documentsDocKind;

  /// No description provided for @documentsDocKind_page.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get documentsDocKind_page;

  /// No description provided for @documentsDocKind_slides.
  ///
  /// In en, this message translates to:
  /// **'Slides'**
  String get documentsDocKind_slides;

  /// No description provided for @documentsDocKindHelp_page.
  ///
  /// In en, this message translates to:
  /// **'A document to read: detailed, for the team.'**
  String get documentsDocKindHelp_page;

  /// No description provided for @documentsDocKindHelp_slides.
  ///
  /// In en, this message translates to:
  /// **'A deck to present: short, for clients and people outside the team.'**
  String get documentsDocKindHelp_slides;

  /// No description provided for @documentsKindFilter_all.
  ///
  /// In en, this message translates to:
  /// **'Pages and slides'**
  String get documentsKindFilter_all;

  /// No description provided for @documentsKindFilter_page.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get documentsKindFilter_page;

  /// No description provided for @documentsKindFilter_slides.
  ///
  /// In en, this message translates to:
  /// **'Slides'**
  String get documentsKindFilter_slides;

  /// No description provided for @documentsKind_document.
  ///
  /// In en, this message translates to:
  /// **'A document'**
  String get documentsKind_document;

  /// No description provided for @documentsKindHelp_document.
  ///
  /// In en, this message translates to:
  /// **'A page of this workspace, retold as slides. The slides are a separate document with their own sharing.'**
  String get documentsKindHelp_document;

  /// No description provided for @documentsSourceDocument.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get documentsSourceDocument;

  /// No description provided for @documentsChooseDocument.
  ///
  /// In en, this message translates to:
  /// **'Choose a document'**
  String get documentsChooseDocument;

  /// No description provided for @documentsTemplate_presentation.
  ///
  /// In en, this message translates to:
  /// **'Presentation'**
  String get documentsTemplate_presentation;

  /// No description provided for @documentsTemplateHint_presentation.
  ///
  /// In en, this message translates to:
  /// **'Key points, what they mean, next steps'**
  String get documentsTemplateHint_presentation;

  /// No description provided for @documentsMakeSlides.
  ///
  /// In en, this message translates to:
  /// **'Make slides'**
  String get documentsMakeSlides;

  /// No description provided for @documentsSlidesOf.
  ///
  /// In en, this message translates to:
  /// **'{title} — slides'**
  String documentsSlidesOf(String title);

  /// No description provided for @documentsSlidesSub.
  ///
  /// In en, this message translates to:
  /// **'agnts retells this document as slides, in a new document you share on its own.'**
  String get documentsSlidesSub;

  /// No description provided for @documentsMadeFrom.
  ///
  /// In en, this message translates to:
  /// **'Made from'**
  String get documentsMadeFrom;

  /// No description provided for @documentsSourceChanged.
  ///
  /// In en, this message translates to:
  /// **'The document has changed since (now version {n}).'**
  String documentsSourceChanged(String n);

  /// No description provided for @documentsDecksTitle.
  ///
  /// In en, this message translates to:
  /// **'Slides made from this document'**
  String get documentsDecksTitle;

  /// No description provided for @documentsSlidesHelp.
  ///
  /// In en, this message translates to:
  /// **'A line with only --- starts a new slide. A line starting with Notes: begins the speaker notes of its slide.'**
  String get documentsSlidesHelp;

  /// No description provided for @documentsNoSlides.
  ///
  /// In en, this message translates to:
  /// **'No slides yet. Separate slides with a line of ---.'**
  String get documentsNoSlides;

  /// No description provided for @documentsPresent.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get documentsPresent;

  /// No description provided for @documentsPresentFrom.
  ///
  /// In en, this message translates to:
  /// **'Present from slide {n}'**
  String documentsPresentFrom(String n);

  /// No description provided for @documentsStopPresenting.
  ///
  /// In en, this message translates to:
  /// **'Stop presenting'**
  String get documentsStopPresenting;

  /// No description provided for @documentsPrevSlide.
  ///
  /// In en, this message translates to:
  /// **'Previous slide'**
  String get documentsPrevSlide;

  /// No description provided for @documentsNextSlide.
  ///
  /// In en, this message translates to:
  /// **'Next slide'**
  String get documentsNextSlide;

  /// No description provided for @documentsNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get documentsNotes;

  /// No description provided for @documentsNoNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes for this slide.'**
  String get documentsNoNotes;

  /// No description provided for @documentsStarterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What it is about, and when'**
  String get documentsStarterSubtitle;

  /// No description provided for @documentsStarterPoint.
  ///
  /// In en, this message translates to:
  /// **'The first point'**
  String get documentsStarterPoint;

  /// No description provided for @documentsComments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get documentsComments;

  /// No description provided for @documentsAddComment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get documentsAddComment;

  /// No description provided for @documentsCommentPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Add a comment…'**
  String get documentsCommentPlaceholder;

  /// No description provided for @documentsReplyPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Reply…'**
  String get documentsReplyPlaceholder;

  /// No description provided for @documentsPost.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get documentsPost;

  /// No description provided for @documentsNoComments.
  ///
  /// In en, this message translates to:
  /// **'No comments yet.'**
  String get documentsNoComments;

  /// No description provided for @documentsNoCommentsHint.
  ///
  /// In en, this message translates to:
  /// **'Select text to comment on it.'**
  String get documentsNoCommentsHint;

  /// No description provided for @documentsGuestsCanRead.
  ///
  /// In en, this message translates to:
  /// **'This document is public: guests with the link read comments.'**
  String get documentsGuestsCanRead;

  /// No description provided for @documentsSlideN.
  ///
  /// In en, this message translates to:
  /// **'Slide {n}'**
  String documentsSlideN(String n);

  /// No description provided for @documentsTextChanged.
  ///
  /// In en, this message translates to:
  /// **'The text it was on has changed.'**
  String get documentsTextChanged;

  /// No description provided for @documentsEdited.
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get documentsEdited;

  /// No description provided for @documentsResolve.
  ///
  /// In en, this message translates to:
  /// **'Resolve'**
  String get documentsResolve;

  /// No description provided for @documentsResolveHelp.
  ///
  /// In en, this message translates to:
  /// **'Mark as done: the thread is folded away'**
  String get documentsResolveHelp;

  /// No description provided for @documentsReopen.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get documentsReopen;

  /// No description provided for @documentsResolvedN.
  ///
  /// In en, this message translates to:
  /// **'Resolved ({n})'**
  String documentsResolvedN(String n);

  /// No description provided for @documentsResolvedBy.
  ///
  /// In en, this message translates to:
  /// **'Resolved by {name}'**
  String documentsResolvedBy(String name);

  /// No description provided for @documentsRepliesN.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} reply} other {{n} replies}}'**
  String documentsRepliesN(num n);

  /// No description provided for @documentsDeleteThreadConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this comment and its replies?'**
  String get documentsDeleteThreadConfirm;

  /// No description provided for @documentsDeleteCommentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this reply?'**
  String get documentsDeleteCommentConfirm;

  /// No description provided for @documentsViewingNow.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} viewing now} other {{n} viewing now}}'**
  String documentsViewingNow(num n);

  /// No description provided for @documentsYou.
  ///
  /// In en, this message translates to:
  /// **'you'**
  String get documentsYou;

  /// No description provided for @documentsGuest.
  ///
  /// In en, this message translates to:
  /// **'guest'**
  String get documentsGuest;

  /// No description provided for @documentsViaGoogle.
  ///
  /// In en, this message translates to:
  /// **'guest via Google'**
  String get documentsViaGoogle;

  /// No description provided for @documentsWhoAreYou.
  ///
  /// In en, this message translates to:
  /// **'Who are you?'**
  String get documentsWhoAreYou;

  /// No description provided for @documentsWhoAreYouSub.
  ///
  /// In en, this message translates to:
  /// **'Your name is shown to the people working on this document, next to your comments and while you have it open.'**
  String get documentsWhoAreYouSub;

  /// No description provided for @documentsYourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get documentsYourName;

  /// No description provided for @documentsYourNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Name and company'**
  String get documentsYourNamePlaceholder;

  /// No description provided for @documentsEnter.
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get documentsEnter;

  /// No description provided for @documentsOrGoogle.
  ///
  /// In en, this message translates to:
  /// **'Or, if you prefer, show who you are with Google:'**
  String get documentsOrGoogle;

  /// No description provided for @documentsViaAccount.
  ///
  /// In en, this message translates to:
  /// **'signed in'**
  String get documentsViaAccount;

  /// No description provided for @documentsTranslate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get documentsTranslate;

  /// No description provided for @documentsTranslateOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original language'**
  String get documentsTranslateOriginal;

  /// No description provided for @documentsTranslating.
  ///
  /// In en, this message translates to:
  /// **'Translating… the first time takes up to a minute for a long document; after that it is saved.'**
  String get documentsTranslating;

  /// No description provided for @documentsTranslateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not translate: {error}'**
  String documentsTranslateFailed(String error);

  /// No description provided for @documentsTranslatedNoComments.
  ///
  /// In en, this message translates to:
  /// **'You are reading a translation. Switch to the original to comment.'**
  String get documentsTranslatedNoComments;

  /// No description provided for @documentsShowOriginal.
  ///
  /// In en, this message translates to:
  /// **'Show original'**
  String get documentsShowOriginal;

  /// No description provided for @documentsTranslatedIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Some parts are still in the original language.'**
  String get documentsTranslatedIncomplete;

  /// No description provided for @draftsTitle.
  ///
  /// In en, this message translates to:
  /// **'Review comments'**
  String get draftsTitle;

  /// No description provided for @draftsSub.
  ///
  /// In en, this message translates to:
  /// **'agnts\'s comments stay here until you accept them. Only accepted ones are published on {host}, together as one review; the rest never leave agnts.'**
  String draftsSub(String host);

  /// No description provided for @draftsLockedSub.
  ///
  /// In en, this message translates to:
  /// **'The review is over or the pull request is closed: these comments can only be read.'**
  String get draftsLockedSub;

  /// No description provided for @draftsChip.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draftsChip;

  /// No description provided for @draftsSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get draftsSummary;

  /// No description provided for @draftsSomeone.
  ///
  /// In en, this message translates to:
  /// **'Someone'**
  String get draftsSomeone;

  /// No description provided for @draftsEdited.
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get draftsEdited;

  /// No description provided for @draftsState_draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draftsState_draft;

  /// No description provided for @draftsState_accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get draftsState_accepted;

  /// No description provided for @draftsState_publishing.
  ///
  /// In en, this message translates to:
  /// **'Publishing'**
  String get draftsState_publishing;

  /// No description provided for @draftsState_dismissed.
  ///
  /// In en, this message translates to:
  /// **'Dismissed'**
  String get draftsState_dismissed;

  /// No description provided for @draftsState_published.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get draftsState_published;

  /// No description provided for @draftsState_outdated.
  ///
  /// In en, this message translates to:
  /// **'Outdated'**
  String get draftsState_outdated;

  /// No description provided for @draftsKind_summary.
  ///
  /// In en, this message translates to:
  /// **'summary'**
  String get draftsKind_summary;

  /// No description provided for @draftsKind_finding.
  ///
  /// In en, this message translates to:
  /// **'finding'**
  String get draftsKind_finding;

  /// No description provided for @draftsKind_comment.
  ///
  /// In en, this message translates to:
  /// **'comment'**
  String get draftsKind_comment;

  /// No description provided for @draftsAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get draftsAccept;

  /// No description provided for @draftsUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get draftsUndo;

  /// No description provided for @draftsDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get draftsDismiss;

  /// No description provided for @draftsReopen.
  ///
  /// In en, this message translates to:
  /// **'Back to draft'**
  String get draftsReopen;

  /// No description provided for @draftsReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Why? (optional: agnts learns what you call noise)'**
  String get draftsReasonLabel;

  /// No description provided for @draftsReasonHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. we never bound caches in this service'**
  String get draftsReasonHint;

  /// No description provided for @draftsDismissedBecause.
  ///
  /// In en, this message translates to:
  /// **'Dismissed: {reason}'**
  String draftsDismissedBecause(String reason);

  /// No description provided for @draftsOutdatedHint.
  ///
  /// In en, this message translates to:
  /// **'agnts\'s newest review no longer finds this.'**
  String get draftsOutdatedHint;

  /// No description provided for @draftsFailed.
  ///
  /// In en, this message translates to:
  /// **'Publishing failed: {error}'**
  String draftsFailed(String error);

  /// No description provided for @draftsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your comment?'**
  String get draftsDeleteTitle;

  /// No description provided for @draftsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'It was never published; it is deleted from agnts.'**
  String get draftsDeleteConfirm;

  /// No description provided for @draftsNAccepted.
  ///
  /// In en, this message translates to:
  /// **'{n} accepted'**
  String draftsNAccepted(String n);

  /// No description provided for @draftsNDraft.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} draft} other {{n} drafts}}'**
  String draftsNDraft(num n);

  /// No description provided for @draftsNDismissed.
  ///
  /// In en, this message translates to:
  /// **'{n} dismissed'**
  String draftsNDismissed(String n);

  /// No description provided for @draftsNPublished.
  ///
  /// In en, this message translates to:
  /// **'{n} published'**
  String draftsNPublished(String n);

  /// No description provided for @draftsNOutdated.
  ///
  /// In en, this message translates to:
  /// **'{n} outdated'**
  String draftsNOutdated(String n);

  /// No description provided for @draftsAcceptMajor.
  ///
  /// In en, this message translates to:
  /// **'Accept major and above'**
  String get draftsAcceptMajor;

  /// No description provided for @draftsAcceptAll.
  ///
  /// In en, this message translates to:
  /// **'Accept all'**
  String get draftsAcceptAll;

  /// No description provided for @draftsPublishBtn.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =0 {Publish} other {Publish {n}}} to {host}'**
  String draftsPublishBtn(num n, String host);

  /// No description provided for @draftsPublishTitle.
  ///
  /// In en, this message translates to:
  /// **'Publish to {host}'**
  String draftsPublishTitle(String host);

  /// No description provided for @draftsPublishSub.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {This comment goes} other {These {n} comments go}} on the pull request as one review, as the {host} token\'s user. Comments not on a changed line go in the review\'s text.'**
  String draftsPublishSub(num n, String host);

  /// No description provided for @draftsPublishedToast.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} comment published} other {{n} comments published}} on {host}'**
  String draftsPublishedToast(num n, String host);

  /// No description provided for @draftsHeadMoved.
  ///
  /// In en, this message translates to:
  /// **'New commits since agnts reviewed it ({from}, now {to}): the comments go on the version agnts reviewed, and {host} may show them as outdated. To put them on the newest lines, review it again first.'**
  String draftsHeadMoved(String from, String to, String host);

  /// No description provided for @draftsShowClosed.
  ///
  /// In en, this message translates to:
  /// **'Show dismissed, outdated and published ({n})'**
  String draftsShowClosed(String n);

  /// No description provided for @draftsDraftsN.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} draft} other {{n} drafts}}'**
  String draftsDraftsN(num n);

  /// No description provided for @draftsNotOnDiff.
  ///
  /// In en, this message translates to:
  /// **'agnts\'s comments not on a line shown here (another version, or outside the diff):'**
  String get draftsNotOnDiff;

  /// No description provided for @draftsAddToReview.
  ///
  /// In en, this message translates to:
  /// **'Add to review'**
  String get draftsAddToReview;

  /// No description provided for @draftsAddedToast.
  ///
  /// In en, this message translates to:
  /// **'Added to the review: it is published with the accepted comments'**
  String get draftsAddedToast;

  /// No description provided for @draftsOnDiff.
  ///
  /// In en, this message translates to:
  /// **'See them on the diff'**
  String get draftsOnDiff;

  /// No description provided for @draftsReviewWithBtn.
  ///
  /// In en, this message translates to:
  /// **'Review with agnts'**
  String get draftsReviewWithBtn;

  /// No description provided for @draftsReviewAgainBtn.
  ///
  /// In en, this message translates to:
  /// **'Review again with agnts'**
  String get draftsReviewAgainBtn;

  /// No description provided for @draftsReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review #{number} with agnts'**
  String draftsReviewTitle(String number);

  /// No description provided for @draftsReviewSub.
  ///
  /// In en, this message translates to:
  /// **'agnts reviews the pull request as it is now. Its comments stay drafts in agnts until you accept them; only accepted ones go on the pull request. Approving the review merges it only when it is assigned to you or asks for your review.'**
  String get draftsReviewSub;

  /// No description provided for @draftsReviewBtn.
  ///
  /// In en, this message translates to:
  /// **'Start the review'**
  String get draftsReviewBtn;

  /// No description provided for @draftsFocusLabel.
  ///
  /// In en, this message translates to:
  /// **'Anything to look at especially? (optional)'**
  String get draftsFocusLabel;

  /// No description provided for @draftsFocusHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. the migration and the retry logic'**
  String get draftsFocusHint;

  /// No description provided for @draftsDeepLabel.
  ///
  /// In en, this message translates to:
  /// **'Deep review (security, failures, tests and types passes)'**
  String get draftsDeepLabel;

  /// No description provided for @draftsDeep_default.
  ///
  /// In en, this message translates to:
  /// **'Workspace setting'**
  String get draftsDeep_default;

  /// No description provided for @draftsDeep_always.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get draftsDeep_always;

  /// No description provided for @draftsDeep_off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get draftsDeep_off;

  /// No description provided for @draftsStartedToast.
  ///
  /// In en, this message translates to:
  /// **'agnts is reviewing it in {key}'**
  String draftsStartedToast(String key);

  /// No description provided for @draftsReviewingNow.
  ///
  /// In en, this message translates to:
  /// **'agnts is reviewing this pull request ({key}). Its comments appear here as drafts when it is done.'**
  String draftsReviewingNow(String key);

  /// No description provided for @draftsFinishBtn.
  ///
  /// In en, this message translates to:
  /// **'Finish review'**
  String get draftsFinishBtn;

  /// No description provided for @draftsFinishConfirm.
  ///
  /// In en, this message translates to:
  /// **'Finish the review of #{number}? Comments not published stay in agnts. The pull request is left as it is: agnts does not merge it.'**
  String draftsFinishConfirm(String number);

  /// No description provided for @draftsReadySub.
  ///
  /// In en, this message translates to:
  /// **'Go through agnts\'s comments, publish the ones you agree with on {host}, then finish the review. Or review again with a note, or dismiss it.'**
  String draftsReadySub(String host);

  /// No description provided for @draftsFinishedTitle.
  ///
  /// In en, this message translates to:
  /// **'Review finished'**
  String get draftsFinishedTitle;

  /// No description provided for @draftsFinishedSub.
  ///
  /// In en, this message translates to:
  /// **'The review of #{number} is finished. The pull request was left as it is.'**
  String draftsFinishedSub(String number);

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get feedbackTitle;

  /// No description provided for @feedbackLede.
  ///
  /// In en, this message translates to:
  /// **'Tell the agnts team what works, what doesn’t, or what you’d like next.'**
  String get feedbackLede;

  /// No description provided for @feedbackTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get feedbackTitleLabel;

  /// No description provided for @feedbackTitlePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'In a few words'**
  String get feedbackTitlePlaceholder;

  /// No description provided for @feedbackDescLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get feedbackDescLabel;

  /// No description provided for @feedbackDescPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'What happened, what you expected, or your idea'**
  String get feedbackDescPlaceholder;

  /// No description provided for @feedbackSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get feedbackSend;

  /// No description provided for @feedbackSent.
  ///
  /// In en, this message translates to:
  /// **'Thanks! Your feedback was sent.'**
  String get feedbackSent;

  /// No description provided for @feedbackAdminTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackAdminTitle;

  /// No description provided for @feedbackAdminLede.
  ///
  /// In en, this message translates to:
  /// **'What people sent from their accounts, and connector requests from the website, newest first. Mark each one done once it’s handled.'**
  String get feedbackAdminLede;

  /// No description provided for @feedbackF_new.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get feedbackF_new;

  /// No description provided for @feedbackF_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get feedbackF_done;

  /// No description provided for @feedbackF_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get feedbackF_all;

  /// No description provided for @feedbackS_new.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get feedbackS_new;

  /// No description provided for @feedbackS_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get feedbackS_done;

  /// No description provided for @feedbackSearch.
  ///
  /// In en, this message translates to:
  /// **'Search feedback, people or workspaces'**
  String get feedbackSearch;

  /// No description provided for @feedbackNone.
  ///
  /// In en, this message translates to:
  /// **'No feedback here.'**
  String get feedbackNone;

  /// No description provided for @feedbackNoneNew.
  ///
  /// In en, this message translates to:
  /// **'No new feedback. Nice!'**
  String get feedbackNoneNew;

  /// No description provided for @feedbackFrom.
  ///
  /// In en, this message translates to:
  /// **'from {workspace}'**
  String feedbackFrom(String workspace);

  /// No description provided for @feedbackAccountGone.
  ///
  /// In en, this message translates to:
  /// **'account deleted'**
  String get feedbackAccountGone;

  /// No description provided for @feedbackMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get feedbackMarkDone;

  /// No description provided for @feedbackReopen.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get feedbackReopen;

  /// No description provided for @feedbackMarkedDone.
  ///
  /// In en, this message translates to:
  /// **'Marked done'**
  String get feedbackMarkedDone;

  /// No description provided for @feedbackReopened.
  ///
  /// In en, this message translates to:
  /// **'Marked new again'**
  String get feedbackReopened;

  /// No description provided for @feedbackKind.
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get feedbackKind;

  /// No description provided for @feedbackK_any.
  ///
  /// In en, this message translates to:
  /// **'Everything'**
  String get feedbackK_any;

  /// No description provided for @feedbackK_feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackK_feedback;

  /// No description provided for @feedbackK_connector.
  ///
  /// In en, this message translates to:
  /// **'Connector requests'**
  String get feedbackK_connector;

  /// No description provided for @feedbackConnectorBadge.
  ///
  /// In en, this message translates to:
  /// **'Connector request'**
  String get feedbackConnectorBadge;

  /// No description provided for @feedbackFromSite.
  ///
  /// In en, this message translates to:
  /// **'from the website'**
  String get feedbackFromSite;

  /// No description provided for @filesTitle.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get filesTitle;

  /// No description provided for @filesAttach.
  ///
  /// In en, this message translates to:
  /// **'Attach files'**
  String get filesAttach;

  /// No description provided for @filesAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get filesAddPhoto;

  /// No description provided for @filesCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get filesCamera;

  /// No description provided for @filesAddFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get filesAddFile;

  /// No description provided for @filesHint.
  ///
  /// In en, this message translates to:
  /// **'Pictures, PDFs, logs or text, up to 10 MB each. Muse reads them all.'**
  String get filesHint;

  /// No description provided for @filesUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading {name}…'**
  String filesUploading(String name);

  /// No description provided for @filesRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String filesRemove(String name);

  /// No description provided for @filesOpen.
  ///
  /// In en, this message translates to:
  /// **'Open {name}'**
  String filesOpen(String name);

  /// No description provided for @filesTooLarge.
  ///
  /// In en, this message translates to:
  /// **'{name} is larger than 10 MB'**
  String filesTooLarge(String name);

  /// No description provided for @filesTooMany.
  ///
  /// In en, this message translates to:
  /// **'Attach at most {n} files'**
  String filesTooMany(String n);

  /// No description provided for @filesFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not upload {name}'**
  String filesFailed(String name);

  /// No description provided for @filesWait.
  ///
  /// In en, this message translates to:
  /// **'Wait for the uploads to finish'**
  String get filesWait;

  /// No description provided for @filesFromTask.
  ///
  /// In en, this message translates to:
  /// **'With the task'**
  String get filesFromTask;

  /// No description provided for @filesFromRetry.
  ///
  /// In en, this message translates to:
  /// **'With a retry'**
  String get filesFromRetry;

  /// No description provided for @filesFromFeedback.
  ///
  /// In en, this message translates to:
  /// **'With requested changes'**
  String get filesFromFeedback;

  /// No description provided for @followUpsTitle.
  ///
  /// In en, this message translates to:
  /// **'Follow-up tickets'**
  String get followUpsTitle;

  /// No description provided for @followUpsSub.
  ///
  /// In en, this message translates to:
  /// **'What finishing this ticket still needs, as agnts sees it. Pick the ones you want, then start them now or keep them held until you start each one.'**
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

  /// No description provided for @followUpsAfter.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get followUpsAfter;

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

  /// No description provided for @followUpsCreateStart.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {Create and start} one {Create and start {count} ticket} other {Create and start {count} tickets}}'**
  String followUpsCreateStart(num count);

  /// No description provided for @followUpsCreateHeld.
  ///
  /// In en, this message translates to:
  /// **'Create, held'**
  String get followUpsCreateHeld;

  /// No description provided for @followUpsQueuedHint.
  ///
  /// In en, this message translates to:
  /// **'Started tickets go to the queue now; one that must wait for another starts coding after that one is merged. Held ones wait until you start them.'**
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

  /// No description provided for @followUpsStartedNotice.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {{count} ticket created} other {{count} tickets created}} and queued to run.'**
  String followUpsStartedNotice(num count);

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

  /// No description provided for @followUpsTargetPlane.
  ///
  /// In en, this message translates to:
  /// **'Plane work item'**
  String get followUpsTargetPlane;

  /// No description provided for @followUpsPlaneOff.
  ///
  /// In en, this message translates to:
  /// **'Connect Plane and link the repository to a Plane project to file work items there'**
  String get followUpsPlaneOff;

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

  /// No description provided for @groupsView.
  ///
  /// In en, this message translates to:
  /// **'Groups ({n})'**
  String groupsView(String n);

  /// No description provided for @groupsSub.
  ///
  /// In en, this message translates to:
  /// **'Repositories that change together. A ticket made from a group works in all of them and opens a pull request in each one it changes.'**
  String get groupsSub;

  /// No description provided for @groupsNone.
  ///
  /// In en, this message translates to:
  /// **'No groups yet. A group lets one ticket change several repositories, such as an API and its web app.'**
  String get groupsNone;

  /// No description provided for @groupsAdd.
  ///
  /// In en, this message translates to:
  /// **'New group'**
  String get groupsAdd;

  /// No description provided for @groupsDrawerSub.
  ///
  /// In en, this message translates to:
  /// **'Repositories that change together, in order: the first is the primary repository of the group\'s tickets.'**
  String get groupsDrawerSub;

  /// No description provided for @groupsName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get groupsName;

  /// No description provided for @groupsNamePh.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get groupsNamePh;

  /// No description provided for @groupsDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get groupsDescription;

  /// No description provided for @groupsMembers.
  ///
  /// In en, this message translates to:
  /// **'Repositories'**
  String get groupsMembers;

  /// No description provided for @groupsMembersHelp.
  ///
  /// In en, this message translates to:
  /// **'Order matters: the first is the primary repository. A role tells agnts what each one is, such as backend or web.'**
  String get groupsMembersHelp;

  /// No description provided for @groupsMembersNeeded.
  ///
  /// In en, this message translates to:
  /// **'Add at least one repository.'**
  String get groupsMembersNeeded;

  /// No description provided for @groupsNoMembers.
  ///
  /// In en, this message translates to:
  /// **'No repositories yet.'**
  String get groupsNoMembers;

  /// No description provided for @groupsAddMember.
  ///
  /// In en, this message translates to:
  /// **'Add a repository…'**
  String get groupsAddMember;

  /// No description provided for @groupsNoMoreRepos.
  ///
  /// In en, this message translates to:
  /// **'Every active repository is in the group'**
  String get groupsNoMoreRepos;

  /// No description provided for @groupsRolePh.
  ///
  /// In en, this message translates to:
  /// **'Role, e.g. backend'**
  String get groupsRolePh;

  /// No description provided for @groupsRoleOf.
  ///
  /// In en, this message translates to:
  /// **'Role of {name}'**
  String groupsRoleOf(String name);

  /// No description provided for @groupsMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move {name} up'**
  String groupsMoveUp(String name);

  /// No description provided for @groupsMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move {name} down'**
  String groupsMoveDown(String name);

  /// No description provided for @groupsPrimary.
  ///
  /// In en, this message translates to:
  /// **'primary'**
  String get groupsPrimary;

  /// No description provided for @groupsArchived.
  ///
  /// In en, this message translates to:
  /// **'archived'**
  String get groupsArchived;

  /// No description provided for @groupsPrefixHelp.
  ///
  /// In en, this message translates to:
  /// **'Key prefix of tasks made from the group, as {prefix}-12. Empty uses the first repository\'s.'**
  String groupsPrefixHelp(String prefix);

  /// No description provided for @groupsBranchTemplateHelp.
  ///
  /// In en, this message translates to:
  /// **'Names the branches of this group\'s tickets in every repository, so they all get the same name. It replaces each repository\'s own format. Must contain {key} or {number}. Leave empty to keep each repository\'s own.'**
  String groupsBranchTemplateHelp(String key, String number);

  /// No description provided for @groupsCommitTemplateHelp.
  ///
  /// In en, this message translates to:
  /// **'Writes the commit messages of this group\'s tickets in every repository, replacing each repository\'s own format. Leave empty to keep each repository\'s own.'**
  String get groupsCommitTemplateHelp;

  /// No description provided for @groupsInstructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get groupsInstructions;

  /// No description provided for @groupsInstructionsPh.
  ///
  /// In en, this message translates to:
  /// **'The web app calls the API through src/api; change both together and keep the OpenAPI spec in sync.'**
  String get groupsInstructionsPh;

  /// No description provided for @groupsInstructionsHelp.
  ///
  /// In en, this message translates to:
  /// **'How the repositories fit together, in Markdown. Added to every prompt of the group\'s tickets.'**
  String get groupsInstructionsHelp;

  /// No description provided for @groupsWarningsTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved, with warnings:'**
  String get groupsWarningsTitle;

  /// No description provided for @groupsWarningsBadge.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {{count} warning} other {{count} warnings}}'**
  String groupsWarningsBadge(num count);

  /// No description provided for @groupsSaved.
  ///
  /// In en, this message translates to:
  /// **'Group {name} saved'**
  String groupsSaved(String name);

  /// No description provided for @groupsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get groupsDelete;

  /// No description provided for @groupsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete the group {name}? Its tickets keep their repositories.'**
  String groupsDeleteConfirm(String name);

  /// No description provided for @groupsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Group {name} deleted'**
  String groupsDeleted(String name);

  /// No description provided for @groupsColGroup.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get groupsColGroup;

  /// No description provided for @groupsColMembers.
  ///
  /// In en, this message translates to:
  /// **'Repositories'**
  String get groupsColMembers;

  /// No description provided for @groupsColPrefix.
  ///
  /// In en, this message translates to:
  /// **'Prefix'**
  String get groupsColPrefix;

  /// No description provided for @groupsInGroups.
  ///
  /// In en, this message translates to:
  /// **'In {names}'**
  String groupsInGroups(String names);

  /// No description provided for @groupsInLabel.
  ///
  /// In en, this message translates to:
  /// **'Groups:'**
  String get groupsInLabel;

  /// No description provided for @groupsPickerGroups.
  ///
  /// In en, this message translates to:
  /// **'Repository groups'**
  String get groupsPickerGroups;

  /// No description provided for @groupsChosen.
  ///
  /// In en, this message translates to:
  /// **'Chosen repositories'**
  String get groupsChosen;

  /// No description provided for @groupsFromGroup.
  ///
  /// In en, this message translates to:
  /// **'From group {name}'**
  String groupsFromGroup(String name);

  /// No description provided for @groupsMakePrimary.
  ///
  /// In en, this message translates to:
  /// **'Make it the primary repository'**
  String get groupsMakePrimary;

  /// No description provided for @groupsMore.
  ///
  /// In en, this message translates to:
  /// **'+{count}'**
  String groupsMore(String count);

  /// No description provided for @groupsAllGroups.
  ///
  /// In en, this message translates to:
  /// **'All groups'**
  String get groupsAllGroups;

  /// No description provided for @groupsFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get groupsFilterLabel;

  /// No description provided for @groupsKvRepos.
  ///
  /// In en, this message translates to:
  /// **'Repositories'**
  String get groupsKvRepos;

  /// No description provided for @groupsKvGroup.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get groupsKvGroup;

  /// No description provided for @groupsTicketRepos.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {{count} repository} other {{count} repositories}}'**
  String groupsTicketRepos(num count);

  /// No description provided for @groupsPartlyMerged.
  ///
  /// In en, this message translates to:
  /// **'Partly merged'**
  String get groupsPartlyMerged;

  /// No description provided for @groupsPr.
  ///
  /// In en, this message translates to:
  /// **'PR #{number}'**
  String groupsPr(String number);

  /// No description provided for @groupsOpenPrIn.
  ///
  /// In en, this message translates to:
  /// **'Open {repo} #{number}'**
  String groupsOpenPrIn(String repo, String number);

  /// No description provided for @groupsFiles.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {{count} file} other {{count} files}}'**
  String groupsFiles(num count);

  /// No description provided for @groupsFilesIn.
  ///
  /// In en, this message translates to:
  /// **'{repo} · {count, plural, one {{count} file} other {{count} files}}'**
  String groupsFilesIn(String repo, num count);

  /// No description provided for @groupsPushError.
  ///
  /// In en, this message translates to:
  /// **'Push failed: {error}'**
  String groupsPushError(String error);

  /// No description provided for @groupsRetryHint.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {A retry pushes the {count} repository that failed; the others stay as they are.} other {A retry pushes the {count} repositories that failed; the others stay as they are.}}'**
  String groupsRetryHint(num count);

  /// No description provided for @groupsState_pending.
  ///
  /// In en, this message translates to:
  /// **'Not pushed'**
  String get groupsState_pending;

  /// No description provided for @groupsState_unchanged.
  ///
  /// In en, this message translates to:
  /// **'Unchanged'**
  String get groupsState_unchanged;

  /// No description provided for @groupsState_pushed.
  ///
  /// In en, this message translates to:
  /// **'Pushed'**
  String get groupsState_pushed;

  /// No description provided for @groupsState_merged.
  ///
  /// In en, this message translates to:
  /// **'Merged'**
  String get groupsState_merged;

  /// No description provided for @groupsState_dropped.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get groupsState_dropped;

  /// No description provided for @groupsMaxTicketRepos.
  ///
  /// In en, this message translates to:
  /// **'Maximum repositories per ticket'**
  String get groupsMaxTicketRepos;

  /// No description provided for @groupsMaxTicketReposHelp.
  ///
  /// In en, this message translates to:
  /// **'How many repositories one ticket, and one repository group, may have.'**
  String get groupsMaxTicketReposHelp;

  /// No description provided for @harnessRepoTab.
  ///
  /// In en, this message translates to:
  /// **'Guardrails'**
  String get harnessRepoTab;

  /// No description provided for @harnessRepoTitle.
  ///
  /// In en, this message translates to:
  /// **'Guardrails'**
  String get harnessRepoTitle;

  /// No description provided for @harnessRepoSub.
  ///
  /// In en, this message translates to:
  /// **'How strictly agnts-guard checks Muse\'s work in this repository, while it works and after.'**
  String get harnessRepoSub;

  /// No description provided for @harnessRepoSave.
  ///
  /// In en, this message translates to:
  /// **'Save guardrails'**
  String get harnessRepoSave;

  /// No description provided for @harnessRepoSaved.
  ///
  /// In en, this message translates to:
  /// **'Guardrails saved'**
  String get harnessRepoSaved;

  /// No description provided for @harnessRepoAgentTitle.
  ///
  /// In en, this message translates to:
  /// **'Agent instruction files'**
  String get harnessRepoAgentTitle;

  /// No description provided for @harnessRepoAgentSub.
  ///
  /// In en, this message translates to:
  /// **'agnts scans CLAUDE.md, AGENTS.md, .claude/ and .mcp.json for text that tries to steer an agent. It never runs this repository\'s hooks or MCP servers.'**
  String get harnessRepoAgentSub;

  /// No description provided for @harnessRepoAgentScanned.
  ///
  /// In en, this message translates to:
  /// **'Scanned {time}'**
  String harnessRepoAgentScanned(String time);

  /// No description provided for @harnessRepoAgentNotScanned.
  ///
  /// In en, this message translates to:
  /// **'Not scanned yet: the next run in this repository scans the files.'**
  String get harnessRepoAgentNotScanned;

  /// No description provided for @harnessRepoAgentNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing found.'**
  String get harnessRepoAgentNothing;

  /// No description provided for @harnessRepoAgentWarn.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} line} other {{n} lines}} may try to steer an agent. Runs treat these files as data, never as instructions; read them before you trust them.'**
  String harnessRepoAgentWarn(num n);

  /// No description provided for @harnessRepoAgentInfo.
  ///
  /// In en, this message translates to:
  /// **'Configuration agnts ignores'**
  String get harnessRepoAgentInfo;

  /// No description provided for @harnessRepoKind_hidden_unicode.
  ///
  /// In en, this message translates to:
  /// **'Hidden characters'**
  String get harnessRepoKind_hidden_unicode;

  /// No description provided for @harnessRepoKind_agent_instruction.
  ///
  /// In en, this message translates to:
  /// **'Instruction to an agent'**
  String get harnessRepoKind_agent_instruction;

  /// No description provided for @harnessRepoKind_exfiltration.
  ///
  /// In en, this message translates to:
  /// **'Sends data out'**
  String get harnessRepoKind_exfiltration;

  /// No description provided for @harnessRepoKind_encoded_blob.
  ///
  /// In en, this message translates to:
  /// **'Encoded text'**
  String get harnessRepoKind_encoded_blob;

  /// No description provided for @harnessRepoKind_hooks.
  ///
  /// In en, this message translates to:
  /// **'Muse hooks'**
  String get harnessRepoKind_hooks;

  /// No description provided for @harnessRepoKind_mcp_server.
  ///
  /// In en, this message translates to:
  /// **'MCP servers'**
  String get harnessRepoKind_mcp_server;

  /// No description provided for @harnessRepoProfile.
  ///
  /// In en, this message translates to:
  /// **'Guard profile'**
  String get harnessRepoProfile;

  /// No description provided for @harnessRepoProfileHelp.
  ///
  /// In en, this message translates to:
  /// **'How strict the in-run checks are for this repository.'**
  String get harnessRepoProfileHelp;

  /// No description provided for @harnessRepoProfile_.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get harnessRepoProfile_;

  /// No description provided for @harnessRepoProfile_minimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get harnessRepoProfile_minimal;

  /// No description provided for @harnessRepoProfile_standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get harnessRepoProfile_standard;

  /// No description provided for @harnessRepoProfile_strict.
  ///
  /// In en, this message translates to:
  /// **'Strict'**
  String get harnessRepoProfile_strict;

  /// No description provided for @harnessRepoProfileHelp_.
  ///
  /// In en, this message translates to:
  /// **'Follows the workspace setting.'**
  String get harnessRepoProfileHelp_;

  /// No description provided for @harnessRepoProfileHelp_minimal.
  ///
  /// In en, this message translates to:
  /// **'Only secrets and enforced rules are blocked; build checked before Muse finishes.'**
  String get harnessRepoProfileHelp_minimal;

  /// No description provided for @harnessRepoProfileHelp_standard.
  ///
  /// In en, this message translates to:
  /// **'Also blocks skipped tests, silenced linters and edits to check configuration; build and lint must pass before Muse finishes.'**
  String get harnessRepoProfileHelp_standard;

  /// No description provided for @harnessRepoProfileHelp_strict.
  ///
  /// In en, this message translates to:
  /// **'Also blocks swallowed errors and removed assertions, runs the tests before Muse finishes, and may ask for facts before editing a file.'**
  String get harnessRepoProfileHelp_strict;

  /// No description provided for @harnessRepoSecretAllow.
  ///
  /// In en, this message translates to:
  /// **'Example credentials allowed in'**
  String get harnessRepoSecretAllow;

  /// No description provided for @harnessRepoSecretAllowHelp.
  ///
  /// In en, this message translates to:
  /// **'Path globs where fake keys are expected, besides testdata/, fixtures/ and *.example.'**
  String get harnessRepoSecretAllowHelp;

  /// No description provided for @harnessRepoChecksTitle.
  ///
  /// In en, this message translates to:
  /// **'Per-file checks'**
  String get harnessRepoChecksTitle;

  /// No description provided for @harnessRepoChecksSub.
  ///
  /// In en, this message translates to:
  /// **'Quick formatters and linters agnts-guard runs on each file Muse edits, so problems are fixed while the change is fresh.'**
  String get harnessRepoChecksSub;

  /// No description provided for @harnessRepoChecksOff.
  ///
  /// In en, this message translates to:
  /// **'Turn per-file checks off'**
  String get harnessRepoChecksOff;

  /// No description provided for @harnessRepoChecksOffHelp.
  ///
  /// In en, this message translates to:
  /// **'Muse is not checked after each edit; the checks after the run still apply.'**
  String get harnessRepoChecksOffHelp;

  /// No description provided for @harnessRepoOwnChecks.
  ///
  /// In en, this message translates to:
  /// **'Use my own checks'**
  String get harnessRepoOwnChecks;

  /// No description provided for @harnessRepoOwnChecksHelp.
  ///
  /// In en, this message translates to:
  /// **'Replace the checks agnts derives from the toolchains with your list.'**
  String get harnessRepoOwnChecksHelp;

  /// No description provided for @harnessRepoDerivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Derived from the toolchains'**
  String get harnessRepoDerivedTitle;

  /// No description provided for @harnessRepoDerivedNone.
  ///
  /// In en, this message translates to:
  /// **'agnts knows no per-file checks for this repository\'s toolchains.'**
  String get harnessRepoDerivedNone;

  /// No description provided for @harnessRepoCheckName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get harnessRepoCheckName;

  /// No description provided for @harnessRepoCheckGlobs.
  ///
  /// In en, this message translates to:
  /// **'Files (globs, comma-separated)'**
  String get harnessRepoCheckGlobs;

  /// No description provided for @harnessRepoCheckCmd.
  ///
  /// In en, this message translates to:
  /// **'Command'**
  String get harnessRepoCheckCmd;

  /// No description provided for @harnessRepoCheckCmdHelp.
  ///
  /// In en, this message translates to:
  /// **'\'{file}\' is the edited file and \'{dir}\' its directory, both relative to the repository.'**
  String harnessRepoCheckCmdHelp(String file, String dir);

  /// No description provided for @harnessRepoCheckEvery.
  ///
  /// In en, this message translates to:
  /// **'At most every (seconds)'**
  String get harnessRepoCheckEvery;

  /// No description provided for @harnessRepoAddCheck.
  ///
  /// In en, this message translates to:
  /// **'Add a check'**
  String get harnessRepoAddCheck;

  /// No description provided for @harnessRepoRemoveCheck.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String harnessRepoRemoveCheck(String name);

  /// No description provided for @harnessRepoCoverageTitle.
  ///
  /// In en, this message translates to:
  /// **'Coverage of changed lines'**
  String get harnessRepoCoverageTitle;

  /// No description provided for @harnessRepoCoverageSub.
  ///
  /// In en, this message translates to:
  /// **'After the checks pass, agnts runs the tests once more with coverage and shows which added lines no test ran.'**
  String get harnessRepoCoverageSub;

  /// No description provided for @harnessRepoCoverage.
  ///
  /// In en, this message translates to:
  /// **'Measure coverage'**
  String get harnessRepoCoverage;

  /// No description provided for @harnessRepoCoverageHelp.
  ///
  /// In en, this message translates to:
  /// **'An extra test run after the checks; it never fails the run.'**
  String get harnessRepoCoverageHelp;

  /// No description provided for @harnessRepoThreshold.
  ///
  /// In en, this message translates to:
  /// **'Threshold'**
  String get harnessRepoThreshold;

  /// No description provided for @harnessRepoThresholdHelp.
  ///
  /// In en, this message translates to:
  /// **'Below it, the code review gets a coverage finding. 0 turns the finding off.'**
  String get harnessRepoThresholdHelp;

  /// No description provided for @harnessRepoCoverageCmd.
  ///
  /// In en, this message translates to:
  /// **'Coverage command'**
  String get harnessRepoCoverageCmd;

  /// No description provided for @harnessRepoCoverageCmdHelp.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to use the command agnts derives.'**
  String get harnessRepoCoverageCmdHelp;

  /// No description provided for @harnessRepoCoverageReport.
  ///
  /// In en, this message translates to:
  /// **'Report file'**
  String get harnessRepoCoverageReport;

  /// No description provided for @harnessRepoCoverageReportHelp.
  ///
  /// In en, this message translates to:
  /// **'A Go cover profile or lcov file, in the repository or under /agnts/out/.'**
  String get harnessRepoCoverageReportHelp;

  /// No description provided for @harnessRepoCoverageNoDerived.
  ///
  /// In en, this message translates to:
  /// **'agnts knows no coverage command for these toolchains: set one.'**
  String get harnessRepoCoverageNoDerived;

  /// No description provided for @harnessRepoAcceptance.
  ///
  /// In en, this message translates to:
  /// **'Check acceptance in the app'**
  String get harnessRepoAcceptance;

  /// No description provided for @harnessRepoAcceptanceHelp.
  ///
  /// In en, this message translates to:
  /// **'After the preview, agnts checks the ticket\'s acceptance criteria in the running app and shows the results with screenshots.'**
  String get harnessRepoAcceptanceHelp;

  /// No description provided for @harnessRepoAcceptanceNoPreview.
  ///
  /// In en, this message translates to:
  /// **'Needs a preview command: set one when you edit the repository.'**
  String get harnessRepoAcceptanceNoPreview;

  /// No description provided for @harnessRepoStarterTitle.
  ///
  /// In en, this message translates to:
  /// **'Starter rules'**
  String get harnessRepoStarterTitle;

  /// No description provided for @harnessRepoStarterSub.
  ///
  /// In en, this message translates to:
  /// **'Specific, checkable conventions for this repository\'s languages. They are added as suggestions: nothing applies until you adopt them.'**
  String get harnessRepoStarterSub;

  /// No description provided for @harnessRepoStarterNone.
  ///
  /// In en, this message translates to:
  /// **'No starter pack fits this repository\'s toolchains.'**
  String get harnessRepoStarterNone;

  /// No description provided for @harnessRepoStarterRules.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} rule} other {{n} rules}}'**
  String harnessRepoStarterRules(num n);

  /// No description provided for @harnessRepoStarterOffer.
  ///
  /// In en, this message translates to:
  /// **'Suggest {n, plural, one {{n} rule} other {{n} rules}}'**
  String harnessRepoStarterOffer(num n);

  /// No description provided for @harnessRepoStarterOffered.
  ///
  /// In en, this message translates to:
  /// **'Already suggested'**
  String get harnessRepoStarterOffered;

  /// No description provided for @harnessRepoStarterAdded.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =0 {Nothing new to suggest} one {{n} rule suggested} other {{n} rules suggested}}'**
  String harnessRepoStarterAdded(num n);

  /// No description provided for @harnessRepoStarterOpenRules.
  ///
  /// In en, this message translates to:
  /// **'Open the suggestions'**
  String get harnessRepoStarterOpenRules;

  /// No description provided for @harnessRepoLayersBlock.
  ///
  /// In en, this message translates to:
  /// **'Block imports across layers'**
  String get harnessRepoLayersBlock;

  /// No description provided for @harnessRepoLayersBlockHelp.
  ///
  /// In en, this message translates to:
  /// **'With an approved architecture, agnts flags a change that adds an import its layers do not allow. On, the flag is a blocker that agnts\'s own review sends back to the coder before you see the change.'**
  String get harnessRepoLayersBlockHelp;

  /// No description provided for @harnessRulesDelivery.
  ///
  /// In en, this message translates to:
  /// **'How runs get it'**
  String get harnessRulesDelivery;

  /// No description provided for @harnessRulesDelivery_prompt.
  ///
  /// In en, this message translates to:
  /// **'Every prompt'**
  String get harnessRulesDelivery_prompt;

  /// No description provided for @harnessRulesDelivery_skill.
  ///
  /// In en, this message translates to:
  /// **'Skill'**
  String get harnessRulesDelivery_skill;

  /// No description provided for @harnessRulesDeliveryHelp_prompt.
  ///
  /// In en, this message translates to:
  /// **'In every prompt, always in view.'**
  String get harnessRulesDeliveryHelp_prompt;

  /// No description provided for @harnessRulesDeliveryHelp_skill.
  ///
  /// In en, this message translates to:
  /// **'A skill Muse loads when its description matches the work: keeps prompts short as rules grow. Keep critical rules in every prompt.'**
  String get harnessRulesDeliveryHelp_skill;

  /// No description provided for @harnessRulesEnforce.
  ///
  /// In en, this message translates to:
  /// **'Enforce'**
  String get harnessRulesEnforce;

  /// No description provided for @harnessRulesEnforceHelp.
  ///
  /// In en, this message translates to:
  /// **'agnts-guard checks the rule while Muse works, not only asks for it.'**
  String get harnessRulesEnforceHelp;

  /// No description provided for @harnessRulesOn.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get harnessRulesOn;

  /// No description provided for @harnessRulesOn_file.
  ///
  /// In en, this message translates to:
  /// **'File edits'**
  String get harnessRulesOn_file;

  /// No description provided for @harnessRulesOn_bash.
  ///
  /// In en, this message translates to:
  /// **'Commands'**
  String get harnessRulesOn_bash;

  /// No description provided for @harnessRulesOn_diff.
  ///
  /// In en, this message translates to:
  /// **'Finished change'**
  String get harnessRulesOn_diff;

  /// No description provided for @harnessRulesOnHelp_file.
  ///
  /// In en, this message translates to:
  /// **'Edits of the files below; with a pattern, only added lines that match it.'**
  String get harnessRulesOnHelp_file;

  /// No description provided for @harnessRulesOnHelp_bash.
  ///
  /// In en, this message translates to:
  /// **'Shell commands Muse runs that match the pattern.'**
  String get harnessRulesOnHelp_bash;

  /// No description provided for @harnessRulesOnHelp_diff.
  ///
  /// In en, this message translates to:
  /// **'The finished change, checked on the server after the run.'**
  String get harnessRulesOnHelp_diff;

  /// No description provided for @harnessRulesPaths.
  ///
  /// In en, this message translates to:
  /// **'Files (globs)'**
  String get harnessRulesPaths;

  /// No description provided for @harnessRulesPathsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'server/migrations/*.sql'**
  String get harnessRulesPathsPlaceholder;

  /// No description provided for @harnessRulesPattern.
  ///
  /// In en, this message translates to:
  /// **'Pattern (RE2 regular expression)'**
  String get harnessRulesPattern;

  /// No description provided for @harnessRulesAction.
  ///
  /// In en, this message translates to:
  /// **'When it matches'**
  String get harnessRulesAction;

  /// No description provided for @harnessRulesAction_block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get harnessRulesAction_block;

  /// No description provided for @harnessRulesAction_warn.
  ///
  /// In en, this message translates to:
  /// **'Warn'**
  String get harnessRulesAction_warn;

  /// No description provided for @harnessRulesMessage.
  ///
  /// In en, this message translates to:
  /// **'Message to Muse'**
  String get harnessRulesMessage;

  /// No description provided for @harnessRulesMessagePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Add a new migration instead.'**
  String get harnessRulesMessagePlaceholder;

  /// No description provided for @harnessRulesTry.
  ///
  /// In en, this message translates to:
  /// **'Try on history'**
  String get harnessRulesTry;

  /// No description provided for @harnessRulesTrying.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get harnessRulesTrying;

  /// No description provided for @harnessRulesTryChecked.
  ///
  /// In en, this message translates to:
  /// **'Checked {n, plural, one {{n} change} other {{n} changes}} agnts made.'**
  String harnessRulesTryChecked(num n);

  /// No description provided for @harnessRulesTryNone.
  ///
  /// In en, this message translates to:
  /// **'It would not have matched any of them.'**
  String get harnessRulesTryNone;

  /// No description provided for @harnessRulesTryHits.
  ///
  /// In en, this message translates to:
  /// **'It would have matched {n, plural, one {{n} ticket} other {{n} tickets}}:'**
  String harnessRulesTryHits(num n);

  /// No description provided for @harnessRulesBadgeBlock.
  ///
  /// In en, this message translates to:
  /// **'Enforced: blocks'**
  String get harnessRulesBadgeBlock;

  /// No description provided for @harnessRulesBadgeWarn.
  ///
  /// In en, this message translates to:
  /// **'Enforced: warns'**
  String get harnessRulesBadgeWarn;

  /// No description provided for @harnessRulesBadgeSkill.
  ///
  /// In en, this message translates to:
  /// **'Skill'**
  String get harnessRulesBadgeSkill;

  /// No description provided for @harnessRulesBadgeTip.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get harnessRulesBadgeTip;

  /// No description provided for @harnessRulesSource_reflect.
  ///
  /// In en, this message translates to:
  /// **'From feedback'**
  String get harnessRulesSource_reflect;

  /// No description provided for @harnessRulesSource_run.
  ///
  /// In en, this message translates to:
  /// **'From a run'**
  String get harnessRulesSource_run;

  /// No description provided for @harnessRulesSource_promoted.
  ///
  /// In en, this message translates to:
  /// **'Seen in several repositories'**
  String get harnessRulesSource_promoted;

  /// No description provided for @harnessRulesSourceStarter.
  ///
  /// In en, this message translates to:
  /// **'Starter: {name}'**
  String harnessRulesSourceStarter(String name);

  /// No description provided for @harnessRulesConfidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence {n}%'**
  String harnessRulesConfidence(String n);

  /// No description provided for @harnessRulesSeen.
  ///
  /// In en, this message translates to:
  /// **'Seen {n, plural, one {{n} time} other {{n} times}}'**
  String harnessRulesSeen(num n);

  /// No description provided for @harnessRulesWatching.
  ///
  /// In en, this message translates to:
  /// **'Watching ({n})'**
  String harnessRulesWatching(String n);

  /// No description provided for @harnessRulesWatchingHelp.
  ///
  /// In en, this message translates to:
  /// **'Lessons agnts noticed once or twice. They become suggestions when it sees them again; until then they reach no ticket.'**
  String get harnessRulesWatchingHelp;

  /// No description provided for @harnessSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Guardrails'**
  String get harnessSettingsTitle;

  /// No description provided for @harnessSettingsSub.
  ///
  /// In en, this message translates to:
  /// **'agnts-guard checks Muse\'s work inside every run, while it happens; agnts\'s checks after the run still apply.'**
  String get harnessSettingsSub;

  /// No description provided for @harnessSettingsProfile.
  ///
  /// In en, this message translates to:
  /// **'Guard profile'**
  String get harnessSettingsProfile;

  /// No description provided for @harnessSettingsProfile_minimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get harnessSettingsProfile_minimal;

  /// No description provided for @harnessSettingsProfile_standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get harnessSettingsProfile_standard;

  /// No description provided for @harnessSettingsProfile_strict.
  ///
  /// In en, this message translates to:
  /// **'Strict'**
  String get harnessSettingsProfile_strict;

  /// No description provided for @harnessSettingsProfileHelp_minimal.
  ///
  /// In en, this message translates to:
  /// **'Blocks secrets and dotenv files, enforces team rules with a pattern, and asks for a green build before Muse finishes.'**
  String get harnessSettingsProfileHelp_minimal;

  /// No description provided for @harnessSettingsProfileHelp_standard.
  ///
  /// In en, this message translates to:
  /// **'Minimal, plus: blocks skipped tests, silenced linters, deleted tests and check config changes; lint in the stop gate; quick checks of each edited file.'**
  String get harnessSettingsProfileHelp_standard;

  /// No description provided for @harnessSettingsProfileHelp_strict.
  ///
  /// In en, this message translates to:
  /// **'Standard, plus: tests in the stop gate, blocks swallowed errors and removed assertions, and the fact check before first edits.'**
  String get harnessSettingsProfileHelp_strict;

  /// No description provided for @harnessSettingsFactCheck.
  ///
  /// In en, this message translates to:
  /// **'Fact check share'**
  String get harnessSettingsFactCheck;

  /// No description provided for @harnessSettingsFactCheckHelp.
  ///
  /// In en, this message translates to:
  /// **'Share of strict-profile tickets whose runs must say who uses a file before editing it, and how to undo destructive commands. Compare the groups on Analytics.'**
  String get harnessSettingsFactCheckHelp;

  /// No description provided for @harnessSettingsStalls.
  ///
  /// In en, this message translates to:
  /// **'When a run looks stuck'**
  String get harnessSettingsStalls;

  /// No description provided for @harnessSettingsStallsHelp.
  ///
  /// In en, this message translates to:
  /// **'The same command failing again and again, no edits for many tool calls, or one file read over and over.'**
  String get harnessSettingsStallsHelp;

  /// No description provided for @harnessSettingsStalls_off.
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get harnessSettingsStalls_off;

  /// No description provided for @harnessSettingsStalls_log.
  ///
  /// In en, this message translates to:
  /// **'Note it'**
  String get harnessSettingsStalls_log;

  /// No description provided for @harnessSettingsStalls_act.
  ///
  /// In en, this message translates to:
  /// **'Step in'**
  String get harnessSettingsStalls_act;

  /// No description provided for @harnessSettingsProveFixes.
  ///
  /// In en, this message translates to:
  /// **'Prove bug fixes'**
  String get harnessSettingsProveFixes;

  /// No description provided for @harnessSettingsProveFixesHelp.
  ///
  /// In en, this message translates to:
  /// **'A bug fix needs a test that fails before the change and passes after it; agnts runs it both ways and shows the result.'**
  String get harnessSettingsProveFixesHelp;

  /// No description provided for @harnessSettingsDeepReview.
  ///
  /// In en, this message translates to:
  /// **'Deep review'**
  String get harnessSettingsDeepReview;

  /// No description provided for @harnessSettingsDeepReviewHelp.
  ///
  /// In en, this message translates to:
  /// **'Specialist passes in the code review (security, silent failures, tests, types). Auto: large or complex work only; it costs more tokens.'**
  String get harnessSettingsDeepReviewHelp;

  /// No description provided for @harnessSettingsDeep_off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get harnessSettingsDeep_off;

  /// No description provided for @harnessSettingsDeep_auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get harnessSettingsDeep_auto;

  /// No description provided for @harnessSettingsDeep_always.
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get harnessSettingsDeep_always;

  /// No description provided for @harnessSettingsLearnFromRuns.
  ///
  /// In en, this message translates to:
  /// **'Learn from runs'**
  String get harnessSettingsLearnFromRuns;

  /// No description provided for @harnessSettingsLearnFromRunsHelp.
  ///
  /// In en, this message translates to:
  /// **'After a run with failed checks or a stall, agnts may suggest a tip for the repository. Tips stay watched until seen again.'**
  String get harnessSettingsLearnFromRunsHelp;

  /// No description provided for @harnessSettingsMethodSkills.
  ///
  /// In en, this message translates to:
  /// **'Method skills'**
  String get harnessSettingsMethodSkills;

  /// No description provided for @harnessSettingsMethodSkillsHelp.
  ///
  /// In en, this message translates to:
  /// **'Coding runs get agnts\'s method skills: add one more of something the way the repository already does it, follow the surrounding style, reuse before writing, and change a database schema safely. Muse loads one only when it fits; compare on Analytics.'**
  String get harnessSettingsMethodSkillsHelp;

  /// No description provided for @harnessSettingsSecondOpinion.
  ///
  /// In en, this message translates to:
  /// **'Second opinion'**
  String get harnessSettingsSecondOpinion;

  /// No description provided for @harnessSettingsSecondOpinionHelp.
  ///
  /// In en, this message translates to:
  /// **'Another model reads the chosen approach of complex tickets and says whether it agrees. Empty turns it off.'**
  String get harnessSettingsSecondOpinionHelp;

  /// No description provided for @harnessSettingsSecondOpinionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. opus or codex:gpt-5-codex'**
  String get harnessSettingsSecondOpinionHint;

  /// No description provided for @harnessSettingsAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced: guard hooks'**
  String get harnessSettingsAdvanced;

  /// No description provided for @harnessSettingsAdvancedHelp.
  ///
  /// In en, this message translates to:
  /// **'Turn single hooks off; the profile still decides the rest.'**
  String get harnessSettingsAdvancedHelp;

  /// No description provided for @harnessSettingsHook_pre_secret.
  ///
  /// In en, this message translates to:
  /// **'refuse credentials and dotenv files'**
  String get harnessSettingsHook_pre_secret;

  /// No description provided for @harnessSettingsHook_pre_redflags.
  ///
  /// In en, this message translates to:
  /// **'refuse skipped tests, silenced linters, weakened checks'**
  String get harnessSettingsHook_pre_redflags;

  /// No description provided for @harnessSettingsHook_pre_rules.
  ///
  /// In en, this message translates to:
  /// **'enforce team rules with a pattern'**
  String get harnessSettingsHook_pre_rules;

  /// No description provided for @harnessSettingsHook_pre_fact_check.
  ///
  /// In en, this message translates to:
  /// **'ask for facts before the first edit of a file'**
  String get harnessSettingsHook_pre_fact_check;

  /// No description provided for @harnessSettingsHook_pre_destructive.
  ///
  /// In en, this message translates to:
  /// **'ask for a rollback plan before destructive commands'**
  String get harnessSettingsHook_pre_destructive;

  /// No description provided for @harnessSettingsHook_post_edit_check.
  ///
  /// In en, this message translates to:
  /// **'check each edited file (formatter, linter)'**
  String get harnessSettingsHook_post_edit_check;

  /// No description provided for @harnessSettingsHook_stop_gate.
  ///
  /// In en, this message translates to:
  /// **'build and lint must pass before Muse finishes'**
  String get harnessSettingsHook_stop_gate;

  /// No description provided for @harnessSettingsHook_session_progress.
  ///
  /// In en, this message translates to:
  /// **'give the plan back after the context is compacted'**
  String get harnessSettingsHook_session_progress;

  /// No description provided for @harnessSettingsCodex.
  ///
  /// In en, this message translates to:
  /// **'Coding on Codex'**
  String get harnessSettingsCodex;

  /// No description provided for @harnessSettingsCodexHelp.
  ///
  /// In en, this message translates to:
  /// **'A Codex model name runs coding on Codex CLI instead of Muse; empty uses Muse. Needs the OpenAI integration and api.openai.com in the allowed hosts (Settings → Preview).'**
  String get harnessSettingsCodexHelp;

  /// No description provided for @harnessSettingsCodexConnect.
  ///
  /// In en, this message translates to:
  /// **'OpenAI integration'**
  String get harnessSettingsCodexConnect;

  /// No description provided for @harnessSettingsQualityTitle.
  ///
  /// In en, this message translates to:
  /// **'Guardrails by prompt version'**
  String get harnessSettingsQualityTitle;

  /// No description provided for @harnessSettingsQualitySub.
  ///
  /// In en, this message translates to:
  /// **'What agnts-guard and the harness checks did for the tickets of each prompt version.'**
  String get harnessSettingsQualitySub;

  /// No description provided for @harnessSettingsColBlocks.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get harnessSettingsColBlocks;

  /// No description provided for @harnessSettingsColBlocksHint.
  ///
  /// In en, this message translates to:
  /// **'Actions agnts-guard refused in coding runs'**
  String get harnessSettingsColBlocksHint;

  /// No description provided for @harnessSettingsColStopSaves.
  ///
  /// In en, this message translates to:
  /// **'Stop-gate saves'**
  String get harnessSettingsColStopSaves;

  /// No description provided for @harnessSettingsColStopSavesHint.
  ///
  /// In en, this message translates to:
  /// **'Tickets whose stop gate sent failing checks back, after which agnts\'s checks passed first time'**
  String get harnessSettingsColStopSavesHint;

  /// No description provided for @harnessSettingsColStalls.
  ///
  /// In en, this message translates to:
  /// **'Stalls'**
  String get harnessSettingsColStalls;

  /// No description provided for @harnessSettingsColStallsHint.
  ///
  /// In en, this message translates to:
  /// **'Times runs looked stuck'**
  String get harnessSettingsColStallsHint;

  /// No description provided for @harnessSettingsColProven.
  ///
  /// In en, this message translates to:
  /// **'Fixes proven'**
  String get harnessSettingsColProven;

  /// No description provided for @harnessSettingsColProvenHint.
  ///
  /// In en, this message translates to:
  /// **'Bug fixes whose test failed before the change and passed after it, of those with a proof'**
  String get harnessSettingsColProvenHint;

  /// No description provided for @harnessSettingsColAdopted.
  ///
  /// In en, this message translates to:
  /// **'Findings adopted'**
  String get harnessSettingsColAdopted;

  /// No description provided for @harnessSettingsColAdoptedHint.
  ///
  /// In en, this message translates to:
  /// **'Review findings people put into their feedback'**
  String get harnessSettingsColAdoptedHint;

  /// No description provided for @harnessSettingsColTokens.
  ///
  /// In en, this message translates to:
  /// **'Tokens per done'**
  String get harnessSettingsColTokens;

  /// No description provided for @harnessSettingsColTokensHint.
  ///
  /// In en, this message translates to:
  /// **'Average tokens of a done ticket, all stages'**
  String get harnessSettingsColTokensHint;

  /// No description provided for @harnessSettingsColFactCheck.
  ///
  /// In en, this message translates to:
  /// **'Fact check first try'**
  String get harnessSettingsColFactCheck;

  /// No description provided for @harnessSettingsColFactCheckHint.
  ///
  /// In en, this message translates to:
  /// **'First-try rate of tickets in the fact check group, next to the rate of all done tickets'**
  String get harnessSettingsColFactCheckHint;

  /// No description provided for @harnessSettingsSkillsTitle.
  ///
  /// In en, this message translates to:
  /// **'Method skills'**
  String get harnessSettingsSkillsTitle;

  /// No description provided for @harnessSettingsSkillsSub.
  ///
  /// In en, this message translates to:
  /// **'Tickets whose coding runs had each method skill, replays included, next to the tickets that had none. Replay the same tickets with the setting off and on to compare.'**
  String get harnessSettingsSkillsSub;

  /// No description provided for @harnessSettingsSkillNone.
  ///
  /// In en, this message translates to:
  /// **'none (baseline)'**
  String get harnessSettingsSkillNone;

  /// No description provided for @harnessSettingsColSkill.
  ///
  /// In en, this message translates to:
  /// **'Skill'**
  String get harnessSettingsColSkill;

  /// No description provided for @harnessSettingsColSkillTickets.
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get harnessSettingsColSkillTickets;

  /// No description provided for @harnessSettingsColSkillTicketsHint.
  ///
  /// In en, this message translates to:
  /// **'Tickets with a coding run that had the skill'**
  String get harnessSettingsColSkillTicketsHint;

  /// No description provided for @harnessSettingsColLoaded.
  ///
  /// In en, this message translates to:
  /// **'Loaded'**
  String get harnessSettingsColLoaded;

  /// No description provided for @harnessSettingsColLoadedHint.
  ///
  /// In en, this message translates to:
  /// **'Share of those tickets where Muse loaded the skill'**
  String get harnessSettingsColLoadedHint;

  /// No description provided for @harnessSettingsColSkillFirstTry.
  ///
  /// In en, this message translates to:
  /// **'First try'**
  String get harnessSettingsColSkillFirstTry;

  /// No description provided for @harnessSettingsColSkillFirstTryHint.
  ///
  /// In en, this message translates to:
  /// **'Done without a person asking for changes, of the done tickets'**
  String get harnessSettingsColSkillFirstTryHint;

  /// No description provided for @harnessSettingsColLoadedFirstTry.
  ///
  /// In en, this message translates to:
  /// **'First try, loaded'**
  String get harnessSettingsColLoadedFirstTry;

  /// No description provided for @harnessSettingsColLoadedFirstTryHint.
  ///
  /// In en, this message translates to:
  /// **'First-try rate of the done tickets where Muse loaded the skill'**
  String get harnessSettingsColLoadedFirstTryHint;

  /// No description provided for @harnessSettingsColTargeted.
  ///
  /// In en, this message translates to:
  /// **'Targeted findings'**
  String get harnessSettingsColTargeted;

  /// No description provided for @harnessSettingsColTargetedHint.
  ///
  /// In en, this message translates to:
  /// **'Review findings per ticket of the kinds the skills target: architecture, maintainability, and any on a migration file'**
  String get harnessSettingsColTargetedHint;

  /// No description provided for @harnessSettingsXOfY.
  ///
  /// In en, this message translates to:
  /// **'{x} of {y}'**
  String harnessSettingsXOfY(String x, String y);

  /// No description provided for @harnessSettingsVsAll.
  ///
  /// In en, this message translates to:
  /// **'vs {n}%'**
  String harnessSettingsVsAll(String n);

  /// No description provided for @harnessSettingsEffort.
  ///
  /// In en, this message translates to:
  /// **'Thinking effort'**
  String get harnessSettingsEffort;

  /// No description provided for @harnessSettingsEffortHelp.
  ///
  /// In en, this message translates to:
  /// **'How hard Muse thinks in each stage (Muse\'s --effort). Higher is slower and costs more of your plan. Complex tickets use their own level for coding and review.'**
  String get harnessSettingsEffortHelp;

  /// No description provided for @harnessSettingsEffortAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get harnessSettingsEffortAnalyze;

  /// No description provided for @harnessSettingsEffortCoding.
  ///
  /// In en, this message translates to:
  /// **'Coding'**
  String get harnessSettingsEffortCoding;

  /// No description provided for @harnessSettingsEffortReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get harnessSettingsEffortReview;

  /// No description provided for @harnessSettingsEffortComplex.
  ///
  /// In en, this message translates to:
  /// **'Complex tickets'**
  String get harnessSettingsEffortComplex;

  /// No description provided for @harnessSettingsEffort_.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get harnessSettingsEffort_;

  /// No description provided for @harnessSettingsEffort_low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get harnessSettingsEffort_low;

  /// No description provided for @harnessSettingsEffort_medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get harnessSettingsEffort_medium;

  /// No description provided for @harnessSettingsEffort_high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get harnessSettingsEffort_high;

  /// No description provided for @harnessSettingsRecheckComplex.
  ///
  /// In en, this message translates to:
  /// **'Re-check complex analyses'**
  String get harnessSettingsRecheckComplex;

  /// No description provided for @harnessSettingsRecheckComplexHelp.
  ///
  /// In en, this message translates to:
  /// **'When the analysis model rates a ticket complex, the coding model reads the analysis again before any code is written, and fixes what is wrong or missing.'**
  String get harnessSettingsRecheckComplexHelp;

  /// No description provided for @harnessSettingsBaselineChecks.
  ///
  /// In en, this message translates to:
  /// **'Check the starting commit first'**
  String get harnessSettingsBaselineChecks;

  /// No description provided for @harnessSettingsBaselineChecksHelp.
  ///
  /// In en, this message translates to:
  /// **'Before a ticket\'s first coding run, agnts runs the checks on the commit the work starts from. What already fails there is not the ticket\'s: no fix attempts go to it, and the reviewer sees it failed before. Results are shared by tickets from the same commit.'**
  String get harnessSettingsBaselineChecksHelp;

  /// No description provided for @harnessTicketFlag_secret.
  ///
  /// In en, this message translates to:
  /// **'Possible secret'**
  String get harnessTicketFlag_secret;

  /// No description provided for @harnessTicketFlag_env_file.
  ///
  /// In en, this message translates to:
  /// **'Dotenv file added'**
  String get harnessTicketFlag_env_file;

  /// No description provided for @harnessTicketFlag_debug_leftover.
  ///
  /// In en, this message translates to:
  /// **'Debug output left'**
  String get harnessTicketFlag_debug_leftover;

  /// No description provided for @harnessTicketFlag_check_config.
  ///
  /// In en, this message translates to:
  /// **'Check configuration changed'**
  String get harnessTicketFlag_check_config;

  /// No description provided for @harnessTicketFlag_rule_violation.
  ///
  /// In en, this message translates to:
  /// **'Team rule broken'**
  String get harnessTicketFlag_rule_violation;

  /// No description provided for @harnessTicketSecretsTitle.
  ///
  /// In en, this message translates to:
  /// **'This change may contain a real credential'**
  String get harnessTicketSecretsTitle;

  /// No description provided for @harnessTicketSecretsBody.
  ///
  /// In en, this message translates to:
  /// **'agnts flagged {n, plural, one {{n} line} other {{n} lines}} as a possible secret or a dotenv file. Check them in the red flags on the Review tab: agnts does not push the change until you confirm they are not real credentials.'**
  String harnessTicketSecretsBody(num n);

  /// No description provided for @harnessTicketSecretsConfirm.
  ///
  /// In en, this message translates to:
  /// **'I checked them: not real credentials'**
  String get harnessTicketSecretsConfirm;

  /// No description provided for @harnessTicketSecretsDone.
  ///
  /// In en, this message translates to:
  /// **'Confirmed: the flagged lines are not real credentials.'**
  String get harnessTicketSecretsDone;

  /// No description provided for @harnessTicketSecretsNeeded.
  ///
  /// In en, this message translates to:
  /// **'First confirm that the lines flagged as secrets are not real credentials.'**
  String get harnessTicketSecretsNeeded;

  /// No description provided for @harnessTicketProofTitle.
  ///
  /// In en, this message translates to:
  /// **'Proof of the fix'**
  String get harnessTicketProofTitle;

  /// No description provided for @harnessTicketProof_proven.
  ///
  /// In en, this message translates to:
  /// **'Proven'**
  String get harnessTicketProof_proven;

  /// No description provided for @harnessTicketProof_not_reproduced.
  ///
  /// In en, this message translates to:
  /// **'Not reproduced'**
  String get harnessTicketProof_not_reproduced;

  /// No description provided for @harnessTicketProof_still_failing.
  ///
  /// In en, this message translates to:
  /// **'Still failing'**
  String get harnessTicketProof_still_failing;

  /// No description provided for @harnessTicketProof_inconclusive.
  ///
  /// In en, this message translates to:
  /// **'Inconclusive'**
  String get harnessTicketProof_inconclusive;

  /// No description provided for @harnessTicketProof_no_test.
  ///
  /// In en, this message translates to:
  /// **'No test'**
  String get harnessTicketProof_no_test;

  /// No description provided for @harnessTicketProof_error.
  ///
  /// In en, this message translates to:
  /// **'Not checked'**
  String get harnessTicketProof_error;

  /// No description provided for @harnessTicketProofHelp_proven.
  ///
  /// In en, this message translates to:
  /// **'The reproducing test fails on the code before the change and passes after it.'**
  String get harnessTicketProofHelp_proven;

  /// No description provided for @harnessTicketProofHelp_not_reproduced.
  ///
  /// In en, this message translates to:
  /// **'The test passes before the change too, so it does not show the bug.'**
  String get harnessTicketProofHelp_not_reproduced;

  /// No description provided for @harnessTicketProofHelp_still_failing.
  ///
  /// In en, this message translates to:
  /// **'The test still fails with the change.'**
  String get harnessTicketProofHelp_still_failing;

  /// No description provided for @harnessTicketProofHelp_inconclusive.
  ///
  /// In en, this message translates to:
  /// **'The test could not run on the code before the change; it may need what the fix adds.'**
  String get harnessTicketProofHelp_inconclusive;

  /// No description provided for @harnessTicketProofHelp_no_test.
  ///
  /// In en, this message translates to:
  /// **'No automated test reproduces the bug.'**
  String get harnessTicketProofHelp_no_test;

  /// No description provided for @harnessTicketProofHelp_error.
  ///
  /// In en, this message translates to:
  /// **'agnts could not run the proof.'**
  String get harnessTicketProofHelp_error;

  /// No description provided for @harnessTicketProofBase.
  ///
  /// In en, this message translates to:
  /// **'Started from {sha}'**
  String harnessTicketProofBase(String sha);

  /// No description provided for @harnessTicketProofBefore.
  ///
  /// In en, this message translates to:
  /// **'Before the change (exit {code})'**
  String harnessTicketProofBefore(String code);

  /// No description provided for @harnessTicketProofAfter.
  ///
  /// In en, this message translates to:
  /// **'After the change (exit {code})'**
  String harnessTicketProofAfter(String code);

  /// No description provided for @harnessTicketCoverageTitle.
  ///
  /// In en, this message translates to:
  /// **'Coverage of changed lines'**
  String get harnessTicketCoverageTitle;

  /// No description provided for @harnessTicketCoveragePct.
  ///
  /// In en, this message translates to:
  /// **'{pct}% of the changed lines ran in the tests ({covered} of {total})'**
  String harnessTicketCoveragePct(String pct, String covered, String total);

  /// No description provided for @harnessTicketCoverageBelow.
  ///
  /// In en, this message translates to:
  /// **'Below the repository\'s {n}%'**
  String harnessTicketCoverageBelow(String n);

  /// No description provided for @harnessTicketCoverageNone.
  ///
  /// In en, this message translates to:
  /// **'No changed line is code the coverage report measures.'**
  String get harnessTicketCoverageNone;

  /// No description provided for @harnessTicketCoverageLines.
  ///
  /// In en, this message translates to:
  /// **'Not run: lines {ranges}'**
  String harnessTicketCoverageLines(String ranges);

  /// No description provided for @harnessTicketCoverageError.
  ///
  /// In en, this message translates to:
  /// **'Coverage could not be measured: {error}'**
  String harnessTicketCoverageError(String error);

  /// No description provided for @harnessTicketConfidence.
  ///
  /// In en, this message translates to:
  /// **'{n}% sure'**
  String harnessTicketConfidence(String n);

  /// No description provided for @harnessTicketPass_security.
  ///
  /// In en, this message translates to:
  /// **'Security pass'**
  String get harnessTicketPass_security;

  /// No description provided for @harnessTicketPass_failures.
  ///
  /// In en, this message translates to:
  /// **'Failures pass'**
  String get harnessTicketPass_failures;

  /// No description provided for @harnessTicketPass_tests.
  ///
  /// In en, this message translates to:
  /// **'Tests pass'**
  String get harnessTicketPass_tests;

  /// No description provided for @harnessTicketPass_types.
  ///
  /// In en, this message translates to:
  /// **'Types pass'**
  String get harnessTicketPass_types;

  /// No description provided for @harnessTicketAdopted.
  ///
  /// In en, this message translates to:
  /// **'In your feedback'**
  String get harnessTicketAdopted;

  /// No description provided for @harnessTicketDeep.
  ///
  /// In en, this message translates to:
  /// **'Deep review'**
  String get harnessTicketDeep;

  /// No description provided for @harnessTicketDropped.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} finding} other {{n} findings}} left out (low confidence or duplicates)'**
  String harnessTicketDropped(num n);

  /// No description provided for @harnessTicketDefect.
  ///
  /// In en, this message translates to:
  /// **'Bug fix'**
  String get harnessTicketDefect;

  /// No description provided for @harnessTicketAcceptanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Acceptance criteria'**
  String get harnessTicketAcceptanceTitle;

  /// No description provided for @harnessTicketCheck_ui.
  ///
  /// In en, this message translates to:
  /// **'In the app'**
  String get harnessTicketCheck_ui;

  /// No description provided for @harnessTicketCheck_api.
  ///
  /// In en, this message translates to:
  /// **'API'**
  String get harnessTicketCheck_api;

  /// No description provided for @harnessTicketCheck_test.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get harnessTicketCheck_test;

  /// No description provided for @harnessTicketCheck_manual.
  ///
  /// In en, this message translates to:
  /// **'By hand'**
  String get harnessTicketCheck_manual;

  /// No description provided for @harnessTicketSecondTitle.
  ///
  /// In en, this message translates to:
  /// **'Second opinion'**
  String get harnessTicketSecondTitle;

  /// No description provided for @harnessTicketSecondBy.
  ///
  /// In en, this message translates to:
  /// **'From {model}'**
  String harnessTicketSecondBy(String model);

  /// No description provided for @harnessTicketSecondAgrees.
  ///
  /// In en, this message translates to:
  /// **'Agrees'**
  String get harnessTicketSecondAgrees;

  /// No description provided for @harnessTicketSecondConcerns.
  ///
  /// In en, this message translates to:
  /// **'Has concerns'**
  String get harnessTicketSecondConcerns;

  /// No description provided for @harnessTicketSecondAlternative.
  ///
  /// In en, this message translates to:
  /// **'Would do instead'**
  String get harnessTicketSecondAlternative;

  /// No description provided for @harnessTicketSecondError.
  ///
  /// In en, this message translates to:
  /// **'No second opinion: {error}'**
  String harnessTicketSecondError(String error);

  /// No description provided for @harnessTicketAccTitle.
  ///
  /// In en, this message translates to:
  /// **'Acceptance check'**
  String get harnessTicketAccTitle;

  /// No description provided for @harnessTicketAcc_ok.
  ///
  /// In en, this message translates to:
  /// **'All met'**
  String get harnessTicketAcc_ok;

  /// No description provided for @harnessTicketAcc_partial.
  ///
  /// In en, this message translates to:
  /// **'Partly checked'**
  String get harnessTicketAcc_partial;

  /// No description provided for @harnessTicketAcc_failed.
  ///
  /// In en, this message translates to:
  /// **'Not met'**
  String get harnessTicketAcc_failed;

  /// No description provided for @harnessTicketVerdict_pass.
  ///
  /// In en, this message translates to:
  /// **'Met'**
  String get harnessTicketVerdict_pass;

  /// No description provided for @harnessTicketVerdict_fail.
  ///
  /// In en, this message translates to:
  /// **'Not met'**
  String get harnessTicketVerdict_fail;

  /// No description provided for @harnessTicketVerdict_unknown.
  ///
  /// In en, this message translates to:
  /// **'Not checked'**
  String get harnessTicketVerdict_unknown;

  /// No description provided for @harnessTicketAccSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get harnessTicketAccSteps;

  /// No description provided for @harnessTicketAccShot.
  ///
  /// In en, this message translates to:
  /// **'Screenshot'**
  String get harnessTicketAccShot;

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

  /// No description provided for @integrationsAssignedOnly.
  ///
  /// In en, this message translates to:
  /// **'Only issues assigned to me'**
  String get integrationsAssignedOnly;

  /// No description provided for @integrationsAssignedOnlyHelp.
  ///
  /// In en, this message translates to:
  /// **'agnts takes a labelled issue only when it is assigned to the account it connects to Jira with ({email}). Turn off to take every labelled issue.'**
  String integrationsAssignedOnlyHelp(String email);

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
  /// **'Under Repository permissions set Contents and Pull requests to Read and write, and Workflows to Read and write if agnts may change CI files in .github/workflows. For the Pipelines tab also set Actions to Read (Read and write to use Deploy) and Deployments to Read. Metadata (read) is added automatically.'**
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

  /// No description provided for @integrationsPermWorkflows.
  ///
  /// In en, this message translates to:
  /// **'Read and write. Push changes to .github/workflows (CI files); without it such pushes are refused.'**
  String get integrationsPermWorkflows;

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

  /// No description provided for @integrationsLabelsTitle.
  ///
  /// In en, this message translates to:
  /// **'How to label tickets'**
  String get integrationsLabelsTitle;

  /// No description provided for @integrationsLabelsSub.
  ///
  /// In en, this message translates to:
  /// **'Add one of these labels to a Jira issue that isn\'t done. Case doesn\'t matter.'**
  String get integrationsLabelsSub;

  /// No description provided for @integrationsLabelsRepo.
  ///
  /// In en, this message translates to:
  /// **'An issue goes to the repository linked to its project (Repositories → Jira project). To send it to another one, add a label repo: followed by the repository\'s name in agnts, such as repo:web. Without a repository, only plans, analyses and bug investigations can run.'**
  String get integrationsLabelsRepo;

  /// No description provided for @integrationsLabelsMany.
  ///
  /// In en, this message translates to:
  /// **'With several kind labels, the first in this list wins.'**
  String get integrationsLabelsMany;

  /// No description provided for @integrationsLabelsLater.
  ///
  /// In en, this message translates to:
  /// **'Adding a kind label before work starts changes the ticket\'s kind. Removing every agnts label stops updates from Jira.'**
  String get integrationsLabelsLater;

  /// No description provided for @integrationsPlaneLabelsSub.
  ///
  /// In en, this message translates to:
  /// **'Add one of these labels to an open work item. Case doesn\'t matter.'**
  String get integrationsPlaneLabelsSub;

  /// No description provided for @integrationsPlaneLabelsCreate.
  ///
  /// In en, this message translates to:
  /// **'Plane labels belong to a project: create the ones you use in each linked project first.'**
  String get integrationsPlaneLabelsCreate;

  /// No description provided for @integrationsPlaneLabelsRepo.
  ///
  /// In en, this message translates to:
  /// **'Link the project to a repository by its identifier (WEB in WEB-123) under Repositories → Plane project. Sync reads only linked projects, and code and test work needs a repository. To send one work item to another repository, add a label repo: followed by the repository\'s name in agnts, such as repo:web.'**
  String get integrationsPlaneLabelsRepo;

  /// No description provided for @integrationsPlaneLabelsLater.
  ///
  /// In en, this message translates to:
  /// **'Adding a kind label before work starts changes the ticket\'s kind. Removing every agnts label stops updates from Plane.'**
  String get integrationsPlaneLabelsLater;

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
  /// **'{found} open issues for you, {created} new, {updated} updated, {waiting} changed after agnts started'**
  String integrationsSynced(String found, String created, String updated, String waiting);

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
  /// **'Pushes, Pull requests, Workflow runs'**
  String get integrationsGitEvents_github;

  /// No description provided for @integrationsGitEvents_gitlab.
  ///
  /// In en, this message translates to:
  /// **'Push events, Merge request events, Pipeline events'**
  String get integrationsGitEvents_gitlab;

  /// No description provided for @integrationsGitWebhookWhy.
  ///
  /// In en, this message translates to:
  /// **'When a pull or merge request is merged, agnts marks the ticket merged and moves the Jira issue or Plane work item to the merged status set on its tracker\'s page. Pipeline events keep the repository page current. Pushes link commits whose branch or message has a ticket\'s number to that ticket.'**
  String get integrationsGitWebhookWhy;

  /// No description provided for @integrationsName_plane.
  ///
  /// In en, this message translates to:
  /// **'Plane'**
  String get integrationsName_plane;

  /// No description provided for @integrationsDesc_plane.
  ///
  /// In en, this message translates to:
  /// **'Pick up work items with the agnts label from Plane Cloud or your own Plane, and keep their state up to date.'**
  String get integrationsDesc_plane;

  /// No description provided for @integrationsConnectSub_plane.
  ///
  /// In en, this message translates to:
  /// **'Use a personal access token from Plane. Works with Plane Cloud and self-hosted Plane.'**
  String get integrationsConnectSub_plane;

  /// No description provided for @integrationsTokenOpen_plane.
  ///
  /// In en, this message translates to:
  /// **'Open Plane API docs'**
  String get integrationsTokenOpen_plane;

  /// No description provided for @integrationsTokenStep1_plane.
  ///
  /// In en, this message translates to:
  /// **'In Plane, sign in as the person agnts should act as (comments appear under this name) and open Profile settings → Personal access tokens.'**
  String get integrationsTokenStep1_plane;

  /// No description provided for @integrationsTokenStep2_plane.
  ///
  /// In en, this message translates to:
  /// **'Click Add personal access token, name it (for example agnts), pick an expiry, then copy the token. Plane shows it only once.'**
  String get integrationsTokenStep2_plane;

  /// No description provided for @integrationsTokenStep3_plane.
  ///
  /// In en, this message translates to:
  /// **'For API address, keep https://api.plane.so for Plane Cloud, or enter your own Plane\'s address if it is self-hosted.'**
  String get integrationsTokenStep3_plane;

  /// No description provided for @integrationsTokenStep4_plane.
  ///
  /// In en, this message translates to:
  /// **'For Workspace, enter the slug from Plane\'s address: acme in app.plane.so/acme/projects.'**
  String get integrationsTokenStep4_plane;

  /// No description provided for @integrationsPlaneBaseUrl.
  ///
  /// In en, this message translates to:
  /// **'API address'**
  String get integrationsPlaneBaseUrl;

  /// No description provided for @integrationsPlaneBaseUrlHelp.
  ///
  /// In en, this message translates to:
  /// **'https://api.plane.so for Plane Cloud, or your Plane\'s address'**
  String get integrationsPlaneBaseUrlHelp;

  /// No description provided for @integrationsPlaneWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get integrationsPlaneWorkspace;

  /// No description provided for @integrationsPlaneWorkspaceHelp.
  ///
  /// In en, this message translates to:
  /// **'The slug in Plane\'s address, such as acme'**
  String get integrationsPlaneWorkspaceHelp;

  /// No description provided for @integrationsApiKey.
  ///
  /// In en, this message translates to:
  /// **'API key'**
  String get integrationsApiKey;

  /// No description provided for @integrationsApiKeyHelp.
  ///
  /// In en, this message translates to:
  /// **'Profile settings → Personal access tokens'**
  String get integrationsApiKeyHelp;

  /// No description provided for @integrationsPlaneWebhookTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up the Plane webhook'**
  String get integrationsPlaneWebhookTitle;

  /// No description provided for @integrationsPlaneWebhookSteps.
  ///
  /// In en, this message translates to:
  /// **'In Plane, open Workspace settings → Webhooks → Add webhook, enter the URL below and tick the work item (issue) events. Plane then shows a secret once: paste it here.'**
  String get integrationsPlaneWebhookSteps;

  /// No description provided for @integrationsPlaneEventsValue.
  ///
  /// In en, this message translates to:
  /// **'Work items (issues)'**
  String get integrationsPlaneEventsValue;

  /// No description provided for @integrationsPlaneSecret.
  ///
  /// In en, this message translates to:
  /// **'Secret from Plane'**
  String get integrationsPlaneSecret;

  /// No description provided for @integrationsPlaneSecretHelp.
  ///
  /// In en, this message translates to:
  /// **'Plane shows it once when you create the webhook'**
  String get integrationsPlaneSecretHelp;

  /// No description provided for @integrationsPlaneSecretSave.
  ///
  /// In en, this message translates to:
  /// **'Save secret'**
  String get integrationsPlaneSecretSave;

  /// No description provided for @integrationsPlaneSecretReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace secret'**
  String get integrationsPlaneSecretReplace;

  /// No description provided for @integrationsPlaneSecretSaved.
  ///
  /// In en, this message translates to:
  /// **'Webhook secret saved: Plane deliveries are accepted now'**
  String get integrationsPlaneSecretSaved;

  /// No description provided for @integrationsPlaneSecretSet.
  ///
  /// In en, this message translates to:
  /// **'Secret saved. Deliveries are accepted.'**
  String get integrationsPlaneSecretSet;

  /// No description provided for @integrationsPlaneSecretMissing.
  ///
  /// In en, this message translates to:
  /// **'No secret yet: agnts refuses deliveries until you paste the secret Plane showed, and only the hourly sync picks up work items.'**
  String get integrationsPlaneSecretMissing;

  /// No description provided for @integrationsPlaneQueryText.
  ///
  /// In en, this message translates to:
  /// **'Open work items in the Plane projects linked to repositories that carry one of these labels: {labels}'**
  String integrationsPlaneQueryText(String labels);

  /// No description provided for @integrationsPlaneNoProjects.
  ///
  /// In en, this message translates to:
  /// **'No repository is linked to a Plane project yet. Add the project identifier (WEB in WEB-123) on the repository.'**
  String get integrationsPlaneNoProjects;

  /// No description provided for @integrationsPlaneStatusesSub.
  ///
  /// In en, this message translates to:
  /// **'How agnts moves work items. Leave a status on Default to use the first state of the matching group; In review moves only to a state you pick.'**
  String get integrationsPlaneStatusesSub;

  /// No description provided for @integrationsPlaneStateDefault.
  ///
  /// In en, this message translates to:
  /// **'Default: first {group} state'**
  String integrationsPlaneStateDefault(String group);

  /// No description provided for @integrationsPlaneStateNone.
  ///
  /// In en, this message translates to:
  /// **'Keep state'**
  String get integrationsPlaneStateNone;

  /// No description provided for @integrationsPlaneStatesError.
  ///
  /// In en, this message translates to:
  /// **'Could not read the states from Plane: {error}'**
  String integrationsPlaneStatesError(String error);

  /// No description provided for @integrationsPlaneSyncHelp.
  ///
  /// In en, this message translates to:
  /// **'Plane sends changes to the webhook right away; agnts also checks every hour in case a delivery was missed.'**
  String get integrationsPlaneSyncHelp;

  /// No description provided for @integrationsPlaneHelp.
  ///
  /// In en, this message translates to:
  /// **'agnts reads only work items with its labels in linked projects, and writes only the state changes and comments you turn on here. Plane allows 60 API requests a minute per key; agnts stays under 50.'**
  String get integrationsPlaneHelp;

  /// No description provided for @integrationsPlaneSynced.
  ///
  /// In en, this message translates to:
  /// **'{found} open work items, {created} new'**
  String integrationsPlaneSynced(String found, String created);

  /// No description provided for @integrationsName_openai.
  ///
  /// In en, this message translates to:
  /// **'OpenAI'**
  String get integrationsName_openai;

  /// No description provided for @integrationsDesc_openai.
  ///
  /// In en, this message translates to:
  /// **'An OpenAI API key for runs on Codex CLI, agnts\'s second coding tool. Pick a codex: model in Settings to use it.'**
  String get integrationsDesc_openai;

  /// No description provided for @integrationsConnectSub_openai.
  ///
  /// In en, this message translates to:
  /// **'Paste an OpenAI API key. agnts checks it, keeps it encrypted, and gives it only to runs that use Codex.'**
  String get integrationsConnectSub_openai;

  /// No description provided for @integrationsTokenOpen_openai.
  ///
  /// In en, this message translates to:
  /// **'Open API keys'**
  String get integrationsTokenOpen_openai;

  /// No description provided for @integrationsTokenStep1_openai.
  ///
  /// In en, this message translates to:
  /// **'Open the OpenAI platform\'s API keys page (button below) and sign in.'**
  String get integrationsTokenStep1_openai;

  /// No description provided for @integrationsTokenStep2_openai.
  ///
  /// In en, this message translates to:
  /// **'Create a new secret key, ideally in a project with a spending limit.'**
  String get integrationsTokenStep2_openai;

  /// No description provided for @integrationsTokenStep3_openai.
  ///
  /// In en, this message translates to:
  /// **'Copy the key (it starts with sk-) and paste it into API key below.'**
  String get integrationsTokenStep3_openai;

  /// No description provided for @integrationsTokenStep4_openai.
  ///
  /// In en, this message translates to:
  /// **'In Settings → Preview, add api.openai.com to the hosts runs may reach, so Codex runs can call OpenAI.'**
  String get integrationsTokenStep4_openai;

  /// No description provided for @integrationsOpenaiKeyHelp.
  ///
  /// In en, this message translates to:
  /// **'Stored encrypted on your server. Only runs on Codex receive it.'**
  String get integrationsOpenaiKeyHelp;

  /// No description provided for @integrationsOpenaiHelp.
  ///
  /// In en, this message translates to:
  /// **'Codex runs have no agnts-guard hooks: agnts\'s checks after the run (red flags, build, lint, tests, review) still apply. Runs also need api.openai.com in the allowed hosts.'**
  String get integrationsOpenaiHelp;

  /// No description provided for @integrationsName_muse.
  ///
  /// In en, this message translates to:
  /// **'Muse Code'**
  String get integrationsName_muse;

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

  /// No description provided for @kindReview.
  ///
  /// In en, this message translates to:
  /// **'PR review'**
  String get kindReview;

  /// No description provided for @kindReviewHint.
  ///
  /// In en, this message translates to:
  /// **'Review a pull request someone else opened. Comes from GitHub or GitLab.'**
  String get kindReviewHint;

  /// No description provided for @kindSwaggertest.
  ///
  /// In en, this message translates to:
  /// **'Swagger test'**
  String get kindSwaggertest;

  /// No description provided for @kindSwaggertestHint.
  ///
  /// In en, this message translates to:
  /// **'Test an HTTP API against its Swagger/OpenAPI spec. Repository optional; ends in a results table and a report.'**
  String get kindSwaggertestHint;

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
  /// **'Muse suggested these links. Check them before relying on them.'**
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

  /// No description provided for @linkedCommitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Commits'**
  String get linkedCommitsTitle;

  /// No description provided for @linkedCommitsSub.
  ///
  /// In en, this message translates to:
  /// **'Anyone\'s commits whose branch or message has {number}, from pushes and the repositories\' recent history.'**
  String linkedCommitsSub(String number);

  /// No description provided for @linkedCommitsNone.
  ///
  /// In en, this message translates to:
  /// **'No commits with {number} yet. Push a branch or write a commit message with it, and the commits show here.'**
  String linkedCommitsNone(String number);

  /// No description provided for @linkedCommitsTotal.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} commit} other {{n} commits}}'**
  String linkedCommitsTotal(num n);

  /// No description provided for @linkedCommitsOnBranch.
  ///
  /// In en, this message translates to:
  /// **'branch'**
  String get linkedCommitsOnBranch;

  /// No description provided for @linkedCommitsOnMessage.
  ///
  /// In en, this message translates to:
  /// **'message'**
  String get linkedCommitsOnMessage;

  /// No description provided for @linkedCommitsOnBranchHint.
  ///
  /// In en, this message translates to:
  /// **'The branch name has the number'**
  String get linkedCommitsOnBranchHint;

  /// No description provided for @linkedCommitsOnMessageHint.
  ///
  /// In en, this message translates to:
  /// **'The commit message has the number'**
  String get linkedCommitsOnMessageHint;

  /// No description provided for @linkedCommitsMeta.
  ///
  /// In en, this message translates to:
  /// **'{author} · {repo} · {branch}'**
  String linkedCommitsMeta(String author, String repo, String branch);

  /// No description provided for @linkedCommitsMore.
  ///
  /// In en, this message translates to:
  /// **'Show more ({n} left)'**
  String linkedCommitsMore(String n);

  /// No description provided for @linkedCommitsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the commits.'**
  String get linkedCommitsLoadError;

  /// No description provided for @linkedCommitsTickets.
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get linkedCommitsTickets;

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

  /// No description provided for @logsTypeBudget.
  ///
  /// In en, this message translates to:
  /// **'Spend'**
  String get logsTypeBudget;

  /// No description provided for @maccountPasswordInstead.
  ///
  /// In en, this message translates to:
  /// **'Sign in with a password'**
  String get maccountPasswordInstead;

  /// No description provided for @maccountGoogleInstead.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google instead'**
  String get maccountGoogleInstead;

  /// No description provided for @maccountSetupLede.
  ///
  /// In en, this message translates to:
  /// **'Admins sign in with two factors. Add this account to an authenticator app with the secret below (or open the setup link on this phone), then enter the 6-digit code it shows.'**
  String get maccountSetupLede;

  /// No description provided for @maccountTotpOpen.
  ///
  /// In en, this message translates to:
  /// **'Open in authenticator app'**
  String get maccountTotpOpen;

  /// No description provided for @maccountLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the link.'**
  String get maccountLinkFailed;

  /// No description provided for @maccountCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get maccountCurrent;

  /// No description provided for @maccountHaveInvite.
  ///
  /// In en, this message translates to:
  /// **'Have an invite?'**
  String get maccountHaveInvite;

  /// No description provided for @maccountInviteHint.
  ///
  /// In en, this message translates to:
  /// **'Paste the invite link'**
  String get maccountInviteHint;

  /// No description provided for @maccountInviteOpen.
  ///
  /// In en, this message translates to:
  /// **'Open invite'**
  String get maccountInviteOpen;

  /// No description provided for @maccountJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined {date}'**
  String maccountJoined(String date);

  /// No description provided for @maccountPaying.
  ///
  /// In en, this message translates to:
  /// **'Finish the payment in your browser. Credits show here once the payment provider confirms it.'**
  String get maccountPaying;

  /// No description provided for @maccountChars.
  ///
  /// In en, this message translates to:
  /// **'{n} / {max}'**
  String maccountChars(String n, String max);

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

  /// No description provided for @massistantTitle.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get massistantTitle;

  /// No description provided for @massistantFab.
  ///
  /// In en, this message translates to:
  /// **'Ask the assistant'**
  String get massistantFab;

  /// No description provided for @massistantMoreRow.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get massistantMoreRow;

  /// No description provided for @massistantMoreRowSub.
  ///
  /// In en, this message translates to:
  /// **'Ask about your workspace'**
  String get massistantMoreRowSub;

  /// No description provided for @massistantPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Ask about tickets, CI, spend…'**
  String get massistantPlaceholder;

  /// No description provided for @massistantSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get massistantSend;

  /// No description provided for @massistantCount.
  ///
  /// In en, this message translates to:
  /// **'{n} / 1000'**
  String massistantCount(String n);

  /// No description provided for @massistantNewConversation.
  ///
  /// In en, this message translates to:
  /// **'New conversation'**
  String get massistantNewConversation;

  /// No description provided for @massistantHistory.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get massistantHistory;

  /// No description provided for @massistantHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet.'**
  String get massistantHistoryEmpty;

  /// No description provided for @massistantDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get massistantDelete;

  /// No description provided for @massistantDeleted.
  ///
  /// In en, this message translates to:
  /// **'Conversation deleted'**
  String get massistantDeleted;

  /// No description provided for @massistantEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask agnts about your work'**
  String get massistantEmptyTitle;

  /// No description provided for @massistantEmptyText.
  ///
  /// In en, this message translates to:
  /// **'It answers from your tickets, CI and spend, and links what it mentions. Ask it to approve, start or create something and it offers the action for you to confirm.'**
  String get massistantEmptyText;

  /// No description provided for @massistantPrivate.
  ///
  /// In en, this message translates to:
  /// **'Only you see your conversations. They are kept for 30 days.'**
  String get massistantPrivate;

  /// No description provided for @massistantSuggestWaiting.
  ///
  /// In en, this message translates to:
  /// **'What is waiting on me?'**
  String get massistantSuggestWaiting;

  /// No description provided for @massistantSuggestCi.
  ///
  /// In en, this message translates to:
  /// **'Why is CI red?'**
  String get massistantSuggestCi;

  /// No description provided for @massistantSuggestSpend.
  ///
  /// In en, this message translates to:
  /// **'How much did we spend this week?'**
  String get massistantSuggestSpend;

  /// No description provided for @massistantSuggestDone.
  ///
  /// In en, this message translates to:
  /// **'What did agnts finish this week?'**
  String get massistantSuggestDone;

  /// No description provided for @massistantThinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking… {seconds}s'**
  String massistantThinking(String seconds);

  /// No description provided for @massistantReading.
  ///
  /// In en, this message translates to:
  /// **'Reading {what}'**
  String massistantReading(String what);

  /// No description provided for @massistantFileInbox.
  ///
  /// In en, this message translates to:
  /// **'your inbox'**
  String get massistantFileInbox;

  /// No description provided for @massistantFileTickets.
  ///
  /// In en, this message translates to:
  /// **'the tickets'**
  String get massistantFileTickets;

  /// No description provided for @massistantFileTicket.
  ///
  /// In en, this message translates to:
  /// **'{key}'**
  String massistantFileTicket(String key);

  /// No description provided for @massistantFileCi.
  ///
  /// In en, this message translates to:
  /// **'CI failures'**
  String get massistantFileCi;

  /// No description provided for @massistantFileUsage.
  ///
  /// In en, this message translates to:
  /// **'plan usage'**
  String get massistantFileUsage;

  /// No description provided for @massistantFileAnalytics.
  ///
  /// In en, this message translates to:
  /// **'analytics'**
  String get massistantFileAnalytics;

  /// No description provided for @massistantFileRepos.
  ///
  /// In en, this message translates to:
  /// **'repositories'**
  String get massistantFileRepos;

  /// No description provided for @massistantFileLessons.
  ///
  /// In en, this message translates to:
  /// **'lessons'**
  String get massistantFileLessons;

  /// No description provided for @massistantFileConversation.
  ///
  /// In en, this message translates to:
  /// **'the conversation'**
  String get massistantFileConversation;

  /// No description provided for @massistantFileQuestion.
  ///
  /// In en, this message translates to:
  /// **'your question'**
  String get massistantFileQuestion;

  /// No description provided for @massistantFileOther.
  ///
  /// In en, this message translates to:
  /// **'the workspace'**
  String get massistantFileOther;

  /// No description provided for @massistantFailed.
  ///
  /// In en, this message translates to:
  /// **'No answer'**
  String get massistantFailed;

  /// No description provided for @massistantAskAgain.
  ///
  /// In en, this message translates to:
  /// **'Ask again'**
  String get massistantAskAgain;

  /// No description provided for @massistantLinkCi.
  ///
  /// In en, this message translates to:
  /// **'CI #{id}'**
  String massistantLinkCi(String id);

  /// No description provided for @massistantLinkLesson.
  ///
  /// In en, this message translates to:
  /// **'Lesson #{id}'**
  String massistantLinkLesson(String id);

  /// No description provided for @massistantTook.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String massistantTook(String seconds);

  /// No description provided for @massistantHelpful.
  ///
  /// In en, this message translates to:
  /// **'Helpful'**
  String get massistantHelpful;

  /// No description provided for @massistantNotHelpful.
  ///
  /// In en, this message translates to:
  /// **'Not helpful'**
  String get massistantNotHelpful;

  /// No description provided for @massistantRateTitle.
  ///
  /// In en, this message translates to:
  /// **'How was this answer?'**
  String get massistantRateTitle;

  /// No description provided for @massistantRateComment.
  ///
  /// In en, this message translates to:
  /// **'What was wrong or missing? (optional)'**
  String get massistantRateComment;

  /// No description provided for @massistantRateShare.
  ///
  /// In en, this message translates to:
  /// **'Keep this question\'s data so agnts can test better answers'**
  String get massistantRateShare;

  /// No description provided for @massistantRateNote.
  ///
  /// In en, this message translates to:
  /// **'Your rating, comment, question and answer are shown to the workspace owner.'**
  String get massistantRateNote;

  /// No description provided for @massistantRateSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get massistantRateSend;

  /// No description provided for @massistantRateClear.
  ///
  /// In en, this message translates to:
  /// **'Remove rating'**
  String get massistantRateClear;

  /// No description provided for @massistantRated.
  ///
  /// In en, this message translates to:
  /// **'Thanks for the rating'**
  String get massistantRated;

  /// No description provided for @massistantStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get massistantStatsTitle;

  /// No description provided for @massistantStatsQuestions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get massistantStatsQuestions;

  /// No description provided for @massistantStatsAnswered.
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get massistantStatsAnswered;

  /// No description provided for @massistantStatsMedian.
  ///
  /// In en, this message translates to:
  /// **'Median time'**
  String get massistantStatsMedian;

  /// No description provided for @massistantStatsHelpful.
  ///
  /// In en, this message translates to:
  /// **'Helpful'**
  String get massistantStatsHelpful;

  /// No description provided for @massistantStatsTokens.
  ///
  /// In en, this message translates to:
  /// **'Tokens'**
  String get massistantStatsTokens;

  /// No description provided for @massistantStatsPeople.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} person asked} other {{n} people asked}}'**
  String massistantStatsPeople(num n);

  /// No description provided for @massistantStatsVersions.
  ///
  /// In en, this message translates to:
  /// **'By prompt version'**
  String get massistantStatsVersions;

  /// No description provided for @massistantStatsVersionRow.
  ///
  /// In en, this message translates to:
  /// **'{answered} answered · {failed} failed · {up} 👍 {down} 👎 · {median}'**
  String massistantStatsVersionRow(String answered, String failed, String up, String down, String median);

  /// No description provided for @massistantStatsNone.
  ///
  /// In en, this message translates to:
  /// **'No questions in this period.'**
  String get massistantStatsNone;

  /// No description provided for @massistantStatsRated.
  ///
  /// In en, this message translates to:
  /// **'Rated answers'**
  String get massistantStatsRated;

  /// No description provided for @massistantRatedEmpty.
  ///
  /// In en, this message translates to:
  /// **'No rated answers yet.'**
  String get massistantRatedEmpty;

  /// No description provided for @massistantRatedShared.
  ///
  /// In en, this message translates to:
  /// **'Kept for prompt tests'**
  String get massistantRatedShared;

  /// No description provided for @massistantStatsParts.
  ///
  /// In en, this message translates to:
  /// **'Container {start} · workspace {snapshot} · Muse {claude}'**
  String massistantStatsParts(String start, String snapshot, String claude);

  /// No description provided for @massistantStatsWarm.
  ///
  /// In en, this message translates to:
  /// **'{n} of {total} reused a warm container'**
  String massistantStatsWarm(String n, String total);

  /// No description provided for @massistantStatsSeeRated.
  ///
  /// In en, this message translates to:
  /// **'Rated answers'**
  String get massistantStatsSeeRated;

  /// No description provided for @massistantDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this conversation?'**
  String get massistantDeleteTitle;

  /// No description provided for @massistantDeleteText.
  ///
  /// In en, this message translates to:
  /// **'Its questions and answers are deleted for good.'**
  String get massistantDeleteText;

  /// No description provided for @massistantSendHint.
  ///
  /// In en, this message translates to:
  /// **'Enter to send, Shift+Enter for a new line'**
  String get massistantSendHint;

  /// No description provided for @massistantConversationsLede.
  ///
  /// In en, this message translates to:
  /// **'Your questions and the assistant\'s answers. Only you see them; they are kept for 30 days.'**
  String get massistantConversationsLede;

  /// No description provided for @massistantOpenChat.
  ///
  /// In en, this message translates to:
  /// **'Open the chat'**
  String get massistantOpenChat;

  /// No description provided for @massistantSuggestAct.
  ///
  /// In en, this message translates to:
  /// **'Approve what passed review'**
  String get massistantSuggestAct;

  /// No description provided for @massistantFileMe.
  ///
  /// In en, this message translates to:
  /// **'your role'**
  String get massistantFileMe;

  /// No description provided for @massistantFileGroups.
  ///
  /// In en, this message translates to:
  /// **'repository groups'**
  String get massistantFileGroups;

  /// No description provided for @massistantActionHint.
  ///
  /// In en, this message translates to:
  /// **'Nothing happens until you confirm.'**
  String get massistantActionHint;

  /// No description provided for @massistantActionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get massistantActionConfirm;

  /// No description provided for @massistantActionDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get massistantActionDecline;

  /// No description provided for @massistantActionRunning.
  ///
  /// In en, this message translates to:
  /// **'Doing it…'**
  String get massistantActionRunning;

  /// No description provided for @massistantActionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get massistantActionDone;

  /// No description provided for @massistantActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Not done'**
  String get massistantActionFailed;

  /// No description provided for @massistantActionCancelled.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get massistantActionCancelled;

  /// No description provided for @massistantActionExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired. Ask again for a new one.'**
  String get massistantActionExpired;

  /// No description provided for @massistantActionConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm this?'**
  String get massistantActionConfirmTitle;

  /// No description provided for @massistantActionConfirmText.
  ///
  /// In en, this message translates to:
  /// **'{summary}\n\nThis cannot be undone.'**
  String massistantActionConfirmText(String summary);

  /// No description provided for @massistantActionNotOffered.
  ///
  /// In en, this message translates to:
  /// **'Not offered: {reason}'**
  String massistantActionNotOffered(String reason);

  /// No description provided for @massistantStatsActions.
  ///
  /// In en, this message translates to:
  /// **'Actions confirmed'**
  String get massistantStatsActions;

  /// No description provided for @massistantStatsActionsLine.
  ///
  /// In en, this message translates to:
  /// **'{proposed} offered · {done} done · {failed} not done · {cancelled} declined · {expired} expired · {notOffered} not offered'**
  String massistantStatsActionsLine(String proposed, String done, String failed, String cancelled, String expired, String notOffered);

  /// No description provided for @massistantStatsActionsOffered.
  ///
  /// In en, this message translates to:
  /// **'Offered'**
  String get massistantStatsActionsOffered;

  /// No description provided for @massistantStatsVersionActions.
  ///
  /// In en, this message translates to:
  /// **'{proposed} actions offered · {done} done'**
  String massistantStatsVersionActions(String proposed, String done);

  /// No description provided for @massistantVoiceStart.
  ///
  /// In en, this message translates to:
  /// **'Ask by voice'**
  String get massistantVoiceStart;

  /// No description provided for @massistantVoiceSend.
  ///
  /// In en, this message translates to:
  /// **'Stop and ask'**
  String get massistantVoiceSend;

  /// No description provided for @massistantVoiceRecording.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get massistantVoiceRecording;

  /// No description provided for @massistantVoiceHearing.
  ///
  /// In en, this message translates to:
  /// **'Muse is listening to your question…'**
  String get massistantVoiceHearing;

  /// No description provided for @massistantVoiceLimit.
  ///
  /// In en, this message translates to:
  /// **'up to {n} min'**
  String massistantVoiceLimit(String n);

  /// No description provided for @massistantVoiceDenied.
  ///
  /// In en, this message translates to:
  /// **'Allow the microphone for this site to ask by voice.'**
  String get massistantVoiceDenied;

  /// No description provided for @massistantVoiceNoMic.
  ///
  /// In en, this message translates to:
  /// **'No microphone could be opened.'**
  String get massistantVoiceNoMic;

  /// No description provided for @mciTitle.
  ///
  /// In en, this message translates to:
  /// **'CI failures'**
  String get mciTitle;

  /// No description provided for @mciLede.
  ///
  /// In en, this message translates to:
  /// **'Watched branches that went red, one row per error.'**
  String get mciLede;

  /// No description provided for @mciFilterRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get mciFilterRed;

  /// No description provided for @mciFilterFlaky.
  ///
  /// In en, this message translates to:
  /// **'Flaky'**
  String get mciFilterFlaky;

  /// No description provided for @mciFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get mciFilterAll;

  /// No description provided for @mciEmptyRed.
  ///
  /// In en, this message translates to:
  /// **'No watched branch is red.'**
  String get mciEmptyRed;

  /// No description provided for @mciEmpty.
  ///
  /// In en, this message translates to:
  /// **'No CI failures here.'**
  String get mciEmpty;

  /// No description provided for @mciStatus_triage.
  ///
  /// In en, this message translates to:
  /// **'Checking'**
  String get mciStatus_triage;

  /// No description provided for @mciStatus_open.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get mciStatus_open;

  /// No description provided for @mciStatus_fixing.
  ///
  /// In en, this message translates to:
  /// **'Fixing'**
  String get mciStatus_fixing;

  /// No description provided for @mciStatus_fixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get mciStatus_fixed;

  /// No description provided for @mciStatus_resolved.
  ///
  /// In en, this message translates to:
  /// **'Green again'**
  String get mciStatus_resolved;

  /// No description provided for @mciStatus_flaky.
  ///
  /// In en, this message translates to:
  /// **'Flaky'**
  String get mciStatus_flaky;

  /// No description provided for @mciStatus_infra.
  ///
  /// In en, this message translates to:
  /// **'Infrastructure'**
  String get mciStatus_infra;

  /// No description provided for @mciStatus_muted.
  ///
  /// In en, this message translates to:
  /// **'Muted'**
  String get mciStatus_muted;

  /// No description provided for @mciStatus_regression.
  ///
  /// In en, this message translates to:
  /// **'Back again'**
  String get mciStatus_regression;

  /// No description provided for @mciLastSeen.
  ///
  /// In en, this message translates to:
  /// **'last {when}'**
  String mciLastSeen(String when);

  /// No description provided for @mciFactFirstCommit.
  ///
  /// In en, this message translates to:
  /// **'First failing commit'**
  String get mciFactFirstCommit;

  /// No description provided for @mciFactCount.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get mciFactCount;

  /// No description provided for @mciTimes.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} time} other {{n} times}}'**
  String mciTimes(num n);

  /// No description provided for @mciFactLastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen'**
  String get mciFactLastSeen;

  /// No description provided for @mciFactFlaky.
  ///
  /// In en, this message translates to:
  /// **'Passed on re-run'**
  String get mciFactFlaky;

  /// No description provided for @mciJob.
  ///
  /// In en, this message translates to:
  /// **'Job'**
  String get mciJob;

  /// No description provided for @mciBranch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get mciBranch;

  /// No description provided for @mciFirstError.
  ///
  /// In en, this message translates to:
  /// **'The first error'**
  String get mciFirstError;

  /// No description provided for @mciLogTail.
  ///
  /// In en, this message translates to:
  /// **'The end of the log'**
  String get mciLogTail;

  /// No description provided for @mciLogNote.
  ///
  /// In en, this message translates to:
  /// **'From the job\'s log, with secrets removed.'**
  String get mciLogNote;

  /// No description provided for @mciNoSample.
  ///
  /// In en, this message translates to:
  /// **'No log excerpt was kept for this failure.'**
  String get mciNoSample;

  /// No description provided for @mciRuns.
  ///
  /// In en, this message translates to:
  /// **'Failing runs'**
  String get mciRuns;

  /// No description provided for @mciRunsCount.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} failing run} other {{n} failing runs}}'**
  String mciRunsCount(num n);

  /// No description provided for @mciRunFlaky.
  ///
  /// In en, this message translates to:
  /// **'passed on re-run'**
  String get mciRunFlaky;

  /// No description provided for @mciTicket.
  ///
  /// In en, this message translates to:
  /// **'Ticket'**
  String get mciTicket;

  /// No description provided for @mciForeignPr.
  ///
  /// In en, this message translates to:
  /// **'This failure is on someone else\'s pull request (#{n}): agnts only comments there.'**
  String mciForeignPr(String n);

  /// No description provided for @mciFix.
  ///
  /// In en, this message translates to:
  /// **'Fix it'**
  String get mciFix;

  /// No description provided for @mciFixConfirm.
  ///
  /// In en, this message translates to:
  /// **'agnts opens a ticket to fix this failure. You review the fix before anything is pushed.'**
  String get mciFixConfirm;

  /// No description provided for @mciMute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get mciMute;

  /// No description provided for @mciUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get mciUnmute;

  /// No description provided for @mciMutedDone.
  ///
  /// In en, this message translates to:
  /// **'Muted: agnts leaves this failure alone until you unmute it.'**
  String get mciMutedDone;

  /// No description provided for @mciUnmutedDone.
  ///
  /// In en, this message translates to:
  /// **'Unmuted.'**
  String get mciUnmutedDone;

  /// No description provided for @mciRerun.
  ///
  /// In en, this message translates to:
  /// **'Re-run'**
  String get mciRerun;

  /// No description provided for @mciRerunDone.
  ///
  /// In en, this message translates to:
  /// **'Re-run started.'**
  String get mciRerunDone;

  /// No description provided for @mciCardTitle.
  ///
  /// In en, this message translates to:
  /// **'CI failure'**
  String get mciCardTitle;

  /// No description provided for @mciCardOpen.
  ///
  /// In en, this message translates to:
  /// **'Open the CI failure'**
  String get mciCardOpen;

  /// No description provided for @mciCiFixes.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {CI sent the pull request back once} other {CI sent the pull request back {n} times}}'**
  String mciCiFixes(num n);

  /// No description provided for @mciSourceCi.
  ///
  /// In en, this message translates to:
  /// **'CI'**
  String get mciSourceCi;

  /// No description provided for @mciNotify.
  ///
  /// In en, this message translates to:
  /// **'A watched branch went red'**
  String get mciNotify;

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

  /// No description provided for @mcpPickWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get mcpPickWorkspace;

  /// No description provided for @mcpPickWorkspaceHelp.
  ///
  /// In en, this message translates to:
  /// **'Claude acts in this workspace, as you.'**
  String get mcpPickWorkspaceHelp;

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

  /// No description provided for @mdocumentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get mdocumentsTitle;

  /// No description provided for @mdocumentsMoreRowSub.
  ///
  /// In en, this message translates to:
  /// **'Reports and pages of the workspace'**
  String get mdocumentsMoreRowSub;

  /// No description provided for @mdocumentsAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get mdocumentsAll;

  /// No description provided for @mdocumentsMine.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get mdocumentsMine;

  /// No description provided for @mdocumentsShared.
  ///
  /// In en, this message translates to:
  /// **'Shared with me'**
  String get mdocumentsShared;

  /// No description provided for @mdocumentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No documents yet'**
  String get mdocumentsEmpty;

  /// No description provided for @mdocumentsEmptyText.
  ///
  /// In en, this message translates to:
  /// **'Write documents in the web app, or make one from a ticket\'s report.'**
  String get mdocumentsEmptyText;

  /// No description provided for @mdocumentsTypePrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get mdocumentsTypePrivate;

  /// No description provided for @mdocumentsTypePublic.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get mdocumentsTypePublic;

  /// No description provided for @mdocumentsWriting.
  ///
  /// In en, this message translates to:
  /// **'agnts is writing'**
  String get mdocumentsWriting;

  /// No description provided for @mdocumentsFailed.
  ///
  /// In en, this message translates to:
  /// **'Writing failed'**
  String get mdocumentsFailed;

  /// No description provided for @mdocumentsFailedText.
  ///
  /// In en, this message translates to:
  /// **'agnts could not write it: {error}'**
  String mdocumentsFailedText(String error);

  /// No description provided for @mdocumentsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {n}'**
  String mdocumentsVersion(String n);

  /// No description provided for @mdocumentsAsOf.
  ///
  /// In en, this message translates to:
  /// **'Based on data up to {date}'**
  String mdocumentsAsOf(String date);

  /// No description provided for @mdocumentsMeta.
  ///
  /// In en, this message translates to:
  /// **'{owner} · {time}'**
  String mdocumentsMeta(String owner, String time);

  /// No description provided for @mdocumentsNoBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing written yet.'**
  String get mdocumentsNoBody;

  /// No description provided for @mdocumentsLinkedTickets.
  ///
  /// In en, this message translates to:
  /// **'Linked tickets'**
  String get mdocumentsLinkedTickets;

  /// No description provided for @mdocumentsCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy public link'**
  String get mdocumentsCopyLink;

  /// No description provided for @mdocumentsLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get mdocumentsLinkCopied;

  /// No description provided for @mdocumentsSharing.
  ///
  /// In en, this message translates to:
  /// **'Sharing'**
  String get mdocumentsSharing;

  /// No description provided for @mdocumentsDownloadMd.
  ///
  /// In en, this message translates to:
  /// **'Download .md'**
  String get mdocumentsDownloadMd;

  /// No description provided for @mdocumentsDownloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download .pdf'**
  String get mdocumentsDownloadPdf;

  /// No description provided for @mdocumentsPreparingPdf.
  ///
  /// In en, this message translates to:
  /// **'Preparing the PDF…'**
  String get mdocumentsPreparingPdf;

  /// No description provided for @mdocumentsPdfSlow.
  ///
  /// In en, this message translates to:
  /// **'The PDF is taking longer than usual. Try again in a minute.'**
  String get mdocumentsPdfSlow;

  /// No description provided for @mdocumentsDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get mdocumentsDownloadFailed;

  /// No description provided for @mdocumentsPublicLink.
  ///
  /// In en, this message translates to:
  /// **'Public link'**
  String get mdocumentsPublicLink;

  /// No description provided for @mdocumentsPublicHint.
  ///
  /// In en, this message translates to:
  /// **'Anyone with the link can read it without signing in.'**
  String get mdocumentsPublicHint;

  /// No description provided for @mdocumentsPublicOff.
  ///
  /// In en, this message translates to:
  /// **'Public documents are turned off in this workspace\'s Settings.'**
  String get mdocumentsPublicOff;

  /// No description provided for @mdocumentsResetLink.
  ///
  /// In en, this message translates to:
  /// **'Reset link'**
  String get mdocumentsResetLink;

  /// No description provided for @mdocumentsResetDone.
  ///
  /// In en, this message translates to:
  /// **'New link made; the old one no longer works.'**
  String get mdocumentsResetDone;

  /// No description provided for @mdocumentsWorkspaceAccess.
  ///
  /// In en, this message translates to:
  /// **'Everyone in the workspace'**
  String get mdocumentsWorkspaceAccess;

  /// No description provided for @mdocumentsAccessNone.
  ///
  /// In en, this message translates to:
  /// **'No access'**
  String get mdocumentsAccessNone;

  /// No description provided for @mdocumentsAccessView.
  ///
  /// In en, this message translates to:
  /// **'Can view'**
  String get mdocumentsAccessView;

  /// No description provided for @mdocumentsAccessEdit.
  ///
  /// In en, this message translates to:
  /// **'Can edit'**
  String get mdocumentsAccessEdit;

  /// No description provided for @mdocumentsPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get mdocumentsPeople;

  /// No description provided for @mdocumentsViewerOnlyView.
  ///
  /// In en, this message translates to:
  /// **'Viewers can only view'**
  String get mdocumentsViewerOnlyView;

  /// No description provided for @mdocumentsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get mdocumentsSave;

  /// No description provided for @mdocumentsSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get mdocumentsSaved;

  /// No description provided for @mdocumentsSecrets.
  ///
  /// In en, this message translates to:
  /// **'The document looks like it holds secrets. Remove them before publishing:'**
  String get mdocumentsSecrets;

  /// No description provided for @mdocumentsSecretLine.
  ///
  /// In en, this message translates to:
  /// **'Line {line}: {excerpt}'**
  String mdocumentsSecretLine(String line, String excerpt);

  /// No description provided for @mdocumentsTicketSection.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get mdocumentsTicketSection;

  /// No description provided for @mdocumentsTicketNone.
  ///
  /// In en, this message translates to:
  /// **'No documents linked yet.'**
  String get mdocumentsTicketNone;

  /// No description provided for @mdocumentsFromReport.
  ///
  /// In en, this message translates to:
  /// **'Make a document from this report'**
  String get mdocumentsFromReport;

  /// No description provided for @mdocumentsFromReportStarted.
  ///
  /// In en, this message translates to:
  /// **'agnts is writing the document'**
  String get mdocumentsFromReportStarted;

  /// No description provided for @mdocumentsLedgerSpent.
  ///
  /// In en, this message translates to:
  /// **'Spent on a document'**
  String get mdocumentsLedgerSpent;

  /// No description provided for @mdocumentsSlides.
  ///
  /// In en, this message translates to:
  /// **'Slides'**
  String get mdocumentsSlides;

  /// No description provided for @mdocumentsPresent.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get mdocumentsPresent;

  /// No description provided for @mdocumentsNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get mdocumentsNotes;

  /// No description provided for @mdocumentsNoNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes for this slide.'**
  String get mdocumentsNoNotes;

  /// No description provided for @mdocumentsNoSlides.
  ///
  /// In en, this message translates to:
  /// **'No slides yet.'**
  String get mdocumentsNoSlides;

  /// No description provided for @mdocumentsPrevSlide.
  ///
  /// In en, this message translates to:
  /// **'Previous slide'**
  String get mdocumentsPrevSlide;

  /// No description provided for @mdocumentsNextSlide.
  ///
  /// In en, this message translates to:
  /// **'Next slide'**
  String get mdocumentsNextSlide;

  /// No description provided for @mdocumentsStopPresenting.
  ///
  /// In en, this message translates to:
  /// **'Stop presenting'**
  String get mdocumentsStopPresenting;

  /// No description provided for @mdocumentsMadeFrom.
  ///
  /// In en, this message translates to:
  /// **'Made from “{title}”'**
  String mdocumentsMadeFrom(String title);

  /// No description provided for @meetingsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Meetings'**
  String get meetingsPageTitle;

  /// No description provided for @meetingsLede.
  ///
  /// In en, this message translates to:
  /// **'Video calls for the team and the guests you let in. Muse can take the notes and turn what was agreed into tickets.'**
  String get meetingsLede;

  /// No description provided for @meetingsStartNow.
  ///
  /// In en, this message translates to:
  /// **'Start now'**
  String get meetingsStartNow;

  /// No description provided for @meetingsSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get meetingsSchedule;

  /// No description provided for @meetingsGetLink.
  ///
  /// In en, this message translates to:
  /// **'Get a link'**
  String get meetingsGetLink;

  /// No description provided for @meetingsLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied: {link}'**
  String meetingsLinkCopied(String link);

  /// No description provided for @meetingsLinkCopiedShort.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get meetingsLinkCopiedShort;

  /// No description provided for @meetingsCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get meetingsCopyLink;

  /// No description provided for @meetingsJoinWithCode.
  ///
  /// In en, this message translates to:
  /// **'Join with a code or link'**
  String get meetingsJoinWithCode;

  /// No description provided for @meetingsCodePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'abc-defg-hij'**
  String get meetingsCodePlaceholder;

  /// No description provided for @meetingsBadCode.
  ///
  /// In en, this message translates to:
  /// **'That is not a meeting code: it looks like abc-defg-hij.'**
  String get meetingsBadCode;

  /// No description provided for @meetingsJoin.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get meetingsJoin;

  /// No description provided for @meetingsOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get meetingsOpen;

  /// No description provided for @meetingsTab_upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get meetingsTab_upcoming;

  /// No description provided for @meetingsTab_past.
  ///
  /// In en, this message translates to:
  /// **'Past calls'**
  String get meetingsTab_past;

  /// No description provided for @meetingsTab_mine.
  ///
  /// In en, this message translates to:
  /// **'I host'**
  String get meetingsTab_mine;

  /// No description provided for @meetingsNoneUpcoming.
  ///
  /// In en, this message translates to:
  /// **'No live or upcoming meetings. Start one now, or schedule one.'**
  String get meetingsNoneUpcoming;

  /// No description provided for @meetingsNoneMine.
  ///
  /// In en, this message translates to:
  /// **'You host no meetings yet.'**
  String get meetingsNoneMine;

  /// No description provided for @meetingsNonePast.
  ///
  /// In en, this message translates to:
  /// **'No calls yet.'**
  String get meetingsNonePast;

  /// No description provided for @meetingsLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get meetingsLive;

  /// No description provided for @meetingsInCallNow.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} person in the call} other {{n} people in the call}}'**
  String meetingsInCallNow(num n);

  /// No description provided for @meetingsLiveEmpty.
  ///
  /// In en, this message translates to:
  /// **'The call is open'**
  String get meetingsLiveEmpty;

  /// No description provided for @meetingsNobodyYet.
  ///
  /// In en, this message translates to:
  /// **'Nobody is in the call yet'**
  String get meetingsNobodyYet;

  /// No description provided for @meetingsHostedBy.
  ///
  /// In en, this message translates to:
  /// **'Hosted by {name}'**
  String meetingsHostedBy(String name);

  /// No description provided for @meetingsUntitled.
  ///
  /// In en, this message translates to:
  /// **'Meeting'**
  String get meetingsUntitled;

  /// No description provided for @meetingsKind_instant.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get meetingsKind_instant;

  /// No description provided for @meetingsKind_scheduled.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get meetingsKind_scheduled;

  /// No description provided for @meetingsColMeeting.
  ///
  /// In en, this message translates to:
  /// **'Meeting'**
  String get meetingsColMeeting;

  /// No description provided for @meetingsColWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get meetingsColWhen;

  /// No description provided for @meetingsColPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get meetingsColPeople;

  /// No description provided for @meetingsColNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get meetingsColNotes;

  /// No description provided for @meetingsRecordings.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} recording} other {{n} recordings}}'**
  String meetingsRecordings(num n);

  /// No description provided for @meetingsActionItemsN.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} action item} other {{n} action items}}'**
  String meetingsActionItemsN(num n);

  /// No description provided for @meetingsOpenNotes.
  ///
  /// In en, this message translates to:
  /// **'Open the notes'**
  String get meetingsOpenNotes;

  /// No description provided for @meetingsNotes_none.
  ///
  /// In en, this message translates to:
  /// **'No notes'**
  String get meetingsNotes_none;

  /// No description provided for @meetingsNotes_recording.
  ///
  /// In en, this message translates to:
  /// **'Taking notes'**
  String get meetingsNotes_recording;

  /// No description provided for @meetingsNotes_queued.
  ///
  /// In en, this message translates to:
  /// **'Notes queued'**
  String get meetingsNotes_queued;

  /// No description provided for @meetingsNotes_transcribing.
  ///
  /// In en, this message translates to:
  /// **'Muse is listening'**
  String get meetingsNotes_transcribing;

  /// No description provided for @meetingsNotes_writing.
  ///
  /// In en, this message translates to:
  /// **'Muse is writing'**
  String get meetingsNotes_writing;

  /// No description provided for @meetingsNotes_done.
  ///
  /// In en, this message translates to:
  /// **'Notes ready'**
  String get meetingsNotes_done;

  /// No description provided for @meetingsNotes_failed.
  ///
  /// In en, this message translates to:
  /// **'Notes failed'**
  String get meetingsNotes_failed;

  /// No description provided for @meetingsOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Meetings are off on this server'**
  String get meetingsOffTitle;

  /// No description provided for @meetingsOffBody.
  ///
  /// In en, this message translates to:
  /// **'The server’s administrator turns them on with a LiveKit server (AGNTS_LIVEKIT_URL).'**
  String get meetingsOffBody;

  /// No description provided for @meetingsYourReminders.
  ///
  /// In en, this message translates to:
  /// **'Your reminders'**
  String get meetingsYourReminders;

  /// No description provided for @meetingsRemindersSub.
  ///
  /// In en, this message translates to:
  /// **'Before a meeting you are invited to starts, on your phone and here.'**
  String get meetingsRemindersSub;

  /// No description provided for @meetingsMinutesBefore.
  ///
  /// In en, this message translates to:
  /// **'{n} min before'**
  String meetingsMinutesBefore(String n);

  /// No description provided for @meetingsNoReminders.
  ///
  /// In en, this message translates to:
  /// **'No reminders'**
  String get meetingsNoReminders;

  /// No description provided for @meetingsSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Meetings in this workspace'**
  String get meetingsSettingsTitle;

  /// No description provided for @meetingsSettingsSub.
  ///
  /// In en, this message translates to:
  /// **'Recordings, what is kept and for how long, and how many people one call takes.'**
  String get meetingsSettingsSub;

  /// No description provided for @meetingsAllowRecording.
  ///
  /// In en, this message translates to:
  /// **'Hosts may record calls as video'**
  String get meetingsAllowRecording;

  /// No description provided for @meetingsKeepAudio.
  ///
  /// In en, this message translates to:
  /// **'Keep the audio of notes after Muse has heard it'**
  String get meetingsKeepAudio;

  /// No description provided for @meetingsRetention.
  ///
  /// In en, this message translates to:
  /// **'Keep recordings and transcripts for (days)'**
  String get meetingsRetention;

  /// No description provided for @meetingsRetentionHelp.
  ///
  /// In en, this message translates to:
  /// **'0 keeps them for ever.'**
  String get meetingsRetentionHelp;

  /// No description provided for @meetingsMaxPeople.
  ///
  /// In en, this message translates to:
  /// **'People in one call'**
  String get meetingsMaxPeople;

  /// No description provided for @meetingsServerCan.
  ///
  /// In en, this message translates to:
  /// **'This server can do:'**
  String get meetingsServerCan;

  /// No description provided for @meetingsRecordingWord.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get meetingsRecordingWord;

  /// No description provided for @meetingsNotesWord.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get meetingsNotesWord;

  /// No description provided for @meetingsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get meetingsSave;

  /// No description provided for @meetingsSettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get meetingsSettingsSaved;

  /// No description provided for @meetingsNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New meeting'**
  String get meetingsNewTitle;

  /// No description provided for @meetingsNewSub.
  ///
  /// In en, this message translates to:
  /// **'A call now, or one in the calendar with invitations.'**
  String get meetingsNewSub;

  /// No description provided for @meetingsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Change the meeting'**
  String get meetingsEditTitle;

  /// No description provided for @meetingsWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get meetingsWhen;

  /// No description provided for @meetingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get meetingsTitle;

  /// No description provided for @meetingsTitlePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Sprint planning'**
  String get meetingsTitlePlaceholder;

  /// No description provided for @meetingsDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get meetingsDate;

  /// No description provided for @meetingsTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get meetingsTime;

  /// No description provided for @meetingsDuration.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get meetingsDuration;

  /// No description provided for @meetingsMinutes.
  ///
  /// In en, this message translates to:
  /// **'{n} min'**
  String meetingsMinutes(String n);

  /// No description provided for @meetingsTimeZoneIs.
  ///
  /// In en, this message translates to:
  /// **'Times are in {zone}.'**
  String meetingsTimeZoneIs(String zone);

  /// No description provided for @meetingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Agenda'**
  String get meetingsDescription;

  /// No description provided for @meetingsDescriptionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'What the meeting is for. Muse reads it when it writes the notes.'**
  String get meetingsDescriptionPlaceholder;

  /// No description provided for @meetingsAccess.
  ///
  /// In en, this message translates to:
  /// **'Who joins without knocking'**
  String get meetingsAccess;

  /// No description provided for @meetingsAccess_workspace.
  ///
  /// In en, this message translates to:
  /// **'Everyone in the workspace'**
  String get meetingsAccess_workspace;

  /// No description provided for @meetingsAccess_invited.
  ///
  /// In en, this message translates to:
  /// **'Only the invited'**
  String get meetingsAccess_invited;

  /// No description provided for @meetingsAccessHelp_workspace.
  ///
  /// In en, this message translates to:
  /// **'Members join; guests knock.'**
  String get meetingsAccessHelp_workspace;

  /// No description provided for @meetingsAccessHelp_invited.
  ///
  /// In en, this message translates to:
  /// **'Invitees join; other members and guests knock.'**
  String get meetingsAccessHelp_invited;

  /// No description provided for @meetingsGuestsMode.
  ///
  /// In en, this message translates to:
  /// **'Guests'**
  String get meetingsGuestsMode;

  /// No description provided for @meetingsGuests_knock.
  ///
  /// In en, this message translates to:
  /// **'Knock'**
  String get meetingsGuests_knock;

  /// No description provided for @meetingsGuests_open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get meetingsGuests_open;

  /// No description provided for @meetingsGuests_off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get meetingsGuests_off;

  /// No description provided for @meetingsGuestsHelp_knock.
  ///
  /// In en, this message translates to:
  /// **'People without a membership wait until a host lets them in.'**
  String get meetingsGuestsHelp_knock;

  /// No description provided for @meetingsGuestsHelp_open.
  ///
  /// In en, this message translates to:
  /// **'Anyone with the link joins without waiting, until the call ends.'**
  String get meetingsGuestsHelp_open;

  /// No description provided for @meetingsGuestsHelp_off.
  ///
  /// In en, this message translates to:
  /// **'Only members of the workspace.'**
  String get meetingsGuestsHelp_off;

  /// No description provided for @meetingsGuestsAre.
  ///
  /// In en, this message translates to:
  /// **'guests: {mode}'**
  String meetingsGuestsAre(String mode);

  /// No description provided for @meetingsInvite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get meetingsInvite;

  /// No description provided for @meetingsEmailsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Email addresses, separated by commas'**
  String get meetingsEmailsPlaceholder;

  /// No description provided for @meetingsInviteHelp.
  ///
  /// In en, this message translates to:
  /// **'Everyone gets an email with the calendar event; people outside the workspace get a personal link.'**
  String get meetingsInviteHelp;

  /// No description provided for @meetingsInviteHelpNow.
  ///
  /// In en, this message translates to:
  /// **'Members are told in agnts; addresses get the link by email.'**
  String get meetingsInviteHelpNow;

  /// No description provided for @meetingsAi.
  ///
  /// In en, this message translates to:
  /// **'Notes and recording'**
  String get meetingsAi;

  /// No description provided for @meetingsAutoNotes.
  ///
  /// In en, this message translates to:
  /// **'Take notes: Muse hears the call and writes the decisions and action items'**
  String get meetingsAutoNotes;

  /// No description provided for @meetingsAutoRecord.
  ///
  /// In en, this message translates to:
  /// **'Record the call as video'**
  String get meetingsAutoRecord;

  /// No description provided for @meetingsAutoNotesOn.
  ///
  /// In en, this message translates to:
  /// **'Notes on'**
  String get meetingsAutoNotesOn;

  /// No description provided for @meetingsAutoRecordOn.
  ///
  /// In en, this message translates to:
  /// **'Recorded'**
  String get meetingsAutoRecordOn;

  /// No description provided for @meetingsNotesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Notes are not set up on this server.'**
  String get meetingsNotesUnavailable;

  /// No description provided for @meetingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language of the notes'**
  String get meetingsLanguage;

  /// No description provided for @meetingsLang_auto.
  ///
  /// In en, this message translates to:
  /// **'As spoken'**
  String get meetingsLang_auto;

  /// No description provided for @meetingsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get meetingsCancel;

  /// No description provided for @meetingsEdit.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get meetingsEdit;

  /// No description provided for @meetingsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get meetingsDelete;

  /// No description provided for @meetingsCancelMeeting.
  ///
  /// In en, this message translates to:
  /// **'Cancel the meeting'**
  String get meetingsCancelMeeting;

  /// No description provided for @meetingsCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this meeting?'**
  String get meetingsCancelTitle;

  /// No description provided for @meetingsCancelBody.
  ///
  /// In en, this message translates to:
  /// **'Invitees get the cancellation in their calendar. A call in progress ends.'**
  String get meetingsCancelBody;

  /// No description provided for @meetingsCancelled.
  ///
  /// In en, this message translates to:
  /// **'This meeting was cancelled.'**
  String get meetingsCancelled;

  /// No description provided for @meetingsCancelledShort.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get meetingsCancelledShort;

  /// No description provided for @meetingsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this meeting?'**
  String get meetingsDeleteTitle;

  /// No description provided for @meetingsDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Its calls, recordings, transcripts and chat are deleted. Notes documents stay.'**
  String get meetingsDeleteBody;

  /// No description provided for @meetingsLink.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get meetingsLink;

  /// No description provided for @meetingsRing.
  ///
  /// In en, this message translates to:
  /// **'Ring people'**
  String get meetingsRing;

  /// No description provided for @meetingsRingWho.
  ///
  /// In en, this message translates to:
  /// **'Who to ring now'**
  String get meetingsRingWho;

  /// No description provided for @meetingsRingNow.
  ///
  /// In en, this message translates to:
  /// **'Ring'**
  String get meetingsRingNow;

  /// No description provided for @meetingsRinging.
  ///
  /// In en, this message translates to:
  /// **'Ringing…'**
  String get meetingsRinging;

  /// No description provided for @meetingsAreYouComing.
  ///
  /// In en, this message translates to:
  /// **'Are you coming?'**
  String get meetingsAreYouComing;

  /// No description provided for @meetingsRsvp_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get meetingsRsvp_yes;

  /// No description provided for @meetingsRsvp_no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get meetingsRsvp_no;

  /// No description provided for @meetingsRsvp_maybe.
  ///
  /// In en, this message translates to:
  /// **'Maybe'**
  String get meetingsRsvp_maybe;

  /// No description provided for @meetingsRsvp_none.
  ///
  /// In en, this message translates to:
  /// **'No answer'**
  String get meetingsRsvp_none;

  /// No description provided for @meetingsInvitees.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =0 {Invited} one {{n} invited} other {{n} invited}}'**
  String meetingsInvitees(num n);

  /// No description provided for @meetingsInviteMore.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get meetingsInviteMore;

  /// No description provided for @meetingsNoInvitees.
  ///
  /// In en, this message translates to:
  /// **'Nobody is invited.'**
  String get meetingsNoInvitees;

  /// No description provided for @meetingsByEmail.
  ///
  /// In en, this message translates to:
  /// **'by email'**
  String get meetingsByEmail;

  /// No description provided for @meetingsUninvite.
  ///
  /// In en, this message translates to:
  /// **'Uninvite'**
  String get meetingsUninvite;

  /// No description provided for @meetingsCalls.
  ///
  /// In en, this message translates to:
  /// **'Calls'**
  String get meetingsCalls;

  /// No description provided for @meetingsNoCalls.
  ///
  /// In en, this message translates to:
  /// **'The meeting has not been live yet.'**
  String get meetingsNoCalls;

  /// No description provided for @meetingsTheMeeting.
  ///
  /// In en, this message translates to:
  /// **'the meeting'**
  String get meetingsTheMeeting;

  /// No description provided for @meetingsNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get meetingsNotesTitle;

  /// No description provided for @meetingsNoNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes were not taken in this call.'**
  String get meetingsNoNotes;

  /// No description provided for @meetingsNotesBusy_recording.
  ///
  /// In en, this message translates to:
  /// **'Notes are being taken; Muse writes them when the call ends.'**
  String get meetingsNotesBusy_recording;

  /// No description provided for @meetingsNotesBusy_queued.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Muse to hear the call…'**
  String get meetingsNotesBusy_queued;

  /// No description provided for @meetingsNotesBusy_transcribing.
  ///
  /// In en, this message translates to:
  /// **'Muse is listening to the call…'**
  String get meetingsNotesBusy_transcribing;

  /// No description provided for @meetingsNotesBusy_writing.
  ///
  /// In en, this message translates to:
  /// **'Muse is writing the notes…'**
  String get meetingsNotesBusy_writing;

  /// No description provided for @meetingsNotesFailed.
  ///
  /// In en, this message translates to:
  /// **'The notes could not be written: {reason}'**
  String meetingsNotesFailed(String reason);

  /// No description provided for @meetingsWriteAgain.
  ///
  /// In en, this message translates to:
  /// **'Write again'**
  String get meetingsWriteAgain;

  /// No description provided for @meetingsNotesAgain.
  ///
  /// In en, this message translates to:
  /// **'Muse is writing the notes again'**
  String get meetingsNotesAgain;

  /// No description provided for @meetingsActionItems.
  ///
  /// In en, this message translates to:
  /// **'Action items'**
  String get meetingsActionItems;

  /// No description provided for @meetingsAnyRepo.
  ///
  /// In en, this message translates to:
  /// **'Any repository'**
  String get meetingsAnyRepo;

  /// No description provided for @meetingsRepository.
  ///
  /// In en, this message translates to:
  /// **'Repository'**
  String get meetingsRepository;

  /// No description provided for @meetingsCreateTicket.
  ///
  /// In en, this message translates to:
  /// **'Create ticket'**
  String get meetingsCreateTicket;

  /// No description provided for @meetingsTicketMade.
  ///
  /// In en, this message translates to:
  /// **'{key} created'**
  String meetingsTicketMade(String key);

  /// No description provided for @meetingsRecordingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get meetingsRecordingsTitle;

  /// No description provided for @meetingsRecordingNow.
  ///
  /// In en, this message translates to:
  /// **'Recording…'**
  String get meetingsRecordingNow;

  /// No description provided for @meetingsDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get meetingsDownload;

  /// No description provided for @meetingsDeleteRecordingTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this recording?'**
  String get meetingsDeleteRecordingTitle;

  /// No description provided for @meetingsDeleteRecordingBody.
  ///
  /// In en, this message translates to:
  /// **'The video is deleted for everyone. The transcript and notes stay.'**
  String get meetingsDeleteRecordingBody;

  /// No description provided for @meetingsAttendance.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} person} other {{n} people}}'**
  String meetingsAttendance(num n);

  /// No description provided for @meetingsStillIn.
  ///
  /// In en, this message translates to:
  /// **'still in'**
  String get meetingsStillIn;

  /// No description provided for @meetingsGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get meetingsGuest;

  /// No description provided for @meetingsMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get meetingsMember;

  /// No description provided for @meetingsTranscript.
  ///
  /// In en, this message translates to:
  /// **'Transcript'**
  String get meetingsTranscript;

  /// No description provided for @meetingsNoTranscript.
  ///
  /// In en, this message translates to:
  /// **'No transcript.'**
  String get meetingsNoTranscript;

  /// No description provided for @meetingsSearchTranscript.
  ///
  /// In en, this message translates to:
  /// **'Search what was said'**
  String get meetingsSearchTranscript;

  /// No description provided for @meetingsMixedNote.
  ///
  /// In en, this message translates to:
  /// **'Everyone’s audio was heard together, so the transcript does not say who spoke.'**
  String get meetingsMixedNote;

  /// No description provided for @meetingsChatLog.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =0 {Chat} one {Chat · {n} message} other {Chat · {n} messages}}'**
  String meetingsChatLog(num n);

  /// No description provided for @meetingsShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get meetingsShow;

  /// No description provided for @meetingsHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get meetingsHide;

  /// No description provided for @meetingsTicketTitle.
  ///
  /// In en, this message translates to:
  /// **'Discussed in meetings'**
  String get meetingsTicketTitle;

  /// No description provided for @meetingsNotFound.
  ///
  /// In en, this message translates to:
  /// **'No such meeting'**
  String get meetingsNotFound;

  /// No description provided for @meetingsSomethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get meetingsSomethingWrong;

  /// No description provided for @meetingsTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get meetingsTryAgain;

  /// No description provided for @meetingsCameraStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting the camera…'**
  String get meetingsCameraStarting;

  /// No description provided for @meetingsCameraOff.
  ///
  /// In en, this message translates to:
  /// **'Camera is off'**
  String get meetingsCameraOff;

  /// No description provided for @meetingsMicOn.
  ///
  /// In en, this message translates to:
  /// **'Microphone on'**
  String get meetingsMicOn;

  /// No description provided for @meetingsMicOff.
  ///
  /// In en, this message translates to:
  /// **'Microphone off'**
  String get meetingsMicOff;

  /// No description provided for @meetingsCamOn.
  ///
  /// In en, this message translates to:
  /// **'Camera on'**
  String get meetingsCamOn;

  /// No description provided for @meetingsCamOff.
  ///
  /// In en, this message translates to:
  /// **'Camera off'**
  String get meetingsCamOff;

  /// No description provided for @meetingsMicLevel.
  ///
  /// In en, this message translates to:
  /// **'Microphone level'**
  String get meetingsMicLevel;

  /// No description provided for @meetingsDevicesBlocked.
  ///
  /// In en, this message translates to:
  /// **'The browser blocked the camera and microphone. Allow them in the address bar, then try again.'**
  String get meetingsDevicesBlocked;

  /// No description provided for @meetingsDevicesFailed.
  ///
  /// In en, this message translates to:
  /// **'The camera or microphone could not start. Another app may be using it.'**
  String get meetingsDevicesFailed;

  /// No description provided for @meetingsMicrophone.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get meetingsMicrophone;

  /// No description provided for @meetingsCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get meetingsCamera;

  /// No description provided for @meetingsSpeakers.
  ///
  /// In en, this message translates to:
  /// **'Speakers'**
  String get meetingsSpeakers;

  /// No description provided for @meetingsDefaultDevice.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get meetingsDefaultDevice;

  /// No description provided for @meetingsLobbyRecording.
  ///
  /// In en, this message translates to:
  /// **'This call is being recorded.'**
  String get meetingsLobbyRecording;

  /// No description provided for @meetingsLobbyNotes.
  ///
  /// In en, this message translates to:
  /// **'agnts is taking notes of this call.'**
  String get meetingsLobbyNotes;

  /// No description provided for @meetingsNotStartedYet.
  ///
  /// In en, this message translates to:
  /// **'You can join 15 minutes before it starts.'**
  String get meetingsNotStartedYet;

  /// No description provided for @meetingsYourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get meetingsYourName;

  /// No description provided for @meetingsYourNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'How others will see you'**
  String get meetingsYourNamePlaceholder;

  /// No description provided for @meetingsJoiningAs.
  ///
  /// In en, this message translates to:
  /// **'You join as {name}.'**
  String meetingsJoiningAs(String name);

  /// No description provided for @meetingsJoinNow.
  ///
  /// In en, this message translates to:
  /// **'Join now'**
  String get meetingsJoinNow;

  /// No description provided for @meetingsAskToJoin.
  ///
  /// In en, this message translates to:
  /// **'Ask to join'**
  String get meetingsAskToJoin;

  /// No description provided for @meetingsJoining.
  ///
  /// In en, this message translates to:
  /// **'Joining…'**
  String get meetingsJoining;

  /// No description provided for @meetingsOrGoogle.
  ///
  /// In en, this message translates to:
  /// **'Or show who you are with Google'**
  String get meetingsOrGoogle;

  /// No description provided for @meetingsWaitingTitle.
  ///
  /// In en, this message translates to:
  /// **'Asking to join…'**
  String get meetingsWaitingTitle;

  /// No description provided for @meetingsWaitingBody.
  ///
  /// In en, this message translates to:
  /// **'Someone in the call will let you in soon.'**
  String get meetingsWaitingBody;

  /// No description provided for @meetingsConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get meetingsConnecting;

  /// No description provided for @meetingsYouLeft.
  ///
  /// In en, this message translates to:
  /// **'You left the call'**
  String get meetingsYouLeft;

  /// No description provided for @meetingsJoinedElsewhere.
  ///
  /// In en, this message translates to:
  /// **'You joined from another tab'**
  String get meetingsJoinedElsewhere;

  /// No description provided for @meetingsRejoin.
  ///
  /// In en, this message translates to:
  /// **'Rejoin'**
  String get meetingsRejoin;

  /// No description provided for @meetingsBackToMeetings.
  ///
  /// In en, this message translates to:
  /// **'Back to meetings'**
  String get meetingsBackToMeetings;

  /// No description provided for @meetingsEnded.
  ///
  /// In en, this message translates to:
  /// **'The call has ended'**
  String get meetingsEnded;

  /// No description provided for @meetingsEndedBody.
  ///
  /// In en, this message translates to:
  /// **'Notes and recordings appear under Past calls when they are ready.'**
  String get meetingsEndedBody;

  /// No description provided for @meetingsRemovedTitle.
  ///
  /// In en, this message translates to:
  /// **'You were removed from the call'**
  String get meetingsRemovedTitle;

  /// No description provided for @meetingsRemovedBody.
  ///
  /// In en, this message translates to:
  /// **'A host removed you. You can’t rejoin this call.'**
  String get meetingsRemovedBody;

  /// No description provided for @meetingsRefused_locked.
  ///
  /// In en, this message translates to:
  /// **'The meeting is locked'**
  String get meetingsRefused_locked;

  /// No description provided for @meetingsRefused_full.
  ///
  /// In en, this message translates to:
  /// **'The meeting is full'**
  String get meetingsRefused_full;

  /// No description provided for @meetingsRefused_removed.
  ///
  /// In en, this message translates to:
  /// **'You were removed from this call'**
  String get meetingsRefused_removed;

  /// No description provided for @meetingsRefused_guests_off.
  ///
  /// In en, this message translates to:
  /// **'This meeting is for the workspace’s members'**
  String get meetingsRefused_guests_off;

  /// No description provided for @meetingsRefused_not_started.
  ///
  /// In en, this message translates to:
  /// **'The meeting hasn’t started yet'**
  String get meetingsRefused_not_started;

  /// No description provided for @meetingsRefused_cancelled.
  ///
  /// In en, this message translates to:
  /// **'This meeting was cancelled'**
  String get meetingsRefused_cancelled;

  /// No description provided for @meetingsRefused_denied.
  ///
  /// In en, this message translates to:
  /// **'You were not let in'**
  String get meetingsRefused_denied;

  /// No description provided for @meetingsRefused_expired.
  ///
  /// In en, this message translates to:
  /// **'Nobody answered'**
  String get meetingsRefused_expired;

  /// No description provided for @meetingsRole_host.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get meetingsRole_host;

  /// No description provided for @meetingsRole_cohost.
  ///
  /// In en, this message translates to:
  /// **'Co-host'**
  String get meetingsRole_cohost;

  /// No description provided for @meetingsRole_member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get meetingsRole_member;

  /// No description provided for @meetingsRole_guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get meetingsRole_guest;

  /// No description provided for @meetingsYou.
  ///
  /// In en, this message translates to:
  /// **'{name} (you)'**
  String meetingsYou(String name);

  /// No description provided for @meetingsYouShort.
  ///
  /// In en, this message translates to:
  /// **'you'**
  String get meetingsYouShort;

  /// No description provided for @meetingsScreenOf.
  ///
  /// In en, this message translates to:
  /// **'{name}’s screen'**
  String meetingsScreenOf(String name);

  /// No description provided for @meetingsPoorConnection.
  ///
  /// In en, this message translates to:
  /// **'Poor connection'**
  String get meetingsPoorConnection;

  /// No description provided for @meetingsHandRaised.
  ///
  /// In en, this message translates to:
  /// **'Hand raised'**
  String get meetingsHandRaised;

  /// No description provided for @meetingsPin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get meetingsPin;

  /// No description provided for @meetingsUnpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get meetingsUnpin;

  /// No description provided for @meetingsRecording.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get meetingsRecording;

  /// No description provided for @meetingsTakingNotes.
  ///
  /// In en, this message translates to:
  /// **'Taking notes'**
  String get meetingsTakingNotes;

  /// No description provided for @meetingsLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get meetingsLocked;

  /// No description provided for @meetingsReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting…'**
  String get meetingsReconnecting;

  /// No description provided for @meetingsEnableAudio.
  ///
  /// In en, this message translates to:
  /// **'Turn the sound on'**
  String get meetingsEnableAudio;

  /// No description provided for @meetingsWantsToJoin.
  ///
  /// In en, this message translates to:
  /// **'wants to join'**
  String get meetingsWantsToJoin;

  /// No description provided for @meetingsAndMore.
  ///
  /// In en, this message translates to:
  /// **'and {n} more'**
  String meetingsAndMore(String n);

  /// No description provided for @meetingsAdmit.
  ///
  /// In en, this message translates to:
  /// **'Admit'**
  String get meetingsAdmit;

  /// No description provided for @meetingsDeny.
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get meetingsDeny;

  /// No description provided for @meetingsSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get meetingsSeeAll;

  /// No description provided for @meetingsAskedToUnmute.
  ///
  /// In en, this message translates to:
  /// **'{name} asks you to unmute.'**
  String meetingsAskedToUnmute(String name);

  /// No description provided for @meetingsUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get meetingsUnmute;

  /// No description provided for @meetingsNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get meetingsNotNow;

  /// No description provided for @meetingsChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get meetingsChat;

  /// No description provided for @meetingsPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get meetingsPeople;

  /// No description provided for @meetingsMicToggle.
  ///
  /// In en, this message translates to:
  /// **'Microphone (Ctrl+D)'**
  String get meetingsMicToggle;

  /// No description provided for @meetingsCamToggle.
  ///
  /// In en, this message translates to:
  /// **'Camera (Ctrl+E)'**
  String get meetingsCamToggle;

  /// No description provided for @meetingsShareScreen.
  ///
  /// In en, this message translates to:
  /// **'Share your screen'**
  String get meetingsShareScreen;

  /// No description provided for @meetingsStopSharing.
  ///
  /// In en, this message translates to:
  /// **'Stop sharing'**
  String get meetingsStopSharing;

  /// No description provided for @meetingsRaiseHand.
  ///
  /// In en, this message translates to:
  /// **'Raise your hand'**
  String get meetingsRaiseHand;

  /// No description provided for @meetingsLowerHand.
  ///
  /// In en, this message translates to:
  /// **'Lower hand'**
  String get meetingsLowerHand;

  /// No description provided for @meetingsReact.
  ///
  /// In en, this message translates to:
  /// **'React'**
  String get meetingsReact;

  /// No description provided for @meetingsSpeakerView.
  ///
  /// In en, this message translates to:
  /// **'Speaker view'**
  String get meetingsSpeakerView;

  /// No description provided for @meetingsGridView.
  ///
  /// In en, this message translates to:
  /// **'Grid view'**
  String get meetingsGridView;

  /// No description provided for @meetingsHostControls.
  ///
  /// In en, this message translates to:
  /// **'Host controls'**
  String get meetingsHostControls;

  /// No description provided for @meetingsStartRecording.
  ///
  /// In en, this message translates to:
  /// **'Start recording'**
  String get meetingsStartRecording;

  /// No description provided for @meetingsStopRecording.
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get meetingsStopRecording;

  /// No description provided for @meetingsRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Record this call?'**
  String get meetingsRecordTitle;

  /// No description provided for @meetingsRecordBody.
  ///
  /// In en, this message translates to:
  /// **'Everyone in the call sees that it is recorded, and people who join are told before they do.'**
  String get meetingsRecordBody;

  /// No description provided for @meetingsStartNotes.
  ///
  /// In en, this message translates to:
  /// **'Take notes'**
  String get meetingsStartNotes;

  /// No description provided for @meetingsStopNotes.
  ///
  /// In en, this message translates to:
  /// **'Stop taking notes'**
  String get meetingsStopNotes;

  /// No description provided for @meetingsLock.
  ///
  /// In en, this message translates to:
  /// **'Lock the meeting'**
  String get meetingsLock;

  /// No description provided for @meetingsUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock the meeting'**
  String get meetingsUnlock;

  /// No description provided for @meetingsMuteAll.
  ///
  /// In en, this message translates to:
  /// **'Mute everyone'**
  String get meetingsMuteAll;

  /// No description provided for @meetingsQuietGuests.
  ///
  /// In en, this message translates to:
  /// **'Turn off guests’ chat and screen sharing'**
  String get meetingsQuietGuests;

  /// No description provided for @meetingsGuestsSpeakAgain.
  ///
  /// In en, this message translates to:
  /// **'Let guests chat and share again'**
  String get meetingsGuestsSpeakAgain;

  /// No description provided for @meetingsOpenTitle.
  ///
  /// In en, this message translates to:
  /// **'Let anyone with the link in?'**
  String get meetingsOpenTitle;

  /// No description provided for @meetingsOpenBody.
  ///
  /// In en, this message translates to:
  /// **'Until this call ends, guests join without waiting.'**
  String get meetingsOpenBody;

  /// No description provided for @meetingsLetAnyoneIn.
  ///
  /// In en, this message translates to:
  /// **'Let them in'**
  String get meetingsLetAnyoneIn;

  /// No description provided for @meetingsEndForAll.
  ///
  /// In en, this message translates to:
  /// **'End the call for everyone'**
  String get meetingsEndForAll;

  /// No description provided for @meetingsEndTitle.
  ///
  /// In en, this message translates to:
  /// **'End the call for everyone?'**
  String get meetingsEndTitle;

  /// No description provided for @meetingsEndBody.
  ///
  /// In en, this message translates to:
  /// **'Everyone is disconnected. Notes are written from what was recorded.'**
  String get meetingsEndBody;

  /// No description provided for @meetingsLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get meetingsLeave;

  /// No description provided for @meetingsWaiting.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} waiting} other {{n} waiting}}'**
  String meetingsWaiting(num n);

  /// No description provided for @meetingsAdmitAll.
  ///
  /// In en, this message translates to:
  /// **'Admit all'**
  String get meetingsAdmitAll;

  /// No description provided for @meetingsHands.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} raised hand} other {{n} raised hands}}'**
  String meetingsHands(num n);

  /// No description provided for @meetingsInCall.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} in the call} other {{n} in the call}}'**
  String meetingsInCall(num n);

  /// No description provided for @meetingsDevices.
  ///
  /// In en, this message translates to:
  /// **'{n} devices'**
  String meetingsDevices(String n);

  /// No description provided for @meetingsActionsFor.
  ///
  /// In en, this message translates to:
  /// **'Actions for {name}'**
  String meetingsActionsFor(String name);

  /// No description provided for @meetingsMuteMic.
  ///
  /// In en, this message translates to:
  /// **'Mute microphone'**
  String get meetingsMuteMic;

  /// No description provided for @meetingsStopCamera.
  ///
  /// In en, this message translates to:
  /// **'Stop camera'**
  String get meetingsStopCamera;

  /// No description provided for @meetingsStopScreen.
  ///
  /// In en, this message translates to:
  /// **'Stop screen sharing'**
  String get meetingsStopScreen;

  /// No description provided for @meetingsAskUnmute.
  ///
  /// In en, this message translates to:
  /// **'Ask to unmute'**
  String get meetingsAskUnmute;

  /// No description provided for @meetingsMakeCohost.
  ///
  /// In en, this message translates to:
  /// **'Make co-host'**
  String get meetingsMakeCohost;

  /// No description provided for @meetingsUncohost.
  ///
  /// In en, this message translates to:
  /// **'Remove as co-host'**
  String get meetingsUncohost;

  /// No description provided for @meetingsRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from the call'**
  String get meetingsRemove;

  /// No description provided for @meetingsRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String meetingsRemoveTitle(String name);

  /// No description provided for @meetingsRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'They are disconnected on every device and can’t come back to this call.'**
  String get meetingsRemoveBody;

  /// No description provided for @meetingsChatEmpty.
  ///
  /// In en, this message translates to:
  /// **'No messages yet. Messages are kept with the call.'**
  String get meetingsChatEmpty;

  /// No description provided for @meetingsChatPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Send a message to everyone'**
  String get meetingsChatPlaceholder;

  /// No description provided for @meetingsChatOff.
  ///
  /// In en, this message translates to:
  /// **'The hosts turned guests’ chat off.'**
  String get meetingsChatOff;

  /// No description provided for @meetingsSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get meetingsSend;

  /// No description provided for @meetingsCallingYou.
  ///
  /// In en, this message translates to:
  /// **'{name} is calling you'**
  String meetingsCallingYou(String name);

  /// No description provided for @meetingsStartsSoon.
  ///
  /// In en, this message translates to:
  /// **'A meeting starts soon'**
  String get meetingsStartsSoon;

  /// No description provided for @meetingsHasStarted.
  ///
  /// In en, this message translates to:
  /// **'A meeting you’re invited to has started'**
  String get meetingsHasStarted;

  /// No description provided for @meetingsKnockAway.
  ///
  /// In en, this message translates to:
  /// **'{name} wants to join your meeting'**
  String meetingsKnockAway(String name);

  /// No description provided for @meetingsDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get meetingsDecline;

  /// No description provided for @meetingsDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get meetingsDismiss;

  /// No description provided for @meetingsColHost.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get meetingsColHost;

  /// No description provided for @meetingsFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Full screen'**
  String get meetingsFullscreen;

  /// No description provided for @meetingsExitFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Exit full screen'**
  String get meetingsExitFullscreen;

  /// No description provided for @meetingsColPerson.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get meetingsColPerson;

  /// No description provided for @meetingsColInCall.
  ///
  /// In en, this message translates to:
  /// **'In the call'**
  String get meetingsColInCall;

  /// No description provided for @meetingsColDuration.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get meetingsColDuration;

  /// No description provided for @meetingsLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave the call?'**
  String get meetingsLeaveTitle;

  /// No description provided for @meetingsLeaveBody.
  ///
  /// In en, this message translates to:
  /// **'You can join again with the same link while the call is on.'**
  String get meetingsLeaveBody;

  /// No description provided for @meetingsLeaveBodyHost.
  ///
  /// In en, this message translates to:
  /// **'The call goes on without you. To close it for everyone, choose “End the call for everyone” in Host controls.'**
  String get meetingsLeaveBodyHost;

  /// No description provided for @meetingsStopRecordingTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop recording?'**
  String get meetingsStopRecordingTitle;

  /// No description provided for @meetingsStopRecordingBody.
  ///
  /// In en, this message translates to:
  /// **'What was recorded so far is saved and appears on the call’s page.'**
  String get meetingsStopRecordingBody;

  /// No description provided for @meetingsStopNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop taking notes?'**
  String get meetingsStopNotesTitle;

  /// No description provided for @meetingsStopNotesBody.
  ///
  /// In en, this message translates to:
  /// **'Muse writes the notes from what it heard until now.'**
  String get meetingsStopNotesBody;

  /// No description provided for @meetingsMuteAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Mute everyone?'**
  String get meetingsMuteAllTitle;

  /// No description provided for @meetingsMuteAllBody.
  ///
  /// In en, this message translates to:
  /// **'Everyone except you is muted. They can unmute themselves.'**
  String get meetingsMuteAllBody;

  /// No description provided for @meetingsLockTitle.
  ///
  /// In en, this message translates to:
  /// **'Lock the meeting?'**
  String get meetingsLockTitle;

  /// No description provided for @meetingsLockBody.
  ///
  /// In en, this message translates to:
  /// **'Nobody new can join or knock until you unlock it. People already admitted, and the hosts, can still come back.'**
  String get meetingsLockBody;

  /// No description provided for @meetingsAdmitAllTitle.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {Let {n} person in?} other {Let {n} people in?}}'**
  String meetingsAdmitAllTitle(num n);

  /// No description provided for @meetingsAdmitAllBody.
  ///
  /// In en, this message translates to:
  /// **'Everyone waiting joins the call now.'**
  String get meetingsAdmitAllBody;

  /// No description provided for @meetingsCohostTitle.
  ///
  /// In en, this message translates to:
  /// **'Make {name} a co-host?'**
  String meetingsCohostTitle(String name);

  /// No description provided for @meetingsCohostBody.
  ///
  /// In en, this message translates to:
  /// **'Co-hosts can let people in, mute and remove them, record the call and take notes.'**
  String get meetingsCohostBody;

  /// No description provided for @meetingsWriteAgainTitle.
  ///
  /// In en, this message translates to:
  /// **'Write the notes again?'**
  String get meetingsWriteAgainTitle;

  /// No description provided for @meetingsWriteAgainBody.
  ///
  /// In en, this message translates to:
  /// **'Muse writes them again from the call and replaces the current notes, with any changes made to them.'**
  String get meetingsWriteAgainBody;

  /// No description provided for @meetingsUninviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from the invitations?'**
  String meetingsUninviteTitle(String name);

  /// No description provided for @meetingsUninviteBody.
  ///
  /// In en, this message translates to:
  /// **'They are no longer invited and get no more reminders.'**
  String get meetingsUninviteBody;

  /// No description provided for @mgroupsGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get mgroupsGroups;

  /// No description provided for @mgroupsRepos.
  ///
  /// In en, this message translates to:
  /// **'Repositories'**
  String get mgroupsRepos;

  /// No description provided for @mgroupsPickHint.
  ///
  /// In en, this message translates to:
  /// **'Pick one or more. The first one is the main one.'**
  String get mgroupsPickHint;

  /// No description provided for @mgroupsInTask.
  ///
  /// In en, this message translates to:
  /// **'In this task'**
  String get mgroupsInTask;

  /// No description provided for @mgroupsFromGroup.
  ///
  /// In en, this message translates to:
  /// **'All of {name}'**
  String mgroupsFromGroup(String name);

  /// No description provided for @mgroupsFromGroupEdited.
  ///
  /// In en, this message translates to:
  /// **'From {name}, edited'**
  String mgroupsFromGroupEdited(String name);

  /// No description provided for @mgroupsPrimary.
  ///
  /// In en, this message translates to:
  /// **'main'**
  String get mgroupsPrimary;

  /// No description provided for @mgroupsRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String mgroupsRemove(String name);

  /// No description provided for @mgroupsNoMembers.
  ///
  /// In en, this message translates to:
  /// **'This group has no active repositories.'**
  String get mgroupsNoMembers;

  /// No description provided for @mgroupsGroup.
  ///
  /// In en, this message translates to:
  /// **'Group {name}'**
  String mgroupsGroup(String name);

  /// No description provided for @mgroupsPartlyMerged.
  ///
  /// In en, this message translates to:
  /// **'Partly merged'**
  String get mgroupsPartlyMerged;

  /// No description provided for @mgroupsArchived.
  ///
  /// In en, this message translates to:
  /// **'archived'**
  String get mgroupsArchived;

  /// No description provided for @mgroupsPushError.
  ///
  /// In en, this message translates to:
  /// **'Push failed: {error}'**
  String mgroupsPushError(String error);

  /// No description provided for @mgroupsFiles.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} file} other {{n} files}}'**
  String mgroupsFiles(num n);

  /// No description provided for @mgroupsCiFixes.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} CI fix} other {{n} CI fixes}}'**
  String mgroupsCiFixes(num n);

  /// No description provided for @mgroupsStatePending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get mgroupsStatePending;

  /// No description provided for @mgroupsStateUnchanged.
  ///
  /// In en, this message translates to:
  /// **'No changes'**
  String get mgroupsStateUnchanged;

  /// No description provided for @mgroupsStatePushed.
  ///
  /// In en, this message translates to:
  /// **'Pushed'**
  String get mgroupsStatePushed;

  /// No description provided for @mgroupsStateMerged.
  ///
  /// In en, this message translates to:
  /// **'Merged'**
  String get mgroupsStateMerged;

  /// No description provided for @mgroupsStateDropped.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get mgroupsStateDropped;

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

  /// No description provided for @minsightsSaved.
  ///
  /// In en, this message translates to:
  /// **'{name} saved'**
  String minsightsSaved(String name);

  /// No description provided for @minsightsEditTask.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get minsightsEditTask;

  /// No description provided for @minsightsEditTaskSub.
  ///
  /// In en, this message translates to:
  /// **'Only a task that hasn\'t started can be changed.'**
  String get minsightsEditTaskSub;

  /// No description provided for @minsightsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get minsightsSave;

  /// No description provided for @minsightsTaskSaved.
  ///
  /// In en, this message translates to:
  /// **'Task saved'**
  String get minsightsTaskSaved;

  /// No description provided for @minsightsTaskDeleted.
  ///
  /// In en, this message translates to:
  /// **'Task {key} deleted'**
  String minsightsTaskDeleted(String key);

  /// No description provided for @minsightsTaskActions.
  ///
  /// In en, this message translates to:
  /// **'Task actions'**
  String get minsightsTaskActions;

  /// No description provided for @mmanageFillAll.
  ///
  /// In en, this message translates to:
  /// **'Fill in the required fields.'**
  String get mmanageFillAll;

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

  /// No description provided for @mobilePushProgress.
  ///
  /// In en, this message translates to:
  /// **'When an agent finishes a step'**
  String get mobilePushProgress;

  /// No description provided for @mobilePushProgressHelp.
  ///
  /// In en, this message translates to:
  /// **'Analysis done, code written. Phone only, silent, one notification per ticket'**
  String get mobilePushProgressHelp;

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

  /// No description provided for @mobileAdminAppOnly.
  ///
  /// In en, this message translates to:
  /// **'This is an Admin account. Open it in the agnts admin app.'**
  String get mobileAdminAppOnly;

  /// No description provided for @mobileGoogleContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get mobileGoogleContinue;

  /// No description provided for @mobileGoogleOff.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in is off on this server.'**
  String get mobileGoogleOff;

  /// No description provided for @mobileGoogleSetup.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in is not set up in this build of the app.'**
  String get mobileGoogleSetup;

  /// No description provided for @modulesName_muse.
  ///
  /// In en, this message translates to:
  /// **'Muse Code'**
  String get modulesName_muse;

  /// No description provided for @modulesName_claude.
  ///
  /// In en, this message translates to:
  /// **'Claude Code'**
  String get modulesName_claude;

  /// No description provided for @modulesName_codex.
  ///
  /// In en, this message translates to:
  /// **'Codex'**
  String get modulesName_codex;

  /// No description provided for @modulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Modules'**
  String get modulesTitle;

  /// No description provided for @modulesSub.
  ///
  /// In en, this message translates to:
  /// **'Which coding modules people may use. The first in a person\'s list is their default module.'**
  String get modulesSub;

  /// No description provided for @modulesAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available on this server'**
  String get modulesAvailable;

  /// No description provided for @modulesAvailableHelp.
  ///
  /// In en, this message translates to:
  /// **'What this server can run (AGNTS_PROVIDERS). It cannot be changed here.'**
  String get modulesAvailableHelp;

  /// No description provided for @modulesEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get modulesEnabled;

  /// No description provided for @modulesEnabledHelp.
  ///
  /// In en, this message translates to:
  /// **'What people may be given. Switching a module off takes it from everyone.'**
  String get modulesEnabledHelp;

  /// No description provided for @modulesDefaultList.
  ///
  /// In en, this message translates to:
  /// **'Default for people'**
  String get modulesDefaultList;

  /// No description provided for @modulesDefaultListHelp.
  ///
  /// In en, this message translates to:
  /// **'What a person gets unless you set theirs on the Users page. The first is their default module.'**
  String get modulesDefaultListHelp;

  /// No description provided for @modulesDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get modulesDefault;

  /// No description provided for @modulesMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move {module} up'**
  String modulesMoveUp(String module);

  /// No description provided for @modulesMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move {module} down'**
  String modulesMoveDown(String module);

  /// No description provided for @modulesProblem_noneEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enable at least one module.'**
  String get modulesProblem_noneEnabled;

  /// No description provided for @modulesProblem_empty.
  ///
  /// In en, this message translates to:
  /// **'Choose at least one module.'**
  String get modulesProblem_empty;

  /// No description provided for @modulesProblem_codexFirst.
  ///
  /// In en, this message translates to:
  /// **'Codex cannot be the default module: put Muse Code or Claude Code first.'**
  String get modulesProblem_codexFirst;

  /// No description provided for @modulesSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get modulesSave;

  /// No description provided for @modulesSaved.
  ///
  /// In en, this message translates to:
  /// **'Modules saved'**
  String get modulesSaved;

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

  /// No description provided for @mpullsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Markdown'**
  String get mpullsPlaceholder;

  /// No description provided for @mpullsLineHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a line to comment on it.'**
  String get mpullsLineHint;

  /// No description provided for @mpullsCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Open on {host}'**
  String mpullsCopyLink(String host);

  /// No description provided for @mqualityNewTest.
  ///
  /// In en, this message translates to:
  /// **'New Swagger test'**
  String get mqualityNewTest;

  /// No description provided for @mqualityStarterFor.
  ///
  /// In en, this message translates to:
  /// **'Starter rules for'**
  String get mqualityStarterFor;

  /// No description provided for @mqualityStarterPick.
  ///
  /// In en, this message translates to:
  /// **'Pick a repository to see the starter packs for its languages.'**
  String get mqualityStarterPick;

  /// No description provided for @mqualitySearchRules.
  ///
  /// In en, this message translates to:
  /// **'Search rules'**
  String get mqualitySearchRules;

  /// No description provided for @mqualityRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Request {id}'**
  String mqualityRequestTitle(String id);

  /// No description provided for @mqualitySpecFile.
  ///
  /// In en, this message translates to:
  /// **'Spec file: {name}'**
  String mqualitySpecFile(String name);

  /// No description provided for @mqualityDeployHook.
  ///
  /// In en, this message translates to:
  /// **'Deploy hook'**
  String get mqualityDeployHook;

  /// No description provided for @mqualityTokenSaved.
  ///
  /// In en, this message translates to:
  /// **'Token saved'**
  String get mqualityTokenSaved;

  /// No description provided for @mqualitySuiteDeleted.
  ///
  /// In en, this message translates to:
  /// **'Suite deleted'**
  String get mqualitySuiteDeleted;

  /// No description provided for @mqualityHourAt.
  ///
  /// In en, this message translates to:
  /// **'{hour}:00 UTC'**
  String mqualityHourAt(String hour);

  /// No description provided for @mqualityReviewTickets.
  ///
  /// In en, this message translates to:
  /// **'Pull requests'**
  String get mqualityReviewTickets;

  /// No description provided for @mqualityAddReviewer.
  ///
  /// In en, this message translates to:
  /// **'Add a reviewer'**
  String get mqualityAddReviewer;

  /// No description provided for @mqualityEndpointsTicked.
  ///
  /// In en, this message translates to:
  /// **'Endpoints'**
  String get mqualityEndpointsTicked;

  /// No description provided for @mqualityShowCases.
  ///
  /// In en, this message translates to:
  /// **'Show cases'**
  String get mqualityShowCases;

  /// No description provided for @mqualityHideCases.
  ///
  /// In en, this message translates to:
  /// **'Hide cases'**
  String get mqualityHideCases;

  /// No description provided for @mrepodetailCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Open on {host}'**
  String mrepodetailCopyLink(String host);

  /// No description provided for @mrepodetailOnePerLine.
  ///
  /// In en, this message translates to:
  /// **'One per line.'**
  String get mrepodetailOnePerLine;

  /// No description provided for @mrepodetailLinesCapped.
  ///
  /// In en, this message translates to:
  /// **'Only the first {n} lines are shown here.'**
  String mrepodetailLinesCapped(String n);

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

  /// No description provided for @mwsNone.
  ///
  /// In en, this message translates to:
  /// **'You\'re not in a workspace yet. Create one or accept an invite in the web admin, then pull to refresh.'**
  String get mwsNone;

  /// No description provided for @mwsSwitched.
  ///
  /// In en, this message translates to:
  /// **'Switched to {name}'**
  String mwsSwitched(String name);

  /// No description provided for @mwsMembers.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} member} other {{n} members}}'**
  String mwsMembers(num n);

  /// No description provided for @mwsSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get mwsSuspended;

  /// No description provided for @navOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get navOverview;

  /// No description provided for @navWorkflow.
  ///
  /// In en, this message translates to:
  /// **'Workflow'**
  String get navWorkflow;

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
  /// **'Search pages, repositories, tickets, chats, lessons'**
  String get navSearch;

  /// No description provided for @navSearchPages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get navSearchPages;

  /// No description provided for @navSearchNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get navSearchNone;

  /// No description provided for @navSearchResults.
  ///
  /// In en, this message translates to:
  /// **'Search results'**
  String get navSearchResults;

  /// No description provided for @navSyncJira.
  ///
  /// In en, this message translates to:
  /// **'Sync Jira'**
  String get navSyncJira;

  /// No description provided for @navSynced.
  ///
  /// In en, this message translates to:
  /// **'Jira synced: {found} open, {created} new, {updated} updated, {waiting} waiting for your choice'**
  String navSynced(String found, String created, String updated, String waiting);

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

  /// No description provided for @navCreditsLeft.
  ///
  /// In en, this message translates to:
  /// **'{amount} of {total} credits left'**
  String navCreditsLeft(String amount, String total);

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
  /// **'Every ticket agnts has picked up from Jira and Plane.'**
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

  /// No description provided for @navSyncPlane.
  ///
  /// In en, this message translates to:
  /// **'Sync Plane'**
  String get navSyncPlane;

  /// No description provided for @navSyncedPlane.
  ///
  /// In en, this message translates to:
  /// **'Plane synced: {found} open, {created} new'**
  String navSyncedPlane(String found, String created);

  /// No description provided for @navWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get navWorkspace;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navPlatform.
  ///
  /// In en, this message translates to:
  /// **'Admin cabinet'**
  String get navPlatform;

  /// No description provided for @navPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get navPeople;

  /// No description provided for @navAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get navAccount;

  /// No description provided for @navReviews.
  ///
  /// In en, this message translates to:
  /// **'PR reviews'**
  String get navReviews;

  /// No description provided for @navCi.
  ///
  /// In en, this message translates to:
  /// **'CI'**
  String get navCi;

  /// No description provided for @navAiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI assistant'**
  String get navAiAssistant;

  /// No description provided for @navAssistantChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navAssistantChat;

  /// No description provided for @navAssistantCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get navAssistantCode;

  /// No description provided for @navAssistantConversations.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get navAssistantConversations;

  /// No description provided for @navDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get navDocuments;

  /// No description provided for @navMeetings.
  ///
  /// In en, this message translates to:
  /// **'Meetings'**
  String get navMeetings;

  /// No description provided for @networkTitle.
  ///
  /// In en, this message translates to:
  /// **'Private networks'**
  String get networkTitle;

  /// No description provided for @networkSub.
  ///
  /// In en, this message translates to:
  /// **'Reach self-hosted GitLab, Jira or package registries inside your networks. A connection goes through the network whose route matches it most closely.'**
  String get networkSub;

  /// No description provided for @networkUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Private networks are not set up on this server: the operator runs the gateway service and sets AGNTS_GATEWAY.'**
  String get networkUnavailable;

  /// No description provided for @networkStatus_up.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get networkStatus_up;

  /// No description provided for @networkStatus_connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting'**
  String get networkStatus_connecting;

  /// No description provided for @networkStatus_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get networkStatus_error;

  /// No description provided for @networkStatus_gateway_down.
  ///
  /// In en, this message translates to:
  /// **'Gateway down'**
  String get networkStatus_gateway_down;

  /// No description provided for @networkStatus_disabled.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get networkStatus_disabled;

  /// No description provided for @networkHandshake.
  ///
  /// In en, this message translates to:
  /// **'Last handshake'**
  String get networkHandshake;

  /// No description provided for @networkHeartbeat.
  ///
  /// In en, this message translates to:
  /// **'Last heartbeat'**
  String get networkHeartbeat;

  /// No description provided for @networkWebhooksRelay.
  ///
  /// In en, this message translates to:
  /// **'Relayed by agnts-link'**
  String get networkWebhooksRelay;

  /// No description provided for @networkWebhooksPolling.
  ///
  /// In en, this message translates to:
  /// **'No webhooks: trackers reached through it are read every {n} min'**
  String networkWebhooksPolling(String n);

  /// No description provided for @networkKind.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get networkKind;

  /// No description provided for @networkKindConnector.
  ///
  /// In en, this message translates to:
  /// **'agnts-link (recommended)'**
  String get networkKindConnector;

  /// No description provided for @networkKindHelp_connector.
  ///
  /// In en, this message translates to:
  /// **'A small agent you run inside your network. It connects out to agnts: no VPN credentials, no inbound firewall rule, and it relays webhooks.'**
  String get networkKindHelp_connector;

  /// No description provided for @networkKindHelp_wireguard.
  ///
  /// In en, this message translates to:
  /// **'agnts connects to your WireGuard peer as a client. The peer must accept UDP from this server.'**
  String get networkKindHelp_wireguard;

  /// No description provided for @networkKindHelp_openvpn.
  ///
  /// In en, this message translates to:
  /// **'agnts runs your OpenVPN client config in an isolated container. Certificates must be inline; logins that need MFA are not supported.'**
  String get networkKindHelp_openvpn;

  /// No description provided for @networkEnabled.
  ///
  /// In en, this message translates to:
  /// **'Turned on'**
  String get networkEnabled;

  /// No description provided for @networkConfigWg.
  ///
  /// In en, this message translates to:
  /// **'WireGuard config'**
  String get networkConfigWg;

  /// No description provided for @networkConfigOvpn.
  ///
  /// In en, this message translates to:
  /// **'OpenVPN config (.ovpn)'**
  String get networkConfigOvpn;

  /// No description provided for @networkSavedConfig.
  ///
  /// In en, this message translates to:
  /// **'Saved: {summary}. Leave empty to keep it.'**
  String networkSavedConfig(String summary);

  /// No description provided for @networkConfigWgHelp.
  ///
  /// In en, this message translates to:
  /// **'The file you would give wg-quick. Add a DNS line to reach hosts by name. Keys are encrypted and never shown again.'**
  String get networkConfigWgHelp;

  /// No description provided for @networkConfigOvpnHelp.
  ///
  /// In en, this message translates to:
  /// **'A client config with its ca, cert and key blocks inline. Scripts (up, down, plugin…) are refused.'**
  String get networkConfigOvpnHelp;

  /// No description provided for @networkUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get networkUsername;

  /// No description provided for @networkPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get networkPassword;

  /// No description provided for @networkPasswordKeep.
  ///
  /// In en, this message translates to:
  /// **'Saved: leave empty to keep it'**
  String get networkPasswordKeep;

  /// No description provided for @networkRoutes.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get networkRoutes;

  /// No description provided for @networkRoutesHelp.
  ///
  /// In en, this message translates to:
  /// **'Hosts (gitlab.corp.local), domains (.corp.local) or private ranges (10.20.0.0/16) that go through this network, with ports (80 and 443 when empty). Another network may have a narrower route inside these (10.30.0.0/16 inside 10.0.0.0/8): the more specific one wins. Two networks may not list the same route.'**
  String get networkRoutesHelp;

  /// No description provided for @networkRouteTarget.
  ///
  /// In en, this message translates to:
  /// **'Host, domain or range'**
  String get networkRouteTarget;

  /// No description provided for @networkRoutePorts.
  ///
  /// In en, this message translates to:
  /// **'Ports'**
  String get networkRoutePorts;

  /// No description provided for @networkRemoveRoute.
  ///
  /// In en, this message translates to:
  /// **'Remove route'**
  String get networkRemoveRoute;

  /// No description provided for @networkAddRoute.
  ///
  /// In en, this message translates to:
  /// **'Add route'**
  String get networkAddRoute;

  /// No description provided for @networkBlastRadius.
  ///
  /// In en, this message translates to:
  /// **'Code agnts runs for your tickets can reach every host listed here. List exact hosts rather than whole ranges.'**
  String get networkBlastRadius;

  /// No description provided for @networkCa.
  ///
  /// In en, this message translates to:
  /// **'Company CA bundle'**
  String get networkCa;

  /// No description provided for @networkCaSaved.
  ///
  /// In en, this message translates to:
  /// **'Trusted: {subjects} (until {date}).'**
  String networkCaSaved(String subjects, String date);

  /// No description provided for @networkCaRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get networkCaRemove;

  /// No description provided for @networkCaHelp.
  ///
  /// In en, this message translates to:
  /// **'PEM certificates of your internal CA. agnts and its runs trust them besides the public roots.'**
  String get networkCaHelp;

  /// No description provided for @networkSaved.
  ///
  /// In en, this message translates to:
  /// **'{name} saved'**
  String networkSaved(String name);

  /// No description provided for @networkRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get networkRemove;

  /// No description provided for @networkRemoved.
  ///
  /// In en, this message translates to:
  /// **'Private network removed'**
  String get networkRemoved;

  /// No description provided for @networkRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}? agnts will stop reaching the hosts on its routes.'**
  String networkRemoveConfirm(String name);

  /// No description provided for @networkLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Run agnts-link'**
  String get networkLinkTitle;

  /// No description provided for @networkLinkHelp.
  ///
  /// In en, this message translates to:
  /// **'Run this on a machine inside the network that can reach the hosts above. AGNTS_LINK_ALLOW is your own limit: agnts-link never dials anything else. Each network has its own token, so one machine can run several links.'**
  String get networkLinkHelp;

  /// No description provided for @networkToken.
  ///
  /// In en, this message translates to:
  /// **'Token'**
  String get networkToken;

  /// No description provided for @networkTokenOnce.
  ///
  /// In en, this message translates to:
  /// **'Copy it now: it is shown only once.'**
  String get networkTokenOnce;

  /// No description provided for @networkLinkHooks.
  ///
  /// In en, this message translates to:
  /// **'Webhooks: point GitLab and Jira at http://AGNTS-LINK-HOST:8080 with the same /webhooks/… path the Integrations page shows.'**
  String get networkLinkHooks;

  /// No description provided for @networkRotate.
  ///
  /// In en, this message translates to:
  /// **'Replace token'**
  String get networkRotate;

  /// No description provided for @networkRotateConfirm.
  ///
  /// In en, this message translates to:
  /// **'Make a new token? The running agnts-link disconnects until you restart it with the new one.'**
  String get networkRotateConfirm;

  /// No description provided for @networkTest.
  ///
  /// In en, this message translates to:
  /// **'Test a connection'**
  String get networkTest;

  /// No description provided for @networkTestRun.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get networkTestRun;

  /// No description provided for @networkTesting.
  ///
  /// In en, this message translates to:
  /// **'Testing…'**
  String get networkTesting;

  /// No description provided for @networkTestOk.
  ///
  /// In en, this message translates to:
  /// **'Connected through {name} ({via}) to {ip} in {ms} ms.'**
  String networkTestOk(String name, String via, String ip, String ms);

  /// No description provided for @networkTlsOk.
  ///
  /// In en, this message translates to:
  /// **'Certificate OK: {subject}, issued by {issuer}.'**
  String networkTlsOk(String subject, String issuer);

  /// No description provided for @networkTlsBad.
  ///
  /// In en, this message translates to:
  /// **'Certificate not trusted: {error}'**
  String networkTlsBad(String error);

  /// No description provided for @networkActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get networkActivity;

  /// No description provided for @networkActivityCounts.
  ///
  /// In en, this message translates to:
  /// **'{n} connections, {refused} refused or failed'**
  String networkActivityCounts(String n, String refused);

  /// No description provided for @networkActivityShow.
  ///
  /// In en, this message translates to:
  /// **'Show connections'**
  String get networkActivityShow;

  /// No description provided for @networkActivityHide.
  ///
  /// In en, this message translates to:
  /// **'Hide connections'**
  String get networkActivityHide;

  /// No description provided for @networkRefused.
  ///
  /// In en, this message translates to:
  /// **'refused'**
  String get networkRefused;

  /// No description provided for @networkSecondsAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} s ago'**
  String networkSecondsAgo(String n);

  /// No description provided for @networkMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} min ago'**
  String networkMinutesAgo(String n);

  /// No description provided for @networkHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} h ago'**
  String networkHoursAgo(String n);

  /// No description provided for @networkReconnect.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get networkReconnect;

  /// No description provided for @networkReconnectHelp.
  ///
  /// In en, this message translates to:
  /// **'Restart the tunnel: a fresh OpenVPN client, a new WireGuard handshake, or agnts-link connects again'**
  String get networkReconnectHelp;

  /// No description provided for @networkReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting: the tunnel restarts within 15 seconds'**
  String get networkReconnecting;

  /// No description provided for @networkAdd.
  ///
  /// In en, this message translates to:
  /// **'Add network'**
  String get networkAdd;

  /// No description provided for @networkAddTitle.
  ///
  /// In en, this message translates to:
  /// **'New private network'**
  String get networkAddTitle;

  /// No description provided for @networkAddSubmit.
  ///
  /// In en, this message translates to:
  /// **'Add network'**
  String get networkAddSubmit;

  /// No description provided for @networkEditorSub.
  ///
  /// In en, this message translates to:
  /// **'A tunnel into one of your networks and the hosts that go through it'**
  String get networkEditorSub;

  /// No description provided for @networkEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get networkEdit;

  /// No description provided for @networkDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get networkDone;

  /// No description provided for @networkName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get networkName;

  /// No description provided for @networkNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Client A, Office, Data center'**
  String get networkNamePlaceholder;

  /// No description provided for @networkNameHelp.
  ///
  /// In en, this message translates to:
  /// **'Unique in the workspace: the company, office or data center it reaches.'**
  String get networkNameHelp;

  /// No description provided for @networkEmpty.
  ///
  /// In en, this message translates to:
  /// **'No private networks yet. Add one to reach hosts that are only inside your network.'**
  String get networkEmpty;

  /// No description provided for @networkLimit.
  ///
  /// In en, this message translates to:
  /// **'A workspace keeps at most {n} private networks'**
  String networkLimit(String n);

  /// No description provided for @networkCaShort.
  ///
  /// In en, this message translates to:
  /// **'Trusts {subjects}'**
  String networkCaShort(String subjects);

  /// No description provided for @networkTestHelp.
  ///
  /// In en, this message translates to:
  /// **'Enter host:port. agnts picks the network the routes lead to, connects and checks the certificate.'**
  String get networkTestHelp;

  /// No description provided for @networkTestThrough.
  ///
  /// In en, this message translates to:
  /// **'Through'**
  String get networkTestThrough;

  /// No description provided for @networkTestAuto.
  ///
  /// In en, this message translates to:
  /// **'The network the routes pick'**
  String get networkTestAuto;

  /// No description provided for @networkActivityAll.
  ///
  /// In en, this message translates to:
  /// **'All networks'**
  String get networkActivityAll;

  /// No description provided for @networkActivityNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get networkActivityNetwork;

  /// No description provided for @networkActivityTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get networkActivityTime;

  /// No description provided for @networkActivityTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get networkActivityTarget;

  /// No description provided for @networkActivitySource.
  ///
  /// In en, this message translates to:
  /// **'Ticket or source'**
  String get networkActivitySource;

  /// No description provided for @networkGone.
  ///
  /// In en, this message translates to:
  /// **'removed'**
  String get networkGone;

  /// No description provided for @networkDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get networkDisconnect;

  /// No description provided for @networkDisconnectHelp.
  ///
  /// In en, this message translates to:
  /// **'Stop the tunnel. Runs reach nothing through it until you connect again; the config is kept'**
  String get networkDisconnectHelp;

  /// No description provided for @networkDisconnectConfirm.
  ///
  /// In en, this message translates to:
  /// **'Disconnect {name}? Runs and trackers reached through it stop working until you connect it again. Its config is kept.'**
  String networkDisconnectConfirm(String name);

  /// No description provided for @networkDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get networkDisconnected;

  /// No description provided for @networkConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get networkConnect;

  /// No description provided for @networkConnectHelp.
  ///
  /// In en, this message translates to:
  /// **'Start the tunnel again with the saved config'**
  String get networkConnectHelp;

  /// No description provided for @networkConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting: the tunnel starts within 15 seconds'**
  String get networkConnecting;

  /// No description provided for @networkManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get networkManage;

  /// No description provided for @platformTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin cabinet'**
  String get platformTitle;

  /// No description provided for @platformLede.
  ///
  /// In en, this message translates to:
  /// **'Every workspace, run and user on this server. Workspaces show metadata only: their tickets are their members\'.'**
  String get platformLede;

  /// No description provided for @platformCapacity.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get platformCapacity;

  /// No description provided for @platformReserved.
  ///
  /// In en, this message translates to:
  /// **'Memory reserved'**
  String get platformReserved;

  /// No description provided for @platformBudgetNone.
  ///
  /// In en, this message translates to:
  /// **'not limited'**
  String get platformBudgetNone;

  /// No description provided for @platformRuns.
  ///
  /// In en, this message translates to:
  /// **'Runs'**
  String get platformRuns;

  /// No description provided for @platformDisk.
  ///
  /// In en, this message translates to:
  /// **'Disk free'**
  String get platformDisk;

  /// No description provided for @platformFull.
  ///
  /// In en, this message translates to:
  /// **'Full: runs are waiting for the server'**
  String get platformFull;

  /// No description provided for @platformRunning.
  ///
  /// In en, this message translates to:
  /// **'Running now'**
  String get platformRunning;

  /// No description provided for @platformNoRuns.
  ///
  /// In en, this message translates to:
  /// **'Nothing is running.'**
  String get platformNoRuns;

  /// No description provided for @platformQueue.
  ///
  /// In en, this message translates to:
  /// **'Server queue'**
  String get platformQueue;

  /// No description provided for @platformNoQueue.
  ///
  /// In en, this message translates to:
  /// **'No run is waiting for the server.'**
  String get platformNoQueue;

  /// No description provided for @platformWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get platformWorkspace;

  /// No description provided for @platformTicket.
  ///
  /// In en, this message translates to:
  /// **'Ticket'**
  String get platformTicket;

  /// No description provided for @platformStage.
  ///
  /// In en, this message translates to:
  /// **'Stage'**
  String get platformStage;

  /// No description provided for @platformStarted.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get platformStarted;

  /// No description provided for @platformWorkspaces.
  ///
  /// In en, this message translates to:
  /// **'Workspaces'**
  String get platformWorkspaces;

  /// No description provided for @platformOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get platformOwner;

  /// No description provided for @platformPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get platformPlan;

  /// No description provided for @platformSlots.
  ///
  /// In en, this message translates to:
  /// **'Slots'**
  String get platformSlots;

  /// No description provided for @platformMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get platformMembers;

  /// No description provided for @platformMemberLimit.
  ///
  /// In en, this message translates to:
  /// **'Member limit'**
  String get platformMemberLimit;

  /// No description provided for @platformCredits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get platformCredits;

  /// No description provided for @platformState.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get platformState;

  /// No description provided for @platformActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get platformActive;

  /// No description provided for @platformSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get platformSuspended;

  /// No description provided for @platformDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get platformDeleted;

  /// No description provided for @platformEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get platformEdit;

  /// No description provided for @platformSuspend.
  ///
  /// In en, this message translates to:
  /// **'Suspend'**
  String get platformSuspend;

  /// No description provided for @platformResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get platformResume;

  /// No description provided for @platformGrant.
  ///
  /// In en, this message translates to:
  /// **'Grant credits'**
  String get platformGrant;

  /// No description provided for @platformGrantAmount.
  ///
  /// In en, this message translates to:
  /// **'Credits (negative takes back)'**
  String get platformGrantAmount;

  /// No description provided for @platformGrantNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get platformGrantNote;

  /// No description provided for @platformGrantDone.
  ///
  /// In en, this message translates to:
  /// **'{n} credits granted to {name}'**
  String platformGrantDone(String n, String name);

  /// No description provided for @platformSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get platformSaved;

  /// No description provided for @platformUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get platformUsers;

  /// No description provided for @platformUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get platformUser;

  /// No description provided for @platformEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get platformEmail;

  /// No description provided for @platformAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get platformAdmin;

  /// No description provided for @platformMakeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Make Admin'**
  String get platformMakeAdmin;

  /// No description provided for @platformRemoveAdmin.
  ///
  /// In en, this message translates to:
  /// **'Remove Admin'**
  String get platformRemoveAdmin;

  /// No description provided for @platformJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get platformJoined;

  /// No description provided for @platformNoLimit.
  ///
  /// In en, this message translates to:
  /// **'no limit'**
  String get platformNoLimit;

  /// No description provided for @platformForbidden.
  ///
  /// In en, this message translates to:
  /// **'Only an Admin can open the operator console.'**
  String get platformForbidden;

  /// No description provided for @platformCabinetBadge.
  ///
  /// In en, this message translates to:
  /// **'Admin cabinet'**
  String get platformCabinetBadge;

  /// No description provided for @platformNavDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get platformNavDashboard;

  /// No description provided for @platformAdmins.
  ///
  /// In en, this message translates to:
  /// **'Admins'**
  String get platformAdmins;

  /// No description provided for @platformNavMine.
  ///
  /// In en, this message translates to:
  /// **'My work'**
  String get platformNavMine;

  /// No description provided for @platformBackToWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Back to my workspace'**
  String get platformBackToWorkspace;

  /// No description provided for @platformDashLede.
  ///
  /// In en, this message translates to:
  /// **'Everyone on the platform, how fast it grows, and what the server is running.'**
  String get platformDashLede;

  /// No description provided for @platformNewThisWeek.
  ///
  /// In en, this message translates to:
  /// **'{n} new this week'**
  String platformNewThisWeek(String n);

  /// No description provided for @platformViaGoogle.
  ///
  /// In en, this message translates to:
  /// **'{n} via Google'**
  String platformViaGoogle(String n);

  /// No description provided for @platformActiveUsers.
  ///
  /// In en, this message translates to:
  /// **'Active this week'**
  String get platformActiveUsers;

  /// No description provided for @platformActiveNote.
  ///
  /// In en, this message translates to:
  /// **'Signed in during the last 7 days'**
  String get platformActiveNote;

  /// No description provided for @platformTeams.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} with a team} other {{n} with teams}}'**
  String platformTeams(num n);

  /// No description provided for @platformRunsNow.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} run right now} other {{n} runs right now}}'**
  String platformRunsNow(num n);

  /// No description provided for @platformGrowthTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign-ups'**
  String get platformGrowthTitle;

  /// No description provided for @platformGrowthSub.
  ///
  /// In en, this message translates to:
  /// **'New accounts and workspaces per day, last {n} days'**
  String platformGrowthSub(String n);

  /// No description provided for @platformLegendUsers.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get platformLegendUsers;

  /// No description provided for @platformLegendWorkspaces.
  ///
  /// In en, this message translates to:
  /// **'Workspaces'**
  String get platformLegendWorkspaces;

  /// No description provided for @platformRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Newest accounts'**
  String get platformRecentTitle;

  /// No description provided for @platformSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get platformSeeAll;

  /// No description provided for @platformNoUsers.
  ///
  /// In en, this message translates to:
  /// **'No users match.'**
  String get platformNoUsers;

  /// No description provided for @platformWsLede.
  ///
  /// In en, this message translates to:
  /// **'Every workspace and who is in it. You see metadata only: tickets and code belong to the workspace’s members.'**
  String get platformWsLede;

  /// No description provided for @platformF_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get platformF_all;

  /// No description provided for @platformF_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get platformF_active;

  /// No description provided for @platformF_suspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get platformF_suspended;

  /// No description provided for @platformF_deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get platformF_deleted;

  /// No description provided for @platformSearchWs.
  ///
  /// In en, this message translates to:
  /// **'Search workspaces or owners'**
  String get platformSearchWs;

  /// No description provided for @platformNoWorkspaces.
  ///
  /// In en, this message translates to:
  /// **'No workspaces match.'**
  String get platformNoWorkspaces;

  /// No description provided for @platformCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get platformCreated;

  /// No description provided for @platformNoMembers.
  ///
  /// In en, this message translates to:
  /// **'No members.'**
  String get platformNoMembers;

  /// No description provided for @platformSuspendTitle.
  ///
  /// In en, this message translates to:
  /// **'Suspend {name}?'**
  String platformSuspendTitle(String name);

  /// No description provided for @platformSuspendBody.
  ///
  /// In en, this message translates to:
  /// **'Its runs stop being started and its members see that the workspace is suspended. You can resume it at any time.'**
  String get platformSuspendBody;

  /// No description provided for @platformUsersLede.
  ///
  /// In en, this message translates to:
  /// **'Everyone who signed up with Google: their workspaces, and when they were last here. Admin accounts are on the Admins page.'**
  String get platformUsersLede;

  /// No description provided for @platformU_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get platformU_all;

  /// No description provided for @platformU_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get platformU_active;

  /// No description provided for @platformU_new.
  ///
  /// In en, this message translates to:
  /// **'New this week'**
  String get platformU_new;

  /// No description provided for @platformU_google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get platformU_google;

  /// No description provided for @platformU_admins.
  ///
  /// In en, this message translates to:
  /// **'Admins'**
  String get platformU_admins;

  /// No description provided for @platformSearchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search by name, email or workspace'**
  String get platformSearchUsers;

  /// No description provided for @platformSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign-in'**
  String get platformSignIn;

  /// No description provided for @platformLastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last sign-in'**
  String get platformLastSeen;

  /// No description provided for @platformPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get platformPassword;

  /// No description provided for @platformUnverified.
  ///
  /// In en, this message translates to:
  /// **'unverified'**
  String get platformUnverified;

  /// No description provided for @platformYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get platformYou;

  /// No description provided for @platformMakeAdminTitle.
  ///
  /// In en, this message translates to:
  /// **'Make {name} an Admin?'**
  String platformMakeAdminTitle(String name);

  /// No description provided for @platformMakeAdminBody.
  ///
  /// In en, this message translates to:
  /// **'Admins open this cabinet: they see every user and workspace, change plans and credits, suspend workspaces and manage other Admins.'**
  String get platformMakeAdminBody;

  /// No description provided for @platformRemoveAdminTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} as Admin?'**
  String platformRemoveAdminTitle(String name);

  /// No description provided for @platformRemoveAdminBody.
  ///
  /// In en, this message translates to:
  /// **'They keep their account and workspaces, but lose the Admin cabinet.'**
  String get platformRemoveAdminBody;

  /// No description provided for @platformAdminAdded.
  ///
  /// In en, this message translates to:
  /// **'Admin {name} created'**
  String platformAdminAdded(String name);

  /// No description provided for @platformAdminRemoved.
  ///
  /// In en, this message translates to:
  /// **'Admin {name} deleted'**
  String platformAdminRemoved(String name);

  /// No description provided for @platformAdminsLede.
  ///
  /// In en, this message translates to:
  /// **'The platform’s operators. Each is its own account, apart from Users: an Admin sees no workspace’s tickets.'**
  String get platformAdminsLede;

  /// No description provided for @platformAdminsCount.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} Admin} other {{n} Admins}}'**
  String platformAdminsCount(num n);

  /// No description provided for @platformAddAdmin.
  ///
  /// In en, this message translates to:
  /// **'Add an Admin'**
  String get platformAddAdmin;

  /// No description provided for @platformAddAdminSub.
  ///
  /// In en, this message translates to:
  /// **'An Admin is a separate account: it signs in with a password, opens this cabinet and has no workspaces. Users can’t be made Admins.'**
  String get platformAddAdminSub;

  /// No description provided for @platformFindUser.
  ///
  /// In en, this message translates to:
  /// **'Find a person'**
  String get platformFindUser;

  /// No description provided for @platformNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No one matches, or they are an Admin already.'**
  String get platformNoMatch;

  /// No description provided for @platformLastSeenAgo.
  ///
  /// In en, this message translates to:
  /// **'last sign-in {when}'**
  String platformLastSeenAgo(String when);

  /// No description provided for @platformAdminName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get platformAdminName;

  /// No description provided for @platformAdminUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get platformAdminUsername;

  /// No description provided for @platformAdminPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'At least {n} characters. They can turn on two-factor sign-in in their profile.'**
  String platformAdminPasswordHint(String n);

  /// No description provided for @platformCreateAdmin.
  ///
  /// In en, this message translates to:
  /// **'Create Admin'**
  String get platformCreateAdmin;

  /// No description provided for @platformDeleteAdmin.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get platformDeleteAdmin;

  /// No description provided for @platformDeleteAdminTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete the Admin account {name}?'**
  String platformDeleteAdminTitle(String name);

  /// No description provided for @platformDeleteAdminBody.
  ///
  /// In en, this message translates to:
  /// **'They can no longer sign in. This cannot be undone.'**
  String get platformDeleteAdminBody;

  /// No description provided for @platformFreeCredits.
  ///
  /// In en, this message translates to:
  /// **'Free credits'**
  String get platformFreeCredits;

  /// No description provided for @platformSetFreeCredits.
  ///
  /// In en, this message translates to:
  /// **'Set free credits'**
  String get platformSetFreeCredits;

  /// No description provided for @platformFreeCreditsSet.
  ///
  /// In en, this message translates to:
  /// **'{name} may spend {n} free credits ({amount})'**
  String platformFreeCreditsSet(String name, String n, String amount);

  /// No description provided for @platformFreeCreditsUsed.
  ///
  /// In en, this message translates to:
  /// **'{used} of {limit} spent so far.'**
  String platformFreeCreditsUsed(String used, String limit);

  /// No description provided for @platformFreeCreditsLimit.
  ///
  /// In en, this message translates to:
  /// **'Credits (1 credit = \$0.01; 0 gives none)'**
  String get platformFreeCreditsLimit;

  /// No description provided for @platformFreeCreditsWorth.
  ///
  /// In en, this message translates to:
  /// **'Worth {amount} of model calls on agnts\'s Muse key.'**
  String platformFreeCreditsWorth(String amount);

  /// No description provided for @platformFreeCreditsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number from 0 to 10,000,000.'**
  String get platformFreeCreditsInvalid;

  /// No description provided for @platformCreditUsage.
  ///
  /// In en, this message translates to:
  /// **'Usage this month'**
  String get platformCreditUsage;

  /// No description provided for @platformCreditUsageTotal.
  ///
  /// In en, this message translates to:
  /// **'{n} ever'**
  String platformCreditUsageTotal(String n);

  /// No description provided for @platformSetLimit.
  ///
  /// In en, this message translates to:
  /// **'Set limit'**
  String get platformSetLimit;

  /// No description provided for @platformLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly credit limit'**
  String get platformLimitTitle;

  /// No description provided for @platformLimitSet.
  ///
  /// In en, this message translates to:
  /// **'{name} may spend up to {n} credits ({amount}) a month'**
  String platformLimitSet(String name, String n, String amount);

  /// No description provided for @platformLimitRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} has no monthly limit now'**
  String platformLimitRemoved(String name);

  /// No description provided for @platformLimitUsed.
  ///
  /// In en, this message translates to:
  /// **'{used} credits ({amount}) spent this month, {total} ever.'**
  String platformLimitUsed(String used, String amount, String total);

  /// No description provided for @platformLimitField.
  ///
  /// In en, this message translates to:
  /// **'Credits per month (1 credit = \$0.01; 0 is no limit)'**
  String get platformLimitField;

  /// No description provided for @platformLimitHelp.
  ///
  /// In en, this message translates to:
  /// **'Free and workspace credits together. Runs stop once it is spent and resume next month or when you raise it.'**
  String get platformLimitHelp;

  /// No description provided for @platformLimitWorth.
  ///
  /// In en, this message translates to:
  /// **'Up to {amount} of model calls a month.'**
  String platformLimitWorth(String amount);

  /// No description provided for @platformLimitNone.
  ///
  /// In en, this message translates to:
  /// **'No limit: only their credits bound what they spend.'**
  String get platformLimitNone;

  /// No description provided for @platformUsageTotals.
  ///
  /// In en, this message translates to:
  /// **'This month: {used} credits ({amount}) across everyone; {limited} people have a limit.'**
  String platformUsageTotals(String used, String amount, String limited);

  /// No description provided for @platformModules.
  ///
  /// In en, this message translates to:
  /// **'Modules'**
  String get platformModules;

  /// No description provided for @platformSetModules.
  ///
  /// In en, this message translates to:
  /// **'Set modules'**
  String get platformSetModules;

  /// No description provided for @platformModulesDefault.
  ///
  /// In en, this message translates to:
  /// **'Default ({list})'**
  String platformModulesDefault(String list);

  /// No description provided for @platformModulesNow.
  ///
  /// In en, this message translates to:
  /// **'Uses now: {list}.'**
  String platformModulesNow(String list);

  /// No description provided for @platformModulesFollowDefault.
  ///
  /// In en, this message translates to:
  /// **'Follow the default'**
  String get platformModulesFollowDefault;

  /// No description provided for @platformModulesCustom.
  ///
  /// In en, this message translates to:
  /// **'Their own list'**
  String get platformModulesCustom;

  /// No description provided for @platformModulesCustomHelp.
  ///
  /// In en, this message translates to:
  /// **'The first is their default module. Only enabled modules can be chosen.'**
  String get platformModulesCustomHelp;

  /// No description provided for @platformModulesSet.
  ///
  /// In en, this message translates to:
  /// **'{name} may use {list}'**
  String platformModulesSet(String name, String list);

  /// No description provided for @platformModulesFollow.
  ///
  /// In en, this message translates to:
  /// **'{name} follows the default modules now'**
  String platformModulesFollow(String name);

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
  /// **'Muse may start the app and look at the pages it changed before it finishes, and fix what looks broken. Costs a few more turns.'**
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
  /// **'Hosts run containers may reach besides the built-in list (Muse, git hosts, package registries), such as a staging API your app calls in a preview. .example.com allows its subdomains.'**
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

  /// No description provided for @pullsTab.
  ///
  /// In en, this message translates to:
  /// **'Pull requests'**
  String get pullsTab;

  /// No description provided for @pullsTitle.
  ///
  /// In en, this message translates to:
  /// **'Pull requests'**
  String get pullsTitle;

  /// No description provided for @pullsSub.
  ///
  /// In en, this message translates to:
  /// **'On the git host, most recently updated first. Open one to read and answer its comments.'**
  String get pullsSub;

  /// No description provided for @pullsBack.
  ///
  /// In en, this message translates to:
  /// **'Back to the repository'**
  String get pullsBack;

  /// No description provided for @pullsState_open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get pullsState_open;

  /// No description provided for @pullsState_merged.
  ///
  /// In en, this message translates to:
  /// **'Merged'**
  String get pullsState_merged;

  /// No description provided for @pullsState_closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get pullsState_closed;

  /// No description provided for @pullsState_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get pullsState_all;

  /// No description provided for @pullsNone.
  ///
  /// In en, this message translates to:
  /// **'No pull requests here.'**
  String get pullsNone;

  /// No description provided for @pullsEnd.
  ///
  /// In en, this message translates to:
  /// **'That is all of them.'**
  String get pullsEnd;

  /// No description provided for @pullsUpdated.
  ///
  /// In en, this message translates to:
  /// **'updated {time}'**
  String pullsUpdated(String time);

  /// No description provided for @pullsDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get pullsDraft;

  /// No description provided for @pullsOwnTicket.
  ///
  /// In en, this message translates to:
  /// **'agnts\'s change · {key}'**
  String pullsOwnTicket(String key);

  /// No description provided for @pullsReviewTicket.
  ///
  /// In en, this message translates to:
  /// **'Review · {key}'**
  String pullsReviewTicket(String key);

  /// No description provided for @pullsConversation.
  ///
  /// In en, this message translates to:
  /// **'Conversation'**
  String get pullsConversation;

  /// No description provided for @pullsFiles.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get pullsFiles;

  /// No description provided for @pullsUnresolvedN.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} unresolved thread} other {{n} unresolved threads}}'**
  String pullsUnresolvedN(num n);

  /// No description provided for @pullsShowResolved.
  ///
  /// In en, this message translates to:
  /// **'Show resolved ({n})'**
  String pullsShowResolved(String n);

  /// No description provided for @pullsNoComments.
  ///
  /// In en, this message translates to:
  /// **'No comments yet.'**
  String get pullsNoComments;

  /// No description provided for @pullsNoFiles.
  ///
  /// In en, this message translates to:
  /// **'The pull request changes no files.'**
  String get pullsNoFiles;

  /// No description provided for @pullsNoPatch.
  ///
  /// In en, this message translates to:
  /// **'No diff to show (a binary file, or too large for the git host to send).'**
  String get pullsNoPatch;

  /// No description provided for @pullsFilesError.
  ///
  /// In en, this message translates to:
  /// **'The changed files could not be read: {error}'**
  String pullsFilesError(String error);

  /// No description provided for @pullsEarlierVersion.
  ///
  /// In en, this message translates to:
  /// **'Written on an earlier version of this file:'**
  String get pullsEarlierVersion;

  /// No description provided for @pullsThreadsN.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} thread} other {{n} threads}}'**
  String pullsThreadsN(num n);

  /// No description provided for @pullsCommentOnLine.
  ///
  /// In en, this message translates to:
  /// **'Comment on line {line}'**
  String pullsCommentOnLine(String line);

  /// No description provided for @pullsAddComment.
  ///
  /// In en, this message translates to:
  /// **'Add a comment'**
  String get pullsAddComment;

  /// No description provided for @pullsComment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get pullsComment;

  /// No description provided for @pullsCommentLabel.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get pullsCommentLabel;

  /// No description provided for @pullsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Markdown. Ctrl+Enter posts.'**
  String get pullsPlaceholder;

  /// No description provided for @pullsWrite.
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get pullsWrite;

  /// No description provided for @pullsPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get pullsPreview;

  /// No description provided for @pullsReply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get pullsReply;

  /// No description provided for @pullsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get pullsEdit;

  /// No description provided for @pullsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get pullsSave;

  /// No description provided for @pullsEdited.
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get pullsEdited;

  /// No description provided for @pullsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get pullsDelete;

  /// No description provided for @pullsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete the comment?'**
  String get pullsDeleteTitle;

  /// No description provided for @pullsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'It is deleted on the git host for everyone. This cannot be undone.'**
  String get pullsDeleteConfirm;

  /// No description provided for @pullsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Comment deleted'**
  String get pullsDeleted;

  /// No description provided for @pullsResolve.
  ///
  /// In en, this message translates to:
  /// **'Resolve'**
  String get pullsResolve;

  /// No description provided for @pullsUnresolve.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get pullsUnresolve;

  /// No description provided for @pullsResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get pullsResolved;

  /// No description provided for @pullsOutdated.
  ///
  /// In en, this message translates to:
  /// **'Outdated'**
  String get pullsOutdated;

  /// No description provided for @pullsSent.
  ///
  /// In en, this message translates to:
  /// **'Sent to agnts'**
  String get pullsSent;

  /// No description provided for @pullsAnswered.
  ///
  /// In en, this message translates to:
  /// **'Answered by agnts'**
  String get pullsAnswered;

  /// No description provided for @pullsVerdict_APPROVED.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get pullsVerdict_APPROVED;

  /// No description provided for @pullsVerdict_CHANGES_REQUESTED.
  ///
  /// In en, this message translates to:
  /// **'Changes requested'**
  String get pullsVerdict_CHANGES_REQUESTED;

  /// No description provided for @pullsVerdict_COMMENTED.
  ///
  /// In en, this message translates to:
  /// **'Commented'**
  String get pullsVerdict_COMMENTED;

  /// No description provided for @pullsVerdict_DISMISSED.
  ///
  /// In en, this message translates to:
  /// **'Dismissed'**
  String get pullsVerdict_DISMISSED;

  /// No description provided for @pullsPostsAs.
  ///
  /// In en, this message translates to:
  /// **'Posts as @{login} on {host}'**
  String pullsPostsAs(String login, String host);

  /// No description provided for @pullsPostsAsToken.
  ///
  /// In en, this message translates to:
  /// **'Posts as the {host} token\'s user'**
  String pullsPostsAsToken(String host);

  /// No description provided for @pullsTicketTitle.
  ///
  /// In en, this message translates to:
  /// **'Comments on #{number} ({host})'**
  String pullsTicketTitle(String number, String host);

  /// No description provided for @pullsTicketSubOwn.
  ///
  /// In en, this message translates to:
  /// **'Reviewers\' comments on agnts\'s pull request. Answer here, or send them back to agnts.'**
  String get pullsTicketSubOwn;

  /// No description provided for @pullsTicketSubReview.
  ///
  /// In en, this message translates to:
  /// **'The pull request\'s conversation on the git host.'**
  String get pullsTicketSubReview;

  /// No description provided for @pullsTicketSubIn.
  ///
  /// In en, this message translates to:
  /// **'In {repo}.'**
  String pullsTicketSubIn(String repo);

  /// No description provided for @pullsOpenWithDiff.
  ///
  /// In en, this message translates to:
  /// **'Open with the diff'**
  String get pullsOpenWithDiff;

  /// No description provided for @pullsAddressBtn.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {Address {n} comment} other {Address {n} comments}}'**
  String pullsAddressBtn(num n);

  /// No description provided for @pullsAddressConfirm.
  ///
  /// In en, this message translates to:
  /// **'agnts goes back to {key} with {n, plural, one {this review thread} other {these {n} review threads}}: it changes the code or answers each. The fix waits for your approval as usual; once it is pushed, agnts replies in each thread.'**
  String pullsAddressConfirm(String key, num n);

  /// No description provided for @pullsAddressed.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} thread went} other {{n} threads went}} back to agnts'**
  String pullsAddressed(num n);

  /// No description provided for @pullsAddressLater.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} new review comment} other {{n} new review comments}}: they can go back to agnts while the ticket waits for your review, or once it is done with its pull request open.'**
  String pullsAddressLater(num n);

  /// No description provided for @pullsPostTitle.
  ///
  /// In en, this message translates to:
  /// **'Post the review on #{number}'**
  String pullsPostTitle(String number);

  /// No description provided for @pullsPostSub.
  ///
  /// In en, this message translates to:
  /// **'One review on {host}, as the token\'s user. Findings on lines of the diff become comments there.'**
  String pullsPostSub(String host);

  /// No description provided for @pullsPostBtn.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =0 {Post} one {Post with {n} line comment} other {Post with {n} line comments}}'**
  String pullsPostBtn(num n);

  /// No description provided for @pullsPostSummary.
  ///
  /// In en, this message translates to:
  /// **'The summary (the verdict and every finding)'**
  String get pullsPostSummary;

  /// No description provided for @pullsPostFindings.
  ///
  /// In en, this message translates to:
  /// **'On their lines:'**
  String get pullsPostFindings;

  /// No description provided for @pullsSummaryOnly.
  ///
  /// In en, this message translates to:
  /// **'summary only: not a line of the diff'**
  String get pullsSummaryOnly;

  /// No description provided for @pullsRequestChanges.
  ///
  /// In en, this message translates to:
  /// **'Request changes'**
  String get pullsRequestChanges;

  /// No description provided for @pullsNoRequestChanges.
  ///
  /// In en, this message translates to:
  /// **'GitLab has no request for changes here: the comments are posted, approvals stay as they are.'**
  String get pullsNoRequestChanges;

  /// No description provided for @pullsSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Comments on pull requests'**
  String get pullsSettingsTitle;

  /// No description provided for @pullsSet_attribution.
  ///
  /// In en, this message translates to:
  /// **'Say who wrote it'**
  String get pullsSet_attribution;

  /// No description provided for @pullsSet_attributionHelp.
  ///
  /// In en, this message translates to:
  /// **'Comments written in agnts go out as the git host token\'s user; this adds \"via agnts · your name\" under each.'**
  String get pullsSet_attributionHelp;

  /// No description provided for @pullsSet_learnFromComments.
  ///
  /// In en, this message translates to:
  /// **'Learn from your comments'**
  String get pullsSet_learnFromComments;

  /// No description provided for @pullsSet_learnFromCommentsHelp.
  ///
  /// In en, this message translates to:
  /// **'What you write on others\' pull requests on the git host becomes notes on how you review.'**
  String get pullsSet_learnFromCommentsHelp;

  /// No description provided for @pullsSet_resolveFixed.
  ///
  /// In en, this message translates to:
  /// **'Resolve fixed threads'**
  String get pullsSet_resolveFixed;

  /// No description provided for @pullsSet_resolveFixedHelp.
  ///
  /// In en, this message translates to:
  /// **'Once agnts pushed a fix and answered a reviewer\'s thread, it resolves the thread.'**
  String get pullsSet_resolveFixedHelp;

  /// No description provided for @pullsSet_autoAddress.
  ///
  /// In en, this message translates to:
  /// **'Address requested changes'**
  String get pullsSet_autoAddress;

  /// No description provided for @pullsSet_autoAddressHelp.
  ///
  /// In en, this message translates to:
  /// **'When a reviewer requests changes on agnts\'s pull request, its unresolved threads go back to the ticket by themselves. The fix still waits for your approval.'**
  String get pullsSet_autoAddressHelp;

  /// No description provided for @pullsCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Point at a line and click the comment button to comment on it.'**
  String get pullsCommentHint;

  /// No description provided for @queueHeader.
  ///
  /// In en, this message translates to:
  /// **'Running {running}/{slots}'**
  String queueHeader(String running, String slots);

  /// No description provided for @queueQueued.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} queued} other {{n} queued}}'**
  String queueQueued(num n);

  /// No description provided for @queueWaitingServer.
  ///
  /// In en, this message translates to:
  /// **'{n} waiting for the server'**
  String queueWaitingServer(String n);

  /// No description provided for @queueBadge_blocked.
  ///
  /// In en, this message translates to:
  /// **'Waiting · related'**
  String get queueBadge_blocked;

  /// No description provided for @queueBadge_slots.
  ///
  /// In en, this message translates to:
  /// **'Queued · slots'**
  String get queueBadge_slots;

  /// No description provided for @queueBadge_server.
  ///
  /// In en, this message translates to:
  /// **'Queued · server'**
  String get queueBadge_server;

  /// No description provided for @queueBadge_claude.
  ///
  /// In en, this message translates to:
  /// **'Paused · Muse'**
  String get queueBadge_claude;

  /// No description provided for @queueTitle_blocked.
  ///
  /// In en, this message translates to:
  /// **'Waiting for related tickets'**
  String get queueTitle_blocked;

  /// No description provided for @queueTitle_slots.
  ///
  /// In en, this message translates to:
  /// **'Waiting for a free slot'**
  String get queueTitle_slots;

  /// No description provided for @queueTitle_server.
  ///
  /// In en, this message translates to:
  /// **'In the server queue'**
  String get queueTitle_server;

  /// No description provided for @queueTitle_claude.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Muse'**
  String get queueTitle_claude;

  /// No description provided for @queuePosition.
  ///
  /// In en, this message translates to:
  /// **'#{position} in the server queue'**
  String queuePosition(String position);

  /// No description provided for @queueOthers.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =0 {} one {{n} ticket of another workspace ahead.} other {{n} tickets of other workspaces ahead.}}'**
  String queueOthers(num n);

  /// No description provided for @queueEstimate.
  ///
  /// In en, this message translates to:
  /// **'Starts in about {minutes, plural, one {{minutes} minute} other {{minutes} minutes}}.'**
  String queueEstimate(num minutes);

  /// No description provided for @queueServerFull.
  ///
  /// In en, this message translates to:
  /// **'The server is at capacity ({runs} runs, {reserved} of {budget} reserved).'**
  String queueServerFull(String runs, String reserved, String budget);

  /// No description provided for @queueSlotsHint.
  ///
  /// In en, this message translates to:
  /// **'{running} of {slots} runs in use. It starts when one ends.'**
  String queueSlotsHint(String running, String slots);

  /// No description provided for @queueAddSlot.
  ///
  /// In en, this message translates to:
  /// **'Add a slot'**
  String get queueAddSlot;

  /// No description provided for @queueClaudeHint.
  ///
  /// In en, this message translates to:
  /// **'Connect an account or turn on credits in Workspace settings → Muse.'**
  String get queueClaudeHint;

  /// No description provided for @queueMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get queueMember;

  /// No description provided for @queueTakeOver.
  ///
  /// In en, this message translates to:
  /// **'Take over'**
  String get queueTakeOver;

  /// No description provided for @queueTakenOver.
  ///
  /// In en, this message translates to:
  /// **'The ticket is yours: it runs on your Muse account in per-member mode.'**
  String get queueTakenOver;

  /// No description provided for @queueCreatedBy.
  ///
  /// In en, this message translates to:
  /// **'Created by {name}'**
  String queueCreatedBy(String name);

  /// No description provided for @queueBy.
  ///
  /// In en, this message translates to:
  /// **'by {name}'**
  String queueBy(String name);

  /// No description provided for @redFlagsTitle.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} red flag} other {{n} red flags}}'**
  String redFlagsTitle(num n);

  /// No description provided for @redFlagsSub.
  ///
  /// In en, this message translates to:
  /// **'agnts\'s scan of the change matched these lines. They often mean the checks were made to pass the wrong way; agnts\'s review checks each one.'**
  String get redFlagsSub;

  /// No description provided for @redFlagsKind_skipped_test.
  ///
  /// In en, this message translates to:
  /// **'Skipped or focused test'**
  String get redFlagsKind_skipped_test;

  /// No description provided for @redFlagsKind_removed_assertion.
  ///
  /// In en, this message translates to:
  /// **'Assertions removed'**
  String get redFlagsKind_removed_assertion;

  /// No description provided for @redFlagsKind_deleted_test.
  ///
  /// In en, this message translates to:
  /// **'Test file deleted'**
  String get redFlagsKind_deleted_test;

  /// No description provided for @redFlagsKind_silenced_lint.
  ///
  /// In en, this message translates to:
  /// **'Linter silenced'**
  String get redFlagsKind_silenced_lint;

  /// No description provided for @redFlagsKind_swallowed_error.
  ///
  /// In en, this message translates to:
  /// **'Error swallowed'**
  String get redFlagsKind_swallowed_error;

  /// No description provided for @redFlagsKind_todo.
  ///
  /// In en, this message translates to:
  /// **'TODO left'**
  String get redFlagsKind_todo;

  /// No description provided for @redFlagsKind_new_dependency.
  ///
  /// In en, this message translates to:
  /// **'New dependency'**
  String get redFlagsKind_new_dependency;

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

  /// No description provided for @relationsSource_plane.
  ///
  /// In en, this message translates to:
  /// **'Plane relation'**
  String get relationsSource_plane;

  /// No description provided for @replayTitle.
  ///
  /// In en, this message translates to:
  /// **'Replay with today\'s agnts'**
  String get replayTitle;

  /// No description provided for @replaySub.
  ///
  /// In en, this message translates to:
  /// **'Re-run this ticket from the commit it started from, with the current prompts, brief and rules, and compare the result with what you approved. The replay is never pushed.'**
  String get replaySub;

  /// No description provided for @replayStart.
  ///
  /// In en, this message translates to:
  /// **'Replay'**
  String get replayStart;

  /// No description provided for @replayConfirm.
  ///
  /// In en, this message translates to:
  /// **'agnts creates a new task that re-does {key} from where it started. It uses your Muse plan like any ticket.'**
  String replayConfirm(String key);

  /// No description provided for @replayCreated.
  ///
  /// In en, this message translates to:
  /// **'Replay {key} queued'**
  String replayCreated(String key);

  /// No description provided for @replayBanner.
  ///
  /// In en, this message translates to:
  /// **'This is a replay to evaluate agnts: it is never pushed. Compare it with'**
  String get replayBanner;

  /// No description provided for @replayEvalTitle.
  ///
  /// In en, this message translates to:
  /// **'Replay evaluation'**
  String get replayEvalTitle;

  /// No description provided for @replayEvalSub.
  ///
  /// In en, this message translates to:
  /// **'Done tickets re-run with a newer agnts, compared with the change you approved. Start one with Replay on a done ticket, or `agnts eval replay KEY`.'**
  String get replayEvalSub;

  /// No description provided for @replayNone.
  ///
  /// In en, this message translates to:
  /// **'No replays yet.'**
  String get replayNone;

  /// No description provided for @replayRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent replays'**
  String get replayRecent;

  /// No description provided for @replayColReplays.
  ///
  /// In en, this message translates to:
  /// **'Replays'**
  String get replayColReplays;

  /// No description provided for @replayColChecks.
  ///
  /// In en, this message translates to:
  /// **'Checks'**
  String get replayColChecks;

  /// No description provided for @replayColLooksGood.
  ///
  /// In en, this message translates to:
  /// **'Review OK'**
  String get replayColLooksGood;

  /// No description provided for @replayColOverlap.
  ///
  /// In en, this message translates to:
  /// **'Same files'**
  String get replayColOverlap;

  /// No description provided for @replayColOverlapHint.
  ///
  /// In en, this message translates to:
  /// **'How much the replay\'s changed files match the approved change\'s (Jaccard index)'**
  String get replayColOverlapHint;

  /// No description provided for @replayColRecall.
  ///
  /// In en, this message translates to:
  /// **'Coverage'**
  String get replayColRecall;

  /// No description provided for @replayColRecallHint.
  ///
  /// In en, this message translates to:
  /// **'Share of the approved change\'s files the replay changed too'**
  String get replayColRecallHint;

  /// No description provided for @replayColTurns.
  ///
  /// In en, this message translates to:
  /// **'Turns (original)'**
  String get replayColTurns;

  /// No description provided for @replayColCost.
  ///
  /// In en, this message translates to:
  /// **'Cost (original)'**
  String get replayColCost;

  /// No description provided for @replayColReplay.
  ///
  /// In en, this message translates to:
  /// **'Replay'**
  String get replayColReplay;

  /// No description provided for @replayColOf.
  ///
  /// In en, this message translates to:
  /// **'Of'**
  String get replayColOf;

  /// No description provided for @replayColState.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get replayColState;

  /// No description provided for @replayColReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get replayColReview;

  /// No description provided for @replayPass.
  ///
  /// In en, this message translates to:
  /// **'pass'**
  String get replayPass;

  /// No description provided for @replayFail.
  ///
  /// In en, this message translates to:
  /// **'fail'**
  String get replayFail;

  /// No description provided for @replayVerdict_looks_good.
  ///
  /// In en, this message translates to:
  /// **'looks good'**
  String get replayVerdict_looks_good;

  /// No description provided for @replayVerdict_has_concerns.
  ///
  /// In en, this message translates to:
  /// **'has concerns'**
  String get replayVerdict_has_concerns;

  /// No description provided for @replayVerdict_needs_changes.
  ///
  /// In en, this message translates to:
  /// **'needs changes'**
  String get replayVerdict_needs_changes;

  /// No description provided for @replayBenchmarkTitle.
  ///
  /// In en, this message translates to:
  /// **'Benchmark'**
  String get replayBenchmarkTitle;

  /// No description provided for @replayBenchmarkSub.
  ///
  /// In en, this message translates to:
  /// **'Merged tickets that every change to agnts is replayed against, and scored against what they merged as. Pick 20–30 of different sizes.'**
  String get replayBenchmarkSub;

  /// No description provided for @replayBenchmarkAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to benchmark'**
  String get replayBenchmarkAdd;

  /// No description provided for @replayBenchmarkRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from benchmark'**
  String get replayBenchmarkRemove;

  /// No description provided for @replayBenchmarkIn.
  ///
  /// In en, this message translates to:
  /// **'In the benchmark: changes to agnts are replayed against this ticket.'**
  String get replayBenchmarkIn;

  /// No description provided for @replayBenchmarkNeedsMerge.
  ///
  /// In en, this message translates to:
  /// **'Only merged tickets can be in the benchmark: replays are scored against what they merged as.'**
  String get replayBenchmarkNeedsMerge;

  /// No description provided for @replayBenchmarkRun.
  ///
  /// In en, this message translates to:
  /// **'Run benchmark'**
  String get replayBenchmarkRun;

  /// No description provided for @replayBenchmarkModel.
  ///
  /// In en, this message translates to:
  /// **'Coding model'**
  String get replayBenchmarkModel;

  /// No description provided for @replayBenchmarkModelDefault.
  ///
  /// In en, this message translates to:
  /// **'as the originals'**
  String get replayBenchmarkModelDefault;

  /// No description provided for @replayBenchmarkConfirm.
  ///
  /// In en, this message translates to:
  /// **'agnts replays the {n} benchmark tickets from where each started. They use your Muse plan like any ticket.'**
  String replayBenchmarkConfirm(String n);

  /// No description provided for @replayBenchmarkStarted.
  ///
  /// In en, this message translates to:
  /// **'{n} replays queued'**
  String replayBenchmarkStarted(String n);

  /// No description provided for @replayBenchmarkFailed.
  ///
  /// In en, this message translates to:
  /// **'{n} could not be replayed: {why}'**
  String replayBenchmarkFailed(String n, String why);

  /// No description provided for @replayBenchmarkEmpty.
  ///
  /// In en, this message translates to:
  /// **'The benchmark is empty. Open a merged ticket and press Add to benchmark.'**
  String get replayBenchmarkEmpty;

  /// No description provided for @replayBenchmarkCount.
  ///
  /// In en, this message translates to:
  /// **'{n} tickets'**
  String replayBenchmarkCount(String n);

  /// No description provided for @replayAllReplays.
  ///
  /// In en, this message translates to:
  /// **'All replays'**
  String get replayAllReplays;

  /// No description provided for @replayColModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get replayColModel;

  /// No description provided for @replayColLines.
  ///
  /// In en, this message translates to:
  /// **'Merged lines'**
  String get replayColLines;

  /// No description provided for @replayColLinesHint.
  ///
  /// In en, this message translates to:
  /// **'Share of the lines the merged pull request added that the replay adds too; in brackets the same for agnts\'s original change. Higher is closer to what people shipped.'**
  String get replayColLinesHint;

  /// No description provided for @replayAgainst_merged.
  ///
  /// In en, this message translates to:
  /// **'vs merged'**
  String get replayAgainst_merged;

  /// No description provided for @replayAgainst_agnts.
  ///
  /// In en, this message translates to:
  /// **'vs agnts'**
  String get replayAgainst_agnts;

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
  /// **'agnts waits for checks before a ticket reaches your review. Deploying is always your decision, and it is never available from Muse chat.'**
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

  /// No description provided for @repoBrief.
  ///
  /// In en, this message translates to:
  /// **'Brief'**
  String get repoBrief;

  /// No description provided for @repoCi.
  ///
  /// In en, this message translates to:
  /// **'CI'**
  String get repoCi;

  /// No description provided for @repoCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get repoCode;

  /// No description provided for @repoCodeSub.
  ///
  /// In en, this message translates to:
  /// **'The repository\'s files on the chosen branch, read from the git host.'**
  String get repoCodeSub;

  /// No description provided for @repoCodeBranch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get repoCodeBranch;

  /// No description provided for @repoCodePath.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get repoCodePath;

  /// No description provided for @repoCodeRoot.
  ///
  /// In en, this message translates to:
  /// **'Root'**
  String get repoCodeRoot;

  /// No description provided for @repoCodeLines.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} line} other {{n} lines}}'**
  String repoCodeLines(num n);

  /// No description provided for @repoCodeView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get repoCodeView;

  /// No description provided for @repoCodePreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get repoCodePreview;

  /// No description provided for @repoCodeSource.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get repoCodeSource;

  /// No description provided for @repoCodeBinary.
  ///
  /// In en, this message translates to:
  /// **'This is a binary file and can\'t be shown here.'**
  String get repoCodeBinary;

  /// No description provided for @repoCodeTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This file is over 1 MB, too large to show here. Open it on the git host.'**
  String get repoCodeTooLarge;

  /// No description provided for @repoCodeEmptyFile.
  ///
  /// In en, this message translates to:
  /// **'This file is empty.'**
  String get repoCodeEmptyFile;

  /// No description provided for @repoCodeEmpty.
  ///
  /// In en, this message translates to:
  /// **'This branch has no files yet.'**
  String get repoCodeEmpty;

  /// No description provided for @repoCodeSubmodule.
  ///
  /// In en, this message translates to:
  /// **'Submodule'**
  String get repoCodeSubmodule;

  /// No description provided for @repoCodeSymlink.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get repoCodeSymlink;

  /// No description provided for @repoCodeCapped.
  ///
  /// In en, this message translates to:
  /// **'Only the first {n} entries of this folder are listed.'**
  String repoCodeCapped(String n);

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
  /// **'Takes side-project tasks, plus Jira tickets or Plane work items once it is linked to a project'**
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
  /// **'Side-project tasks are numbered like {prefix}-1, {prefix}-2. Must differ from the Jira project key and the Plane project.'**
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

  /// No description provided for @reposBranchTemplate.
  ///
  /// In en, this message translates to:
  /// **'Branch name format'**
  String get reposBranchTemplate;

  /// No description provided for @reposBranchTemplateHelp.
  ///
  /// In en, this message translates to:
  /// **'How agnts names the branch for each ticket. Must contain {key} or {number}. Leave empty for {fallback}.'**
  String reposBranchTemplateHelp(String key, String number, String fallback);

  /// No description provided for @reposBranchTemplateExample.
  ///
  /// In en, this message translates to:
  /// **'Example: {example}'**
  String reposBranchTemplateExample(String example);

  /// No description provided for @reposCommitTemplate.
  ///
  /// In en, this message translates to:
  /// **'Commit message format'**
  String get reposCommitTemplate;

  /// No description provided for @reposCommitTemplateHelp.
  ///
  /// In en, this message translates to:
  /// **'How agnts writes its commit messages. An empty scope drops its parentheses. Leave empty for KEY: Title.'**
  String get reposCommitTemplateHelp;

  /// No description provided for @reposCommitTemplateExample.
  ///
  /// In en, this message translates to:
  /// **'Example: {example}'**
  String reposCommitTemplateExample(String example);

  /// No description provided for @reposPlaceholders.
  ///
  /// In en, this message translates to:
  /// **'Placeholders'**
  String get reposPlaceholders;

  /// No description provided for @reposPhPrefix.
  ///
  /// In en, this message translates to:
  /// **'The repository\'s branch prefix, agnts/ by default.'**
  String get reposPhPrefix;

  /// No description provided for @reposPhType.
  ///
  /// In en, this message translates to:
  /// **'The kind of work: feature for code, bugfix for a bug, test, swagger-test.'**
  String get reposPhType;

  /// No description provided for @reposPhKey.
  ///
  /// In en, this message translates to:
  /// **'The agnts ticket key: VIS-42, or the Jira or Plane issue key.'**
  String get reposPhKey;

  /// No description provided for @reposPhNumber.
  ///
  /// In en, this message translates to:
  /// **'The task\'s ticket number, such as AMANAT-2288. Falls back to the key when empty.'**
  String get reposPhNumber;

  /// No description provided for @reposPhSlug.
  ///
  /// In en, this message translates to:
  /// **'The ticket title in lowercase with hyphens, up to 40 characters.'**
  String get reposPhSlug;

  /// No description provided for @reposPhUser.
  ///
  /// In en, this message translates to:
  /// **'Username of whoever the ticket is assigned to, or its creator.'**
  String get reposPhUser;

  /// No description provided for @reposPhCommitType.
  ///
  /// In en, this message translates to:
  /// **'The change type the agent picks: feat, fix, chore, refactor, docs, test... Falls back to the ticket kind.'**
  String get reposPhCommitType;

  /// No description provided for @reposPhScope.
  ///
  /// In en, this message translates to:
  /// **'The area the agent says it changed, such as deps or auth. May be empty.'**
  String get reposPhScope;

  /// No description provided for @reposPhSubject.
  ///
  /// In en, this message translates to:
  /// **'The agent\'s one-line summary of the change. Falls back to the ticket title.'**
  String get reposPhSubject;

  /// No description provided for @reposPhTitle.
  ///
  /// In en, this message translates to:
  /// **'The ticket title as written.'**
  String get reposPhTitle;

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

  /// No description provided for @reposColStack.
  ///
  /// In en, this message translates to:
  /// **'Toolchains'**
  String get reposColStack;

  /// No description provided for @reposToolchains.
  ///
  /// In en, this message translates to:
  /// **'Toolchains'**
  String get reposToolchains;

  /// No description provided for @reposToolchainsHelp.
  ///
  /// In en, this message translates to:
  /// **'Language runtimes and build tools installed into every run, once per version, and kept for later runs.'**
  String get reposToolchainsHelp;

  /// No description provided for @reposToolchainsAuto.
  ///
  /// In en, this message translates to:
  /// **'Detected from the repository (go.mod, .nvmrc, .python-version, mise.toml, …) and kept up to date as those files change.'**
  String get reposToolchainsAuto;

  /// No description provided for @reposToolchainsManual.
  ///
  /// In en, this message translates to:
  /// **'Set by hand: detection leaves them as they are.'**
  String get reposToolchainsManual;

  /// No description provided for @reposToolchainsBackToAuto.
  ///
  /// In en, this message translates to:
  /// **'Detect automatically'**
  String get reposToolchainsBackToAuto;

  /// No description provided for @reposToolchainFrom.
  ///
  /// In en, this message translates to:
  /// **'from {source}'**
  String reposToolchainFrom(String source);

  /// No description provided for @reposToolchainRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove {tool}'**
  String reposToolchainRemove(String tool);

  /// No description provided for @reposToolchainAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get reposToolchainAdd;

  /// No description provided for @reposToolchainPh.
  ///
  /// In en, this message translates to:
  /// **'tool@version, e.g. python@3.12'**
  String get reposToolchainPh;

  /// No description provided for @reposToolchainBad.
  ///
  /// In en, this message translates to:
  /// **'Write it as tool@version, e.g. node@20 or rust@stable.'**
  String get reposToolchainBad;

  /// No description provided for @reposToolchainsNone.
  ///
  /// In en, this message translates to:
  /// **'None yet: they are detected after you save, or press Detect.'**
  String get reposToolchainsNone;

  /// No description provided for @reposDetect.
  ///
  /// In en, this message translates to:
  /// **'Detect'**
  String get reposDetect;

  /// No description provided for @reposDetectDeep.
  ///
  /// In en, this message translates to:
  /// **'Ask Muse'**
  String get reposDetectDeep;

  /// No description provided for @reposDetectDeepHelp.
  ///
  /// In en, this message translates to:
  /// **'Muse reads the README and CI files when the scan finds no commands. Takes about a minute and uses your Muse plan.'**
  String get reposDetectDeepHelp;

  /// No description provided for @reposDetecting.
  ///
  /// In en, this message translates to:
  /// **'Reading the repository…'**
  String get reposDetecting;

  /// No description provided for @reposDetectDone.
  ///
  /// In en, this message translates to:
  /// **'Found {list}.'**
  String reposDetectDone(String list);

  /// No description provided for @reposDetectNothing.
  ///
  /// In en, this message translates to:
  /// **'No known build files found. Add the toolchains and commands by hand, or ask Muse.'**
  String get reposDetectNothing;

  /// No description provided for @reposDetectFilled.
  ///
  /// In en, this message translates to:
  /// **'Empty check commands were filled in; review them before saving.'**
  String get reposDetectFilled;

  /// No description provided for @reposDetectByClaude.
  ///
  /// In en, this message translates to:
  /// **'Muse filled in what the scan could not find.'**
  String get reposDetectByClaude;

  /// No description provided for @reposDetectNeedsUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter the clone URL first.'**
  String get reposDetectNeedsUrl;

  /// No description provided for @reposCmdAuto.
  ///
  /// In en, this message translates to:
  /// **'detected after saving'**
  String get reposCmdAuto;

  /// No description provided for @reposNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes from detection'**
  String get reposNotes;

  /// No description provided for @reposAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get reposAdvanced;

  /// No description provided for @reposRunnerImage.
  ///
  /// In en, this message translates to:
  /// **'Runner image'**
  String get reposRunnerImage;

  /// No description provided for @reposRunnerImageHelp.
  ///
  /// In en, this message translates to:
  /// **'Optional. An image built on the server FROM agnts-runner, for system libraries or SDKs toolchains cannot provide (Android, Flutter). Empty uses the default.'**
  String get reposRunnerImageHelp;

  /// No description provided for @reposMemory.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get reposMemory;

  /// No description provided for @reposMemoryHelp.
  ///
  /// In en, this message translates to:
  /// **'Optional, for heavy builds (JVM, Rust, .NET). Server default unless set; the server caps it (AGNTS_RUN_MEMORY_MAX_MB, 8 GB by default).'**
  String get reposMemoryHelp;

  /// No description provided for @reposMemoryDefault.
  ///
  /// In en, this message translates to:
  /// **'Server default'**
  String get reposMemoryDefault;

  /// No description provided for @reposBuildEnv.
  ///
  /// In en, this message translates to:
  /// **'Build environment'**
  String get reposBuildEnv;

  /// No description provided for @reposBuildEnvHelp.
  ///
  /// In en, this message translates to:
  /// **'KEY=value lines given to every run, such as tokens for private package registries (NPM_TOKEN, PIP_INDEX_URL). Stored encrypted and never shown again. Muse can read them while it works, so use read-only tokens.'**
  String get reposBuildEnvHelp;

  /// No description provided for @reposBuildEnvSet.
  ///
  /// In en, this message translates to:
  /// **'Set: {names}'**
  String reposBuildEnvSet(String names);

  /// No description provided for @reposBuildEnvReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get reposBuildEnvReplace;

  /// No description provided for @reposBuildEnvClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get reposBuildEnvClear;

  /// No description provided for @reposBuildEnvCleared.
  ///
  /// In en, this message translates to:
  /// **'Cleared when you save.'**
  String get reposBuildEnvCleared;

  /// No description provided for @reposPlane.
  ///
  /// In en, this message translates to:
  /// **'Plane {project}'**
  String reposPlane(String project);

  /// No description provided for @reposPlaneProject.
  ///
  /// In en, this message translates to:
  /// **'Plane project'**
  String get reposPlaneProject;

  /// No description provided for @reposPlaneHelp.
  ///
  /// In en, this message translates to:
  /// **'Optional. The project identifier (WEB in WEB-123). Work items from this Plane project with the agnts label run here.'**
  String get reposPlaneHelp;

  /// No description provided for @reposSearch.
  ///
  /// In en, this message translates to:
  /// **'Search by name, stack, project or group'**
  String get reposSearch;

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

  /// No description provided for @reviewCat_architecture.
  ///
  /// In en, this message translates to:
  /// **'Architecture'**
  String get reviewCat_architecture;

  /// No description provided for @reviewCat_scope.
  ///
  /// In en, this message translates to:
  /// **'Scope'**
  String get reviewCat_scope;

  /// No description provided for @reviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Pull request reviews'**
  String get reviewsTitle;

  /// No description provided for @reviewsLede.
  ///
  /// In en, this message translates to:
  /// **'agnts lists the open pull requests of your repositories on GitHub and GitLab. Open one and press Review to have agnts review it as it is now; review it again whenever you want, after new commits say. Its reviews stay on the pull request.'**
  String get reviewsLede;

  /// No description provided for @reviewsSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get reviewsSyncing;

  /// No description provided for @reviewsSyncErrors.
  ///
  /// In en, this message translates to:
  /// **'Some could not be read:'**
  String get reviewsSyncErrors;

  /// No description provided for @reviewsSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'How agnts picks them up'**
  String get reviewsSettingsTitle;

  /// No description provided for @reviewsReviewRequested.
  ///
  /// In en, this message translates to:
  /// **'Review requests too'**
  String get reviewsReviewRequested;

  /// No description provided for @reviewsReviewRequestedHelp.
  ///
  /// In en, this message translates to:
  /// **'Also take pull requests whose review is requested from you, not only those assigned to you.'**
  String get reviewsReviewRequestedHelp;

  /// No description provided for @reviewsAll.
  ///
  /// In en, this message translates to:
  /// **'Every open pull request'**
  String get reviewsAll;

  /// No description provided for @reviewsAllHelp.
  ///
  /// In en, this message translates to:
  /// **'Take every open pull request in your repositories, your own included, not only those assigned to you or asking for your review. Approving one of these does not merge it.'**
  String get reviewsAllHelp;

  /// No description provided for @reviewsSkipDrafts.
  ///
  /// In en, this message translates to:
  /// **'Skip drafts'**
  String get reviewsSkipDrafts;

  /// No description provided for @reviewsSkipDraftsHelp.
  ///
  /// In en, this message translates to:
  /// **'Leave draft pull requests alone until they are ready.'**
  String get reviewsSkipDraftsHelp;

  /// No description provided for @reviewsMergeMethod.
  ///
  /// In en, this message translates to:
  /// **'Merge method'**
  String get reviewsMergeMethod;

  /// No description provided for @reviewsMergeMethodHelp.
  ///
  /// In en, this message translates to:
  /// **'How agnts merges a pull request you accept.'**
  String get reviewsMergeMethodHelp;

  /// No description provided for @reviewsMerge_merge.
  ///
  /// In en, this message translates to:
  /// **'Merge commit'**
  String get reviewsMerge_merge;

  /// No description provided for @reviewsMerge_squash.
  ///
  /// In en, this message translates to:
  /// **'Squash'**
  String get reviewsMerge_squash;

  /// No description provided for @reviewsMerge_rebase.
  ///
  /// In en, this message translates to:
  /// **'Rebase'**
  String get reviewsMerge_rebase;

  /// No description provided for @reviewsWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for you'**
  String get reviewsWaiting;

  /// No description provided for @reviewsInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get reviewsInProgress;

  /// No description provided for @reviewsFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get reviewsFinished;

  /// No description provided for @reviewsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here.'**
  String get reviewsEmpty;

  /// No description provided for @reviewsEmptyAll.
  ///
  /// In en, this message translates to:
  /// **'No open pull requests. Check which ones are taken in the settings, then press Refresh.'**
  String get reviewsEmptyAll;

  /// No description provided for @reviewsWhy_assigned.
  ///
  /// In en, this message translates to:
  /// **'assigned'**
  String get reviewsWhy_assigned;

  /// No description provided for @reviewsWhy_review_requested.
  ///
  /// In en, this message translates to:
  /// **'review requested'**
  String get reviewsWhy_review_requested;

  /// No description provided for @reviewsWhy_open.
  ///
  /// In en, this message translates to:
  /// **'open'**
  String get reviewsWhy_open;

  /// No description provided for @reviewsWhy_own.
  ///
  /// In en, this message translates to:
  /// **'yours'**
  String get reviewsWhy_own;

  /// No description provided for @reviewsWhy_manual.
  ///
  /// In en, this message translates to:
  /// **'asked for here'**
  String get reviewsWhy_manual;

  /// No description provided for @reviewsBy.
  ///
  /// In en, this message translates to:
  /// **'by @{author}'**
  String reviewsBy(String author);

  /// No description provided for @reviewsHowTitle.
  ///
  /// In en, this message translates to:
  /// **'How you review'**
  String get reviewsHowTitle;

  /// No description provided for @reviewsHowSub.
  ///
  /// In en, this message translates to:
  /// **'Notes you leave when you ask for another review or dismiss one are folded into your profile on the next review. Every later review reads it.'**
  String get reviewsHowSub;

  /// No description provided for @reviewsNoReviewers.
  ///
  /// In en, this message translates to:
  /// **'agnts knows nothing about how you review yet. Leave a note when you ask for another review, or add one below.'**
  String get reviewsNoReviewers;

  /// No description provided for @reviewsProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get reviewsProfile;

  /// No description provided for @reviewsProfileHint.
  ///
  /// In en, this message translates to:
  /// **'Markdown: what you care about, what is noise, how severe you rate things.'**
  String get reviewsProfileHint;

  /// No description provided for @reviewsFolded.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} note learned} other {{n} notes learned}}'**
  String reviewsFolded(num n);

  /// No description provided for @reviewsPending.
  ///
  /// In en, this message translates to:
  /// **'Not learned yet'**
  String get reviewsPending;

  /// No description provided for @reviewsSaveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get reviewsSaveProfile;

  /// No description provided for @reviewsProfileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get reviewsProfileSaved;

  /// No description provided for @reviewsAddNote.
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get reviewsAddNote;

  /// No description provided for @reviewsNotePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'For example: naming nits are noise to me; always check that migrations can be rolled back.'**
  String get reviewsNotePlaceholder;

  /// No description provided for @reviewsNoteAdded.
  ///
  /// In en, this message translates to:
  /// **'Note added'**
  String get reviewsNoteAdded;

  /// No description provided for @reviewsDeleteNote.
  ///
  /// In en, this message translates to:
  /// **'Delete note'**
  String get reviewsDeleteNote;

  /// No description provided for @reviewsNoteKind_rereview.
  ///
  /// In en, this message translates to:
  /// **'re-review'**
  String get reviewsNoteKind_rereview;

  /// No description provided for @reviewsNoteKind_dismissed.
  ///
  /// In en, this message translates to:
  /// **'dismissed'**
  String get reviewsNoteKind_dismissed;

  /// No description provided for @reviewsNoteKind_manual.
  ///
  /// In en, this message translates to:
  /// **'written here'**
  String get reviewsNoteKind_manual;

  /// No description provided for @reviewsLogin.
  ///
  /// In en, this message translates to:
  /// **'Git host username'**
  String get reviewsLogin;

  /// No description provided for @reviewsPr.
  ///
  /// In en, this message translates to:
  /// **'Pull request #{number}'**
  String reviewsPr(String number);

  /// No description provided for @reviewsReviewed.
  ///
  /// In en, this message translates to:
  /// **'Head at {sha}'**
  String reviewsReviewed(String sha);

  /// No description provided for @reviewsNewCommits.
  ///
  /// In en, this message translates to:
  /// **'New commits since'**
  String get reviewsNewCommits;

  /// No description provided for @reviewsPostBtn.
  ///
  /// In en, this message translates to:
  /// **'Post review on {host}'**
  String reviewsPostBtn(String host);

  /// No description provided for @reviewsPostConfirm.
  ///
  /// In en, this message translates to:
  /// **'Post agnts\'s review of #{number} on {host} as a comment? It is posted as your {host} account and everyone on the pull request sees it.'**
  String reviewsPostConfirm(String number, String host);

  /// No description provided for @reviewsPostedToast.
  ///
  /// In en, this message translates to:
  /// **'Review posted on {host}'**
  String reviewsPostedToast(String host);

  /// No description provided for @reviewsPosted.
  ///
  /// In en, this message translates to:
  /// **'agnts\'s review of this commit is on {host} · {when}'**
  String reviewsPosted(String host, String when);

  /// No description provided for @reviewsQueuedSub.
  ///
  /// In en, this message translates to:
  /// **'agnts will fetch it and review it.'**
  String get reviewsQueuedSub;

  /// No description provided for @reviewsFetchingTitle.
  ///
  /// In en, this message translates to:
  /// **'Fetching the pull request'**
  String get reviewsFetchingTitle;

  /// No description provided for @reviewsReviewingTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviewing the pull request'**
  String get reviewsReviewingTitle;

  /// No description provided for @reviewsReviewingSub.
  ///
  /// In en, this message translates to:
  /// **'agnts is reading the change. Its review appears here.'**
  String get reviewsReviewingSub;

  /// No description provided for @reviewsReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'agnts\'s review is ready'**
  String get reviewsReadyTitle;

  /// No description provided for @reviewsReadySub.
  ///
  /// In en, this message translates to:
  /// **'Merge it from here, review again with a note, or dismiss it and review on {host} yourself.'**
  String reviewsReadySub(String host);

  /// No description provided for @reviewsNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Review again with a note'**
  String get reviewsNoteLabel;

  /// No description provided for @reviewsNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Tell agnts what it got wrong or missed. The note also teaches it how you review.'**
  String get reviewsNoteHint;

  /// No description provided for @reviewsMergeBtn.
  ///
  /// In en, this message translates to:
  /// **'Merge pull request'**
  String get reviewsMergeBtn;

  /// No description provided for @reviewsMergeConfirm.
  ///
  /// In en, this message translates to:
  /// **'agnts merges #{number} on {host} ({method}), at the commit it reviewed.'**
  String reviewsMergeConfirm(String number, String host, String method);

  /// No description provided for @reviewsRereviewBtn.
  ///
  /// In en, this message translates to:
  /// **'Review again'**
  String get reviewsRereviewBtn;

  /// No description provided for @reviewsDismissBtn.
  ///
  /// In en, this message translates to:
  /// **'Dismiss, I\'ll review it on {host}'**
  String reviewsDismissBtn(String host);

  /// No description provided for @reviewsDismissReason.
  ///
  /// In en, this message translates to:
  /// **'Why (optional)'**
  String get reviewsDismissReason;

  /// No description provided for @reviewsDismissReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Optional. It also teaches agnts how you review.'**
  String get reviewsDismissReasonHint;

  /// No description provided for @reviewsDismissConfirm.
  ///
  /// In en, this message translates to:
  /// **'agnts stops reviewing #{number}. The pull request stays open on {host}.'**
  String reviewsDismissConfirm(String number, String host);

  /// No description provided for @reviewsMergingTitle.
  ///
  /// In en, this message translates to:
  /// **'Merging the pull request'**
  String get reviewsMergingTitle;

  /// No description provided for @reviewsMergedTitle.
  ///
  /// In en, this message translates to:
  /// **'Merged'**
  String get reviewsMergedTitle;

  /// No description provided for @reviewsMergedSub.
  ///
  /// In en, this message translates to:
  /// **'#{number} is merged.'**
  String reviewsMergedSub(String number);

  /// No description provided for @reviewsDismissedTitle.
  ///
  /// In en, this message translates to:
  /// **'Review dismissed'**
  String get reviewsDismissedTitle;

  /// No description provided for @reviewsDismissedSub.
  ///
  /// In en, this message translates to:
  /// **'The pull request is yours on {host}.'**
  String reviewsDismissedSub(String host);

  /// No description provided for @reviewsOpenOn.
  ///
  /// In en, this message translates to:
  /// **'Open on {host}'**
  String reviewsOpenOn(String host);

  /// No description provided for @reviewsReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'agnts\'s review of the pull request'**
  String get reviewsReviewTitle;

  /// No description provided for @reviewsRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get reviewsRefresh;

  /// No description provided for @reviewsOpenPulls.
  ///
  /// In en, this message translates to:
  /// **'Open pull requests'**
  String get reviewsOpenPulls;

  /// No description provided for @reviewsNotReviewed.
  ///
  /// In en, this message translates to:
  /// **'Not reviewed'**
  String get reviewsNotReviewed;

  /// No description provided for @reviewsHistory.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewsHistory;

  /// No description provided for @reviewsHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Not reviewed yet. Press Review with agnts to start one.'**
  String get reviewsHistoryEmpty;

  /// No description provided for @reviewsReviewedAt.
  ///
  /// In en, this message translates to:
  /// **'at {sha}'**
  String reviewsReviewedAt(String sha);

  /// No description provided for @rulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get rulesTitle;

  /// No description provided for @rulesLede.
  ///
  /// In en, this message translates to:
  /// **'Instructions agnts follows on every ticket: global rules for all repositories and rules for one repository. Muse reviews each rule and asks about anything unclear before it applies.'**
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
  /// **'Write it the way you would brief a new teammate. Muse checks it before any ticket follows it.'**
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
  /// **'You changed what the rule says, so Muse reviews it again. Tickets stop getting it until the review is done.'**
  String get rulesRereviewHelp;

  /// No description provided for @rulesSaved.
  ///
  /// In en, this message translates to:
  /// **'Rule saved'**
  String get rulesSaved;

  /// No description provided for @rulesSavedReview.
  ///
  /// In en, this message translates to:
  /// **'Rule saved; Muse is reviewing it'**
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
  /// **'Waiting for a free worker. Muse reviews rules before the next ticket starts.'**
  String get rulesPending;

  /// No description provided for @rulesAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Muse is reading the rule and checking it for anything unclear or conflicting.'**
  String get rulesAnalyzing;

  /// No description provided for @rulesQuestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} question before this rule applies} other {{n} questions before this rule applies}}'**
  String rulesQuestionsTitle(num n);

  /// No description provided for @rulesQuestionsSub.
  ///
  /// In en, this message translates to:
  /// **'Muse found something unclear. Your answers become part of the rule.'**
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
  /// **'Muse could not review this rule: {error}'**
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
  /// **'Answers sent; Muse is reviewing the rule again'**
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

  /// No description provided for @rulesStatus_suggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get rulesStatus_suggested;

  /// No description provided for @rulesSuggestedFrom.
  ///
  /// In en, this message translates to:
  /// **'agnts suggests this rule from your feedback on'**
  String get rulesSuggestedFrom;

  /// No description provided for @rulesSuggestedHint.
  ///
  /// In en, this message translates to:
  /// **'Tickets don\'t follow it until you adopt it. Edit it to adopt it with your changes.'**
  String get rulesSuggestedHint;

  /// No description provided for @rulesSuggestedHelp.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {agnts suggests {n} rule learned from your feedback.} other {agnts suggests {n} rules learned from your feedback.}}'**
  String rulesSuggestedHelp(num n);

  /// No description provided for @rulesAdopt.
  ///
  /// In en, this message translates to:
  /// **'Adopt'**
  String get rulesAdopt;

  /// No description provided for @rulesAdoptAsWritten.
  ///
  /// In en, this message translates to:
  /// **'Adopt as written'**
  String get rulesAdoptAsWritten;

  /// No description provided for @rulesDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get rulesDismiss;

  /// No description provided for @rulesDismissBody.
  ///
  /// In en, this message translates to:
  /// **'agnts drops “{title}” and won\'t suggest it again.'**
  String rulesDismissBody(String title);

  /// No description provided for @rulesDismissed.
  ///
  /// In en, this message translates to:
  /// **'Suggestion dismissed'**
  String get rulesDismissed;

  /// No description provided for @rulesKind.
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get rulesKind;

  /// No description provided for @rulesKindRule.
  ///
  /// In en, this message translates to:
  /// **'Rule'**
  String get rulesKindRule;

  /// No description provided for @rulesKindContext.
  ///
  /// In en, this message translates to:
  /// **'Business context'**
  String get rulesKindContext;

  /// No description provided for @rulesKindRuleHelp.
  ///
  /// In en, this message translates to:
  /// **'An instruction agnts follows on every ticket.'**
  String get rulesKindRuleHelp;

  /// No description provided for @rulesKindContextHelp.
  ///
  /// In en, this message translates to:
  /// **'Knowledge about your product: what its terms mean, invariants the code must keep, who uses what. Every run reads it before it starts.'**
  String get rulesKindContextHelp;

  /// No description provided for @rulesTag_reuse.
  ///
  /// In en, this message translates to:
  /// **'reuse'**
  String get rulesTag_reuse;

  /// No description provided for @rulesTag_layer.
  ///
  /// In en, this message translates to:
  /// **'layer'**
  String get rulesTag_layer;

  /// No description provided for @rulesTag_tests.
  ///
  /// In en, this message translates to:
  /// **'tests'**
  String get rulesTag_tests;

  /// No description provided for @rulesTag_style.
  ///
  /// In en, this message translates to:
  /// **'style'**
  String get rulesTag_style;

  /// No description provided for @rulesTag_logic.
  ///
  /// In en, this message translates to:
  /// **'logic'**
  String get rulesTag_logic;

  /// No description provided for @rulesTag_other.
  ///
  /// In en, this message translates to:
  /// **'other'**
  String get rulesTag_other;

  /// No description provided for @runsNavRuns.
  ///
  /// In en, this message translates to:
  /// **'Runs'**
  String get runsNavRuns;

  /// No description provided for @runsTitle.
  ///
  /// In en, this message translates to:
  /// **'Run history'**
  String get runsTitle;

  /// No description provided for @runsLede.
  ///
  /// In en, this message translates to:
  /// **'Every Muse and Codex invocation across workspaces: what it cost, how long it took and how it ended. Opening one shows customer content, and every read is logged.'**
  String get runsLede;

  /// No description provided for @runsRunTitle.
  ///
  /// In en, this message translates to:
  /// **'Invocation'**
  String get runsRunTitle;

  /// No description provided for @runsBack.
  ///
  /// In en, this message translates to:
  /// **'All runs'**
  String get runsBack;

  /// No description provided for @runsSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get runsSettings;

  /// No description provided for @runsSumCount.
  ///
  /// In en, this message translates to:
  /// **'Invocations'**
  String get runsSumCount;

  /// No description provided for @runsSumErrors.
  ///
  /// In en, this message translates to:
  /// **'Error rate'**
  String get runsSumErrors;

  /// No description provided for @runsSumErrorsNote.
  ///
  /// In en, this message translates to:
  /// **'{n} ended in an error, timeout or out of memory'**
  String runsSumErrorsNote(String n);

  /// No description provided for @runsSumStalls.
  ///
  /// In en, this message translates to:
  /// **'Had stalls'**
  String get runsSumStalls;

  /// No description provided for @runsSumStallsNote.
  ///
  /// In en, this message translates to:
  /// **'invocations with at least one stall'**
  String get runsSumStallsNote;

  /// No description provided for @runsSumCost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get runsSumCost;

  /// No description provided for @runsSumCostNote.
  ///
  /// In en, this message translates to:
  /// **'background {cost}'**
  String runsSumCostNote(String cost);

  /// No description provided for @runsSumTokens.
  ///
  /// In en, this message translates to:
  /// **'Tokens in / out'**
  String get runsSumTokens;

  /// No description provided for @runsSumTokensNote.
  ///
  /// In en, this message translates to:
  /// **'without cache reads'**
  String get runsSumTokensNote;

  /// No description provided for @runsSumDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration p50 / p95'**
  String get runsSumDuration;

  /// No description provided for @runsSumDurationNote.
  ///
  /// In en, this message translates to:
  /// **'of finished invocations'**
  String get runsSumDurationNote;

  /// No description provided for @runsFWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get runsFWorkspace;

  /// No description provided for @runsAllWorkspaces.
  ///
  /// In en, this message translates to:
  /// **'All workspaces'**
  String get runsAllWorkspaces;

  /// No description provided for @runsFPurpose.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get runsFPurpose;

  /// No description provided for @runsAllPurposes.
  ///
  /// In en, this message translates to:
  /// **'All purposes'**
  String get runsAllPurposes;

  /// No description provided for @runsPStages.
  ///
  /// In en, this message translates to:
  /// **'Ticket stages'**
  String get runsPStages;

  /// No description provided for @runsPBackground.
  ///
  /// In en, this message translates to:
  /// **'Background calls'**
  String get runsPBackground;

  /// No description provided for @runsP_analyze.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get runsP_analyze;

  /// No description provided for @runsP_code.
  ///
  /// In en, this message translates to:
  /// **'Coding'**
  String get runsP_code;

  /// No description provided for @runsP_review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get runsP_review;

  /// No description provided for @runsP_push.
  ///
  /// In en, this message translates to:
  /// **'Push'**
  String get runsP_push;

  /// No description provided for @runsP_learn.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get runsP_learn;

  /// No description provided for @runsP_preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get runsP_preview;

  /// No description provided for @runsP_second_opinion.
  ///
  /// In en, this message translates to:
  /// **'Second opinion'**
  String get runsP_second_opinion;

  /// No description provided for @runsP_assistant.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get runsP_assistant;

  /// No description provided for @runsP_brief.
  ///
  /// In en, this message translates to:
  /// **'Repository brief'**
  String get runsP_brief;

  /// No description provided for @runsP_detect.
  ///
  /// In en, this message translates to:
  /// **'Toolchain detection'**
  String get runsP_detect;

  /// No description provided for @runsP_reflect.
  ///
  /// In en, this message translates to:
  /// **'Reflection'**
  String get runsP_reflect;

  /// No description provided for @runsP_rules.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get runsP_rules;

  /// No description provided for @runsP_translate.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get runsP_translate;

  /// No description provided for @runsFStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get runsFStatus;

  /// No description provided for @runsAnyStatus.
  ///
  /// In en, this message translates to:
  /// **'Any status'**
  String get runsAnyStatus;

  /// No description provided for @runsS_running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get runsS_running;

  /// No description provided for @runsS_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get runsS_done;

  /// No description provided for @runsS_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get runsS_error;

  /// No description provided for @runsS_timeout.
  ///
  /// In en, this message translates to:
  /// **'Timed out'**
  String get runsS_timeout;

  /// No description provided for @runsS_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get runsS_cancelled;

  /// No description provided for @runsS_oom.
  ///
  /// In en, this message translates to:
  /// **'Out of memory'**
  String get runsS_oom;

  /// No description provided for @runsFEngine.
  ///
  /// In en, this message translates to:
  /// **'Engine'**
  String get runsFEngine;

  /// No description provided for @runsAnyEngine.
  ///
  /// In en, this message translates to:
  /// **'Any engine'**
  String get runsAnyEngine;

  /// No description provided for @runsE_claude.
  ///
  /// In en, this message translates to:
  /// **'Muse'**
  String get runsE_claude;

  /// No description provided for @runsE_codex.
  ///
  /// In en, this message translates to:
  /// **'Codex'**
  String get runsE_codex;

  /// No description provided for @runsFModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get runsFModel;

  /// No description provided for @runsFTicket.
  ///
  /// In en, this message translates to:
  /// **'Ticket'**
  String get runsFTicket;

  /// No description provided for @runsFStalled.
  ///
  /// In en, this message translates to:
  /// **'Had stalls'**
  String get runsFStalled;

  /// No description provided for @runsFPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get runsFPeriod;

  /// No description provided for @runsPer_1d.
  ///
  /// In en, this message translates to:
  /// **'Last 24 hours'**
  String get runsPer_1d;

  /// No description provided for @runsPer_7d.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get runsPer_7d;

  /// No description provided for @runsPer_30d.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get runsPer_30d;

  /// No description provided for @runsPer_all.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get runsPer_all;

  /// No description provided for @runsFMinCost.
  ///
  /// In en, this message translates to:
  /// **'Min. cost'**
  String get runsFMinCost;

  /// No description provided for @runsClear.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get runsClear;

  /// No description provided for @runsNone.
  ///
  /// In en, this message translates to:
  /// **'No invocations match these filters.'**
  String get runsNone;

  /// No description provided for @runsLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get runsLoadMore;

  /// No description provided for @runsColStarted.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get runsColStarted;

  /// No description provided for @runsColWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get runsColWorkspace;

  /// No description provided for @runsColTicket.
  ///
  /// In en, this message translates to:
  /// **'Ticket or subject'**
  String get runsColTicket;

  /// No description provided for @runsColPurpose.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get runsColPurpose;

  /// No description provided for @runsColModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get runsColModel;

  /// No description provided for @runsColTurns.
  ///
  /// In en, this message translates to:
  /// **'Turns'**
  String get runsColTurns;

  /// No description provided for @runsColTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get runsColTools;

  /// No description provided for @runsColCost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get runsColCost;

  /// No description provided for @runsColDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get runsColDuration;

  /// No description provided for @runsColOutcome.
  ///
  /// In en, this message translates to:
  /// **'Outcome'**
  String get runsColOutcome;

  /// No description provided for @runsToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'{calls} tool calls, {errors} failed'**
  String runsToolsTitle(String calls, String errors);

  /// No description provided for @runsStallsTitle.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} stall} other {{n} stalls}}'**
  String runsStallsTitle(num n);

  /// No description provided for @runsSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Run history settings'**
  String get runsSettingsTitle;

  /// No description provided for @runsSettingsSub.
  ///
  /// In en, this message translates to:
  /// **'How long transcripts are kept and how much of each is stored. Caps apply to invocations started after saving.'**
  String get runsSettingsSub;

  /// No description provided for @runsSet_retentionDays.
  ///
  /// In en, this message translates to:
  /// **'Keep transcripts, days'**
  String get runsSet_retentionDays;

  /// No description provided for @runsSet_retentionDaysHelp.
  ///
  /// In en, this message translates to:
  /// **'Older ones are deleted daily; 0 keeps them'**
  String get runsSet_retentionDaysHelp;

  /// No description provided for @runsSet_toolOutputKB.
  ///
  /// In en, this message translates to:
  /// **'Tool output cap, KB'**
  String get runsSet_toolOutputKB;

  /// No description provided for @runsSet_toolOutputKBHelp.
  ///
  /// In en, this message translates to:
  /// **'One tool\'s output; its start and end are kept'**
  String get runsSet_toolOutputKBHelp;

  /// No description provided for @runsSet_textKB.
  ///
  /// In en, this message translates to:
  /// **'Text cap, KB'**
  String get runsSet_textKB;

  /// No description provided for @runsSet_textKBHelp.
  ///
  /// In en, this message translates to:
  /// **'One text block or tool input'**
  String get runsSet_textKBHelp;

  /// No description provided for @runsSet_transcriptMB.
  ///
  /// In en, this message translates to:
  /// **'Transcript cap, MB'**
  String get runsSet_transcriptMB;

  /// No description provided for @runsSet_transcriptMBHelp.
  ///
  /// In en, this message translates to:
  /// **'Past it only tool calls and the result are kept'**
  String get runsSet_transcriptMBHelp;

  /// No description provided for @runsSettingsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get runsSettingsSave;

  /// No description provided for @runsSettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Run history settings saved'**
  String get runsSettingsSaved;

  /// No description provided for @runsBanner.
  ///
  /// In en, this message translates to:
  /// **'Viewing customer content. This access is logged.'**
  String get runsBanner;

  /// No description provided for @runsDownload.
  ///
  /// In en, this message translates to:
  /// **'Download JSONL'**
  String get runsDownload;

  /// No description provided for @runsNotFound.
  ///
  /// In en, this message translates to:
  /// **'This transcript no longer exists.'**
  String get runsNotFound;

  /// No description provided for @runsUnreadable.
  ///
  /// In en, this message translates to:
  /// **'Part of this transcript could not be read; what follows is what could.'**
  String get runsUnreadable;

  /// No description provided for @runsTruncated.
  ///
  /// In en, this message translates to:
  /// **'The size limit was reached; later content was left out.'**
  String get runsTruncated;

  /// No description provided for @runsAccount.
  ///
  /// In en, this message translates to:
  /// **'Muse account'**
  String get runsAccount;

  /// No description provided for @runsSession.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get runsSession;

  /// No description provided for @runsStartedAt.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get runsStartedAt;

  /// No description provided for @runsFinishedAt.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get runsFinishedAt;

  /// No description provided for @runsTokens.
  ///
  /// In en, this message translates to:
  /// **'Tokens'**
  String get runsTokens;

  /// No description provided for @runsTokensVal.
  ///
  /// In en, this message translates to:
  /// **'{input} in · {output} out'**
  String runsTokensVal(String input, String output);

  /// No description provided for @runsCacheVal.
  ///
  /// In en, this message translates to:
  /// **'cache: {read} read · {write} written'**
  String runsCacheVal(String read, String write);

  /// No description provided for @runsSize.
  ///
  /// In en, this message translates to:
  /// **'Stored / raw size'**
  String get runsSize;

  /// No description provided for @runsExitReason.
  ///
  /// In en, this message translates to:
  /// **'Exit reason'**
  String get runsExitReason;

  /// No description provided for @runsRunningNote.
  ///
  /// In en, this message translates to:
  /// **'Still running. Reloading reads the transcript again, which is logged.'**
  String get runsRunningNote;

  /// No description provided for @runsReload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get runsReload;

  /// No description provided for @runsSiblings.
  ///
  /// In en, this message translates to:
  /// **'This run\'s invocations'**
  String get runsSiblings;

  /// No description provided for @runsSiblingsSub.
  ///
  /// In en, this message translates to:
  /// **'First pass, fix attempts and second opinion, oldest first'**
  String get runsSiblingsSub;

  /// No description provided for @runsThisOne.
  ///
  /// In en, this message translates to:
  /// **'this one'**
  String get runsThisOne;

  /// No description provided for @runsTab_timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get runsTab_timeline;

  /// No description provided for @runsTab_prompt.
  ///
  /// In en, this message translates to:
  /// **'Prompt'**
  String get runsTab_prompt;

  /// No description provided for @runsTab_result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get runsTab_result;

  /// No description provided for @runsEventsCount.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} event} other {{n} events}}'**
  String runsEventsCount(num n);

  /// No description provided for @runsNextError.
  ///
  /// In en, this message translates to:
  /// **'Next error ({n})'**
  String runsNextError(String n);

  /// No description provided for @runsNoErrors.
  ///
  /// In en, this message translates to:
  /// **'No errors'**
  String get runsNoErrors;

  /// No description provided for @runsNoEvents.
  ///
  /// In en, this message translates to:
  /// **'Nothing was recorded.'**
  String get runsNoEvents;

  /// No description provided for @runsShowMore.
  ///
  /// In en, this message translates to:
  /// **'Show {n} more'**
  String runsShowMore(String n);

  /// No description provided for @runsKTool.
  ///
  /// In en, this message translates to:
  /// **'Tool'**
  String get runsKTool;

  /// No description provided for @runsKToolResult.
  ///
  /// In en, this message translates to:
  /// **'Tool result'**
  String get runsKToolResult;

  /// No description provided for @runsKInit.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get runsKInit;

  /// No description provided for @runsKRateLimit.
  ///
  /// In en, this message translates to:
  /// **'Rate limit'**
  String get runsKRateLimit;

  /// No description provided for @runsKNote.
  ///
  /// In en, this message translates to:
  /// **'agnts'**
  String get runsKNote;

  /// No description provided for @runsKResult.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get runsKResult;

  /// No description provided for @runsToolOk.
  ///
  /// In en, this message translates to:
  /// **'Succeeded'**
  String get runsToolOk;

  /// No description provided for @runsToolFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get runsToolFailed;

  /// No description provided for @runsExitCode.
  ///
  /// In en, this message translates to:
  /// **'exit {code}'**
  String runsExitCode(String code);

  /// No description provided for @runsInput.
  ///
  /// In en, this message translates to:
  /// **'Input'**
  String get runsInput;

  /// No description provided for @runsOutput.
  ///
  /// In en, this message translates to:
  /// **'Output'**
  String get runsOutput;

  /// No description provided for @runsNoOutput.
  ///
  /// In en, this message translates to:
  /// **'(no output)'**
  String get runsNoOutput;

  /// No description provided for @runsCutNote.
  ///
  /// In en, this message translates to:
  /// **'cut, original {kb} KB'**
  String runsCutNote(String kb);

  /// No description provided for @runsTurnsN.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} turn} other {{n} turns}}'**
  String runsTurnsN(num n);

  /// No description provided for @runsNoPrompt.
  ///
  /// In en, this message translates to:
  /// **'(empty prompt)'**
  String get runsNoPrompt;

  /// No description provided for @runsNoResult.
  ///
  /// In en, this message translates to:
  /// **'No result was recorded.'**
  String get runsNoResult;

  /// No description provided for @runsSubtype.
  ///
  /// In en, this message translates to:
  /// **'Subtype'**
  String get runsSubtype;

  /// No description provided for @runsAuditTitle.
  ///
  /// In en, this message translates to:
  /// **'Audit log'**
  String get runsAuditTitle;

  /// No description provided for @runsAuditLede.
  ///
  /// In en, this message translates to:
  /// **'Every time an Admin read customer content (a transcript, a prompt, a download) or changed run history settings, newest first.'**
  String get runsAuditLede;

  /// No description provided for @runsAllActions.
  ///
  /// In en, this message translates to:
  /// **'All actions'**
  String get runsAllActions;

  /// No description provided for @runsA_transcript_view.
  ///
  /// In en, this message translates to:
  /// **'Viewed a transcript'**
  String get runsA_transcript_view;

  /// No description provided for @runsA_transcript_prompt.
  ///
  /// In en, this message translates to:
  /// **'Viewed a prompt'**
  String get runsA_transcript_prompt;

  /// No description provided for @runsA_transcript_download.
  ///
  /// In en, this message translates to:
  /// **'Downloaded a transcript'**
  String get runsA_transcript_download;

  /// No description provided for @runsA_run_history_settings.
  ///
  /// In en, this message translates to:
  /// **'Changed settings'**
  String get runsA_run_history_settings;

  /// No description provided for @runsColTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get runsColTime;

  /// No description provided for @runsColAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get runsColAdmin;

  /// No description provided for @runsColAction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get runsColAction;

  /// No description provided for @runsColTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get runsColTarget;

  /// No description provided for @runsColIp.
  ///
  /// In en, this message translates to:
  /// **'IP'**
  String get runsColIp;

  /// No description provided for @runsNoAudit.
  ///
  /// In en, this message translates to:
  /// **'Nothing in the audit log yet.'**
  String get runsNoAudit;

  /// No description provided for @runsAuditSearch.
  ///
  /// In en, this message translates to:
  /// **'Search admin, target or workspace'**
  String get runsAuditSearch;

  /// No description provided for @runsAuditTranscript.
  ///
  /// In en, this message translates to:
  /// **'Transcript #{id}'**
  String runsAuditTranscript(String id);

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

  /// No description provided for @settingsRunBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget per run'**
  String get settingsRunBudget;

  /// No description provided for @settingsRunBudgetHelp.
  ///
  /// In en, this message translates to:
  /// **'The most one run on credits may spend; Muse is told to wrap up at 80% and stopped before going over'**
  String get settingsRunBudgetHelp;

  /// No description provided for @settingsRunBudgetServer.
  ///
  /// In en, this message translates to:
  /// **'Server cap'**
  String get settingsRunBudgetServer;

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
  /// **'Commits and PR'**
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
  /// **'Leave empty to commit as each ticket\'s owner, with the name and email of their account'**
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

  /// No description provided for @settingsProgress.
  ///
  /// In en, this message translates to:
  /// **'When an agent finishes a step'**
  String get settingsProgress;

  /// No description provided for @settingsProgressHelp.
  ///
  /// In en, this message translates to:
  /// **'Analysis done, code written. Phone only, silent, one notification per ticket'**
  String get settingsProgressHelp;

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

  /// No description provided for @settingsSecretsHelp.
  ///
  /// In en, this message translates to:
  /// **'Tokens for Jira, GitHub and Muse are stored encrypted on your server. This page never shows them.'**
  String get settingsSecretsHelp;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// No description provided for @settingsParallelSlots.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} run} other {{n} runs}} at once'**
  String settingsParallelSlots(num n);

  /// No description provided for @settingsParallelSlotsHelp.
  ///
  /// In en, this message translates to:
  /// **'The workspace\'s slots. Change them in Workspace → Billing.'**
  String get settingsParallelSlotsHelp;

  /// No description provided for @settingsClaudeMoved.
  ///
  /// In en, this message translates to:
  /// **'Claude is connected per workspace now.'**
  String get settingsClaudeMoved;

  /// No description provided for @settingsClaudeOpen.
  ///
  /// In en, this message translates to:
  /// **'Workspace → Claude'**
  String get settingsClaudeOpen;

  /// No description provided for @settingsSelfReview.
  ///
  /// In en, this message translates to:
  /// **'Fix review findings first'**
  String get settingsSelfReview;

  /// No description provided for @settingsSelfReviewHelp.
  ///
  /// In en, this message translates to:
  /// **'When agnts\'s own code review finds a blocker or major problem, agnts sends it back to the coder once before you review. Needs the code review above.'**
  String get settingsSelfReviewHelp;

  /// No description provided for @settingsAutoBrief.
  ///
  /// In en, this message translates to:
  /// **'Survey repositories'**
  String get settingsAutoBrief;

  /// No description provided for @settingsAutoBriefHelp.
  ///
  /// In en, this message translates to:
  /// **'Write a repository brief (architecture, recipes, conventions) when a repository\'s first ticket is analysed, and update it after every 10 merges. A brief reaches the agent only after you approve it.'**
  String get settingsAutoBriefHelp;

  /// No description provided for @settingsReflect.
  ///
  /// In en, this message translates to:
  /// **'Learn from your feedback'**
  String get settingsReflect;

  /// No description provided for @settingsReflectHelp.
  ///
  /// In en, this message translates to:
  /// **'When you ask for changes or reject work with a reason, agnts looks for a convention behind it and suggests a rule on the Rules page. Nothing applies until you adopt it.'**
  String get settingsReflectHelp;

  /// No description provided for @settingsCiRed.
  ///
  /// In en, this message translates to:
  /// **'When a watched branch goes red'**
  String get settingsCiRed;

  /// No description provided for @settingsClaudeMuse.
  ///
  /// In en, this message translates to:
  /// **'Muse Code'**
  String get settingsClaudeMuse;

  /// No description provided for @settingsClaudeMovedMuse.
  ///
  /// In en, this message translates to:
  /// **'Muse is connected per workspace.'**
  String get settingsClaudeMovedMuse;

  /// No description provided for @settingsClaudeOpenMuse.
  ///
  /// In en, this message translates to:
  /// **'Workspace → Muse'**
  String get settingsClaudeOpenMuse;

  /// No description provided for @settingsModelsHelpMuse.
  ///
  /// In en, this message translates to:
  /// **'Pick which model runs each step. Muse Spark costs the least; Muse Wonder is stronger and costs more.'**
  String get settingsModelsHelpMuse;

  /// No description provided for @settingsStageCodingHelpMuse.
  ///
  /// In en, this message translates to:
  /// **'The main run. Spends the most.'**
  String get settingsStageCodingHelpMuse;

  /// No description provided for @settingsStageReviewHelpMuse.
  ///
  /// In en, this message translates to:
  /// **'Reviews each result while you review it. Auto uses Muse Wonder for complex tickets and Muse Spark for the rest.'**
  String get settingsStageReviewHelpMuse;

  /// No description provided for @settingsAllowHelpMuse.
  ///
  /// In en, this message translates to:
  /// **'Muse Code can run these without asking'**
  String get settingsAllowHelpMuse;

  /// No description provided for @settingsDenyHelpMuse.
  ///
  /// In en, this message translates to:
  /// **'Always refused, even if a ticket asks for them. Pushing is done by agnts, never by Muse Code.'**
  String get settingsDenyHelpMuse;

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
  /// **'Nothing recorded yet. Spend appears after agnts\'s first Muse run on this ticket.'**
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
  /// **'Cost is Muse\'s estimate of the same work at API prices. On a Muse plan you are not charged it; it shows the relative weight of each stage.'**
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
  /// **'No Muse runs recorded in this period.'**
  String get spendTopEmpty;

  /// No description provided for @spendTopNote.
  ///
  /// In en, this message translates to:
  /// **'Ranked by Muse\'s cost estimate, which weighs cache traffic properly. Share is of the period\'s estimated cost. Only spend inside the period counts.'**
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

  /// No description provided for @stateReviewAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Fetching'**
  String get stateReviewAnalyzing;

  /// No description provided for @stateReviewCoding.
  ///
  /// In en, this message translates to:
  /// **'Reviewing'**
  String get stateReviewCoding;

  /// No description provided for @stateReviewWaiting_for_review.
  ///
  /// In en, this message translates to:
  /// **'Review ready'**
  String get stateReviewWaiting_for_review;

  /// No description provided for @stateReviewPushing.
  ///
  /// In en, this message translates to:
  /// **'Merging'**
  String get stateReviewPushing;

  /// No description provided for @stateReviewDone.
  ///
  /// In en, this message translates to:
  /// **'Merged'**
  String get stateReviewDone;

  /// No description provided for @stateReviewRejected.
  ///
  /// In en, this message translates to:
  /// **'Dismissed'**
  String get stateReviewRejected;

  /// No description provided for @swaggerFormSub.
  ///
  /// In en, this message translates to:
  /// **'Test an HTTP API against its Swagger/OpenAPI spec: agnts plans the cases, sends real requests and reports a verdict per case with the evidence.'**
  String get swaggerFormSub;

  /// No description provided for @swaggerSpec.
  ///
  /// In en, this message translates to:
  /// **'Spec'**
  String get swaggerSpec;

  /// No description provided for @swaggerSpecUrl.
  ///
  /// In en, this message translates to:
  /// **'Spec or docs page URL'**
  String get swaggerSpecUrl;

  /// No description provided for @swaggerSpecUrlPh.
  ///
  /// In en, this message translates to:
  /// **'https://staging.example.com/swagger/index.html'**
  String get swaggerSpecUrlPh;

  /// No description provided for @swaggerSpecRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get swaggerSpecRead;

  /// No description provided for @swaggerSpecReading.
  ///
  /// In en, this message translates to:
  /// **'Reading the spec…'**
  String get swaggerSpecReading;

  /// No description provided for @swaggerSpecUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload a file'**
  String get swaggerSpecUpload;

  /// No description provided for @swaggerSpecHint.
  ///
  /// In en, this message translates to:
  /// **'A Swagger UI, Springdoc or Redoc page works too: agnts finds the spec behind it. Swagger 2.0 and OpenAPI 3.x, up to 5 MB.'**
  String get swaggerSpecHint;

  /// No description provided for @swaggerSpecFound.
  ///
  /// In en, this message translates to:
  /// **'{title} {version} · {count, plural, one {{count} endpoint} other {{count} endpoints}} · {format}'**
  String swaggerSpecFound(String title, String version, num count, String format);

  /// No description provided for @swaggerSpecChoose.
  ///
  /// In en, this message translates to:
  /// **'This page offers several specs. Pick one:'**
  String get swaggerSpecChoose;

  /// No description provided for @swaggerBaseUrl.
  ///
  /// In en, this message translates to:
  /// **'Base URL'**
  String get swaggerBaseUrl;

  /// No description provided for @swaggerBaseUrlHint.
  ///
  /// In en, this message translates to:
  /// **'Where requests go. It starts as the spec\'s server, which often is production: check it. A host name or an IP, on any port. Internal hosts need a Private network route.'**
  String get swaggerBaseUrlHint;

  /// No description provided for @swaggerEndpoints.
  ///
  /// In en, this message translates to:
  /// **'Endpoints'**
  String get swaggerEndpoints;

  /// No description provided for @swaggerEndpointsCount.
  ///
  /// In en, this message translates to:
  /// **'{n} of {total} ticked'**
  String swaggerEndpointsCount(String n, String total);

  /// No description provided for @swaggerSearch.
  ///
  /// In en, this message translates to:
  /// **'Search endpoints'**
  String get swaggerSearch;

  /// No description provided for @swaggerAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get swaggerAll;

  /// No description provided for @swaggerNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get swaggerNone;

  /// No description provided for @swaggerUntickedSideEffect.
  ///
  /// In en, this message translates to:
  /// **'Left unticked: its name suggests it changes something ({word})'**
  String swaggerUntickedSideEffect(String word);

  /// No description provided for @swaggerUntickedDeprecated.
  ///
  /// In en, this message translates to:
  /// **'Left unticked: deprecated'**
  String get swaggerUntickedDeprecated;

  /// No description provided for @swaggerAuth.
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get swaggerAuth;

  /// No description provided for @swaggerAuthKind_none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get swaggerAuthKind_none;

  /// No description provided for @swaggerAuthKind_bearer.
  ///
  /// In en, this message translates to:
  /// **'Bearer token'**
  String get swaggerAuthKind_bearer;

  /// No description provided for @swaggerAuthKind_header.
  ///
  /// In en, this message translates to:
  /// **'API key in a header'**
  String get swaggerAuthKind_header;

  /// No description provided for @swaggerAuthKind_query.
  ///
  /// In en, this message translates to:
  /// **'API key in the query'**
  String get swaggerAuthKind_query;

  /// No description provided for @swaggerAuthKind_basic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get swaggerAuthKind_basic;

  /// No description provided for @swaggerAuthName.
  ///
  /// In en, this message translates to:
  /// **'Header or parameter name'**
  String get swaggerAuthName;

  /// No description provided for @swaggerAuthValue.
  ///
  /// In en, this message translates to:
  /// **'Token'**
  String get swaggerAuthValue;

  /// No description provided for @swaggerAuthValueBasic.
  ///
  /// In en, this message translates to:
  /// **'user:password, or the Basic token'**
  String get swaggerAuthValueBasic;

  /// No description provided for @swaggerAuthHint.
  ///
  /// In en, this message translates to:
  /// **'Use a test account\'s token, never a personal or production one. It is sealed, never shown again, and deleted when the ticket closes.'**
  String get swaggerAuthHint;

  /// No description provided for @swaggerAuthFromSpec.
  ///
  /// In en, this message translates to:
  /// **'The spec declares: {schemes}'**
  String swaggerAuthFromSpec(String schemes);

  /// No description provided for @swaggerWrite.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get swaggerWrite;

  /// No description provided for @swaggerWriteOff.
  ///
  /// In en, this message translates to:
  /// **'Read-only'**
  String get swaggerWriteOff;

  /// No description provided for @swaggerWriteOffHint.
  ///
  /// In en, this message translates to:
  /// **'Only GET, HEAD and OPTIONS'**
  String get swaggerWriteOffHint;

  /// No description provided for @swaggerWriteOn.
  ///
  /// In en, this message translates to:
  /// **'Write requests too'**
  String get swaggerWriteOn;

  /// No description provided for @swaggerWriteOnHint.
  ///
  /// In en, this message translates to:
  /// **'Also POST, PUT, PATCH and DELETE'**
  String get swaggerWriteOnHint;

  /// No description provided for @swaggerWriteConfirm.
  ///
  /// In en, this message translates to:
  /// **'I confirm {url} is not production'**
  String swaggerWriteConfirm(String url);

  /// No description provided for @swaggerWriteConfirmNeeded.
  ///
  /// In en, this message translates to:
  /// **'Confirm the base URL is not production to send write requests.'**
  String get swaggerWriteConfirmNeeded;

  /// No description provided for @swaggerReadOnlyNote.
  ///
  /// In en, this message translates to:
  /// **'Read-only means only GET, HEAD and OPTIONS, not harmless: some APIs change things on GET. That is your call.'**
  String get swaggerReadOnlyNote;

  /// No description provided for @swaggerLockoutNote.
  ///
  /// In en, this message translates to:
  /// **'The no-token and wrong-token cases can look like a login attack to a firewall. A test sends at most 3 of them, but it may still lock the test account or get the caller\'s address blocked. Behind a Private network, that address is the workspace\'s VPN connection, which GitLab and other tests also use.'**
  String get swaggerLockoutNote;

  /// No description provided for @swaggerRepository.
  ///
  /// In en, this message translates to:
  /// **'Repository (optional)'**
  String get swaggerRepository;

  /// No description provided for @swaggerRepositoryHint.
  ///
  /// In en, this message translates to:
  /// **'With one, agnts reads the handlers to explain failures, and failures can become a Bug or Code ticket.'**
  String get swaggerRepositoryHint;

  /// No description provided for @swaggerNoRepo.
  ///
  /// In en, this message translates to:
  /// **'No repository'**
  String get swaggerNoRepo;

  /// No description provided for @swaggerNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get swaggerNotes;

  /// No description provided for @swaggerNotesPh.
  ///
  /// In en, this message translates to:
  /// **'For example: user 42 is a test account; orders need an existing product id'**
  String get swaggerNotesPh;

  /// No description provided for @swaggerLimits.
  ///
  /// In en, this message translates to:
  /// **'Limits'**
  String get swaggerLimits;

  /// No description provided for @swaggerRate.
  ///
  /// In en, this message translates to:
  /// **'Requests a second'**
  String get swaggerRate;

  /// No description provided for @swaggerMaxRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests per run'**
  String get swaggerMaxRequests;

  /// No description provided for @swaggerStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get swaggerStart;

  /// No description provided for @swaggerStartNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get swaggerStartNow;

  /// No description provided for @swaggerStartQueue.
  ///
  /// In en, this message translates to:
  /// **'Keep in the queue'**
  String get swaggerStartQueue;

  /// No description provided for @swaggerCreate.
  ///
  /// In en, this message translates to:
  /// **'Create test'**
  String get swaggerCreate;

  /// No description provided for @swaggerCreateStart.
  ///
  /// In en, this message translates to:
  /// **'Create and start'**
  String get swaggerCreateStart;

  /// No description provided for @swaggerCreated.
  ///
  /// In en, this message translates to:
  /// **'{key} created'**
  String swaggerCreated(String key);

  /// No description provided for @swaggerNeedSpec.
  ///
  /// In en, this message translates to:
  /// **'Read a spec first.'**
  String get swaggerNeedSpec;

  /// No description provided for @swaggerNeedToken.
  ///
  /// In en, this message translates to:
  /// **'Enter the token.'**
  String get swaggerNeedToken;

  /// No description provided for @swaggerClaudeOnly.
  ///
  /// In en, this message translates to:
  /// **'Swagger tests always run on Muse\'s light model, whatever model the workspace codes with.'**
  String get swaggerClaudeOnly;

  /// No description provided for @swaggerTab.
  ///
  /// In en, this message translates to:
  /// **'API results'**
  String get swaggerTab;

  /// No description provided for @swaggerRequestsTab.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get swaggerRequestsTab;

  /// No description provided for @swaggerNoRun.
  ///
  /// In en, this message translates to:
  /// **'No results yet: the test is running or has not run.'**
  String get swaggerNoRun;

  /// No description provided for @swaggerVerdict_pass.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get swaggerVerdict_pass;

  /// No description provided for @swaggerVerdict_fail.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get swaggerVerdict_fail;

  /// No description provided for @swaggerVerdict_skipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get swaggerVerdict_skipped;

  /// No description provided for @swaggerVerdict_blocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get swaggerVerdict_blocked;

  /// No description provided for @swaggerCount_pass.
  ///
  /// In en, this message translates to:
  /// **'{n} passed'**
  String swaggerCount_pass(String n);

  /// No description provided for @swaggerCount_fail.
  ///
  /// In en, this message translates to:
  /// **'{n} failed'**
  String swaggerCount_fail(String n);

  /// No description provided for @swaggerCount_skipped.
  ///
  /// In en, this message translates to:
  /// **'{n} skipped'**
  String swaggerCount_skipped(String n);

  /// No description provided for @swaggerCount_blocked.
  ///
  /// In en, this message translates to:
  /// **'{n} blocked'**
  String swaggerCount_blocked(String n);

  /// No description provided for @swaggerColEndpoint.
  ///
  /// In en, this message translates to:
  /// **'Endpoint'**
  String get swaggerColEndpoint;

  /// No description provided for @swaggerColCases.
  ///
  /// In en, this message translates to:
  /// **'Cases'**
  String get swaggerColCases;

  /// No description provided for @swaggerColResult.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get swaggerColResult;

  /// No description provided for @swaggerAgntsCheck.
  ///
  /// In en, this message translates to:
  /// **'agnts check'**
  String get swaggerAgntsCheck;

  /// No description provided for @swaggerAgntsCheckHint.
  ///
  /// In en, this message translates to:
  /// **'agnts checked this response against the spec\'s schema itself'**
  String get swaggerAgntsCheckHint;

  /// No description provided for @swaggerExpected.
  ///
  /// In en, this message translates to:
  /// **'Expected: {text}'**
  String swaggerExpected(String text);

  /// No description provided for @swaggerRequestLabel.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get swaggerRequestLabel;

  /// No description provided for @swaggerResponseLabel.
  ///
  /// In en, this message translates to:
  /// **'Response'**
  String get swaggerResponseLabel;

  /// No description provided for @swaggerNoResponse.
  ///
  /// In en, this message translates to:
  /// **'No response'**
  String get swaggerNoResponse;

  /// No description provided for @swaggerTruncated.
  ///
  /// In en, this message translates to:
  /// **'The body was cut at 64 KB'**
  String get swaggerTruncated;

  /// No description provided for @swaggerCopyCurl.
  ///
  /// In en, this message translates to:
  /// **'Copy as curl'**
  String get swaggerCopyCurl;

  /// No description provided for @swaggerCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get swaggerCopied;

  /// No description provided for @swaggerLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get swaggerLoading;

  /// No description provided for @swaggerCreateBug.
  ///
  /// In en, this message translates to:
  /// **'Create bug ticket'**
  String get swaggerCreateBug;

  /// No description provided for @swaggerBugTitle.
  ///
  /// In en, this message translates to:
  /// **'Fix the API failures {key} found'**
  String swaggerBugTitle(String key);

  /// No description provided for @swaggerBugIntro.
  ///
  /// In en, this message translates to:
  /// **'The Swagger test {key} of {base} found these failures:'**
  String swaggerBugIntro(String key, String base);

  /// No description provided for @swaggerBugCreated.
  ///
  /// In en, this message translates to:
  /// **'{key} created'**
  String swaggerBugCreated(String key);

  /// No description provided for @swaggerNewFailures.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} new failure} other {{n} new failures}} since the last run'**
  String swaggerNewFailures(num n);

  /// No description provided for @swaggerNoNewFailures.
  ///
  /// In en, this message translates to:
  /// **'No new failures since the last run'**
  String get swaggerNoNewFailures;

  /// No description provided for @swaggerPrevious.
  ///
  /// In en, this message translates to:
  /// **'Last run: {passed} passed, {failed} failed'**
  String swaggerPrevious(String passed, String failed);

  /// No description provided for @swaggerRerun.
  ///
  /// In en, this message translates to:
  /// **'Run again'**
  String get swaggerRerun;

  /// No description provided for @swaggerRerunToken.
  ///
  /// In en, this message translates to:
  /// **'New token (optional)'**
  String get swaggerRerunToken;

  /// No description provided for @swaggerRerunTokenNeeded.
  ///
  /// In en, this message translates to:
  /// **'New token (required: the old one was deleted when the ticket closed)'**
  String get swaggerRerunTokenNeeded;

  /// No description provided for @swaggerRerunStarted.
  ///
  /// In en, this message translates to:
  /// **'Started again'**
  String get swaggerRerunStarted;

  /// No description provided for @swaggerRerunNew.
  ///
  /// In en, this message translates to:
  /// **'Started again as {key}'**
  String swaggerRerunNew(String key);

  /// No description provided for @swaggerModeRead.
  ///
  /// In en, this message translates to:
  /// **'read-only'**
  String get swaggerModeRead;

  /// No description provided for @swaggerModeWrite.
  ///
  /// In en, this message translates to:
  /// **'write requests on'**
  String get swaggerModeWrite;

  /// No description provided for @swaggerTokenStored.
  ///
  /// In en, this message translates to:
  /// **'token stored'**
  String get swaggerTokenStored;

  /// No description provided for @swaggerTokenGone.
  ///
  /// In en, this message translates to:
  /// **'no token stored'**
  String get swaggerTokenGone;

  /// No description provided for @swaggerAgntsNotes.
  ///
  /// In en, this message translates to:
  /// **'What agnts adjusted'**
  String get swaggerAgntsNotes;

  /// No description provided for @swaggerAllPassed.
  ///
  /// In en, this message translates to:
  /// **'Every case passed.'**
  String get swaggerAllPassed;

  /// No description provided for @swaggerRunningTitle.
  ///
  /// In en, this message translates to:
  /// **'Testing the API'**
  String get swaggerRunningTitle;

  /// No description provided for @swaggerRunningSub.
  ///
  /// In en, this message translates to:
  /// **'agnts plans the cases and sends real requests to the base URL. Results appear here when the run ends.'**
  String get swaggerRunningSub;

  /// No description provided for @swaggerQueuedTitle.
  ///
  /// In en, this message translates to:
  /// **'Swagger test in the queue'**
  String get swaggerQueuedTitle;

  /// No description provided for @swaggerQueuedSub.
  ///
  /// In en, this message translates to:
  /// **'Start it when you are ready.'**
  String get swaggerQueuedSub;

  /// No description provided for @swaggerSuites.
  ///
  /// In en, this message translates to:
  /// **'Swagger suites'**
  String get swaggerSuites;

  /// No description provided for @swaggerSuitesLede.
  ///
  /// In en, this message translates to:
  /// **'Saved Swagger tests that run again on a schedule or after each deploy. Each run is a new ticket, compared with the suite\'s last run, and reuses its plan, so repeat runs cost fewer turns.'**
  String get swaggerSuitesLede;

  /// No description provided for @swaggerSuitesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No suites yet. Open a finished Swagger test and save it as a suite.'**
  String get swaggerSuitesEmpty;

  /// No description provided for @swaggerSaveSuite.
  ///
  /// In en, this message translates to:
  /// **'Save as suite'**
  String get swaggerSaveSuite;

  /// No description provided for @swaggerSaveSuiteHint.
  ///
  /// In en, this message translates to:
  /// **'Run this test again on a schedule or after each deploy. The suite keeps its own copy of the token.'**
  String get swaggerSaveSuiteHint;

  /// No description provided for @swaggerSuiteName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get swaggerSuiteName;

  /// No description provided for @swaggerSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get swaggerSchedule;

  /// No description provided for @swaggerSchedule_off.
  ///
  /// In en, this message translates to:
  /// **'By hand or deploy hook'**
  String get swaggerSchedule_off;

  /// No description provided for @swaggerSchedule_hourly.
  ///
  /// In en, this message translates to:
  /// **'Every hour'**
  String get swaggerSchedule_hourly;

  /// No description provided for @swaggerSchedule_daily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get swaggerSchedule_daily;

  /// No description provided for @swaggerSchedule_weekly.
  ///
  /// In en, this message translates to:
  /// **'Every Monday'**
  String get swaggerSchedule_weekly;

  /// No description provided for @swaggerHourUtc.
  ///
  /// In en, this message translates to:
  /// **'At (UTC hour)'**
  String get swaggerHourUtc;

  /// No description provided for @swaggerSuiteSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved as the suite {name}'**
  String swaggerSuiteSaved(String name);

  /// No description provided for @swaggerRunNow.
  ///
  /// In en, this message translates to:
  /// **'Run now'**
  String get swaggerRunNow;

  /// No description provided for @swaggerRunStarted.
  ///
  /// In en, this message translates to:
  /// **'{key} started'**
  String swaggerRunStarted(String key);

  /// No description provided for @swaggerBusy.
  ///
  /// In en, this message translates to:
  /// **'The last run is still going'**
  String get swaggerBusy;

  /// No description provided for @swaggerPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get swaggerPause;

  /// No description provided for @swaggerResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get swaggerResume;

  /// No description provided for @swaggerPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get swaggerPaused;

  /// No description provided for @swaggerDeleteSuite.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get swaggerDeleteSuite;

  /// No description provided for @swaggerDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete the suite {name}? Its past runs stay.'**
  String swaggerDeleteConfirm(String name);

  /// No description provided for @swaggerHookCreate.
  ///
  /// In en, this message translates to:
  /// **'Create deploy hook'**
  String get swaggerHookCreate;

  /// No description provided for @swaggerHookRotate.
  ///
  /// In en, this message translates to:
  /// **'New deploy hook'**
  String get swaggerHookRotate;

  /// No description provided for @swaggerHookHint.
  ///
  /// In en, this message translates to:
  /// **'POST this URL from your deploy pipeline, with no body, to run the suite after each deploy. It is shown once; making a new one stops the old.'**
  String get swaggerHookHint;

  /// No description provided for @swaggerHookExample.
  ///
  /// In en, this message translates to:
  /// **'curl -X POST {url}'**
  String swaggerHookExample(String url);

  /// No description provided for @swaggerLastRun.
  ///
  /// In en, this message translates to:
  /// **'Last run'**
  String get swaggerLastRun;

  /// No description provided for @swaggerNextRun.
  ///
  /// In en, this message translates to:
  /// **'Next run'**
  String get swaggerNextRun;

  /// No description provided for @swaggerNever.
  ///
  /// In en, this message translates to:
  /// **'never'**
  String get swaggerNever;

  /// No description provided for @swaggerColSuite.
  ///
  /// In en, this message translates to:
  /// **'Suite'**
  String get swaggerColSuite;

  /// No description provided for @swaggerColSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get swaggerColSchedule;

  /// No description provided for @swaggerColLast.
  ///
  /// In en, this message translates to:
  /// **'Last run'**
  String get swaggerColLast;

  /// No description provided for @swaggerSuiteToken.
  ///
  /// In en, this message translates to:
  /// **'New token (optional)'**
  String get swaggerSuiteToken;

  /// No description provided for @swaggerSetToken.
  ///
  /// In en, this message translates to:
  /// **'Set token'**
  String get swaggerSetToken;

  /// No description provided for @swaggerSpecAuth.
  ///
  /// In en, this message translates to:
  /// **'The spec link needs a sign-in'**
  String get swaggerSpecAuth;

  /// No description provided for @swaggerSpecAuthHint.
  ///
  /// In en, this message translates to:
  /// **'Sent with the spec fetch to the spec\'s host only, and not stored.'**
  String get swaggerSpecAuthHint;

  /// No description provided for @swaggerSpecAuthNeeded.
  ///
  /// In en, this message translates to:
  /// **'The spec URL answered 401/403: give the token it needs, then read it again.'**
  String get swaggerSpecAuthNeeded;

  /// No description provided for @swaggerSpecAuthReused.
  ///
  /// In en, this message translates to:
  /// **'The API requests use this token too. Change it here if they need another.'**
  String get swaggerSpecAuthReused;

  /// No description provided for @swaggerSpecAuthLogin.
  ///
  /// In en, this message translates to:
  /// **'Login and password'**
  String get swaggerSpecAuthLogin;

  /// No description provided for @swaggerSpecAuthToken.
  ///
  /// In en, this message translates to:
  /// **'Token'**
  String get swaggerSpecAuthToken;

  /// No description provided for @swaggerSpecLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get swaggerSpecLogin;

  /// No description provided for @swaggerSpecPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get swaggerSpecPassword;

  /// No description provided for @swaggerSpecLoginNeeded.
  ///
  /// In en, this message translates to:
  /// **'The spec link asks for a login and password: enter them, then read it again.'**
  String get swaggerSpecLoginNeeded;

  /// No description provided for @swaggerSpecLoginHint.
  ///
  /// In en, this message translates to:
  /// **'Opens the spec link only, and is not stored. The agent\'s API requests use the token under Authentication below.'**
  String get swaggerSpecLoginHint;

  /// No description provided for @swaggerFilterProblems.
  ///
  /// In en, this message translates to:
  /// **'Failures and blocked'**
  String get swaggerFilterProblems;

  /// No description provided for @swaggerFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All cases'**
  String get swaggerFilterAll;

  /// No description provided for @swaggerNothingToShow.
  ///
  /// In en, this message translates to:
  /// **'Nothing failed or was blocked. Show all cases to see the rest.'**
  String get swaggerNothingToShow;

  /// No description provided for @swaggerCasesHidden.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} endpoint} other {{n} endpoints}} without failures hidden'**
  String swaggerCasesHidden(num n);

  /// No description provided for @swaggerWhatToTest.
  ///
  /// In en, this message translates to:
  /// **'What to test'**
  String get swaggerWhatToTest;

  /// No description provided for @swaggerWhatToTestPh.
  ///
  /// In en, this message translates to:
  /// **'For example: only the POST endpoints under /v1/orders and /v1/payments; check validation errors and unknown ids. User 42 is a test account.'**
  String get swaggerWhatToTestPh;

  /// No description provided for @swaggerWhatToTestHint.
  ///
  /// In en, this message translates to:
  /// **'agnts tests only what you write here. To test exact endpoints instead, tick them below.'**
  String get swaggerWhatToTestHint;

  /// No description provided for @swaggerWhatToTestNeeded.
  ///
  /// In en, this message translates to:
  /// **'Write what to test, or tick the endpoints to test.'**
  String get swaggerWhatToTestNeeded;

  /// No description provided for @swaggerEndpointsOptional.
  ///
  /// In en, this message translates to:
  /// **'Pick endpoints (optional)'**
  String get swaggerEndpointsOptional;

  /// No description provided for @swaggerEndpointsOptionalHint.
  ///
  /// In en, this message translates to:
  /// **'Ticked endpoints are tested exactly as ticked. With none ticked, the text above decides what is tested.'**
  String get swaggerEndpointsOptionalHint;

  /// No description provided for @swaggerSuggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get swaggerSuggested;

  /// No description provided for @swaggerNoneTicked.
  ///
  /// In en, this message translates to:
  /// **'none ticked: the text above decides'**
  String get swaggerNoneTicked;

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

  /// No description provided for @tasksTicketNumber.
  ///
  /// In en, this message translates to:
  /// **'Ticket number'**
  String get tasksTicketNumber;

  /// No description provided for @tasksTicketNumberPh.
  ///
  /// In en, this message translates to:
  /// **'For example: AMANAT-2288'**
  String get tasksTicketNumberPh;

  /// No description provided for @tasksTicketNumberHelp.
  ///
  /// In en, this message translates to:
  /// **'Optional. Your team\'s number for this work, used in branch and commit names in place of the task key.'**
  String get tasksTicketNumberHelp;

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

  /// No description provided for @ticketUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Changed in {source} after agnts started'**
  String ticketUpdateTitle(String source);

  /// No description provided for @ticketUpdateSub.
  ///
  /// In en, this message translates to:
  /// **'agnts keeps working on the version it started with. Restart to drop the work so far and start over from the new version, or keep going with the current one.'**
  String get ticketUpdateSub;

  /// No description provided for @ticketUpdateNow.
  ///
  /// In en, this message translates to:
  /// **'New version, {when}'**
  String ticketUpdateNow(String when);

  /// No description provided for @ticketUpdateRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart with the new version'**
  String get ticketUpdateRestart;

  /// No description provided for @ticketUpdateKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep the current version'**
  String get ticketUpdateKeep;

  /// No description provided for @ticketUpdateRestartConfirm.
  ///
  /// In en, this message translates to:
  /// **'Restart {key} with the new version from {source}? The analysis, answers, commits and reviews so far are dropped, and agnts starts over.'**
  String ticketUpdateRestartConfirm(String key, String source);

  /// No description provided for @ticketUpdatePushed.
  ///
  /// In en, this message translates to:
  /// **'Pushed already: it cannot restart. Reject it and let agnts take the issue again, or keep the current version.'**
  String get ticketUpdatePushed;

  /// No description provided for @ticketUpdateRestarted.
  ///
  /// In en, this message translates to:
  /// **'{key} restarts with the new version'**
  String ticketUpdateRestarted(String key);

  /// No description provided for @ticketUpdateKept.
  ///
  /// In en, this message translates to:
  /// **'agnts keeps working on the current version'**
  String get ticketUpdateKept;

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
  /// **'Stop all work on {key}? You can continue it later.'**
  String ticketRejectConfirm(String key);

  /// No description provided for @ticketRejectPushingConfirm.
  ///
  /// In en, this message translates to:
  /// **'Stop pushing {key}? What already reached the git host stays there. You can continue it later.'**
  String ticketRejectPushingConfirm(String key);

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

  /// No description provided for @ticketDraftSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving draft…'**
  String get ticketDraftSaving;

  /// No description provided for @ticketDraftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved'**
  String get ticketDraftSaved;

  /// No description provided for @ticketDraftFailed.
  ///
  /// In en, this message translates to:
  /// **'Draft not saved, will try again'**
  String get ticketDraftFailed;

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

  /// No description provided for @ticketChecksSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped for this ticket'**
  String get ticketChecksSkipped;

  /// No description provided for @ticketSkipChecks.
  ///
  /// In en, this message translates to:
  /// **'Skip checks: go to review on the code alone'**
  String get ticketSkipChecks;

  /// No description provided for @ticketSkipChecksHint.
  ///
  /// In en, this message translates to:
  /// **'For checks the run container can\'t run, such as a private dependency it can\'t fetch. Muse won\'t run the build, lint or tests either, so you review the code yourself. It stays on for this ticket until you untick it.'**
  String get ticketSkipChecksHint;

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

  /// No description provided for @ticketDiffReposLabel.
  ///
  /// In en, this message translates to:
  /// **'Changes by repository'**
  String get ticketDiffReposLabel;

  /// No description provided for @ticketDiffOtherRepo.
  ///
  /// In en, this message translates to:
  /// **'Other files'**
  String get ticketDiffOtherRepo;

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

  /// No description provided for @ticketRejectedSubContinue.
  ///
  /// In en, this message translates to:
  /// **'agnts stopped working on this ticket. You can pick it up again where it stopped.'**
  String get ticketRejectedSubContinue;

  /// No description provided for @ticketContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get ticketContinue;

  /// No description provided for @ticketContinueNote.
  ///
  /// In en, this message translates to:
  /// **'Note for agnts'**
  String get ticketContinueNote;

  /// No description provided for @ticketContinueNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Optional. What to do differently; the next coding run gets it, like requested changes.'**
  String get ticketContinueNoteHint;

  /// No description provided for @ticketContinueToNew.
  ///
  /// In en, this message translates to:
  /// **'It goes back to the queue and is analysed again.'**
  String get ticketContinueToNew;

  /// No description provided for @ticketContinueToAnswers.
  ///
  /// In en, this message translates to:
  /// **'It goes back to its questions; answers given so far are kept.'**
  String get ticketContinueToAnswers;

  /// No description provided for @ticketContinueToCoding.
  ///
  /// In en, this message translates to:
  /// **'agnts goes on writing the code where it stopped.'**
  String get ticketContinueToCoding;

  /// No description provided for @ticketContinueToReview.
  ///
  /// In en, this message translates to:
  /// **'It goes back to review. With a note, agnts makes those changes first.'**
  String get ticketContinueToReview;

  /// No description provided for @ticketContinueToFailed.
  ///
  /// In en, this message translates to:
  /// **'It goes back to the error it stopped with, so you can retry it.'**
  String get ticketContinueToFailed;

  /// No description provided for @ticketContinueToRateLimited.
  ///
  /// In en, this message translates to:
  /// **'It goes back to waiting for the plan limit.'**
  String get ticketContinueToRateLimited;

  /// No description provided for @ticketStartOver.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get ticketStartOver;

  /// No description provided for @ticketStartOverConfirm.
  ///
  /// In en, this message translates to:
  /// **'Start {key} over? The analysis, answers and commits are dropped and agnts analyses it again.'**
  String ticketStartOverConfirm(String key);

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

  /// No description provided for @ticketRetryNote.
  ///
  /// In en, this message translates to:
  /// **'Note for the retry'**
  String get ticketRetryNote;

  /// No description provided for @ticketRetryNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Optional. Tell agnts how to get past the error; the next coding run gets it with the error.'**
  String get ticketRetryNoteHint;

  /// No description provided for @ticketSavedWork.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {The stopped run left {count} changed file unfinished.} other {The stopped run left {count} changed files unfinished.}} The next run picks it up where it stopped.'**
  String ticketSavedWork(num count);

  /// No description provided for @ticketSavedWorkFiles.
  ///
  /// In en, this message translates to:
  /// **'Show files'**
  String get ticketSavedWorkFiles;

  /// No description provided for @ticketDiscardWork.
  ///
  /// In en, this message translates to:
  /// **'Discard the unfinished change'**
  String get ticketDiscardWork;

  /// No description provided for @ticketDiscardWorkHint.
  ///
  /// In en, this message translates to:
  /// **'The next run starts from the last commit instead. Use it when the stopped run was going the wrong way.'**
  String get ticketDiscardWorkHint;

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

  /// No description provided for @ticketBranchRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get ticketBranchRename;

  /// No description provided for @ticketBranchRenameHint.
  ///
  /// In en, this message translates to:
  /// **'The pull request opens from this name. Letters, digits, - _ . and /; no spaces.'**
  String get ticketBranchRenameHint;

  /// No description provided for @ticketNumberEdit.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get ticketNumberEdit;

  /// No description provided for @ticketNumberSet.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get ticketNumberSet;

  /// No description provided for @ticketNumberHint.
  ///
  /// In en, this message translates to:
  /// **'New branches and commits use it. Existing ones keep their names: rename the branch or re-apply the commit format. Empty uses the key.'**
  String get ticketNumberHint;

  /// No description provided for @ticketCommitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Commits'**
  String get ticketCommitsTitle;

  /// No description provided for @ticketCommitsSub.
  ///
  /// In en, this message translates to:
  /// **'agnts pushes these when you approve. Until then you can change their messages.'**
  String get ticketCommitsSub;

  /// No description provided for @ticketCommitEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit message'**
  String get ticketCommitEdit;

  /// No description provided for @ticketCommitEditHint.
  ///
  /// In en, this message translates to:
  /// **'The subject on the first line, then a blank line and the body. Changing an earlier commit makes the ones after it again with the same changes.'**
  String get ticketCommitEditHint;

  /// No description provided for @ticketCommitsReapply.
  ///
  /// In en, this message translates to:
  /// **'Re-apply format'**
  String get ticketCommitsReapply;

  /// No description provided for @ticketCommitsReapplyHelp.
  ///
  /// In en, this message translates to:
  /// **'Writes these messages again from the commit message format (the group\'s, else each repository\'s), with the type, scope and subject of the run that made each commit. Check the preview, then apply.'**
  String get ticketCommitsReapplyHelp;

  /// No description provided for @ticketCommitsNumber.
  ///
  /// In en, this message translates to:
  /// **'Ticket number for {number}'**
  String ticketCommitsNumber(String number);

  /// No description provided for @ticketCommitsPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get ticketCommitsPreview;

  /// No description provided for @ticketCommitsApply.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {Apply {n} change} other {Apply {n} changes}}'**
  String ticketCommitsApply(num n);

  /// No description provided for @ticketCommitsUpToDate.
  ///
  /// In en, this message translates to:
  /// **'The messages already match the format.'**
  String get ticketCommitsUpToDate;

  /// No description provided for @ticketCommitsNotSuggested.
  ///
  /// In en, this message translates to:
  /// **'Not ticked: this message may have been written by hand, and applying would replace it.'**
  String get ticketCommitsNotSuggested;

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
  /// **'Saving the approved report and posting it to the issue tracker if you asked.'**
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

  /// No description provided for @ticketFactsTicket.
  ///
  /// In en, this message translates to:
  /// **'Ticket'**
  String get ticketFactsTicket;

  /// No description provided for @ticketFactsCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get ticketFactsCode;

  /// No description provided for @ticketFactsPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get ticketFactsPeople;

  /// No description provided for @ticketFactsLinks.
  ///
  /// In en, this message translates to:
  /// **'Linked tickets'**
  String get ticketFactsLinks;

  /// No description provided for @ticketFactsRuns.
  ///
  /// In en, this message translates to:
  /// **'Runs'**
  String get ticketFactsRuns;

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

  /// No description provided for @ticketSrcPlane.
  ///
  /// In en, this message translates to:
  /// **'Plane'**
  String get ticketSrcPlane;

  /// No description provided for @ticketReviewSubPlane.
  ///
  /// In en, this message translates to:
  /// **'Nothing has left the server yet. Approving pushes {branch}, opens a pull request and updates the Plane work item.'**
  String ticketReviewSubPlane(String branch);

  /// No description provided for @ticketReviewReportSubPlane.
  ///
  /// In en, this message translates to:
  /// **'Approving keeps the report here and closes the ticket. It goes to Plane only if you tick the box below.'**
  String get ticketReviewReportSubPlane;

  /// No description provided for @ticketPostReportPlane.
  ///
  /// In en, this message translates to:
  /// **'Also post the report as a comment on {key} in Plane'**
  String ticketPostReportPlane(String key);

  /// No description provided for @ticketApproveReportPostConfirmPlane.
  ///
  /// In en, this message translates to:
  /// **'Approve the report, close this ticket and post the report to {key} in Plane?'**
  String ticketApproveReportPostConfirmPlane(String key);

  /// No description provided for @ticketDoneReportPostedPlane.
  ///
  /// In en, this message translates to:
  /// **'The report is kept here and was posted to {key} in Plane.'**
  String ticketDoneReportPostedPlane(String key);

  /// No description provided for @ticketPickAny.
  ///
  /// In en, this message translates to:
  /// **'Pick all that apply'**
  String get ticketPickAny;

  /// No description provided for @ticketCopyQuestions.
  ///
  /// In en, this message translates to:
  /// **'Copy questions'**
  String get ticketCopyQuestions;

  /// No description provided for @ticketOtherAnswer.
  ///
  /// In en, this message translates to:
  /// **'Something else (optional)'**
  String get ticketOtherAnswer;

  /// No description provided for @ticketSrcGit.
  ///
  /// In en, this message translates to:
  /// **'Pull request'**
  String get ticketSrcGit;

  /// No description provided for @ticketSrcCi.
  ///
  /// In en, this message translates to:
  /// **'CI failure'**
  String get ticketSrcCi;

  /// No description provided for @ticketKvCi.
  ///
  /// In en, this message translates to:
  /// **'CI'**
  String get ticketKvCi;

  /// No description provided for @ticketCiFixes.
  ///
  /// In en, this message translates to:
  /// **'CI sent the pull request back {n, plural, one {{n} time} other {{n} times}}'**
  String ticketCiFixes(num n);

  /// No description provided for @ticketMuseMeter.
  ///
  /// In en, this message translates to:
  /// **'Muse spend for this run'**
  String get ticketMuseMeter;

  /// No description provided for @ticketMuseSpentOf.
  ///
  /// In en, this message translates to:
  /// **'{spent} of {limit}'**
  String ticketMuseSpentOf(String spent, String limit);

  /// No description provided for @ticketMuseCalls.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} call} other {{n} calls}}'**
  String ticketMuseCalls(num n);

  /// No description provided for @ticketMuseCharged.
  ///
  /// In en, this message translates to:
  /// **'charged {amount}'**
  String ticketMuseCharged(String amount);

  /// No description provided for @ticketMuseSteered.
  ///
  /// In en, this message translates to:
  /// **'Budget low: told to wrap up'**
  String get ticketMuseSteered;

  /// No description provided for @ticketMuseStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped over budget'**
  String get ticketMuseStopped;

  /// No description provided for @ticketMuseEscalated.
  ///
  /// In en, this message translates to:
  /// **'Moved to {model}'**
  String ticketMuseEscalated(String model);

  /// No description provided for @ticketsTabsLabel.
  ///
  /// In en, this message translates to:
  /// **'Ticket lists'**
  String get ticketsTabsLabel;

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

  /// No description provided for @ticketsRepoLabel.
  ///
  /// In en, this message translates to:
  /// **'Repository'**
  String get ticketsRepoLabel;

  /// No description provided for @ticketsAllRepos.
  ///
  /// In en, this message translates to:
  /// **'All repositories'**
  String get ticketsAllRepos;

  /// No description provided for @ticketsNoRepo.
  ///
  /// In en, this message translates to:
  /// **'No repository'**
  String get ticketsNoRepo;

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
  /// **'Jira and Plane tickets with the agnts label, plus tasks you create for side projects.'**
  String get ticketsListSub;

  /// No description provided for @ticketsNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No tickets match your filters.'**
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

  /// No description provided for @ticketsSourcePlane.
  ///
  /// In en, this message translates to:
  /// **'Plane'**
  String get ticketsSourcePlane;

  /// No description provided for @ticketsSourceGit.
  ///
  /// In en, this message translates to:
  /// **'PR'**
  String get ticketsSourceGit;

  /// No description provided for @ticketsSourceCi.
  ///
  /// In en, this message translates to:
  /// **'CI'**
  String get ticketsSourceCi;

  /// No description provided for @usageTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan usage'**
  String get usageTitle;

  /// No description provided for @usageLede.
  ///
  /// In en, this message translates to:
  /// **'agnts runs on your Muse plan. These limits are shared with your own Muse use.'**
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
  /// **'Read from Muse\'s rate limit events. Includes your own Muse use on this account.'**
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
  /// **'Numbers come from the rate limit events Muse emits during each run. When agnts is idle, a tiny refresh run keeps them current.'**
  String get usageHelp;

  /// No description provided for @usageCardFor.
  ///
  /// In en, this message translates to:
  /// **'{name} plan usage'**
  String usageCardFor(String name);

  /// No description provided for @usageNotConnected.
  ///
  /// In en, this message translates to:
  /// **'No {name} account is connected for you, so there is nothing to read. Connect one on your Profile (or the workspace\'s in Workspace settings).'**
  String usageNotConnected(String name);

  /// No description provided for @usageMuseSource.
  ///
  /// In en, this message translates to:
  /// **'Read from the allowance Muse reports after every run (a Meta subscription\'s 5-hour and weekly windows). API keys and credits have no windows.'**
  String get usageMuseSource;

  /// No description provided for @usageCodexSub.
  ///
  /// In en, this message translates to:
  /// **'OpenAI API key'**
  String get usageCodexSub;

  /// No description provided for @usageCodexBody.
  ///
  /// In en, this message translates to:
  /// **'Codex runs on the workspace\'s OpenAI API key and OpenAI bills each call, so there are no plan windows to watch. What its runs cost is in Tickets by spend below.'**
  String get usageCodexBody;

  /// No description provided for @wsTitle.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get wsTitle;

  /// No description provided for @wsSwitcher.
  ///
  /// In en, this message translates to:
  /// **'Switch workspace'**
  String get wsSwitcher;

  /// No description provided for @wsAll.
  ///
  /// In en, this message translates to:
  /// **'All workspaces'**
  String get wsAll;

  /// No description provided for @wsNew.
  ///
  /// In en, this message translates to:
  /// **'New workspace'**
  String get wsNew;

  /// No description provided for @wsRole_owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get wsRole_owner;

  /// No description provided for @wsRole_user.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get wsRole_user;

  /// No description provided for @wsTabGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get wsTabGeneral;

  /// No description provided for @wsTabMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get wsTabMembers;

  /// No description provided for @wsTabClaude.
  ///
  /// In en, this message translates to:
  /// **'Claude'**
  String get wsTabClaude;

  /// No description provided for @wsTabBilling.
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get wsTabBilling;

  /// No description provided for @wsGeneral.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get wsGeneral;

  /// No description provided for @wsGeneralSub.
  ///
  /// In en, this message translates to:
  /// **'Its name and the address in links.'**
  String get wsGeneralSub;

  /// No description provided for @wsName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get wsName;

  /// No description provided for @wsSlug.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get wsSlug;

  /// No description provided for @wsSlugHelp.
  ///
  /// In en, this message translates to:
  /// **'Links to this workspace: /w/{slug}. Old links stop working when it changes.'**
  String wsSlugHelp(String slug);

  /// No description provided for @wsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get wsSave;

  /// No description provided for @wsSaved.
  ///
  /// In en, this message translates to:
  /// **'Workspace saved'**
  String get wsSaved;

  /// No description provided for @wsReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Only the owner can change this.'**
  String get wsReadOnly;

  /// No description provided for @wsPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get wsPlan;

  /// No description provided for @wsSlots.
  ///
  /// In en, this message translates to:
  /// **'Parallel runs'**
  String get wsSlots;

  /// No description provided for @wsSlotsHelp.
  ///
  /// In en, this message translates to:
  /// **'How many runs this workspace may have at once. Change it in Billing.'**
  String get wsSlotsHelp;

  /// No description provided for @wsTrialEnds.
  ///
  /// In en, this message translates to:
  /// **'Trial until {date}'**
  String wsTrialEnds(String date);

  /// No description provided for @wsSuspended.
  ///
  /// In en, this message translates to:
  /// **'This workspace is suspended: nothing new starts until it is resumed.'**
  String get wsSuspended;

  /// No description provided for @wsDanger.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get wsDanger;

  /// No description provided for @wsDangerSub.
  ///
  /// In en, this message translates to:
  /// **'Deleting stops every run and removes the workspace, its repositories\' copies, tickets and history. It is kept 7 days for undo, then purged.'**
  String get wsDangerSub;

  /// No description provided for @wsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete workspace'**
  String get wsDelete;

  /// No description provided for @wsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String wsDeleteTitle(String name);

  /// No description provided for @wsDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Type the address ({slug}) to confirm. Everyone loses access.'**
  String wsDeleteBody(String slug);

  /// No description provided for @wsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Workspace deleted'**
  String get wsDeleted;

  /// No description provided for @wsMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get wsMembers;

  /// No description provided for @wsMembersSub.
  ///
  /// In en, this message translates to:
  /// **'Everyone in the workspace sees its tickets and can create, answer, review and retry them. The owner also manages settings, integrations, Muse, members and billing.'**
  String get wsMembersSub;

  /// No description provided for @wsYou.
  ///
  /// In en, this message translates to:
  /// **'you'**
  String get wsYou;

  /// No description provided for @wsRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get wsRemove;

  /// No description provided for @wsRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String wsRemoveTitle(String name);

  /// No description provided for @wsRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'They lose access to this workspace. Their tickets stay.'**
  String get wsRemoveBody;

  /// No description provided for @wsRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} removed'**
  String wsRemoved(String name);

  /// No description provided for @wsMakeOwner.
  ///
  /// In en, this message translates to:
  /// **'Make owner'**
  String get wsMakeOwner;

  /// No description provided for @wsTransferTitle.
  ///
  /// In en, this message translates to:
  /// **'Make {name} the owner?'**
  String wsTransferTitle(String name);

  /// No description provided for @wsTransferBody.
  ///
  /// In en, this message translates to:
  /// **'You stay a member but can no longer change settings, members or billing.'**
  String get wsTransferBody;

  /// No description provided for @wsTransferred.
  ///
  /// In en, this message translates to:
  /// **'{name} is the owner now'**
  String wsTransferred(String name);

  /// No description provided for @wsLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave workspace'**
  String get wsLeave;

  /// No description provided for @wsLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave {name}?'**
  String wsLeaveTitle(String name);

  /// No description provided for @wsLeaveBody.
  ///
  /// In en, this message translates to:
  /// **'You lose access until someone invites you again.'**
  String get wsLeaveBody;

  /// No description provided for @wsOwnerCannotLeave.
  ///
  /// In en, this message translates to:
  /// **'The owner cannot leave: make someone else the owner first.'**
  String get wsOwnerCannotLeave;

  /// No description provided for @wsClaudeBadge.
  ///
  /// In en, this message translates to:
  /// **'Claude connected'**
  String get wsClaudeBadge;

  /// No description provided for @wsNoClaudeBadge.
  ///
  /// In en, this message translates to:
  /// **'No Claude'**
  String get wsNoClaudeBadge;

  /// No description provided for @wsInvite.
  ///
  /// In en, this message translates to:
  /// **'Invite people'**
  String get wsInvite;

  /// No description provided for @wsInviteSub.
  ///
  /// In en, this message translates to:
  /// **'Send a link by email, or make a link to share yourself. Links work for 7 days and once.'**
  String get wsInviteSub;

  /// No description provided for @wsInviteEmail.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get wsInviteEmail;

  /// No description provided for @wsInviteSend.
  ///
  /// In en, this message translates to:
  /// **'Create invite'**
  String get wsInviteSend;

  /// No description provided for @wsInviteLink.
  ///
  /// In en, this message translates to:
  /// **'Invite link (shown once)'**
  String get wsInviteLink;

  /// No description provided for @wsInviteEmailed.
  ///
  /// In en, this message translates to:
  /// **'Sent to {email}'**
  String wsInviteEmailed(String email);

  /// No description provided for @wsInviteCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get wsInviteCopy;

  /// No description provided for @wsInvites.
  ///
  /// In en, this message translates to:
  /// **'Open invites'**
  String get wsInvites;

  /// No description provided for @wsInviteAnyone.
  ///
  /// In en, this message translates to:
  /// **'Anyone with the link'**
  String get wsInviteAnyone;

  /// No description provided for @wsInviteExpires.
  ///
  /// In en, this message translates to:
  /// **'expires {date}'**
  String wsInviteExpires(String date);

  /// No description provided for @wsRevoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get wsRevoke;

  /// No description provided for @wsRevoked.
  ///
  /// In en, this message translates to:
  /// **'Invite revoked'**
  String get wsRevoked;

  /// No description provided for @wsMemberLimit.
  ///
  /// In en, this message translates to:
  /// **'{n} of {limit} members'**
  String wsMemberLimit(String n, String limit);

  /// No description provided for @wsMemberLimitNone.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} member} other {{n} members}}'**
  String wsMemberLimitNone(num n);

  /// No description provided for @wsClaude.
  ///
  /// In en, this message translates to:
  /// **'Claude'**
  String get wsClaude;

  /// No description provided for @wsClaudeSub.
  ///
  /// In en, this message translates to:
  /// **'Which Claude account this workspace\'s runs use.'**
  String get wsClaudeSub;

  /// No description provided for @wsMode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get wsMode;

  /// No description provided for @wsModeShared.
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get wsModeShared;

  /// No description provided for @wsModeSharedHelp.
  ///
  /// In en, this message translates to:
  /// **'Every run uses the workspace\'s account, set here by the owner.'**
  String get wsModeSharedHelp;

  /// No description provided for @wsModeMember.
  ///
  /// In en, this message translates to:
  /// **'Per member'**
  String get wsModeMember;

  /// No description provided for @wsModeMemberHelp.
  ///
  /// In en, this message translates to:
  /// **'Each run uses the account of the ticket\'s member. Members connect theirs in their profile.'**
  String get wsModeMemberHelp;

  /// No description provided for @wsConnection.
  ///
  /// In en, this message translates to:
  /// **'Workspace account'**
  String get wsConnection;

  /// No description provided for @wsConnectionSub.
  ///
  /// In en, this message translates to:
  /// **'Used by every run in shared mode.'**
  String get wsConnectionSub;

  /// No description provided for @wsKind.
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get wsKind;

  /// No description provided for @wsKindSubscription.
  ///
  /// In en, this message translates to:
  /// **'Claude subscription'**
  String get wsKindSubscription;

  /// No description provided for @wsKindApiKey.
  ///
  /// In en, this message translates to:
  /// **'Anthropic API key'**
  String get wsKindApiKey;

  /// No description provided for @wsKindSubscriptionHelp.
  ///
  /// In en, this message translates to:
  /// **'Run `claude setup-token` where you are signed in to your Claude plan, and paste the token.'**
  String get wsKindSubscriptionHelp;

  /// No description provided for @wsKindApiKeyHelp.
  ///
  /// In en, this message translates to:
  /// **'Create a key in the Anthropic Console (sk-ant-api…). Usage is billed by Anthropic to its owner.'**
  String get wsKindApiKeyHelp;

  /// No description provided for @wsKeyStep1.
  ///
  /// In en, this message translates to:
  /// **'Sign in to the Claude Console (button below) and open Settings → API keys.'**
  String get wsKeyStep1;

  /// No description provided for @wsKeyStep2.
  ///
  /// In en, this message translates to:
  /// **'Click Create Key, name it (for example agnts) and pick the Console workspace it bills to.'**
  String get wsKeyStep2;

  /// No description provided for @wsKeyStep3.
  ///
  /// In en, this message translates to:
  /// **'Copy the key (it starts with sk-ant-api) and paste it below. The Console shows it only once.'**
  String get wsKeyStep3;

  /// No description provided for @wsKeyStep4.
  ///
  /// In en, this message translates to:
  /// **'Runs are billed per token to that Console account: add credits and set a spend limit under Billing.'**
  String get wsKeyStep4;

  /// No description provided for @wsKeyOpen.
  ///
  /// In en, this message translates to:
  /// **'Open the Claude Console'**
  String get wsKeyOpen;

  /// No description provided for @wsSubscriptionsOff.
  ///
  /// In en, this message translates to:
  /// **'This server takes Anthropic API keys only.'**
  String get wsSubscriptionsOff;

  /// No description provided for @wsToken.
  ///
  /// In en, this message translates to:
  /// **'Token'**
  String get wsToken;

  /// No description provided for @wsConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get wsConnect;

  /// No description provided for @wsReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get wsReplace;

  /// No description provided for @wsDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get wsDisconnect;

  /// No description provided for @wsConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get wsConnected;

  /// No description provided for @wsNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get wsNotConnected;

  /// No description provided for @wsPausedUntil.
  ///
  /// In en, this message translates to:
  /// **'At its limit until {time}'**
  String wsPausedUntil(String time);

  /// No description provided for @wsConnectedAs.
  ///
  /// In en, this message translates to:
  /// **'{account} · …{hint}'**
  String wsConnectedAs(String account, String hint);

  /// No description provided for @wsFallback.
  ///
  /// In en, this message translates to:
  /// **'Continue on credits'**
  String get wsFallback;

  /// No description provided for @wsFallbackHelp.
  ///
  /// In en, this message translates to:
  /// **'When the chosen account is at its limit or missing, runs continue on agnts\'s API key and spend the workspace\'s credits instead of pausing.'**
  String get wsFallbackHelp;

  /// No description provided for @wsFallbackOff.
  ///
  /// In en, this message translates to:
  /// **'Credits are not available on this server.'**
  String get wsFallbackOff;

  /// No description provided for @wsCredits.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} credit} other {{n} credits}}'**
  String wsCredits(num n);

  /// No description provided for @wsDefaultMember.
  ///
  /// In en, this message translates to:
  /// **'Tickets without a person'**
  String get wsDefaultMember;

  /// No description provided for @wsDefaultMemberHelp.
  ///
  /// In en, this message translates to:
  /// **'Tickets from Jira, Plane, follow-ups and incidents run on this member\'s account in per-member mode.'**
  String get wsDefaultMemberHelp;

  /// No description provided for @wsDefaultOwner.
  ///
  /// In en, this message translates to:
  /// **'The owner'**
  String get wsDefaultOwner;

  /// No description provided for @wsMemberAccounts.
  ///
  /// In en, this message translates to:
  /// **'Members\' accounts'**
  String get wsMemberAccounts;

  /// No description provided for @wsMemberAccountsSub.
  ///
  /// In en, this message translates to:
  /// **'Who has connected their own Claude account (Profile → Claude).'**
  String get wsMemberAccountsSub;

  /// No description provided for @wsYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Connect yours in your profile'**
  String get wsYourAccount;

  /// No description provided for @wsClaudeSaved.
  ///
  /// In en, this message translates to:
  /// **'Claude settings saved'**
  String get wsClaudeSaved;

  /// No description provided for @wsRole_viewer.
  ///
  /// In en, this message translates to:
  /// **'Viewer'**
  String get wsRole_viewer;

  /// No description provided for @wsViewerBanner.
  ///
  /// In en, this message translates to:
  /// **'You are a viewer here: you can see everything, but you cannot change anything.'**
  String get wsViewerBanner;

  /// No description provided for @wsInviteAs.
  ///
  /// In en, this message translates to:
  /// **'Joins as'**
  String get wsInviteAs;

  /// No description provided for @wsInviteAsHelp.
  ///
  /// In en, this message translates to:
  /// **'Members work on tickets; viewers only look.'**
  String get wsInviteAsHelp;

  /// No description provided for @wsRoleChanged.
  ///
  /// In en, this message translates to:
  /// **'{name} is now {role}'**
  String wsRoleChanged(String name, String role);

  /// No description provided for @wsRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role of {name}'**
  String wsRoleLabel(String name);

  /// No description provided for @wsTabMuse.
  ///
  /// In en, this message translates to:
  /// **'Muse'**
  String get wsTabMuse;

  /// No description provided for @wsClaudeMuse.
  ///
  /// In en, this message translates to:
  /// **'Muse'**
  String get wsClaudeMuse;

  /// No description provided for @wsClaudeSubMuse.
  ///
  /// In en, this message translates to:
  /// **'Which Muse account this workspace\'s runs use.'**
  String get wsClaudeSubMuse;

  /// No description provided for @wsClaudeSavedMuse.
  ///
  /// In en, this message translates to:
  /// **'Muse settings saved'**
  String get wsClaudeSavedMuse;

  /// No description provided for @wsFallbackHelpMuse.
  ///
  /// In en, this message translates to:
  /// **'When the chosen account is missing or out of budget, runs continue on agnts\'s Muse key and spend your free credits, then the workspace\'s credits, instead of pausing.'**
  String get wsFallbackHelpMuse;

  /// No description provided for @wsMemberAccountsSubMuse.
  ///
  /// In en, this message translates to:
  /// **'Who has connected their own Muse account (Profile → Muse).'**
  String get wsMemberAccountsSubMuse;

  /// No description provided for @wsMuseBadge.
  ///
  /// In en, this message translates to:
  /// **'Muse connected'**
  String get wsMuseBadge;

  /// No description provided for @wsNoMuseBadge.
  ///
  /// In en, this message translates to:
  /// **'No Muse'**
  String get wsNoMuseBadge;

  /// No description provided for @wsKindMuseLogin.
  ///
  /// In en, this message translates to:
  /// **'Meta account'**
  String get wsKindMuseLogin;

  /// No description provided for @wsKindMuseApiKey.
  ///
  /// In en, this message translates to:
  /// **'Muse API key'**
  String get wsKindMuseApiKey;

  /// No description provided for @wsMuseSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Meta'**
  String get wsMuseSignIn;

  /// No description provided for @wsMuseSignInHelp.
  ///
  /// In en, this message translates to:
  /// **'Shows a code to confirm on Meta\'s page; runs then use that Meta account\'s Muse.'**
  String get wsMuseSignInHelp;

  /// No description provided for @wsMuseCode.
  ///
  /// In en, this message translates to:
  /// **'Enter this code on Meta\'s page'**
  String get wsMuseCode;

  /// No description provided for @wsMuseCopyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get wsMuseCopyCode;

  /// No description provided for @wsMuseOpenMeta.
  ///
  /// In en, this message translates to:
  /// **'Open Meta'**
  String get wsMuseOpenMeta;

  /// No description provided for @wsMuseWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for you to approve…'**
  String get wsMuseWaiting;

  /// No description provided for @wsMuseExpires.
  ///
  /// In en, this message translates to:
  /// **'The code works until {time}.'**
  String wsMuseExpires(String time);

  /// No description provided for @wsMuse_denied.
  ///
  /// In en, this message translates to:
  /// **'The sign-in was declined on Meta\'s page.'**
  String get wsMuse_denied;

  /// No description provided for @wsMuse_expired.
  ///
  /// In en, this message translates to:
  /// **'The code expired before it was confirmed.'**
  String get wsMuse_expired;

  /// No description provided for @wsMuse_failed.
  ///
  /// In en, this message translates to:
  /// **'The sign-in failed.'**
  String get wsMuse_failed;

  /// No description provided for @wsMuseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get wsMuseTryAgain;

  /// No description provided for @wsMuseUseKey.
  ///
  /// In en, this message translates to:
  /// **'Use an API key'**
  String get wsMuseUseKey;

  /// No description provided for @wsMuseKeyHelp.
  ///
  /// In en, this message translates to:
  /// **'Paste a Muse API key (it starts with LLM_). Usage is billed by Meta to its owner.'**
  String get wsMuseKeyHelp;

  /// No description provided for @wsClaudeBoth.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get wsClaudeBoth;

  /// No description provided for @wsClaudeSubBoth.
  ///
  /// In en, this message translates to:
  /// **'Which Muse and Claude accounts this workspace\'s runs use.'**
  String get wsClaudeSubBoth;

  /// No description provided for @wsClaudeSavedBoth.
  ///
  /// In en, this message translates to:
  /// **'Account settings saved'**
  String get wsClaudeSavedBoth;

  /// No description provided for @wsFallbackHelpBoth.
  ///
  /// In en, this message translates to:
  /// **'When the chosen account is at its limit or missing, runs continue on agnts\'s key and spend credits instead of pausing.'**
  String get wsFallbackHelpBoth;

  /// No description provided for @wsMemberAccountsSubBoth.
  ///
  /// In en, this message translates to:
  /// **'Who has connected their own Muse and Claude accounts (Profile).'**
  String get wsMemberAccountsSubBoth;

  /// No description provided for @wsConnectionMuse.
  ///
  /// In en, this message translates to:
  /// **'Workspace Muse account'**
  String get wsConnectionMuse;

  /// No description provided for @wsConnectionClaude.
  ///
  /// In en, this message translates to:
  /// **'Workspace Claude account'**
  String get wsConnectionClaude;

  /// No description provided for @wsNoAccountModules.
  ///
  /// In en, this message translates to:
  /// **'Your modules have no account to connect here: Codex runs on the workspace\'s OpenAI integration.'**
  String get wsNoAccountModules;
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
