# agnts_api.model.TicketPreview

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**runId** | **int** |  | 
**revision** | **int** |  | 
**model** | **String** | A Claude model (haiku, sonnet, opus), or codex:<model> for a run on Codex CLI | 
**compare** | **bool** | Before shots were taken too | 
**status** | **String** | failed: the app did not start | 
**summary** | **String** |  | 
**shots** | [**List&lt;PreviewShot&gt;**](PreviewShot.md) |  | 
**issues** | [**List&lt;PreviewIssue&gt;**](PreviewIssue.md) |  | 
**acceptance** | [**Acceptance**](Acceptance.md) |  | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


