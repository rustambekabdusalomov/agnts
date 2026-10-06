# agnts_api.model.TaskCreate

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**repoId** | **int** | Omit for a task without a repository (report kinds or auto) | [optional] 
**kind** | [**TicketKindChoice**](TicketKindChoice.md) |  | [optional] 
**title** | **String** |  | 
**description** | **String** |  | [optional] 
**priority** | **String** |  | 
**afterApprove** | **String** |  | 
**start** | **String** | ask = analyse and ask first, code = no questions, queue = keep until started | 
**followUps** | [**FollowUpsMode**](FollowUpsMode.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


