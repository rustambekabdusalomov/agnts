# agnts_api.model.RepositoryInput

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**name** | **String** |  | 
**kind** | **String** | Ignored; derived from jiraProject. | [optional] 
**cloneUrl** | **String** |  | 
**defaultBranch** | **String** |  | [optional] 
**buildCmd** | **String** |  | [optional] 
**lintCmd** | **String** |  | [optional] 
**testCmd** | **String** |  | [optional] 
**branchPrefix** | **String** |  | [optional] 
**taskPrefix** | **String** |  | [optional] 
**instructions** | **String** |  | [optional] 
**jiraProject** | **String** |  | [optional] 
**deployWorkflow** | **String** | GitHub workflow file run by Deploy, e.g. deploy.yml | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


