import 'package:agnts_api/src/model/accept_follow_up.dart';
import 'package:agnts_api/src/model/accept_follow_up_result.dart';
import 'package:agnts_api/src/model/accept_follow_ups.dart';
import 'package:agnts_api/src/model/accept_follow_ups_result.dart';
import 'package:agnts_api/src/model/analysis.dart';
import 'package:agnts_api/src/model/analytics.dart';
import 'package:agnts_api/src/model/analytics_insights_inner.dart';
import 'package:agnts_api/src/model/analytics_models_inner.dart';
import 'package:agnts_api/src/model/analytics_repos_inner.dart';
import 'package:agnts_api/src/model/answers_request.dart';
import 'package:agnts_api/src/model/answers_request_answers_inner.dart';
import 'package:agnts_api/src/model/approach.dart';
import 'package:agnts_api/src/model/approve_ticket_request.dart';
import 'package:agnts_api/src/model/attachment.dart';
import 'package:agnts_api/src/model/begin_login_totp200_response.dart';
import 'package:agnts_api/src/model/begin_login_totp_request.dart';
import 'package:agnts_api/src/model/begin_totp200_response.dart';
import 'package:agnts_api/src/model/billing.dart';
import 'package:agnts_api/src/model/billing_prices.dart';
import 'package:agnts_api/src/model/blocker.dart';
import 'package:agnts_api/src/model/branch.dart';
import 'package:agnts_api/src/model/capacity.dart';
import 'package:agnts_api/src/model/change_password_request.dart';
import 'package:agnts_api/src/model/check_step.dart';
import 'package:agnts_api/src/model/checkout_credits200_response.dart';
import 'package:agnts_api/src/model/checkout_credits_request.dart';
import 'package:agnts_api/src/model/claude_connection_input.dart';
import 'package:agnts_api/src/model/claude_connection_state.dart';
import 'package:agnts_api/src/model/code_review.dart';
import 'package:agnts_api/src/model/commit.dart';
import 'package:agnts_api/src/model/confirm_totp_request.dart';
import 'package:agnts_api/src/model/connect_integration_request.dart';
import 'package:agnts_api/src/model/connect_result.dart';
import 'package:agnts_api/src/model/create_invite201_response.dart';
import 'package:agnts_api/src/model/create_invite_request.dart';
import 'package:agnts_api/src/model/create_platform_admin_request.dart';
import 'package:agnts_api/src/model/create_workspace_request.dart';
import 'package:agnts_api/src/model/dashboard.dart';
import 'package:agnts_api/src/model/dashboard_counts.dart';
import 'package:agnts_api/src/model/day_stat.dart';
import 'package:agnts_api/src/model/decide_consent200_response.dart';
import 'package:agnts_api/src/model/decide_consent_request.dart';
import 'package:agnts_api/src/model/delete_workspace_request.dart';
import 'package:agnts_api/src/model/deploy_repo_request.dart';
import 'package:agnts_api/src/model/device_registration.dart';
import 'package:agnts_api/src/model/disable_totp_request.dart';
import 'package:agnts_api/src/model/environment.dart';
import 'package:agnts_api/src/model/error.dart';
import 'package:agnts_api/src/model/event.dart';
import 'package:agnts_api/src/model/event_page.dart';
import 'package:agnts_api/src/model/event_summary.dart';
import 'package:agnts_api/src/model/feedback.dart';
import 'package:agnts_api/src/model/file_change.dart';
import 'package:agnts_api/src/model/finding.dart';
import 'package:agnts_api/src/model/follow_up_suggestion.dart';
import 'package:agnts_api/src/model/follow_up_ticket.dart';
import 'package:agnts_api/src/model/follow_ups.dart';
import 'package:agnts_api/src/model/follow_ups_setting.dart';
import 'package:agnts_api/src/model/footprint.dart';
import 'package:agnts_api/src/model/forgot_password_request.dart';
import 'package:agnts_api/src/model/get_consent200_response.dart';
import 'package:agnts_api/src/model/git_settings.dart';
import 'package:agnts_api/src/model/google_sign_in_request.dart';
import 'package:agnts_api/src/model/grant_credits_request.dart';
import 'package:agnts_api/src/model/history_item.dart';
import 'package:agnts_api/src/model/hour_bucket.dart';
import 'package:agnts_api/src/model/implement_input.dart';
import 'package:agnts_api/src/model/integration.dart';
import 'package:agnts_api/src/model/invite.dart';
import 'package:agnts_api/src/model/invite_preview.dart';
import 'package:agnts_api/src/model/learn_queue_item.dart';
import 'package:agnts_api/src/model/ledger_entry.dart';
import 'package:agnts_api/src/model/lesson.dart';
import 'package:agnts_api/src/model/lesson_brief.dart';
import 'package:agnts_api/src/model/lesson_list.dart';
import 'package:agnts_api/src/model/lesson_ref.dart';
import 'package:agnts_api/src/model/link.dart';
import 'package:agnts_api/src/model/live_run.dart';
import 'package:agnts_api/src/model/local_branch.dart';
import 'package:agnts_api/src/model/login_request.dart';
import 'package:agnts_api/src/model/login_response.dart';
import 'package:agnts_api/src/model/mcp_status.dart';
import 'package:agnts_api/src/model/member.dart';
import 'package:agnts_api/src/model/meta.dart';
import 'package:agnts_api/src/model/model_overrides.dart';
import 'package:agnts_api/src/model/notify_settings.dart';
import 'package:agnts_api/src/model/period_stats.dart';
import 'package:agnts_api/src/model/pipeline.dart';
import 'package:agnts_api/src/model/plane_state.dart';
import 'package:agnts_api/src/model/platform_overview.dart';
import 'package:agnts_api/src/model/platform_overview_runs_inner.dart';
import 'package:agnts_api/src/model/platform_overview_server_queue_inner.dart';
import 'package:agnts_api/src/model/platform_user.dart';
import 'package:agnts_api/src/model/platform_workspace.dart';
import 'package:agnts_api/src/model/preview_input.dart';
import 'package:agnts_api/src/model/preview_issue.dart';
import 'package:agnts_api/src/model/preview_shot.dart';
import 'package:agnts_api/src/model/pull_request.dart';
import 'package:agnts_api/src/model/pull_review_settings.dart';
import 'package:agnts_api/src/model/quality_stat.dart';
import 'package:agnts_api/src/model/question.dart';
import 'package:agnts_api/src/model/queue_status.dart';
import 'package:agnts_api/src/model/queue_status_server_queue_inner.dart';
import 'package:agnts_api/src/model/queue_status_waiting.dart';
import 'package:agnts_api/src/model/quiz_question.dart';
import 'package:agnts_api/src/model/red_flag.dart';
import 'package:agnts_api/src/model/register_request.dart';
import 'package:agnts_api/src/model/reject_ticket_request.dart';
import 'package:agnts_api/src/model/related_ticket.dart';
import 'package:agnts_api/src/model/relation.dart';
import 'package:agnts_api/src/model/relation_input.dart';
import 'package:agnts_api/src/model/relations.dart';
import 'package:agnts_api/src/model/remote_repository.dart';
import 'package:agnts_api/src/model/replay_report.dart';
import 'package:agnts_api/src/model/replay_result.dart';
import 'package:agnts_api/src/model/replay_version.dart';
import 'package:agnts_api/src/model/repo_activity.dart';
import 'package:agnts_api/src/model/repo_brief.dart';
import 'package:agnts_api/src/model/repo_brief_input.dart';
import 'package:agnts_api/src/model/repo_detect_input.dart';
import 'package:agnts_api/src/model/repo_detection.dart';
import 'package:agnts_api/src/model/repo_member.dart';
import 'package:agnts_api/src/model/repo_preview.dart';
import 'package:agnts_api/src/model/repo_preview_input.dart';
import 'package:agnts_api/src/model/repository.dart';
import 'package:agnts_api/src/model/repository_input.dart';
import 'package:agnts_api/src/model/request_changes_request.dart';
import 'package:agnts_api/src/model/reset_password_request.dart';
import 'package:agnts_api/src/model/result.dart';
import 'package:agnts_api/src/model/retry_ticket_request.dart';
import 'package:agnts_api/src/model/review_sync.dart';
import 'package:agnts_api/src/model/reviewer.dart';
import 'package:agnts_api/src/model/reviewer_note.dart';
import 'package:agnts_api/src/model/reviewer_note_input.dart';
import 'package:agnts_api/src/model/reviewer_profile_input.dart';
import 'package:agnts_api/src/model/reviewers.dart';
import 'package:agnts_api/src/model/rotate_mcp_token200_response.dart';
import 'package:agnts_api/src/model/rule.dart';
import 'package:agnts_api/src/model/rule_answers.dart';
import 'package:agnts_api/src/model/rule_answers_answers_inner.dart';
import 'package:agnts_api/src/model/rule_input.dart';
import 'package:agnts_api/src/model/rule_question.dart';
import 'package:agnts_api/src/model/send_feedback_request.dart';
import 'package:agnts_api/src/model/set_member_role_request.dart';
import 'package:agnts_api/src/model/set_plane_webhook_secret_request.dart';
import 'package:agnts_api/src/model/set_slots_request.dart';
import 'package:agnts_api/src/model/set_ticket_member_request.dart';
import 'package:agnts_api/src/model/settings.dart';
import 'package:agnts_api/src/model/ship_notes.dart';
import 'package:agnts_api/src/model/shot_ref.dart';
import 'package:agnts_api/src/model/signup_info.dart';
import 'package:agnts_api/src/model/stage.dart';
import 'package:agnts_api/src/model/stage_models.dart';
import 'package:agnts_api/src/model/stage_spend.dart';
import 'package:agnts_api/src/model/step_duration.dart';
import 'package:agnts_api/src/model/sync_jira200_response.dart';
import 'package:agnts_api/src/model/sync_plane200_response.dart';
import 'package:agnts_api/src/model/task_create.dart';
import 'package:agnts_api/src/model/task_update.dart';
import 'package:agnts_api/src/model/ticket.dart';
import 'package:agnts_api/src/model/ticket_detail.dart';
import 'package:agnts_api/src/model/ticket_kind_input.dart';
import 'package:agnts_api/src/model/ticket_preview.dart';
import 'package:agnts_api/src/model/ticket_repo.dart';
import 'package:agnts_api/src/model/ticket_spend_list.dart';
import 'package:agnts_api/src/model/ticket_spend_row.dart';
import 'package:agnts_api/src/model/token_request.dart';
import 'package:agnts_api/src/model/token_spend.dart';
import 'package:agnts_api/src/model/toolchain.dart';
import 'package:agnts_api/src/model/tracker_update.dart';
import 'package:agnts_api/src/model/transfer_workspace_request.dart';
import 'package:agnts_api/src/model/translate_input.dart';
import 'package:agnts_api/src/model/translation.dart';
import 'package:agnts_api/src/model/translation_items_inner.dart';
import 'package:agnts_api/src/model/unregister_device_request.dart';
import 'package:agnts_api/src/model/update_integration_request.dart';
import 'package:agnts_api/src/model/update_platform_feedback_request.dart';
import 'package:agnts_api/src/model/update_platform_user_request.dart';
import 'package:agnts_api/src/model/update_platform_workspace_request.dart';
import 'package:agnts_api/src/model/update_profile_request.dart';
import 'package:agnts_api/src/model/update_workspace_claude_request.dart';
import 'package:agnts_api/src/model/update_workspace_request.dart';
import 'package:agnts_api/src/model/usage.dart';
import 'package:agnts_api/src/model/usage_window.dart';
import 'package:agnts_api/src/model/user.dart';
import 'package:agnts_api/src/model/week_stats.dart';
import 'package:agnts_api/src/model/workspace_claude.dart';
import 'package:agnts_api/src/model/workspace_claude_members_inner.dart';
import 'package:agnts_api/src/model/workspace_detail.dart';
import 'package:agnts_api/src/model/workspace_summary.dart';

