# agnts_api.model.Repository

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | 
**name** | **String** |  | 
**kind** | **String** | jira when the repository has a Jira project key, else side. Every repository takes side-project tasks. | 
**provider** | **String** |  | 
**cloneUrl** | **String** |  | 
**defaultBranch** | **String** |  | 
**buildCmd** | **String** |  | 
**lintCmd** | **String** |  | 
**testCmd** | **String** |  | 
**branchPrefix** | **String** |  | 
**taskPrefix** | **String** |  | 
**instructions** | **String** | Extra instructions added to every prompt | 
**jiraProject** | **String** |  | 
**claudeMd** | **String** |  | 
**openTickets** | **int** |  | 
**deployWorkflow** | **String** |  | [optional] 
**archivedAt** | [**DateTime**](DateTime.md) | Set while the repository is archived | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


