# agnts_api.model.AssistantMessage

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | 
**role** | **String** |  | 
**text** | **String** | The question, or the answer in Markdown | 
**speech** | **String** | The answer in 1-3 plain sentences (empty for questions) | 
**links** | [**List&lt;AssistantLink&gt;**](AssistantLink.md) |  | 
**status** | **String** |  | 
**error** | **String** | Why the answer failed | [optional] 
**lang** | [**AssistantLanguage**](AssistantLanguage.md) |  | 
**durationMs** | **int** |  | [optional] 
**files** | **List&lt;String&gt;** | The snapshot files the answer was made from | [optional] 
**rating** | **int** | Your rating: 1 helpful, -1 not, 0 none | 
**ratingComment** | **String** |  | [optional] 
**shared** | **bool** | The answer's snapshot is kept for prompt tests | 
**actions** | [**List&lt;AssistantAction&gt;**](AssistantAction.md) | Actions the answer proposes, each waiting for you to confirm | [optional] 
**actionErrors** | **List&lt;String&gt;** | Actions the assistant tried to propose that agnts could not prepare, and why | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


