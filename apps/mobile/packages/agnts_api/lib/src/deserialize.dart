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
import 'package:agnts_api/src/model/approve_ticket_request.dart';
import 'package:agnts_api/src/model/blocker.dart';
import 'package:agnts_api/src/model/branch.dart';
import 'package:agnts_api/src/model/check_step.dart';
import 'package:agnts_api/src/model/code_review.dart';
import 'package:agnts_api/src/model/commit.dart';
import 'package:agnts_api/src/model/connect_integration_request.dart';
import 'package:agnts_api/src/model/connect_result.dart';
import 'package:agnts_api/src/model/dashboard.dart';
import 'package:agnts_api/src/model/dashboard_counts.dart';
import 'package:agnts_api/src/model/day_stat.dart';
import 'package:agnts_api/src/model/decide_consent200_response.dart';
import 'package:agnts_api/src/model/decide_consent_request.dart';
import 'package:agnts_api/src/model/deploy_repo_request.dart';
import 'package:agnts_api/src/model/device_registration.dart';
import 'package:agnts_api/src/model/environment.dart';
import 'package:agnts_api/src/model/error.dart';
import 'package:agnts_api/src/model/event.dart';
import 'package:agnts_api/src/model/event_page.dart';
import 'package:agnts_api/src/model/event_summary.dart';
import 'package:agnts_api/src/model/file_change.dart';
import 'package:agnts_api/src/model/finding.dart';
import 'package:agnts_api/src/model/follow_up_suggestion.dart';
import 'package:agnts_api/src/model/follow_up_ticket.dart';
import 'package:agnts_api/src/model/follow_ups.dart';
import 'package:agnts_api/src/model/follow_ups_setting.dart';
import 'package:agnts_api/src/model/footprint.dart';
import 'package:agnts_api/src/model/get_consent200_response.dart';
import 'package:agnts_api/src/model/git_settings.dart';
import 'package:agnts_api/src/model/history_item.dart';
import 'package:agnts_api/src/model/hour_bucket.dart';
import 'package:agnts_api/src/model/implement_input.dart';
import 'package:agnts_api/src/model/integration.dart';
import 'package:agnts_api/src/model/learn_queue_item.dart';
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
import 'package:agnts_api/src/model/meta.dart';
import 'package:agnts_api/src/model/model_overrides.dart';
import 'package:agnts_api/src/model/notify_settings.dart';
import 'package:agnts_api/src/model/period_stats.dart';
import 'package:agnts_api/src/model/pipeline.dart';
import 'package:agnts_api/src/model/question.dart';
import 'package:agnts_api/src/model/quiz_question.dart';
import 'package:agnts_api/src/model/reject_ticket_request.dart';
import 'package:agnts_api/src/model/related_ticket.dart';
import 'package:agnts_api/src/model/relation.dart';
import 'package:agnts_api/src/model/relation_input.dart';
import 'package:agnts_api/src/model/relations.dart';
import 'package:agnts_api/src/model/remote_repository.dart';
import 'package:agnts_api/src/model/repo_activity.dart';
import 'package:agnts_api/src/model/repo_member.dart';
import 'package:agnts_api/src/model/repository.dart';
import 'package:agnts_api/src/model/repository_input.dart';
import 'package:agnts_api/src/model/request_changes_request.dart';
import 'package:agnts_api/src/model/result.dart';
import 'package:agnts_api/src/model/rotate_mcp_token200_response.dart';
import 'package:agnts_api/src/model/rule.dart';
import 'package:agnts_api/src/model/rule_answers.dart';
import 'package:agnts_api/src/model/rule_answers_answers_inner.dart';
import 'package:agnts_api/src/model/rule_input.dart';
import 'package:agnts_api/src/model/rule_question.dart';
import 'package:agnts_api/src/model/settings.dart';
import 'package:agnts_api/src/model/stage.dart';
import 'package:agnts_api/src/model/stage_models.dart';
import 'package:agnts_api/src/model/stage_spend.dart';
import 'package:agnts_api/src/model/step_duration.dart';
import 'package:agnts_api/src/model/sync_jira200_response.dart';
import 'package:agnts_api/src/model/task_create.dart';
import 'package:agnts_api/src/model/task_update.dart';
import 'package:agnts_api/src/model/ticket.dart';
import 'package:agnts_api/src/model/ticket_detail.dart';
import 'package:agnts_api/src/model/ticket_kind_input.dart';
import 'package:agnts_api/src/model/ticket_repo.dart';
import 'package:agnts_api/src/model/ticket_spend_list.dart';
import 'package:agnts_api/src/model/ticket_spend_row.dart';
import 'package:agnts_api/src/model/token_spend.dart';
import 'package:agnts_api/src/model/translate_input.dart';
import 'package:agnts_api/src/model/translation.dart';
import 'package:agnts_api/src/model/translation_items_inner.dart';
import 'package:agnts_api/src/model/unregister_device_request.dart';
import 'package:agnts_api/src/model/update_integration_request.dart';
import 'package:agnts_api/src/model/usage.dart';
import 'package:agnts_api/src/model/usage_window.dart';
import 'package:agnts_api/src/model/user.dart';
import 'package:agnts_api/src/model/week_stats.dart';

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
        case 'ApproveTicketRequest':
          return ApproveTicketRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Blocker':
          return Blocker.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Branch':
          return Branch.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CI':
          
          
        case 'CheckStep':
          return CheckStep.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CodeReview':
          return CodeReview.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Commit':
          return Commit.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ConnectIntegrationRequest':
          return ConnectIntegrationRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ConnectResult':
          return ConnectResult.fromJson(value as Map<String, dynamic>) as ReturnType;
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
        case 'DeployRepoRequest':
          return DeployRepoRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DeviceRegistration':
          return DeviceRegistration.fromJson(value as Map<String, dynamic>) as ReturnType;
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
        case 'GetConsent200Response':
          return GetConsent200Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GitSettings':
          return GitSettings.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'HistoryItem':
          return HistoryItem.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'HourBucket':
          return HourBucket.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ImplementInput':
          return ImplementInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Integration':
          return Integration.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LearnQueueItem':
          return LearnQueueItem.fromJson(value as Map<String, dynamic>) as ReturnType;
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
        case 'Question':
          return Question.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'QuizQuestion':
          return QuizQuestion.fromJson(value as Map<String, dynamic>) as ReturnType;
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
        case 'RepoActivity':
          return RepoActivity.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RepoMember':
          return RepoMember.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Repository':
          return Repository.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RepositoryInput':
          return RepositoryInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RequestChangesRequest':
          return RequestChangesRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Result':
          return Result.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReviewModel':
          
          
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
        case 'RuleQuestion':
          return RuleQuestion.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RuleStatus':
          
          
        case 'Settings':
          return Settings.fromJson(value as Map<String, dynamic>) as ReturnType;
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
        case 'TicketRepo':
          return TicketRepo.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TicketSpendList':
          return TicketSpendList.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TicketSpendRow':
          return TicketSpendRow.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TicketState':
          
          
        case 'TokenSpend':
          return TokenSpend.fromJson(value as Map<String, dynamic>) as ReturnType;
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
        case 'Usage':
          return Usage.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UsageWindow':
          return UsageWindow.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'User':
          return User.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WeekStats':
          return WeekStats.fromJson(value as Map<String, dynamic>) as ReturnType;
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