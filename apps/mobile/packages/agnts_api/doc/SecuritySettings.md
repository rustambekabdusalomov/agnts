# agnts_api.model.SecuritySettings

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**schedule** | **String** | Scan on its own at a quiet hour (03:00 UTC) | 
**exclude** | **List&lt;String&gt;** | Path patterns no tool reports on, besides vendor, node_modules, dist, build and *.min.js | 
**minNotify** | [**SecSeverity**](SecSeverity.md) |  | 
**nextAt** | [**DateTime**](DateTime.md) | When the next scheduled scan is due | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


