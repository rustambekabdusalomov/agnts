# agnts_api.model.LogSourceInput

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** | For a test of a saved source | [optional] 
**name** | **String** |  | 
**kind** | **String** |  | 
**environment** | **String** |  | 
**address** | **String** | https://loki.example.com, or http:// on a private network; empty for push | [optional] 
**auth** | [**LogAuthInput**](LogAuthInput.md) |  | [optional] 
**caPem** | **String** |  | [optional] 
**scope** | [**LogScope**](LogScope.md) |  | [optional] 
**fields** | [**LogFields**](LogFields.md) |  | [optional] 
**pollSeconds** | **int** | How often agnts reads it (15 by default) | [optional] 
**enabled** | **bool** |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


