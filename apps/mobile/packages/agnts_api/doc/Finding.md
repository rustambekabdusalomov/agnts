# agnts_api.model.Finding

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**severity** | **String** |  | 
**category** | **String** |  | 
**file** | **String** | Path relative to the repository | [optional] 
**line** | **int** |  | [optional] 
**title** | **String** |  | 
**detail** | **String** |  | [optional] 
**suggestion** | **String** | What to change, written to be sent back as feedback | [optional] 
**confidence** | **num** | How sure the reviewer was, 0 to 1; absent when it did not say | [optional] 
**pass** | **String** | The specialist pass that found it (security, failures, tests, types), empty for the main review | [optional] 
**adopted** | **bool** | A person put it in their feedback | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


