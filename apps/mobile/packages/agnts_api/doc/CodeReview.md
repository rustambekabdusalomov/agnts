# agnts_api.model.CodeReview

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**revision** | **int** |  | 
**model** | **String** | A Claude model (haiku, sonnet, opus), or codex:<model> for a run on Codex CLI | 
**modelReason** | **String** | Why this model reviewed it | 
**verdict** | **String** |  | 
**summary** | **String** |  | 
**findings** | [**List&lt;Finding&gt;**](Finding.md) |  | 
**strengths** | **List&lt;String&gt;** |  | 
**deep** | **bool** | The review ran the specialist passes | [optional] 
**dropped** | **int** | Findings left out for low confidence or as duplicates | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


