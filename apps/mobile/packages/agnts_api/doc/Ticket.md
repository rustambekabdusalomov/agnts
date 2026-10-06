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
**repoId** | **int** |  | [optional] 
**title** | **String** |  | 
**description** | **String** |  | 
**priority** | **String** |  | 
**state** | [**TicketState**](TicketState.md) |  | 
**resumeState** | [**TicketState**](TicketState.md) |  | [optional] 
**revision** | **int** |  | 
**turns** | **int** |  | 
**branch** | **String** |  | 
**prNumber** | **int** |  | [optional] 
**prUrl** | **String** |  | 
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
**learnState** | **String** | The learn run after push; pending also while it runs | [optional] 
**reviewState** | **String** | The code review agnts runs beside the human review | [optional] 
**spend** | [**TokenSpend**](TokenSpend.md) |  | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


