# agnts_api.model.SwaggerSuiteInput

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**fromTicket** | **String** | Create: the Swagger test ticket whose test to keep | [optional] 
**name** | **String** |  | [optional] 
**schedule** | **String** | off runs only by hand or the deploy hook | [optional] 
**hour** | **int** | UTC hour of daily and weekly runs (weekly: Mondays) | [optional] 
**enabled** | **bool** |  | [optional] 
**token** | **String** | A new token for the suite; left out keeps it (a new suite takes the ticket's) | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


