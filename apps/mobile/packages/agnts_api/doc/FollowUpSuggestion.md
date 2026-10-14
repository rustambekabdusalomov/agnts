# agnts_api.model.FollowUpSuggestion

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | 
**source_** | **String** | The run that suggested it; manual = made from a review finding | 
**type** | **String** | How it serves the parent ticket | 
**revision** | **int** | The parent's revision when it was suggested | 
**title** | **String** |  | 
**description** | **String** |  | 
**serves** | **String** | How it helps finish the parent ticket | 
**kind** | [**TicketKind**](TicketKind.md) |  | 
**priority** | **String** |  | 
**status** | **String** |  | 
**ready** | **bool** | A ticket can be made from it now (open, and the parent is done unless the analysis suggested it) | 
**after** | **List&lt;int&gt;** | Ids of sibling suggestions that must land first; once both are tickets, this one depends on them | [optional] 
**childKey** | **String** | The ticket made from it | [optional] 
**repoIds** | **List&lt;int&gt;** | The parent's repositories it is about; absent for all of them | [optional] 
**decidedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


