import 'package:agnts_api/src/model/accept_all_review_drafts_request.dart';
import 'package:agnts_api/src/model/accept_follow_up.dart';
import 'package:agnts_api/src/model/accept_follow_up_result.dart';
import 'package:agnts_api/src/model/accept_follow_ups.dart';
import 'package:agnts_api/src/model/accept_follow_ups_result.dart';
import 'package:agnts_api/src/model/acceptance.dart';
import 'package:agnts_api/src/model/acceptance_criteria_inner.dart';
import 'package:agnts_api/src/model/act_on_meeting_person_request.dart';
import 'package:agnts_api/src/model/action_item_ticket_input.dart';
import 'package:agnts_api/src/model/add_review_draft_request.dart';
import 'package:agnts_api/src/model/address_pull_comments_request.dart';
import 'package:agnts_api/src/model/admin_audit_entry.dart';
import 'package:agnts_api/src/model/agent_config_finding.dart';
import 'package:agnts_api/src/model/agent_config_scan.dart';
import 'package:agnts_api/src/model/analysis.dart';
import 'package:agnts_api/src/model/analysis_acceptance_inner.dart';
import 'package:agnts_api/src/model/analysis_repro.dart';
import 'package:agnts_api/src/model/analysis_reuse_inner.dart';
import 'package:agnts_api/src/model/analysis_test_plan_inner.dart';
import 'package:agnts_api/src/model/analytics.dart';
import 'package:agnts_api/src/model/analytics_ci.dart';
import 'package:agnts_api/src/model/analytics_delivery.dart';
import 'package:agnts_api/src/model/analytics_insights_inner.dart';
import 'package:agnts_api/src/model/analytics_learning.dart';
import 'package:agnts_api/src/model/analytics_models_inner.dart';
import 'package:agnts_api/src/model/analytics_repos_inner.dart';
import 'package:agnts_api/src/model/answer_draft.dart';
import 'package:agnts_api/src/model/answer_draft_request.dart';
import 'package:agnts_api/src/model/answer_draft_request_answers_inner.dart';
import 'package:agnts_api/src/model/answer_meeting_request.dart';
import 'package:agnts_api/src/model/answers_request.dart';
import 'package:agnts_api/src/model/answers_request_answers_inner.dart';
import 'package:agnts_api/src/model/api_case.dart';
import 'package:agnts_api/src/model/api_counts.dart';
import 'package:agnts_api/src/model/api_exchange.dart';
import 'package:agnts_api/src/model/api_request_row.dart';
import 'package:agnts_api/src/model/approach.dart';
import 'package:agnts_api/src/model/approve_ticket_request.dart';
import 'package:agnts_api/src/model/assistant_action.dart';
import 'package:agnts_api/src/model/assistant_ask.dart';
import 'package:agnts_api/src/model/assistant_conversation.dart';
import 'package:agnts_api/src/model/assistant_link.dart';
import 'package:agnts_api/src/model/assistant_message.dart';
import 'package:agnts_api/src/model/assistant_rated.dart';
import 'package:agnts_api/src/model/assistant_rating.dart';
import 'package:agnts_api/src/model/assistant_stats.dart';
import 'package:agnts_api/src/model/assistant_stats_actions.dart';
import 'package:agnts_api/src/model/assistant_stats_versions_inner.dart';
import 'package:agnts_api/src/model/assistant_transcript.dart';
import 'package:agnts_api/src/model/attach_code_ticket_request.dart';
import 'package:agnts_api/src/model/attachment.dart';
import 'package:agnts_api/src/model/begin_login_totp200_response.dart';
import 'package:agnts_api/src/model/begin_login_totp_request.dart';
import 'package:agnts_api/src/model/begin_totp200_response.dart';
import 'package:agnts_api/src/model/benchmark_run.dart';
import 'package:agnts_api/src/model/billing.dart';
import 'package:agnts_api/src/model/billing_prices.dart';
import 'package:agnts_api/src/model/blocker.dart';
import 'package:agnts_api/src/model/branch.dart';
import 'package:agnts_api/src/model/branch_commit.dart';
import 'package:agnts_api/src/model/ci_day.dart';
import 'package:agnts_api/src/model/ci_failure.dart';
import 'package:agnts_api/src/model/ci_occurrence.dart';
import 'package:agnts_api/src/model/ci_period.dart';
import 'package:agnts_api/src/model/ci_settings.dart';
import 'package:agnts_api/src/model/ci_watch.dart';
import 'package:agnts_api/src/model/capacity.dart';
import 'package:agnts_api/src/model/change_password_request.dart';
import 'package:agnts_api/src/model/check_step.dart';
import 'package:agnts_api/src/model/checkout_credits200_response.dart';
import 'package:agnts_api/src/model/checkout_credits_request.dart';
import 'package:agnts_api/src/model/claude_connection_input.dart';
import 'package:agnts_api/src/model/claude_connection_state.dart';
import 'package:agnts_api/src/model/code_approval.dart';
import 'package:agnts_api/src/model/code_handoff.dart';
import 'package:agnts_api/src/model/code_review.dart';
import 'package:agnts_api/src/model/code_send.dart';
import 'package:agnts_api/src/model/code_send_answers_inner.dart';
import 'package:agnts_api/src/model/code_start.dart';
import 'package:agnts_api/src/model/code_ticket.dart';
import 'package:agnts_api/src/model/code_timeline.dart';
import 'package:agnts_api/src/model/commit.dart';
import 'package:agnts_api/src/model/commit_detail.dart';
import 'package:agnts_api/src/model/commit_pull.dart';
import 'package:agnts_api/src/model/commit_ticket.dart';
import 'package:agnts_api/src/model/confirm_totp_request.dart';
import 'package:agnts_api/src/model/connect_integration_request.dart';
import 'package:agnts_api/src/model/connect_result.dart';
import 'package:agnts_api/src/model/continue_ticket_request.dart';
import 'package:agnts_api/src/model/coverage.dart';
import 'package:agnts_api/src/model/coverage_config.dart';
import 'package:agnts_api/src/model/coverage_files_inner.dart';
import 'package:agnts_api/src/model/coverage_files_inner_uncovered_inner.dart';
import 'package:agnts_api/src/model/create_invite201_response.dart';
import 'package:agnts_api/src/model/create_invite_request.dart';
import 'package:agnts_api/src/model/create_platform_admin_request.dart';
import 'package:agnts_api/src/model/create_ticket_document_request.dart';
import 'package:agnts_api/src/model/create_workspace_request.dart';
import 'package:agnts_api/src/model/credit_usage.dart';
import 'package:agnts_api/src/model/dashboard.dart';
import 'package:agnts_api/src/model/dashboard_counts.dart';
import 'package:agnts_api/src/model/day_stat.dart';
import 'package:agnts_api/src/model/decide_code_approval_request.dart';
import 'package:agnts_api/src/model/decide_consent200_response.dart';
import 'package:agnts_api/src/model/decide_consent_request.dart';
import 'package:agnts_api/src/model/delete_workspace_request.dart';
import 'package:agnts_api/src/model/delivery_day.dart';
import 'package:agnts_api/src/model/delivery_period.dart';
import 'package:agnts_api/src/model/deploy_repo_request.dart';
import 'package:agnts_api/src/model/device_registration.dart';
import 'package:agnts_api/src/model/disable_totp_request.dart';
import 'package:agnts_api/src/model/document.dart';
import 'package:agnts_api/src/model/document_all_of_derived_from.dart';
import 'package:agnts_api/src/model/document_comment.dart';
import 'package:agnts_api/src/model/document_comment_input.dart';
import 'package:agnts_api/src/model/document_comment_patch.dart';
import 'package:agnts_api/src/model/document_conflict.dart';
import 'package:agnts_api/src/model/document_generation.dart';
import 'package:agnts_api/src/model/document_grant.dart';
import 'package:agnts_api/src/model/document_input.dart';
import 'package:agnts_api/src/model/document_presence.dart';
import 'package:agnts_api/src/model/document_regenerate.dart';
import 'package:agnts_api/src/model/document_save.dart';
import 'package:agnts_api/src/model/document_share_input.dart';
import 'package:agnts_api/src/model/document_share_input_grants_inner.dart';
import 'package:agnts_api/src/model/document_sharing.dart';
import 'package:agnts_api/src/model/document_source_input.dart';
import 'package:agnts_api/src/model/document_source_input_filter.dart';
import 'package:agnts_api/src/model/document_summary.dart';
import 'package:agnts_api/src/model/document_ticket.dart';
import 'package:agnts_api/src/model/document_translation.dart';
import 'package:agnts_api/src/model/document_version.dart';
import 'package:agnts_api/src/model/document_viewer.dart';
import 'package:agnts_api/src/model/edit_check.dart';
import 'package:agnts_api/src/model/edit_commit_message_request.dart';
import 'package:agnts_api/src/model/edit_pull_comment_request.dart';
import 'package:agnts_api/src/model/effort_settings.dart';
import 'package:agnts_api/src/model/environment.dart';
import 'package:agnts_api/src/model/error.dart';
import 'package:agnts_api/src/model/event.dart';
import 'package:agnts_api/src/model/event_page.dart';
import 'package:agnts_api/src/model/event_summary.dart';
import 'package:agnts_api/src/model/feedback.dart';
import 'package:agnts_api/src/model/file_change.dart';
import 'package:agnts_api/src/model/finding.dart';
import 'package:agnts_api/src/model/flaky_job.dart';
import 'package:agnts_api/src/model/follow_up_count.dart';
import 'package:agnts_api/src/model/follow_up_suggestion.dart';
import 'package:agnts_api/src/model/follow_up_ticket.dart';
import 'package:agnts_api/src/model/follow_ups.dart';
import 'package:agnts_api/src/model/follow_ups_setting.dart';
import 'package:agnts_api/src/model/footprint.dart';
import 'package:agnts_api/src/model/forgot_password_request.dart';
import 'package:agnts_api/src/model/free_credits.dart';
import 'package:agnts_api/src/model/get_consent200_response.dart';
import 'package:agnts_api/src/model/get_platform_run_prompt200_response.dart';
import 'package:agnts_api/src/model/get_ticket_chat200_response.dart';
import 'package:agnts_api/src/model/git_settings.dart';
import 'package:agnts_api/src/model/google_sign_in_request.dart';
import 'package:agnts_api/src/model/grant_credits_request.dart';
import 'package:agnts_api/src/model/guard_settings.dart';
import 'package:agnts_api/src/model/guest_join.dart';
import 'package:agnts_api/src/model/guest_session.dart';
import 'package:agnts_api/src/model/history_item.dart';
import 'package:agnts_api/src/model/hour_bucket.dart';
import 'package:agnts_api/src/model/implement_input.dart';
import 'package:agnts_api/src/model/integration.dart';
import 'package:agnts_api/src/model/invite.dart';
import 'package:agnts_api/src/model/invite_preview.dart';
import 'package:agnts_api/src/model/learn_queue_item.dart';
import 'package:agnts_api/src/model/learning_period.dart';
import 'package:agnts_api/src/model/ledger_entry.dart';
import 'package:agnts_api/src/model/lesson.dart';
import 'package:agnts_api/src/model/lesson_brief.dart';
import 'package:agnts_api/src/model/lesson_count.dart';
import 'package:agnts_api/src/model/lesson_list.dart';
import 'package:agnts_api/src/model/lesson_ref.dart';
import 'package:agnts_api/src/model/link.dart';
import 'package:agnts_api/src/model/linked_commit.dart';
import 'package:agnts_api/src/model/linked_commits.dart';
import 'package:agnts_api/src/model/live_run.dart';
import 'package:agnts_api/src/model/local_branch.dart';
import 'package:agnts_api/src/model/log_auth_input.dart';
import 'package:agnts_api/src/model/log_fields.dart';
import 'package:agnts_api/src/model/log_finding.dart';
import 'package:agnts_api/src/model/log_occurrence.dart';
import 'package:agnts_api/src/model/log_override.dart';
import 'package:agnts_api/src/model/log_pattern.dart';
import 'package:agnts_api/src/model/log_push_token.dart';
import 'package:agnts_api/src/model/log_scope.dart';
import 'package:agnts_api/src/model/log_service.dart';
import 'package:agnts_api/src/model/log_source.dart';
import 'package:agnts_api/src/model/log_source_input.dart';
import 'package:agnts_api/src/model/log_source_test.dart';
import 'package:agnts_api/src/model/log_watch_settings.dart';
import 'package:agnts_api/src/model/login_request.dart';
import 'package:agnts_api/src/model/login_response.dart';
import 'package:agnts_api/src/model/mcp_status.dart';
import 'package:agnts_api/src/model/meeting.dart';
import 'package:agnts_api/src/model/meeting_action_item.dart';
import 'package:agnts_api/src/model/meeting_attendee.dart';
import 'package:agnts_api/src/model/meeting_call.dart';
import 'package:agnts_api/src/model/meeting_call_settings.dart';
import 'package:agnts_api/src/model/meeting_detail.dart';
import 'package:agnts_api/src/model/meeting_grant.dart';
import 'package:agnts_api/src/model/meeting_input.dart';
import 'package:agnts_api/src/model/meeting_invitee.dart';
import 'package:agnts_api/src/model/meeting_invitees_input.dart';
import 'package:agnts_api/src/model/meeting_invites.dart';
import 'package:agnts_api/src/model/meeting_join.dart';
import 'package:agnts_api/src/model/meeting_join_input.dart';
import 'package:agnts_api/src/model/meeting_knock.dart';
import 'package:agnts_api/src/model/meeting_live.dart';
import 'package:agnts_api/src/model/meeting_message.dart';
import 'package:agnts_api/src/model/meeting_person.dart';
import 'package:agnts_api/src/model/meeting_prefs.dart';
import 'package:agnts_api/src/model/meeting_recording.dart';
import 'package:agnts_api/src/model/meeting_rights.dart';
import 'package:agnts_api/src/model/meeting_segment.dart';
import 'package:agnts_api/src/model/meeting_session_brief.dart';
import 'package:agnts_api/src/model/meeting_session_detail.dart';
import 'package:agnts_api/src/model/meeting_session_summary.dart';
import 'package:agnts_api/src/model/meeting_settings.dart';
import 'package:agnts_api/src/model/meeting_settings_available.dart';
import 'package:agnts_api/src/model/meeting_settings_input.dart';
import 'package:agnts_api/src/model/meeting_ticket_link.dart';
import 'package:agnts_api/src/model/meeting_transcript.dart';
import 'package:agnts_api/src/model/meeting_transcript_hit.dart';
import 'package:agnts_api/src/model/meeting_usage_day.dart';
import 'package:agnts_api/src/model/member.dart';
import 'package:agnts_api/src/model/meta.dart';
import 'package:agnts_api/src/model/model_catalog.dart';
import 'package:agnts_api/src/model/model_catalog_models_inner.dart';
import 'package:agnts_api/src/model/model_catalog_modules_inner.dart';
import 'package:agnts_api/src/model/model_catalog_tiers_inner.dart';
import 'package:agnts_api/src/model/model_overrides.dart';
import 'package:agnts_api/src/model/modules_settings.dart';
import 'package:agnts_api/src/model/muse_login.dart';
import 'package:agnts_api/src/model/network_activity.dart';
import 'package:agnts_api/src/model/network_activity_dials_inner.dart';
import 'package:agnts_api/src/model/network_route.dart';
import 'package:agnts_api/src/model/network_test.dart';
import 'package:agnts_api/src/model/network_test_network.dart';
import 'package:agnts_api/src/model/network_test_tls.dart';
import 'package:agnts_api/src/model/new_pull_comment.dart';
import 'package:agnts_api/src/model/notify_settings.dart';
import 'package:agnts_api/src/model/offer_starter_rules_request.dart';
import 'package:agnts_api/src/model/pr_comment_settings.dart';
import 'package:agnts_api/src/model/pattern.dart';
import 'package:agnts_api/src/model/period_stats.dart';
import 'package:agnts_api/src/model/pipeline.dart';
import 'package:agnts_api/src/model/plane_state.dart';
import 'package:agnts_api/src/model/platform_overview.dart';
import 'package:agnts_api/src/model/platform_overview_runs_inner.dart';
import 'package:agnts_api/src/model/platform_overview_server_queue_inner.dart';
import 'package:agnts_api/src/model/platform_user.dart';
import 'package:agnts_api/src/model/platform_workspace.dart';
import 'package:agnts_api/src/model/post_review_input.dart';
import 'package:agnts_api/src/model/presence_input.dart';
import 'package:agnts_api/src/model/preview_input.dart';
import 'package:agnts_api/src/model/preview_issue.dart';
import 'package:agnts_api/src/model/preview_shot.dart';
import 'package:agnts_api/src/model/private_network.dart';
import 'package:agnts_api/src/model/private_network_ca.dart';
import 'package:agnts_api/src/model/private_network_input.dart';
import 'package:agnts_api/src/model/private_network_list.dart';
import 'package:agnts_api/src/model/private_network_saved.dart';
import 'package:agnts_api/src/model/proof.dart';
import 'package:agnts_api/src/model/proof_run.dart';
import 'package:agnts_api/src/model/proof_test.dart';
import 'package:agnts_api/src/model/public_document.dart';
import 'package:agnts_api/src/model/public_document_info.dart';
import 'package:agnts_api/src/model/public_meeting.dart';
import 'package:agnts_api/src/model/publish_review_drafts_request.dart';
import 'package:agnts_api/src/model/published_review.dart';
import 'package:agnts_api/src/model/pull_comment.dart';
import 'package:agnts_api/src/model/pull_detail.dart';
import 'package:agnts_api/src/model/pull_item.dart';
import 'package:agnts_api/src/model/pull_request.dart';
import 'package:agnts_api/src/model/pull_review_ref.dart';
import 'package:agnts_api/src/model/pull_review_settings.dart';
import 'package:agnts_api/src/model/pull_thread.dart';
import 'package:agnts_api/src/model/quality_stat.dart';
import 'package:agnts_api/src/model/question.dart';
import 'package:agnts_api/src/model/queue_status.dart';
import 'package:agnts_api/src/model/queue_status_server_queue_inner.dart';
import 'package:agnts_api/src/model/queue_status_waiting.dart';
import 'package:agnts_api/src/model/quiz_question.dart';
import 'package:agnts_api/src/model/reapply_commit_format200_response.dart';
import 'package:agnts_api/src/model/reapply_commit_format200_response_changes_inner.dart';
import 'package:agnts_api/src/model/reapply_commit_format_request.dart';
import 'package:agnts_api/src/model/red_flag.dart';
import 'package:agnts_api/src/model/register_request.dart';
import 'package:agnts_api/src/model/reject_ticket_request.dart';
import 'package:agnts_api/src/model/related_ticket.dart';
import 'package:agnts_api/src/model/relation.dart';
import 'package:agnts_api/src/model/relation_input.dart';
import 'package:agnts_api/src/model/relations.dart';
import 'package:agnts_api/src/model/remote_repository.dart';
import 'package:agnts_api/src/model/rename_ticket_branch_request.dart';
import 'package:agnts_api/src/model/replay_report.dart';
import 'package:agnts_api/src/model/replay_result.dart';
import 'package:agnts_api/src/model/replay_version.dart';
import 'package:agnts_api/src/model/reply_pull_thread_request.dart';
import 'package:agnts_api/src/model/repo_activity.dart';
import 'package:agnts_api/src/model/repo_brief.dart';
import 'package:agnts_api/src/model/repo_brief_input.dart';
import 'package:agnts_api/src/model/repo_choice.dart';
import 'package:agnts_api/src/model/repo_detect_input.dart';
import 'package:agnts_api/src/model/repo_detection.dart';
import 'package:agnts_api/src/model/repo_file.dart';
import 'package:agnts_api/src/model/repo_group.dart';
import 'package:agnts_api/src/model/repo_group_input.dart';
import 'package:agnts_api/src/model/repo_group_input_members_inner.dart';
import 'package:agnts_api/src/model/repo_group_member.dart';
import 'package:agnts_api/src/model/repo_group_ref.dart';
import 'package:agnts_api/src/model/repo_harness.dart';
import 'package:agnts_api/src/model/repo_harness_all_of_derived_coverage.dart';
import 'package:agnts_api/src/model/repo_harness_input.dart';
import 'package:agnts_api/src/model/repo_member.dart';
import 'package:agnts_api/src/model/repo_preview.dart';
import 'package:agnts_api/src/model/repo_preview_input.dart';
import 'package:agnts_api/src/model/repo_tree.dart';
import 'package:agnts_api/src/model/repository.dart';
import 'package:agnts_api/src/model/repository_input.dart';
import 'package:agnts_api/src/model/request_changes_request.dart';
import 'package:agnts_api/src/model/reset_password_request.dart';
import 'package:agnts_api/src/model/resolve_pull_thread_request.dart';
import 'package:agnts_api/src/model/result.dart';
import 'package:agnts_api/src/model/retry_ticket_request.dart';
import 'package:agnts_api/src/model/review_draft.dart';
import 'package:agnts_api/src/model/review_pull_list.dart';
import 'package:agnts_api/src/model/review_pull_row.dart';
import 'package:agnts_api/src/model/review_repo_pull409_response.dart';
import 'package:agnts_api/src/model/review_repo_pull_request.dart';
import 'package:agnts_api/src/model/review_sync.dart';
import 'package:agnts_api/src/model/reviewer.dart';
import 'package:agnts_api/src/model/reviewer_note.dart';
import 'package:agnts_api/src/model/reviewer_note_input.dart';
import 'package:agnts_api/src/model/reviewer_profile_input.dart';
import 'package:agnts_api/src/model/reviewer_stat.dart';
import 'package:agnts_api/src/model/reviewers.dart';
import 'package:agnts_api/src/model/ring_meeting_request.dart';
import 'package:agnts_api/src/model/rotate_mcp_token200_response.dart';
import 'package:agnts_api/src/model/rotate_swagger_suite_hook200_response.dart';
import 'package:agnts_api/src/model/rule.dart';
import 'package:agnts_api/src/model/rule_answers.dart';
import 'package:agnts_api/src/model/rule_answers_answers_inner.dart';
import 'package:agnts_api/src/model/rule_enforce.dart';
import 'package:agnts_api/src/model/rule_input.dart';
import 'package:agnts_api/src/model/rule_question.dart';
import 'package:agnts_api/src/model/run_benchmark_request.dart';
import 'package:agnts_api/src/model/run_history_page.dart';
import 'package:agnts_api/src/model/run_history_settings.dart';
import 'package:agnts_api/src/model/run_history_summary.dart';
import 'package:agnts_api/src/model/run_transcript.dart';
import 'package:agnts_api/src/model/run_transcript_detail.dart';
import 'package:agnts_api/src/model/run_transcript_event.dart';
import 'package:agnts_api/src/model/second_opinion.dart';
import 'package:agnts_api/src/model/secret_findings.dart';
import 'package:agnts_api/src/model/secret_findings_findings_inner.dart';
import 'package:agnts_api/src/model/send_feedback_request.dart';
import 'package:agnts_api/src/model/send_meeting_message_request.dart';
import 'package:agnts_api/src/model/set_credit_limit_request.dart';
import 'package:agnts_api/src/model/set_free_credits_request.dart';
import 'package:agnts_api/src/model/set_meeting_cohosts_request.dart';
import 'package:agnts_api/src/model/set_member_role_request.dart';
import 'package:agnts_api/src/model/set_my_module_order_request.dart';
import 'package:agnts_api/src/model/set_plane_webhook_secret_request.dart';
import 'package:agnts_api/src/model/set_slots_request.dart';
import 'package:agnts_api/src/model/set_ticket_benchmark_request.dart';
import 'package:agnts_api/src/model/set_ticket_member_request.dart';
import 'package:agnts_api/src/model/set_ticket_number_request.dart';
import 'package:agnts_api/src/model/set_user_modules_request.dart';
import 'package:agnts_api/src/model/settings.dart';
import 'package:agnts_api/src/model/ship_notes.dart';
import 'package:agnts_api/src/model/shot_ref.dart';
import 'package:agnts_api/src/model/signup_info.dart';
import 'package:agnts_api/src/model/skill_stat.dart';
import 'package:agnts_api/src/model/slow_ticket.dart';
import 'package:agnts_api/src/model/spread.dart';
import 'package:agnts_api/src/model/stage.dart';
import 'package:agnts_api/src/model/stage_models.dart';
import 'package:agnts_api/src/model/stage_spend.dart';
import 'package:agnts_api/src/model/stale_pr.dart';
import 'package:agnts_api/src/model/starter_pack.dart';
import 'package:agnts_api/src/model/step_duration.dart';
import 'package:agnts_api/src/model/swagger_auth_input.dart';
import 'package:agnts_api/src/model/swagger_operation.dart';
import 'package:agnts_api/src/model/swagger_rerun_input.dart';
import 'package:agnts_api/src/model/swagger_results.dart';
import 'package:agnts_api/src/model/swagger_security_scheme.dart';
import 'package:agnts_api/src/model/swagger_server.dart';
import 'package:agnts_api/src/model/swagger_server_variables_inner.dart';
import 'package:agnts_api/src/model/swagger_spec.dart';
import 'package:agnts_api/src/model/swagger_spec_choices_inner.dart';
import 'package:agnts_api/src/model/swagger_spec_input.dart';
import 'package:agnts_api/src/model/swagger_spec_input_login.dart';
import 'package:agnts_api/src/model/swagger_suite.dart';
import 'package:agnts_api/src/model/swagger_suite_input.dart';
import 'package:agnts_api/src/model/swagger_test_create.dart';
import 'package:agnts_api/src/model/swagger_test_view.dart';
import 'package:agnts_api/src/model/sync_jira200_response.dart';
import 'package:agnts_api/src/model/sync_plane200_response.dart';
import 'package:agnts_api/src/model/task_create.dart';
import 'package:agnts_api/src/model/task_update.dart';
import 'package:agnts_api/src/model/test_private_network_request.dart';
import 'package:agnts_api/src/model/ticket.dart';
import 'package:agnts_api/src/model/ticket_detail.dart';
import 'package:agnts_api/src/model/ticket_kind_input.dart';
import 'package:agnts_api/src/model/ticket_preview.dart';
import 'package:agnts_api/src/model/ticket_repo.dart';
import 'package:agnts_api/src/model/ticket_repo_state.dart';
import 'package:agnts_api/src/model/ticket_repos_input.dart';
import 'package:agnts_api/src/model/ticket_spend_list.dart';
import 'package:agnts_api/src/model/ticket_spend_row.dart';
import 'package:agnts_api/src/model/timeline_item.dart';
import 'package:agnts_api/src/model/token_request.dart';
import 'package:agnts_api/src/model/token_spend.dart';
import 'package:agnts_api/src/model/toolchain.dart';
import 'package:agnts_api/src/model/tracker_update.dart';
import 'package:agnts_api/src/model/transfer_workspace_request.dart';
import 'package:agnts_api/src/model/translate_input.dart';
import 'package:agnts_api/src/model/translation.dart';
import 'package:agnts_api/src/model/translation_items_inner.dart';
import 'package:agnts_api/src/model/tree_entry.dart';
import 'package:agnts_api/src/model/try_enforce_input.dart';
import 'package:agnts_api/src/model/try_enforce_result.dart';
import 'package:agnts_api/src/model/try_enforce_result_hits_inner.dart';
import 'package:agnts_api/src/model/unregister_device_request.dart';
import 'package:agnts_api/src/model/update_integration_request.dart';
import 'package:agnts_api/src/model/update_platform_feedback_request.dart';
import 'package:agnts_api/src/model/update_platform_user_request.dart';
import 'package:agnts_api/src/model/update_platform_workspace_request.dart';
import 'package:agnts_api/src/model/update_profile_request.dart';
import 'package:agnts_api/src/model/update_review_draft_request.dart';
import 'package:agnts_api/src/model/update_workspace_claude_request.dart';
import 'package:agnts_api/src/model/update_workspace_request.dart';
import 'package:agnts_api/src/model/usage.dart';
import 'package:agnts_api/src/model/usage_window.dart';
import 'package:agnts_api/src/model/user.dart';
import 'package:agnts_api/src/model/user_modules.dart';
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
        case 'AcceptAllReviewDraftsRequest':
          return AcceptAllReviewDraftsRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AcceptFollowUp':
          return AcceptFollowUp.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AcceptFollowUpResult':
          return AcceptFollowUpResult.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AcceptFollowUps':
          return AcceptFollowUps.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AcceptFollowUpsResult':
          return AcceptFollowUpsResult.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Acceptance':
          return Acceptance.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AcceptanceCriteriaInner':
          return AcceptanceCriteriaInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ActOnMeetingPersonRequest':
          return ActOnMeetingPersonRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ActionItemTicketInput':
          return ActionItemTicketInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AddReviewDraftRequest':
          return AddReviewDraftRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AddressPullCommentsRequest':
          return AddressPullCommentsRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AdminAuditEntry':
          return AdminAuditEntry.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AgentConfigFinding':
          return AgentConfigFinding.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AgentConfigScan':
          return AgentConfigScan.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Analysis':
          return Analysis.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AnalysisAcceptanceInner':
          return AnalysisAcceptanceInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AnalysisRepro':
          return AnalysisRepro.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AnalysisReuseInner':
          return AnalysisReuseInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AnalysisTestPlanInner':
          return AnalysisTestPlanInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Analytics':
          return Analytics.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AnalyticsCI':
          return AnalyticsCI.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AnalyticsDelivery':
          return AnalyticsDelivery.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AnalyticsInsightsInner':
          return AnalyticsInsightsInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AnalyticsLearning':
          return AnalyticsLearning.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AnalyticsModelsInner':
          return AnalyticsModelsInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AnalyticsReposInner':
          return AnalyticsReposInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AnswerDraft':
          return AnswerDraft.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AnswerDraftRequest':
          return AnswerDraftRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AnswerDraftRequestAnswersInner':
          return AnswerDraftRequestAnswersInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AnswerMeetingRequest':
          return AnswerMeetingRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AnswersRequest':
          return AnswersRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AnswersRequestAnswersInner':
          return AnswersRequestAnswersInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ApiAuthKind':
          
          
        case 'ApiCase':
          return ApiCase.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ApiCounts':
          return ApiCounts.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ApiExchange':
          return ApiExchange.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ApiRequestRow':
          return ApiRequestRow.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Approach':
          return Approach.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ApproveTicketRequest':
          return ApproveTicketRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssistantAction':
          return AssistantAction.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssistantAsk':
          return AssistantAsk.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssistantConversation':
          return AssistantConversation.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssistantLanguage':
          
          
        case 'AssistantLink':
          return AssistantLink.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssistantMessage':
          return AssistantMessage.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssistantRated':
          return AssistantRated.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssistantRating':
          return AssistantRating.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssistantStats':
          return AssistantStats.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssistantStatsActions':
          return AssistantStatsActions.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssistantStatsVersionsInner':
          return AssistantStatsVersionsInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssistantTranscript':
          return AssistantTranscript.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AttachCodeTicketRequest':
          return AttachCodeTicketRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Attachment':
          return Attachment.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BeginLoginTotp200Response':
          return BeginLoginTotp200Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BeginLoginTotpRequest':
          return BeginLoginTotpRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BeginTotp200Response':
          return BeginTotp200Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BenchmarkRun':
          return BenchmarkRun.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Billing':
          return Billing.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BillingPrices':
          return BillingPrices.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Blocker':
          return Blocker.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Branch':
          return Branch.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BranchCommit':
          return BranchCommit.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CI':
          
          
        case 'CIDay':
          return CIDay.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CIFailure':
          return CIFailure.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CIOccurrence':
          return CIOccurrence.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CIPeriod':
          return CIPeriod.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CISettings':
          return CISettings.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CIStatus':
          
          
        case 'CIWatch':
          return CIWatch.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Capacity':
          return Capacity.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ChangePasswordRequest':
          return ChangePasswordRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ChatMode':
          
          
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
        case 'CodeApproval':
          return CodeApproval.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CodeHandoff':
          return CodeHandoff.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CodeReview':
          return CodeReview.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CodeRouted':
          
          
        case 'CodeSend':
          return CodeSend.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CodeSendAnswersInner':
          return CodeSendAnswersInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CodeStart':
          return CodeStart.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CodeTicket':
          return CodeTicket.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CodeTimeline':
          return CodeTimeline.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Commit':
          return Commit.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CommitDetail':
          return CommitDetail.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CommitPull':
          return CommitPull.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CommitTicket':
          return CommitTicket.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ConfirmTotpRequest':
          return ConfirmTotpRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ConnectIntegrationRequest':
          return ConnectIntegrationRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ConnectResult':
          return ConnectResult.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ContinueTicketRequest':
          return ContinueTicketRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Coverage':
          return Coverage.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CoverageConfig':
          return CoverageConfig.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CoverageFilesInner':
          return CoverageFilesInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CoverageFilesInnerUncoveredInner':
          return CoverageFilesInnerUncoveredInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateInvite201Response':
          return CreateInvite201Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateInviteRequest':
          return CreateInviteRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreatePlatformAdminRequest':
          return CreatePlatformAdminRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateTicketDocumentRequest':
          return CreateTicketDocumentRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateWorkspaceRequest':
          return CreateWorkspaceRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreditUsage':
          return CreditUsage.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Dashboard':
          return Dashboard.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DashboardCounts':
          return DashboardCounts.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DayStat':
          return DayStat.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DecideCodeApprovalRequest':
          return DecideCodeApprovalRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DecideConsent200Response':
          return DecideConsent200Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DecideConsentRequest':
          return DecideConsentRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DeleteWorkspaceRequest':
          return DeleteWorkspaceRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DeliveryDay':
          return DeliveryDay.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DeliveryPeriod':
          return DeliveryPeriod.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DeployRepoRequest':
          return DeployRepoRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DeviceRegistration':
          return DeviceRegistration.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DisableTotpRequest':
          return DisableTotpRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Document':
          return Document.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DocumentAccess':
          
          
        case 'DocumentAllOfDerivedFrom':
          return DocumentAllOfDerivedFrom.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DocumentComment':
          return DocumentComment.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DocumentCommentInput':
          return DocumentCommentInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DocumentCommentPatch':
          return DocumentCommentPatch.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DocumentConflict':
          return DocumentConflict.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DocumentGeneration':
          return DocumentGeneration.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DocumentGrant':
          return DocumentGrant.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DocumentInput':
          return DocumentInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DocumentKind':
          
          
        case 'DocumentPresence':
          return DocumentPresence.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DocumentRegenerate':
          return DocumentRegenerate.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DocumentSave':
          return DocumentSave.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DocumentShareInput':
          return DocumentShareInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DocumentShareInputGrantsInner':
          return DocumentShareInputGrantsInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DocumentSharing':
          return DocumentSharing.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DocumentSourceInput':
          return DocumentSourceInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DocumentSourceInputFilter':
          return DocumentSourceInputFilter.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DocumentSummary':
          return DocumentSummary.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DocumentTicket':
          return DocumentTicket.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DocumentTranslation':
          return DocumentTranslation.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DocumentVersion':
          return DocumentVersion.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DocumentViewer':
          return DocumentViewer.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EditCheck':
          return EditCheck.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EditCommitMessageRequest':
          return EditCommitMessageRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EditPullCommentRequest':
          return EditPullCommentRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EffortSettings':
          return EffortSettings.fromJson(value as Map<String, dynamic>) as ReturnType;
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
        case 'FlakyJob':
          return FlakyJob.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'FollowUpCount':
          return FollowUpCount.fromJson(value as Map<String, dynamic>) as ReturnType;
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
        case 'FreeCredits':
          return FreeCredits.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GetConsent200Response':
          return GetConsent200Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GetPlatformRunPrompt200Response':
          return GetPlatformRunPrompt200Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GetTicketChat200Response':
          return GetTicketChat200Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GitSettings':
          return GitSettings.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GoogleSignInRequest':
          return GoogleSignInRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GrantCreditsRequest':
          return GrantCreditsRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GuardHook':
          
          
        case 'GuardProfile':
          
          
        case 'GuardSettings':
          return GuardSettings.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GuestJoin':
          return GuestJoin.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GuestSession':
          return GuestSession.fromJson(value as Map<String, dynamic>) as ReturnType;
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
        case 'LearningPeriod':
          return LearningPeriod.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LedgerEntry':
          return LedgerEntry.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Lesson':
          return Lesson.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LessonBrief':
          return LessonBrief.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LessonCategory':
          
          
        case 'LessonCount':
          return LessonCount.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LessonLevel':
          
          
        case 'LessonList':
          return LessonList.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LessonRef':
          return LessonRef.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Link':
          return Link.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LinkedCommit':
          return LinkedCommit.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LinkedCommits':
          return LinkedCommits.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LiveRun':
          return LiveRun.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LocalBranch':
          return LocalBranch.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LogAuthInput':
          return LogAuthInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LogFields':
          return LogFields.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LogFinding':
          return LogFinding.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LogFindingStatus':
          
          
        case 'LogMode':
          
          
        case 'LogOccurrence':
          return LogOccurrence.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LogOverride':
          return LogOverride.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LogPattern':
          return LogPattern.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LogPushToken':
          return LogPushToken.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LogScope':
          return LogScope.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LogService':
          return LogService.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LogSeverity':
          
          
        case 'LogSource':
          return LogSource.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LogSourceInput':
          return LogSourceInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LogSourceTest':
          return LogSourceTest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LogWatchSettings':
          return LogWatchSettings.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LoginRequest':
          return LoginRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LoginResponse':
          return LoginResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'McpStatus':
          return McpStatus.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Meeting':
          return Meeting.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MeetingActionItem':
          return MeetingActionItem.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MeetingAttendee':
          return MeetingAttendee.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MeetingCall':
          return MeetingCall.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MeetingCallSettings':
          return MeetingCallSettings.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MeetingDetail':
          return MeetingDetail.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MeetingGrant':
          return MeetingGrant.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MeetingInput':
          return MeetingInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MeetingInvitee':
          return MeetingInvitee.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MeetingInviteesInput':
          return MeetingInviteesInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MeetingInvites':
          return MeetingInvites.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MeetingJoin':
          return MeetingJoin.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MeetingJoinInput':
          return MeetingJoinInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MeetingKnock':
          return MeetingKnock.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MeetingLive':
          return MeetingLive.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MeetingMessage':
          return MeetingMessage.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MeetingNotesStatus':
          
          
        case 'MeetingPerson':
          return MeetingPerson.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MeetingPrefs':
          return MeetingPrefs.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MeetingRecording':
          return MeetingRecording.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MeetingRights':
          return MeetingRights.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MeetingSegment':
          return MeetingSegment.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MeetingSessionBrief':
          return MeetingSessionBrief.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MeetingSessionDetail':
          return MeetingSessionDetail.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MeetingSessionSummary':
          return MeetingSessionSummary.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MeetingSettings':
          return MeetingSettings.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MeetingSettingsAvailable':
          return MeetingSettingsAvailable.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MeetingSettingsInput':
          return MeetingSettingsInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MeetingTicketLink':
          return MeetingTicketLink.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MeetingTranscript':
          return MeetingTranscript.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MeetingTranscriptHit':
          return MeetingTranscriptHit.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MeetingUsageDay':
          return MeetingUsageDay.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Member':
          return Member.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Meta':
          return Meta.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ModelCatalog':
          return ModelCatalog.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ModelCatalogModelsInner':
          return ModelCatalogModelsInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ModelCatalogModulesInner':
          return ModelCatalogModulesInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ModelCatalogTiersInner':
          return ModelCatalogTiersInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ModelOverrides':
          return ModelOverrides.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Module':
          
          
        case 'ModulesSettings':
          return ModulesSettings.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MuseLogin':
          return MuseLogin.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'NetworkActivity':
          return NetworkActivity.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'NetworkActivityDialsInner':
          return NetworkActivityDialsInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'NetworkRoute':
          return NetworkRoute.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'NetworkTest':
          return NetworkTest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'NetworkTestNetwork':
          return NetworkTestNetwork.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'NetworkTestTls':
          return NetworkTestTls.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'NewPullComment':
          return NewPullComment.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'NotifySettings':
          return NotifySettings.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'OfferStarterRulesRequest':
          return OfferStarterRulesRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PRCommentSettings':
          return PRCommentSettings.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Pattern':
          return Pattern.fromJson(value as Map<String, dynamic>) as ReturnType;
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
        case 'PostReviewInput':
          return PostReviewInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PresenceInput':
          return PresenceInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PreviewInput':
          return PreviewInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PreviewIssue':
          return PreviewIssue.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PreviewShot':
          return PreviewShot.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PrivateNetwork':
          return PrivateNetwork.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PrivateNetworkCa':
          return PrivateNetworkCa.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PrivateNetworkInput':
          return PrivateNetworkInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PrivateNetworkList':
          return PrivateNetworkList.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PrivateNetworkSaved':
          return PrivateNetworkSaved.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Proof':
          return Proof.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ProofRun':
          return ProofRun.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ProofTest':
          return ProofTest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PublicDocument':
          return PublicDocument.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PublicDocumentInfo':
          return PublicDocumentInfo.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PublicMeeting':
          return PublicMeeting.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PublishReviewDraftsRequest':
          return PublishReviewDraftsRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PublishedReview':
          return PublishedReview.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PullComment':
          return PullComment.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PullDetail':
          return PullDetail.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PullItem':
          return PullItem.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PullRequest':
          return PullRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PullReviewRef':
          return PullReviewRef.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PullReviewSettings':
          return PullReviewSettings.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PullThread':
          return PullThread.fromJson(value as Map<String, dynamic>) as ReturnType;
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
        case 'ReapplyCommitFormat200Response':
          return ReapplyCommitFormat200Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReapplyCommitFormat200ResponseChangesInner':
          return ReapplyCommitFormat200ResponseChangesInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReapplyCommitFormatRequest':
          return ReapplyCommitFormatRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
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
        case 'RenameTicketBranchRequest':
          return RenameTicketBranchRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReplayReport':
          return ReplayReport.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReplayResult':
          return ReplayResult.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReplayVersion':
          return ReplayVersion.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReplyPullThreadRequest':
          return ReplyPullThreadRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RepoActivity':
          return RepoActivity.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RepoBrief':
          return RepoBrief.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RepoBriefInput':
          return RepoBriefInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RepoChoice':
          return RepoChoice.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RepoDetectInput':
          return RepoDetectInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RepoDetection':
          return RepoDetection.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RepoFile':
          return RepoFile.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RepoGroup':
          return RepoGroup.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RepoGroupInput':
          return RepoGroupInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RepoGroupInputMembersInner':
          return RepoGroupInputMembersInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RepoGroupMember':
          return RepoGroupMember.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RepoGroupRef':
          return RepoGroupRef.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RepoHarness':
          return RepoHarness.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RepoHarnessAllOfDerivedCoverage':
          return RepoHarnessAllOfDerivedCoverage.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RepoHarnessInput':
          return RepoHarnessInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RepoMember':
          return RepoMember.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RepoPreview':
          return RepoPreview.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RepoPreviewInput':
          return RepoPreviewInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RepoTree':
          return RepoTree.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Repository':
          return Repository.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RepositoryInput':
          return RepositoryInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RequestChangesRequest':
          return RequestChangesRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ResetPasswordRequest':
          return ResetPasswordRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ResolvePullThreadRequest':
          return ResolvePullThreadRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Result':
          return Result.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RetryTicketRequest':
          return RetryTicketRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReviewDraft':
          return ReviewDraft.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReviewPullList':
          return ReviewPullList.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReviewPullRow':
          return ReviewPullRow.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReviewRepoPull409Response':
          return ReviewRepoPull409Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReviewRepoPullRequest':
          return ReviewRepoPullRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
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
        case 'ReviewerStat':
          return ReviewerStat.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Reviewers':
          return Reviewers.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RingMeetingRequest':
          return RingMeetingRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RotateMcpToken200Response':
          return RotateMcpToken200Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RotateSwaggerSuiteHook200Response':
          return RotateSwaggerSuiteHook200Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Rule':
          return Rule.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RuleAnswers':
          return RuleAnswers.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RuleAnswersAnswersInner':
          return RuleAnswersAnswersInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RuleEnforce':
          return RuleEnforce.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RuleInput':
          return RuleInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RuleKind':
          
          
        case 'RuleQuestion':
          return RuleQuestion.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RuleStatus':
          
          
        case 'RunBenchmarkRequest':
          return RunBenchmarkRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RunHistoryPage':
          return RunHistoryPage.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RunHistorySettings':
          return RunHistorySettings.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RunHistorySummary':
          return RunHistorySummary.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RunTranscript':
          return RunTranscript.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RunTranscriptDetail':
          return RunTranscriptDetail.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RunTranscriptEvent':
          return RunTranscriptEvent.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SecondOpinion':
          return SecondOpinion.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SecretFindings':
          return SecretFindings.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SecretFindingsFindingsInner':
          return SecretFindingsFindingsInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SendFeedbackRequest':
          return SendFeedbackRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SendMeetingMessageRequest':
          return SendMeetingMessageRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SetCreditLimitRequest':
          return SetCreditLimitRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SetFreeCreditsRequest':
          return SetFreeCreditsRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SetMeetingCohostsRequest':
          return SetMeetingCohostsRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SetMemberRoleRequest':
          return SetMemberRoleRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SetMyModuleOrderRequest':
          return SetMyModuleOrderRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SetPlaneWebhookSecretRequest':
          return SetPlaneWebhookSecretRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SetSlotsRequest':
          return SetSlotsRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SetTicketBenchmarkRequest':
          return SetTicketBenchmarkRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SetTicketMemberRequest':
          return SetTicketMemberRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SetTicketNumberRequest':
          return SetTicketNumberRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SetUserModulesRequest':
          return SetUserModulesRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Settings':
          return Settings.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ShipNotes':
          return ShipNotes.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ShotRef':
          return ShotRef.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SignupInfo':
          return SignupInfo.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SkillStat':
          return SkillStat.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SlowTicket':
          return SlowTicket.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Spread':
          return Spread.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Stage':
          return Stage.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'StageModels':
          return StageModels.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'StageSpend':
          return StageSpend.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'StalePR':
          return StalePR.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'StarterPack':
          return StarterPack.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'StepDuration':
          return StepDuration.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SwaggerAuthInput':
          return SwaggerAuthInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SwaggerOperation':
          return SwaggerOperation.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SwaggerRerunInput':
          return SwaggerRerunInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SwaggerResults':
          return SwaggerResults.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SwaggerSecurityScheme':
          return SwaggerSecurityScheme.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SwaggerServer':
          return SwaggerServer.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SwaggerServerVariablesInner':
          return SwaggerServerVariablesInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SwaggerSpec':
          return SwaggerSpec.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SwaggerSpecChoicesInner':
          return SwaggerSpecChoicesInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SwaggerSpecInput':
          return SwaggerSpecInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SwaggerSpecInputLogin':
          return SwaggerSpecInputLogin.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SwaggerSuite':
          return SwaggerSuite.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SwaggerSuiteInput':
          return SwaggerSuiteInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SwaggerTestCreate':
          return SwaggerTestCreate.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SwaggerTestView':
          return SwaggerTestView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SyncJira200Response':
          return SyncJira200Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SyncPlane200Response':
          return SyncPlane200Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TaskCreate':
          return TaskCreate.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TaskUpdate':
          return TaskUpdate.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TestPrivateNetworkRequest':
          return TestPrivateNetworkRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
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
        case 'TicketRepoState':
          return TicketRepoState.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TicketReposInput':
          return TicketReposInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TicketSpendList':
          return TicketSpendList.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TicketSpendRow':
          return TicketSpendRow.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TicketState':
          
          
        case 'TimelineItem':
          return TimelineItem.fromJson(value as Map<String, dynamic>) as ReturnType;
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
          
          
        case 'TreeEntry':
          return TreeEntry.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TryEnforceInput':
          return TryEnforceInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TryEnforceResult':
          return TryEnforceResult.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TryEnforceResultHitsInner':
          return TryEnforceResultHitsInner.fromJson(value as Map<String, dynamic>) as ReturnType;
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
        case 'UpdateReviewDraftRequest':
          return UpdateReviewDraftRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
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
        case 'UserModules':
          return UserModules.fromJson(value as Map<String, dynamic>) as ReturnType;
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