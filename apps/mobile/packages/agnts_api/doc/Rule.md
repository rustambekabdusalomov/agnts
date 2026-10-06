# agnts_api.model.Rule

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | 
**repoId** | **int** | Absent for a global rule | [optional] 
**repoName** | **String** |  | [optional] 
**title** | **String** |  | 
**body** | **String** | The rule as written | 
**enabled** | **bool** |  | 
**status** | [**RuleStatus**](RuleStatus.md) |  | 
**interpretation** | **String** | What Claude will do because of the rule | 
**clarified** | **String** | The rule rewritten with what the answers settled; empty when used as written | 
**text** | **String** | What tickets are given | 
**questions** | [**List&lt;RuleQuestion&gt;**](RuleQuestion.md) |  | 
**rounds** | **int** | Question rounds so far | 
**error** | **String** | Why the last review failed | 
**analyzedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


