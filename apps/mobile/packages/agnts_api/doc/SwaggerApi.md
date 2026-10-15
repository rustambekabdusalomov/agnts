# agnts_api.api.SwaggerApi

## Load the API package
```dart
import 'package:agnts_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createSwaggerSuite**](SwaggerApi.md#createswaggersuite) | **POST** /swagger-suites | Keep a Swagger test ticket&#39;s test as a suite that runs again on a schedule or after each deploy
[**createSwaggerTest**](SwaggerApi.md#createswaggertest) | **POST** /swagger-tests | Create a Swagger test ticket; it starts at once (no analysis) unless start is queue
[**deleteSwaggerSuite**](SwaggerApi.md#deleteswaggersuite) | **DELETE** /swagger-suites/{id} | Delete a suite; its past runs stay
[**getApiRequest**](SwaggerApi.md#getapirequest) | **GET** /tickets/{key}/api-results/requests/{requestId} | One logged request and response of a Swagger test&#39;s latest run (credentials masked)
[**getApiResults**](SwaggerApi.md#getapiresults) | **GET** /tickets/{key}/api-results | A Swagger test&#39;s latest results, its request log (without bodies) and how it compares with the run before
[**getSwaggerSuite**](SwaggerApi.md#getswaggersuite) | **GET** /swagger-suites/{id} | One suite
[**listSwaggerSuites**](SwaggerApi.md#listswaggersuites) | **GET** /swagger-suites | Saved Swagger test suites
[**readSwaggerSpec**](SwaggerApi.md#readswaggerspec) | **POST** /swagger-tests/spec | Fetch (from a URL or a docs page in front of it) or read (uploaded text) a Swagger/OpenAPI spec for the Swagger test form; nothing is stored
[**rerunSwaggerTest**](SwaggerApi.md#rerunswaggertest) | **POST** /tickets/{key}/swagger-test/rerun | Run a Swagger test again
[**rotateSwaggerSuiteHook**](SwaggerApi.md#rotateswaggersuitehook) | **POST** /swagger-suites/{id}/hook | Make a new deploy hook URL for a suite (shown once; the old one stops working)
[**runSwaggerSuite**](SwaggerApi.md#runswaggersuite) | **POST** /swagger-suites/{id}/run | Run a suite now, as a new Swagger test ticket
[**updateSwaggerSuite**](SwaggerApi.md#updateswaggersuite) | **PATCH** /swagger-suites/{id} | Rename a suite, change its schedule, pause it or give it a new token


# **createSwaggerSuite**
> SwaggerSuite createSwaggerSuite(swaggerSuiteInput)

Keep a Swagger test ticket's test as a suite that runs again on a schedule or after each deploy

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getSwaggerApi();
final SwaggerSuiteInput swaggerSuiteInput = ; // SwaggerSuiteInput | 

try {
    final response = api.createSwaggerSuite(swaggerSuiteInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SwaggerApi->createSwaggerSuite: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **swaggerSuiteInput** | [**SwaggerSuiteInput**](SwaggerSuiteInput.md)|  | 

### Return type

[**SwaggerSuite**](SwaggerSuite.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createSwaggerTest**
> Ticket createSwaggerTest(swaggerTestCreate)

Create a Swagger test ticket; it starts at once (no analysis) unless start is queue

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getSwaggerApi();
final SwaggerTestCreate swaggerTestCreate = ; // SwaggerTestCreate | 

try {
    final response = api.createSwaggerTest(swaggerTestCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SwaggerApi->createSwaggerTest: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **swaggerTestCreate** | [**SwaggerTestCreate**](SwaggerTestCreate.md)|  | 

### Return type

[**Ticket**](Ticket.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteSwaggerSuite**
> deleteSwaggerSuite(id)

Delete a suite; its past runs stay

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getSwaggerApi();
final int id = 789; // int | 

try {
    api.deleteSwaggerSuite(id);
} on DioException catch (e) {
    print('Exception when calling SwaggerApi->deleteSwaggerSuite: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getApiRequest**
> ApiExchange getApiRequest(key, requestId)

One logged request and response of a Swagger test's latest run (credentials masked)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getSwaggerApi();
final String key = key_example; // String | 
final String requestId = requestId_example; // String | 

try {
    final response = api.getApiRequest(key, requestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SwaggerApi->getApiRequest: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **requestId** | **String**|  | 

### Return type

[**ApiExchange**](ApiExchange.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getApiResults**
> SwaggerResults getApiResults(key)

A Swagger test's latest results, its request log (without bodies) and how it compares with the run before

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getSwaggerApi();
final String key = key_example; // String | 

try {
    final response = api.getApiResults(key);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SwaggerApi->getApiResults: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 

### Return type

[**SwaggerResults**](SwaggerResults.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSwaggerSuite**
> SwaggerSuite getSwaggerSuite(id)

One suite

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getSwaggerApi();
final int id = 789; // int | 

try {
    final response = api.getSwaggerSuite(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SwaggerApi->getSwaggerSuite: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**SwaggerSuite**](SwaggerSuite.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listSwaggerSuites**
> List<SwaggerSuite> listSwaggerSuites()

Saved Swagger test suites

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getSwaggerApi();

try {
    final response = api.listSwaggerSuites();
    print(response);
} on DioException catch (e) {
    print('Exception when calling SwaggerApi->listSwaggerSuites: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;SwaggerSuite&gt;**](SwaggerSuite.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **readSwaggerSpec**
> SwaggerSpec readSwaggerSpec(swaggerSpecInput)

Fetch (from a URL or a docs page in front of it) or read (uploaded text) a Swagger/OpenAPI spec for the Swagger test form; nothing is stored

A URL is fetched by a short container behind the egress proxy, never by the agnts server: at most one fetch at a time per workspace and 10 a minute, and a URL fetched in the last 10 minutes comes from the cache. An uploaded spec is kept for an hour under specRef, which the create call refers to. A docs page offering several specs returns them as choices.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getSwaggerApi();
final SwaggerSpecInput swaggerSpecInput = ; // SwaggerSpecInput | 

try {
    final response = api.readSwaggerSpec(swaggerSpecInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SwaggerApi->readSwaggerSpec: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **swaggerSpecInput** | [**SwaggerSpecInput**](SwaggerSpecInput.md)|  | 

### Return type

[**SwaggerSpec**](SwaggerSpec.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rerunSwaggerTest**
> Ticket rerunSwaggerTest(key, swaggerRerunInput)

Run a Swagger test again

An open test (in review or failed) runs again in place; a new token is optional. A closed one (done or rejected) runs again as a new ticket, returned here, and needs a token: closing deleted the old one.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getSwaggerApi();
final String key = key_example; // String | 
final SwaggerRerunInput swaggerRerunInput = ; // SwaggerRerunInput | 

try {
    final response = api.rerunSwaggerTest(key, swaggerRerunInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SwaggerApi->rerunSwaggerTest: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **swaggerRerunInput** | [**SwaggerRerunInput**](SwaggerRerunInput.md)|  | [optional] 

### Return type

[**Ticket**](Ticket.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rotateSwaggerSuiteHook**
> RotateSwaggerSuiteHook200Response rotateSwaggerSuiteHook(id)

Make a new deploy hook URL for a suite (shown once; the old one stops working)

A deploy pipeline POSTs to the URL, with no body, to run the suite after each deploy.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getSwaggerApi();
final int id = 789; // int | 

try {
    final response = api.rotateSwaggerSuiteHook(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SwaggerApi->rotateSwaggerSuiteHook: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**RotateSwaggerSuiteHook200Response**](RotateSwaggerSuiteHook200Response.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **runSwaggerSuite**
> Ticket runSwaggerSuite(id)

Run a suite now, as a new Swagger test ticket

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getSwaggerApi();
final int id = 789; // int | 

try {
    final response = api.runSwaggerSuite(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SwaggerApi->runSwaggerSuite: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**Ticket**](Ticket.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateSwaggerSuite**
> SwaggerSuite updateSwaggerSuite(id, swaggerSuiteInput)

Rename a suite, change its schedule, pause it or give it a new token

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getSwaggerApi();
final int id = 789; // int | 
final SwaggerSuiteInput swaggerSuiteInput = ; // SwaggerSuiteInput | 

try {
    final response = api.updateSwaggerSuite(id, swaggerSuiteInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SwaggerApi->updateSwaggerSuite: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **swaggerSuiteInput** | [**SwaggerSuiteInput**](SwaggerSuiteInput.md)|  | 

### Return type

[**SwaggerSuite**](SwaggerSuite.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

