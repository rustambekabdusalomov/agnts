# agnts_api.model.AssistantAction

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**messageId** | **int** |  | 
**conversationId** | **int** |  | 
**tool** | **String** |  | 
**ticketKey** | **String** | The ticket it acts on, or the one it created | [optional] 
**summary** | **String** |  | 
**destructive** | **bool** | It cannot be taken back (approve, reject): ask once more before confirming | 
**status** | **String** |  | 
**result** | **String** | What happened (done), or why not (failed) | [optional] 
**expiresAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


