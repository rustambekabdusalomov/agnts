# agnts_api.model.AssistantStats

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**days** | **int** |  | 
**questions** | **int** |  | 
**answered** | **int** |  | 
**failed** | **int** |  | 
**people** | **int** | How many people asked | 
**medianMs** | **int** |  | 
**p90Ms** | **int** |  | 
**medianStartMs** | **int** | Opening (or reusing) the container, median | 
**medianSnapshotMs** | **int** | Reading the workspace, median | 
**medianClaudeMs** | **int** | The Claude Code run, median | 
**warm** | **int** | Answers that reused the container kept from the last one | 
**up** | **int** |  | 
**down** | **int** |  | 
**tokens** | **int** |  | 
**costUsd** | **double** |  | 
**actions** | [**AssistantStatsActions**](AssistantStatsActions.md) |  | 
**versions** | [**List&lt;AssistantStatsVersionsInner&gt;**](AssistantStatsVersionsInner.md) | Per prompt version, newest first | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


