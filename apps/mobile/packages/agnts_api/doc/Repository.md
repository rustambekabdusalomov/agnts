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
**kind** | **String** | jira when the repository has a Jira project key, plane when it has only a Plane project, else side. Every repository takes side-project tasks. | 
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
**planeProject** | **String** | Plane project identifier (WEB in WEB-123); empty when not linked | [optional] 
**claudeMd** | **String** |  | 
**openTickets** | **int** |  | 
**deployWorkflow** | **String** |  | [optional] 
**archivedAt** | [**DateTime**](DateTime.md) | Set while the repository is archived | [optional] 
**preview** | [**RepoPreview**](RepoPreview.md) |  | [optional] 
**stack** | **String** | Toolchain names, comma-separated (go,node) | [optional] 
**toolchains** | [**List&lt;Toolchain&gt;**](Toolchain.md) | Installed into every run container | [optional] 
**toolchainsOverride** | **bool** | Set by a person; detection leaves them alone | [optional] 
**toolchainsDetectedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**toolchainNotes** | **List&lt;String&gt;** | What detection could not handle | [optional] 
**runnerImage** | **String** | Custom runner image (built FROM agnts-runner); empty uses the default | [optional] 
**memoryMb** | **int** | Run container memory; 0 uses the server default | [optional] 
**buildEnvSet** | **bool** |  | [optional] 
**buildEnvNames** | **List&lt;String&gt;** | Names of the build environment variables; the values are never returned | [optional] 
**harness** | [**RepoHarness**](RepoHarness.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


