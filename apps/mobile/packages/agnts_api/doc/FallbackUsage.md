# agnts_api.model.FallbackUsage

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**provider** | **String** | e.g. baseten | 
**monthLimit** | **int** | Credits per calendar month (UTC); 0 is no limit | 
**monthUsed** | **int** |  | 
**isDefault** | **bool** | The server's default limit applies; an Admin has not set one | 
**setAt** | [**DateTime**](DateTime.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


