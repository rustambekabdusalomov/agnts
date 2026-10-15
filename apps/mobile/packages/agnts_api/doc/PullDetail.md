# agnts_api.model.PullDetail

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**repoId** | **int** |  | 
**repoName** | **String** |  | 
**provider** | **String** |  | 
**pull** | [**PullItem**](PullItem.md) |  | 
**body** | **String** | The description, Markdown | [optional] 
**login** | **String** | The git host token's user: who comments made here appear from | [optional] 
**files** | [**List&lt;FileChange&gt;**](FileChange.md) |  | 
**filesError** | **String** | Why the files could not be read | [optional] 
**ticketKey** | **String** |  | [optional] 
**own** | **bool** |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


