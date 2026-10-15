# agnts_api.model.SwaggerSpec

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**specRef** | **String** | An uploaded spec, or one fetched with a token, kept for an hour: pass it to createSwaggerTest | [optional] 
**url** | **String** | Where the spec was found (a docs page leads to its spec) | [optional] 
**title** | **String** |  | [optional] 
**version** | **String** |  | [optional] 
**format** | **String** | \"swagger 2.0\" or \"openapi 3.x\" | [optional] 
**servers** | [**List&lt;SwaggerServer&gt;**](SwaggerServer.md) |  | 
**operations** | [**List&lt;SwaggerOperation&gt;**](SwaggerOperation.md) |  | 
**securitySchemes** | [**List&lt;SwaggerSecurityScheme&gt;**](SwaggerSecurityScheme.md) |  | 
**choices** | [**List&lt;SwaggerSpecChoicesInner&gt;**](SwaggerSpecChoicesInner.md) | The specs a docs page offers; read the chosen one's url | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


