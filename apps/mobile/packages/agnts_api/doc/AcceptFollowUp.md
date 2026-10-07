# agnts_api.model.AcceptFollowUp

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | 
**target** | **String** | local = an agnts task (default), jira = a new issue in the Jira project, plane = a new work item in the Plane project | [optional] 
**title** | **String** |  | [optional] 
**description** | **String** |  | [optional] 
**kind** | [**TicketKind**](TicketKind.md) |  | [optional] 
**priority** | **String** |  | [optional] 
**repoId** | **int** | Defaults to the parent ticket's repository | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


