# agnts_api.model.ReplayVersion

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**promptVersion** | **String** |  | 
**model** | **String** | The coding model of the replays | [optional] 
**replays** | **int** |  | 
**merged** | **int** | Replays scored against what the original merged as | [optional] 
**avgLineRecall** | **num** | Average share of the merged change's added lines the replays add too; absent when none was scored against a merge | [optional] 
**originalLineRecall** | **num** | The same for the originals' own changes, to compare with | [optional] 
**checksPassed** | **int** |  | 
**reviewed** | **int** | Replays agnts's code review read | 
**looksGood** | **int** | Reviews that found nothing to block | 
**avgOverlap** | **num** | Average Jaccard index of the changed files, replay against original | 
**avgRecall** | **num** | Average share of the original's files the replay changed too | 
**avgTurns** | **num** |  | 
**avgCostUsd** | **num** |  | 
**originalTurns** | **num** | Average turns of the originals, for comparison | 
**originalCostUsd** | **num** |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


