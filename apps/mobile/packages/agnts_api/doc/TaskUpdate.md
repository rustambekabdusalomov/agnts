# agnts_api.model.TaskUpdate

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**title** | **String** |  | [optional] 
**description** | **String** |  | [optional] 
**priority** | **String** |  | [optional] 
**afterApprove** | **String** |  | [optional] 
**kind** | [**TicketKindChoice**](TicketKindChoice.md) |  | [optional] 
**attachments** | **List&lt;int&gt;** | The files the description should have: the task's files to keep and new uploads. Left out keeps them; files not listed are deleted. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


