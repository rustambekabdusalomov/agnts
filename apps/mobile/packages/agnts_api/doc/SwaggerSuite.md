# agnts_api.model.SwaggerSuite

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | 
**name** | **String** |  | 
**specUrl** | **String** |  | [optional] 
**baseUrl** | **String** |  | 
**operations** | **int** | How many endpoints it tests | 
**writeEnabled** | **bool** |  | 
**authKind** | [**ApiAuthKind**](ApiAuthKind.md) |  | 
**hasToken** | **bool** |  | 
**repoId** | **int** |  | [optional] 
**schedule** | **String** |  | 
**hour** | **int** |  | 
**enabled** | **bool** |  | 
**hookSet** | **bool** | A deploy hook URL exists | 
**lastRunAt** | [**DateTime**](DateTime.md) |  | [optional] 
**nextRunAt** | [**DateTime**](DateTime.md) |  | [optional] 
**lastTicketKey** | **String** |  | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


