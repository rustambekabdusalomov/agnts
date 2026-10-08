# agnts_api.model.RepoBrief

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**repoId** | **int** |  | 
**repoName** | **String** |  | 
**body** | **String** | The approved brief, Markdown; empty when there is none | 
**bodySha** | **String** | The commit the approved brief describes | 
**draft** | **String** | The latest survey, waiting for approval; empty when there is none | 
**draftSha** | **String** |  | 
**status** | **String** |  | 
**mergesSince** | **int** | Tickets merged since the brief was approved | 
**refreshAfter** | **int** | Merges after which agnts surveys again, when Settings allow | 
**error** | **String** | Why the last survey failed | 
**surveyedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**approvedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**updatedAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


