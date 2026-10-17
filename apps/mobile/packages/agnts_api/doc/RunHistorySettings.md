# agnts_api.model.RunHistorySettings

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**retentionDays** | **int** | Transcripts older than this are deleted daily; 0 keeps them | 
**toolOutputKB** | **int** | Cap of one tool output; its start and end are kept | 
**textKB** | **int** | Cap of one text block or tool input | 
**transcriptMB** | **int** | Cap of one transcript; past it only tool calls and the result are kept | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


