# agnts_api.model.AdminAuditEntry

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | 
**adminId** | **int** | Absent once the Admin account is deleted | [optional] 
**adminName** | **String** |  | 
**action** | **String** | transcript.view, transcript.prompt, transcript.download, run_history.settings | 
**target** | **String** |  | 
**workspaceId** | **int** |  | [optional] 
**workspace** | **String** |  | [optional] 
**ip** | **String** |  | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


