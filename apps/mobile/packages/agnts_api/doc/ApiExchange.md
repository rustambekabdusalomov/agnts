# agnts_api.model.ApiExchange

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**case_** | **String** |  | [optional] 
**auth** | **String** | default, none or wrong | [optional] 
**method** | **String** |  | 
**url** | **String** |  | 
**status** | **int** | 0 when no response came back | 
**ms** | **int** |  | 
**error** | **String** |  | [optional] 
**truncated** | **bool** |  | [optional] 
**requestHeaders** | **Map&lt;String, String&gt;** |  | [optional] 
**requestBody** | **String** |  | [optional] 
**responseHeaders** | **Map&lt;String, String&gt;** |  | [optional] 
**responseBody** | **String** |  | [optional] 
**at** | [**DateTime**](DateTime.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


