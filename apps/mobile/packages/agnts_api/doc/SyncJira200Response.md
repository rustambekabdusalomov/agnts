# agnts_api.model.SyncJira200Response

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**found** | **int** |  | 
**created** | **int** |  | 
**updated** | **int** | Tickets not started yet that took the issue's new text | [optional] 
**waiting** | **int** | Started tickets whose issue changed: each asks you to restart with the new version or keep the current one | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


