# agnts_api.model.RepositoryInput

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**name** | **String** |  | 
**kind** | **String** | Ignored; derived from jiraProject and planeProject. | [optional] 
**cloneUrl** | **String** |  | 
**defaultBranch** | **String** |  | [optional] 
**buildCmd** | **String** |  | [optional] 
**lintCmd** | **String** |  | [optional] 
**testCmd** | **String** |  | [optional] 
**branchPrefix** | **String** |  | [optional] 
**taskPrefix** | **String** |  | [optional] 
**instructions** | **String** |  | [optional] 
**jiraProject** | **String** |  | [optional] 
**planeProject** | **String** |  | [optional] 
**deployWorkflow** | **String** | GitHub workflow file run by Deploy, e.g. deploy.yml | [optional] 
**preview** | [**RepoPreviewInput**](RepoPreviewInput.md) |  | [optional] 
**toolchains** | [**List&lt;Toolchain&gt;**](Toolchain.md) | Absent keeps the stored list | [optional] 
**toolchainsOverride** | **bool** | true: these toolchains were set by hand; detection keeps them | [optional] 
**runnerImage** | **String** |  | [optional] 
**memoryMb** | **int** |  | [optional] 
**buildEnv** | **String** | KEY=value lines given to every run (registry tokens); replaces the stored one, \"\" clears it, absent keeps it | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


