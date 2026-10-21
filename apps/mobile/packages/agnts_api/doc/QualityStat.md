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
**ciRounds** | **num** | Average times red CI on the pull request sent the work back, over the tickets that reached review | [optional] 
**merged** | **int** | Their pull requests merged | [optional] 
**costUsd** | **num** | What all their runs cost | [optional] 
**costPerMerged** | **num** | Cost over merged tickets; absent when none merged | [optional] 
**score** | **num** | 0–100: done first time 35%, merged 25%, no serious finding 20%, few change rounds 20% | [optional] 
**peopleEdited** | **num** | Average share of agnts's lines people changed before merging; absent when no merge was recorded | [optional] 
**reverted** | **int** | Tickets whose merged work people reverted | [optional] 
**fixAttempts** | **num** | Average failing checks sent back to Claude | 
**serious** | **int** | Reviewed with a blocker or major finding at least once | 
**footprintHit** | **num** | Average share of the changed files the analysis predicted; absent when none was measured | [optional] 
**redFlags** | **int** | Red flags found in the diffs | 
**selfFixes** | **int** | Findings of agnts's own review sent back to the coder | 
**guardBlocks** | **int** | Actions agnts-guard refused in their coding runs | [optional] 
**stopSaves** | **int** | Tickets whose stop gate sent failing checks back and whose checks then passed first time | [optional] 
**stalls** | **int** | Times their runs looked stuck | [optional] 
**proofDue** | **int** | Tickets with a proof of fix | [optional] 
**proven** | **int** | Of those, proven | [optional] 
**findings** | **int** | Review findings shown on them | [optional] 
**adopted** | **int** | Of those, put into a person's feedback | [optional] 
**tokens** | **num** | Average tokens of a done ticket, all stages | [optional] 
**factCheck** | **int** | Tickets in the fact check group (A/B) | [optional] 
**factCheckFirst** | **int** | Of those, done without a person asking for changes | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


