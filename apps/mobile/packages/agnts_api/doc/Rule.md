# agnts_api.model.Rule

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | 
**kind** | [**RuleKind**](RuleKind.md) |  | 
**sourceTicket** | **String** | For a rule agnts suggested: the ticket whose feedback taught it | [optional] 
**reason** | **String** | For a rule agnts suggested: which feedback shows it | [optional] 
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
**enforce** | [**RuleEnforce**](RuleEnforce.md) |  | [optional] 
**delivery** | **String** | prompt: in every prompt; skill: a skill Claude loads when its description matches the work | [optional] 
**skillDescription** | **String** | When the rule applies, for its skill | [optional] 
**source_** | **String** | Where it came from: empty (a person), reflect, run, promoted or pack:<language> | [optional] 
**confidence** | **num** | For a learned suggestion: 0.3 to 0.9, earned each time it is seen again | [optional] 
**evidence** | **int** | How many times a learned suggestion was seen | [optional] 
**lastSeen** | [**DateTime**](DateTime.md) |  | [optional] 
**watching** | **bool** | A learned suggestion with too little evidence to show yet | [optional] 
**analyzedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