final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

  ReturnType deserialize<ReturnType, BaseType>(dynamic value, String targetType, {bool growable= true}) {
      switch (targetType) {
        case 'String':
          return '$value' as ReturnType;
        case 'int':
          return (value is int ? value : int.parse('$value')) as ReturnType;
        case 'bool':
          if (value is bool) {
            return value as ReturnType;
          }
          final valueString = '$value'.toLowerCase();
          return (valueString == 'true' || valueString == '1') as ReturnType;
        case 'double':
          return (value is double ? value : double.parse('$value')) as ReturnType;
        case 'AcceptFollowUp':
          return AcceptFollowUp.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AcceptFollowUpResult':
          return AcceptFollowUpResult.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AcceptFollowUps':
          return AcceptFollowUps.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AcceptFollowUpsResult':
          return AcceptFollowUpsResult.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Analysis':
          return Analysis.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Analytics':
          return Analytics.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AnalyticsInsightsInner':
          return AnalyticsInsightsInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AnalyticsModelsInner':
          return AnalyticsModelsInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AnalyticsReposInner':
          return AnalyticsReposInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AnswersRequest':
          return AnswersRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AnswersRequestAnswersInner':
          return AnswersRequestAnswersInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Approach':
          return Approach.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ApproveTicketRequest':
          return ApproveTicketRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Attachment':
          return Attachment.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BeginLoginTotp200Response':
          return BeginLoginTotp200Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BeginLoginTotpRequest':
          return BeginLoginTotpRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BeginTotp200Response':
          return BeginTotp200Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Billing':
          return Billing.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BillingPrices':
          return BillingPrices.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Blocker':
          return Blocker.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Branch':
          return Branch.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CI':
          
          
        case 'Capacity':
          return Capacity.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ChangePasswordRequest':
          return ChangePasswordRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CheckStep':
          return CheckStep.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CheckoutCredits200Response':
          return CheckoutCredits200Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CheckoutCreditsRequest':
          return CheckoutCreditsRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ClaudeConnectionInput':
          return ClaudeConnectionInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ClaudeConnectionState':
          return ClaudeConnectionState.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CodeReview':
          return CodeReview.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Commit':
          return Commit.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ConfirmTotpRequest':
          return ConfirmTotpRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ConnectIntegrationRequest':
          return ConnectIntegrationRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ConnectResult':
          return ConnectResult.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateInvite201Response':
          return CreateInvite201Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateInviteRequest':
          return CreateInviteRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreatePlatformAdminRequest':
          return CreatePlatformAdminRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateWorkspaceRequest':
          return CreateWorkspaceRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Dashboard':
          return Dashboard.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DashboardCounts':
          return DashboardCounts.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DayStat':
          return DayStat.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DecideConsent200Response':
          return DecideConsent200Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DecideConsentRequest':
          return DecideConsentRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DeleteWorkspaceRequest':
          return DeleteWorkspaceRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DeployRepoRequest':
          return DeployRepoRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DeviceRegistration':
          return DeviceRegistration.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DisableTotpRequest':
          return DisableTotpRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Environment':
          return Environment.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Error':
          return Error.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Event':
          return Event.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EventPage':
          return EventPage.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EventSummary':
          return EventSummary.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Feedback':
          return Feedback.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'FileChange':
          return FileChange.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Finding':
          return Finding.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'FollowUpSuggestion':
          return FollowUpSuggestion.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'FollowUpTicket':
          return FollowUpTicket.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'FollowUps':
          return FollowUps.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'FollowUpsMode':
          
          
        case 'FollowUpsSetting':
          return FollowUpsSetting.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Footprint':
          return Footprint.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ForgotPasswordRequest':
          return ForgotPasswordRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GetConsent200Response':
          return GetConsent200Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GitSettings':
          return GitSettings.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GoogleSignInRequest':
          return GoogleSignInRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GrantCreditsRequest':
          return GrantCreditsRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'HistoryItem':
          return HistoryItem.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'HourBucket':
          return HourBucket.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ImplementInput':
          return ImplementInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Integration':
          return Integration.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Invite':
          return Invite.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'InvitePreview':
          return InvitePreview.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LearnQueueItem':
          return LearnQueueItem.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LedgerEntry':
          return LedgerEntry.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Lesson':
          return Lesson.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LessonBrief':
          return LessonBrief.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LessonCategory':
          
          
        case 'LessonLevel':
          
          
        case 'LessonList':
          return LessonList.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LessonRef':
          return LessonRef.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Link':
          return Link.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LiveRun':
          return LiveRun.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LocalBranch':
          return LocalBranch.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LoginRequest':
          return LoginRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LoginResponse':
          return LoginResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'McpStatus':
          return McpStatus.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Member':
          return Member.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Meta':
          return Meta.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Model':
          
          
        case 'ModelOverrides':
          return ModelOverrides.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'NotifySettings':
          return NotifySettings.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PeriodStats':
          return PeriodStats.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Pipeline':
          return Pipeline.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PlaneState':
          return PlaneState.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PlatformOverview':
          return PlatformOverview.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PlatformOverviewRunsInner':
          return PlatformOverviewRunsInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PlatformOverviewServerQueueInner':
          return PlatformOverviewServerQueueInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PlatformUser':
          return PlatformUser.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PlatformWorkspace':
          return PlatformWorkspace.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PreviewInput':
          return PreviewInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PreviewIssue':
          return PreviewIssue.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PreviewShot':
          return PreviewShot.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PullRequest':
          return PullRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PullReviewSettings':
          return PullReviewSettings.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'QualityStat':
          return QualityStat.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Question':
          return Question.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'QueueStatus':
          return QueueStatus.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'QueueStatusServerQueueInner':
          return QueueStatusServerQueueInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'QueueStatusWaiting':
          return QueueStatusWaiting.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'QuizQuestion':
          return QuizQuestion.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RedFlag':
          return RedFlag.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RegisterRequest':
          return RegisterRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RejectTicketRequest':
          return RejectTicketRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RelatedTicket':
          return RelatedTicket.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Relation':
          return Relation.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RelationInput':
          return RelationInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RelationType':
          
          
        case 'Relations':
          return Relations.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RemoteRepository':
          return RemoteRepository.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReplayReport':
          return ReplayReport.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReplayResult':
          return ReplayResult.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReplayVersion':
          return ReplayVersion.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RepoActivity':
          return RepoActivity.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RepoBrief':
          return RepoBrief.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RepoBriefInput':
          return RepoBriefInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RepoDetectInput':
          return RepoDetectInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RepoDetection':
          return RepoDetection.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RepoMember':
          return RepoMember.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RepoPreview':
          return RepoPreview.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RepoPreviewInput':
          return RepoPreviewInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Repository':
          return Repository.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RepositoryInput':
          return RepositoryInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RequestChangesRequest':
          return RequestChangesRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ResetPasswordRequest':
          return ResetPasswordRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Result':
          return Result.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RetryTicketRequest':
          return RetryTicketRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReviewModel':
          
          
        case 'ReviewSync':
          return ReviewSync.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Reviewer':
          return Reviewer.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReviewerNote':
          return ReviewerNote.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReviewerNoteInput':
          return ReviewerNoteInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReviewerProfileInput':
          return ReviewerProfileInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Reviewers':
          return Reviewers.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RotateMcpToken200Response':
          return RotateMcpToken200Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Rule':
          return Rule.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RuleAnswers':
          return RuleAnswers.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RuleAnswersAnswersInner':
          return RuleAnswersAnswersInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RuleInput':
          return RuleInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RuleKind':
          
          
        case 'RuleQuestion':
          return RuleQuestion.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RuleStatus':
          
          
        case 'SendFeedbackRequest':
          return SendFeedbackRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SetMemberRoleRequest':
          return SetMemberRoleRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SetPlaneWebhookSecretRequest':
          return SetPlaneWebhookSecretRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SetSlotsRequest':
          return SetSlotsRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SetTicketMemberRequest':
          return SetTicketMemberRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Settings':
          return Settings.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ShipNotes':
          return ShipNotes.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ShotRef':
          return ShotRef.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SignupInfo':
          return SignupInfo.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Stage':
          return Stage.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'StageModels':
          return StageModels.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'StageSpend':
          return StageSpend.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'StepDuration':
          return StepDuration.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SyncJira200Response':
          return SyncJira200Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SyncPlane200Response':
          return SyncPlane200Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TaskCreate':
          return TaskCreate.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TaskUpdate':
          return TaskUpdate.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Ticket':
          return Ticket.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TicketDetail':
          return TicketDetail.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TicketKind':
          
          
        case 'TicketKindChoice':
          
          
        case 'TicketKindInput':
          return TicketKindInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TicketPreview':
          return TicketPreview.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TicketRepo':
          return TicketRepo.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TicketSpendList':
          return TicketSpendList.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TicketSpendRow':
          return TicketSpendRow.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TicketState':
          
          
        case 'TokenRequest':
          return TokenRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TokenSpend':
          return TokenSpend.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Toolchain':
          return Toolchain.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TrackerUpdate':
          return TrackerUpdate.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TransferWorkspaceRequest':
          return TransferWorkspaceRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TranslateInput':
          return TranslateInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Translation':
          return Translation.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TranslationItemsInner':
          return TranslationItemsInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TranslationLanguage':
          
          
        case 'UnregisterDeviceRequest':
          return UnregisterDeviceRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdateIntegrationRequest':
          return UpdateIntegrationRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdatePlatformFeedbackRequest':
          return UpdatePlatformFeedbackRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdatePlatformUserRequest':
          return UpdatePlatformUserRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdatePlatformWorkspaceRequest':
          return UpdatePlatformWorkspaceRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdateProfileRequest':
          return UpdateProfileRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdateWorkspaceClaudeRequest':
          return UpdateWorkspaceClaudeRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdateWorkspaceRequest':
          return UpdateWorkspaceRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Usage':
          return Usage.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UsageWindow':
          return UsageWindow.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'User':
          return User.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WaitReason':
          
          
        case 'WeekStats':
          return WeekStats.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WorkspaceClaude':
          return WorkspaceClaude.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WorkspaceClaudeMembersInner':
          return WorkspaceClaudeMembersInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WorkspaceDetail':
          return WorkspaceDetail.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WorkspaceRole':
          
          
        case 'WorkspaceSummary':
          return WorkspaceSummary.fromJson(value as Map<String, dynamic>) as ReturnType;
        default:
          RegExpMatch? match;

          if (value is List && (match = _regList.firstMatch(targetType)) != null) {
            targetType = match![1]!; // ignore: parameter_assignments
            return value
              .map<BaseType>((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable))
              .toList(growable: growable) as ReturnType;
          }
          if (value is Set && (match = _regSet.firstMatch(targetType)) != null) {
            targetType = match![1]!; // ignore: parameter_assignments
            return value
              .map<BaseType>((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable))
              .toSet() as ReturnType;
          }
          if (value is Map && (match = _regMap.firstMatch(targetType)) != null) {
            targetType = match![1]!.trim(); // ignore: parameter_assignments
            return Map<String, BaseType>.fromIterables(
              value.keys as Iterable<String>,
              value.values.map((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable)),
            ) as ReturnType;
          }
          break;
    }
    throw Exception('Cannot deserialize');
  }