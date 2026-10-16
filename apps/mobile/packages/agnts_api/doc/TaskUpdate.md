# agnts_api.model.TaskUpdate

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**title** | **String** |  | [optional] 
**ticketNumber** | **String** | The team's number for the work (AMANAT-2288), used in branch and commit names; empty clears it, absent keeps it | [optional] 
**description** | **String** |  | [optional] 
**priority** | **String** |  | [optional] 
**afterApprove** | **String** |  | [optional] 
**kind** | [**TicketKindChoice**](TicketKindChoice.md) |  | [optional] 
**attachments** | **List&lt;int&gt;** | The files the description should have: the task's files to keep and new uploads. Left out keeps them; files not listed are deleted. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


