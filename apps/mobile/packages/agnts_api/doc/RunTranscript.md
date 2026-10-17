# agnts_api.model.RunTranscript

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | 
**workspaceId** | **int** |  | 
**workspace** | **String** |  | 
**workspaceSlug** | **String** |  | 
**runId** | **int** |  | [optional] 
**ticketKey** | **String** |  | [optional] 
**subject** | **String** | What a background call is about: a repository, a rule, a language | [optional] 
**claudeAccount** | **String** | The Claude account's label | [optional] 
**claudeUser** | **String** | The member whose Claude account it is (per-member mode) | [optional] 
**purpose** | **String** |  | 
**background** | **bool** | A call outside a ticket's stages | 
**modelStage** | **String** |  | [optional] 
**engine** | **String** |  | 
**model** | **String** |  | 
**sessionId** | **String** |  | [optional] 
**startedAt** | [**DateTime**](DateTime.md) |  | 
**finishedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**status** | **String** |  | 
**exitReason** | **String** |  | 
**turns** | **int** |  | 
**toolCalls** | **int** |  | 
**toolErrors** | **int** |  | 
**stalls** | **int** |  | 
**inputTokens** | **int** |  | 
**outputTokens** | **int** |  | 
**cacheReadTokens** | **int** |  | 
**cacheWriteTokens** | **int** |  | 
**costUsd** | **num** |  | 
**rawBytes** | **int** | Uncompressed size of the events | 
**storedBytes** | **int** | Compressed size as stored | 
**truncated** | **bool** | The size limit was reached; later content was left out | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


