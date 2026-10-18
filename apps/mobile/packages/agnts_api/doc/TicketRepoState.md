# agnts_api.model.TicketRepoState

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**repoId** | **int** |  | 
**repoName** | **String** |  | 
**role** | **String** | Its role in the group, as people named it (backend, web) | 
**folder** | **String** | Its folder in the run, /workspace/<folder>; empty when the ticket has one repository | 
**branch** | **String** |  | 
**headSha** | **String** |  | 
**prNumber** | **int** |  | [optional] 
**prUrl** | **String** |  | 
**ciFixes** | **int** | Rounds a red CI check on its pull request sent the ticket back to coding | 
**state** | **String** | pending = not pushed yet; unchanged = the work did not change it (no pull request); pushed; merged; dropped = its pull request was closed without a merge | 
**mergedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**closedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**pushError** | **String** | Why its last push failed; a retry pushes it again | [optional] 
**canRenameBranch** | **bool** | Its branch was never pushed and can still be renamed (ticket detail only) | [optional] 
**commits** | [**List&lt;BranchCommit&gt;**](BranchCommit.md) | The commits agnts made on its branch whose messages can still change (editCommitMessage), newest first (ticket detail only) | [optional] 
**files** | **int** | Files its change touches | 
**archived** | **bool** | The repository is archived | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


