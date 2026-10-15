# agnts_api.model.SwaggerTestCreate

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**title** | **String** | Defaults to \"Swagger test: <API> on <host>\" | [optional] 
**specUrl** | **String** | The URL readSwaggerSpec read (served from its cache) | [optional] 
**specRef** | **String** | An uploaded spec, from readSwaggerSpec | [optional] 
**baseUrl** | **String** |  | 
**operations** | **List&lt;String&gt;** |  | [optional] 
**writeEnabled** | **bool** | Send POST, PUT, PATCH and DELETE too; off by default | [optional] 
**notProduction** | **bool** | Confirms the base URL is not production; required with writeEnabled | [optional] 
**auth** | [**SwaggerAuthInput**](SwaggerAuthInput.md) |  | [optional] 
**repoId** | **int** | Optional: the API's repository, to explain failures | [optional] 
**notes** | **String** | What to test: which endpoints, cases or data. Without operations, it decides the scope. | [optional] 
**rateLimit** | **int** | Requests a second (0: 5) | [optional] 
**maxRequests** | **int** | Requests per run (0: 300) | [optional] 
**priority** | **String** |  | [optional] 
**start** | **String** | code starts now; queue keeps it until started | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


