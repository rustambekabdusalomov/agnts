# agnts_api.model.TaskCreate

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**repoId** | **int** | Omit for a task without a repository (report kinds or auto) | [optional] 
**repoIds** | **List&lt;int&gt;** | Several repositories instead of repoId; the first is the primary. Give one of repoId, repoIds and groupId. | [optional] 
**groupId** | **int** | A repository group: the task works in its repositories (copied now) | [optional] 
**kind** | [**TicketKindChoice**](TicketKindChoice.md) |  | [optional] 
**title** | **String** |  | 
**description** | **String** |  | [optional] 
**ticketNumber** | **String** | The team's number for the work (AMANAT-2288), used in branch and commit names | [optional] 
**priority** | **String** |  | 
**afterApprove** | **String** |  | 
**start** | **String** | ask = analyse and ask first, code = no questions, queue = keep until started | 
**followUps** | [**FollowUpsMode**](FollowUpsMode.md) |  | [optional] 
**attachments** | **List&lt;int&gt;** | Uploads to attach to the description | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


