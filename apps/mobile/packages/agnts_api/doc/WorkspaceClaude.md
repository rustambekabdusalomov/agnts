# agnts_api.model.WorkspaceClaude

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**mode** | **String** |  | 
**fallback** | **bool** |  | 
**defaultMemberId** | **int** |  | [optional] 
**connection** | [**ClaudeConnectionState**](ClaudeConnectionState.md) |  | 
**members** | [**List&lt;WorkspaceClaudeMembersInner&gt;**](WorkspaceClaudeMembersInner.md) | Who has a personal connection (per-member mode) | 
**creditsBalance** | **int** |  | 
**subscriptionsAllowed** | **bool** | This server accepts Claude subscription tokens (self-hosted); otherwise API keys only | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


