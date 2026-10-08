# agnts_api.model.QualityStat

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**promptVersion** | **String** | Empty for runs from before versions were recorded | 
**tickets** | **int** | First coding run in the period | 
**reachedReview** | **int** |  | 
**done** | **int** |  | 
**firstTry** | **int** | Done without a person asking for changes | 
**rejected** | **int** |  | 
**changeRounds** | **num** | Average change requests by a person, over the tickets that reached review | 
**fixAttempts** | **num** | Average failing checks sent back to Claude | 
**serious** | **int** | Reviewed with a blocker or major finding at least once | 
**footprintHit** | **num** | Average share of the changed files the analysis predicted; absent when none was measured | [optional] 
**redFlags** | **int** | Red flags found in the diffs | 
**selfFixes** | **int** | Findings of agnts's own review sent back to the coder | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


