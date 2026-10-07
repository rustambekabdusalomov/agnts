# agnts_api.model.Attachment

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | 
**name** | **String** |  | 
**contentType** | **String** |  | 
**size** | **int** | Bytes | 
**purpose** | **String** | pending = uploaded, not attached yet; ticket = the task description; answer = an answer (see questionId); retry = a retry note; feedback = requested changes | 
**questionId** | **int** |  | [optional] 
**image** | **bool** | A picture clients can show in place | [optional] 
**url** | **String** | Where to load the file, relative to the API base | 
**createdAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


