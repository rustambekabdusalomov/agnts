# agnts_api.model.ReplayVersion

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**promptVersion** | **String** |  | 
**replays** | **int** |  | 
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


