# agnts_api.model.RunTranscriptEvent

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**k** | **String** | init, text, tool, tool_result, rate_limit, result or note; clients show kinds they do not know as is | 
**t** | **int** |  | 
**text** | **String** | text, result, note: the text | [optional] 
**id** | **String** | tool, tool_result: pairs a result with its call | [optional] 
**name** | **String** | tool: the tool (Bash, Read, Edit…) | [optional] 
**summary** | **String** | tool: a one-line summary of the call | [optional] 
**input** | **Object** | tool: the input as given (an object), or as text when it was too big to keep as JSON (cut is then set) | [optional] 
**output** | **String** | tool_result: what the tool returned | [optional] 
**error** | **bool** | tool_result, result: it failed | [optional] 
**exitCode** | **int** | tool_result: a command's exit code (Codex) | [optional] 
**cut** | **int** | The original length in bytes when the content was shortened | [optional] 
**subtype** | **String** | result: success, error_max_turns… | [optional] 
**turns** | **int** | result: turns taken | [optional] 
**cost** | **num** | result: cost in USD | [optional] 
**status** | **String** | rate_limit: the plan usage status | [optional] 
**sessionId** | **String** | init: the Claude Code session | [optional] 
**model** | **String** | init: the model Claude Code reported | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


