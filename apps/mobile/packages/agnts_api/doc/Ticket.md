# agnts_api.model.Ticket

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**key** | **String** |  | 
**source_** | **String** |  | 
**repoId** | **int** | The primary repository; repos lists all of them | [optional] 
**repos** | [**List&lt;TicketRepoState&gt;**](TicketRepoState.md) | Every repository the ticket works in, the primary first, with its branch and pull request | [optional] 
**group** | [**RepoGroupRef**](RepoGroupRef.md) |  | [optional] 
**partlyMerged** | **bool** | Some pull requests merged and at least one closed without a merge | [optional] 
**title** | **String** |  | 
**description** | **String** |  | 
**priority** | **String** |  | 
**state** | [**TicketState**](TicketState.md) |  | 
**resumeState** | [**TicketState**](TicketState.md) |  | [optional] 
**revision** | **int** |  | 
**replayOf** | **String** | For a replay: the done ticket it re-runs. Replays are never pushed. | [optional] 
**turns** | **int** |  | 
**branch** | **String** | The primary repository's branch (see repos) | 
**headSha** | **String** | The reviewed commit: the branch head agnts committed (in the primary repository; see repos), or for a pull request review the head agnts reviewed | [optional] 
**prNumber** | **int** | The primary repository's pull request (see repos) | [optional] 
**prUrl** | **String** | The primary repository's pull request (see repos) | 
**ciFixes** | **int** | Rounds a red CI check sent the pull request back to coding | [optional] 
**assignees** | **List&lt;String&gt;** | Git host usernames the pull request is (or will be) assigned to | [optional] 
**afterApprove** | **String** |  | [optional] 
**held** | **bool** | Kept in the queue until started | [optional] 
**askFirst** | **bool** |  | [optional] 
**kind** | [**TicketKind**](TicketKind.md) |  | 
**kindAuto** | **bool** | agnts picks the kind; the analysis may still change it | 
**postReport** | **bool** | The approved report is posted to the tracker issue | [optional] 
**parentKey** | **String** | The plan or bug investigation this ticket implements | [optional] 
**followUpOf** | **String** | The ticket that suggested this one as a follow-up | [optional] 
**suggestFollowUps** | [**FollowUpsMode**](FollowUpsMode.md) |  | [optional] 
**openSuggestions** | **int** | Follow-up suggestions waiting for a decision | [optional] 
**blockedBy** | [**List&lt;Blocker&gt;**](Blocker.md) | The tickets holding this one's coding back right now (it is in coding with no commit yet). Absent when nothing does. | [optional] 
**repoName** | **String** |  | [optional] 
**models** | [**ModelOverrides**](ModelOverrides.md) |  | [optional] 
**since** | [**DateTime**](DateTime.md) | When the ticket entered its current state | [optional] 
**stopReason** | **String** | Why it failed or paused | [optional] 
**mergedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**pull** | [**PullRequest**](PullRequest.md) |  | [optional] 
**trackerUpdate** | [**TrackerUpdate**](TrackerUpdate.md) |  | [optional] 
**learnState** | **String** | The learn run after push; pending also while it runs | [optional] 
**reviewState** | **String** | The code review agnts runs beside the human review | [optional] 
**previewState** | **String** | The screenshots agnts takes beside the human review | [optional] 
**previewCompare** | **bool** | Previews of this ticket also capture the default branch (before shots) | [optional] 
**canPreview** | **bool** | The ticket's repository has a preview command | [optional] 
**spend** | [**TokenSpend**](TokenSpend.md) |  | [optional] 
**waitReason** | [**WaitReason**](WaitReason.md) |  | [optional] 
**waitMessage** | **String** | Why it waits, in a sentence | [optional] 
**queuedAt** | [**DateTime**](DateTime.md) | When it started waiting for a worker | [optional] 
**memberId** | **int** | Whose ticket it is (per-member Claude mode runs on their account) | [optional] 
**member** | **String** | The member's username | [optional] 
**createdBy** | **String** | Who created it; absent for webhooks and agnts | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


