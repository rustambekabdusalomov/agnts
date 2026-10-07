# agnts_api.api.IntegrationsApi

## Load the API package
```dart
import 'package:agnts_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**connectIntegration**](IntegrationsApi.md#connectintegration) | **POST** /integrations/{provider}/connect | Save a token (and settings), check it against the provider, and connect
[**disconnectIntegration**](IntegrationsApi.md#disconnectintegration) | **POST** /integrations/{provider}/disconnect | Forget the token
[**listIntegrations**](IntegrationsApi.md#listintegrations) | **GET** /integrations | 
[**listPlaneStates**](IntegrationsApi.md#listplanestates) | **GET** /integrations/plane/states | States of the Plane projects linked to repositories, for the status mapping
[**listRemoteRepos**](IntegrationsApi.md#listremoterepos) | **GET** /integrations/{provider}/repos | Repositories the connected GitHub or GitLab token can reach, for import
[**setPlaneWebhookSecret**](IntegrationsApi.md#setplanewebhooksecret) | **PUT** /integrations/plane/webhook-secret | Store the secret Plane generated for the agnts webhook
[**syncJira**](IntegrationsApi.md#syncjira) | **POST** /integrations/jira/sync | Pick up labelled Jira issues now
[**syncPlane**](IntegrationsApi.md#syncplane) | **POST** /integrations/plane/sync | Pick up labelled Plane work items now
[**testIntegration**](IntegrationsApi.md#testintegration) | **POST** /integrations/{provider}/test | 
[**updateIntegration**](IntegrationsApi.md#updateintegration) | **PUT** /integrations/{provider} | Change an integration&#39;s settings (never its token)


# **connectIntegration**
> ConnectResult connectIntegration(provider, connectIntegrationRequest)

Save a token (and settings), check it against the provider, and connect

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getIntegrationsApi();
final String provider = provider_example; // String | 
final ConnectIntegrationRequest connectIntegrationRequest = ; // ConnectIntegrationRequest | 

try {
    final response = api.connectIntegration(provider, connectIntegrationRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling IntegrationsApi->connectIntegration: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **provider** | **String**|  | 
 **connectIntegrationRequest** | [**ConnectIntegrationRequest**](ConnectIntegrationRequest.md)|  | 

### Return type

[**ConnectResult**](ConnectResult.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **disconnectIntegration**
> Integration disconnectIntegration(provider)

Forget the token

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getIntegrationsApi();
final String provider = provider_example; // String | 

try {
    final response = api.disconnectIntegration(provider);
    print(response);
} on DioException catch (e) {
    print('Exception when calling IntegrationsApi->disconnectIntegration: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **provider** | **String**|  | 

### Return type

[**Integration**](Integration.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listIntegrations**
> List<Integration> listIntegrations()



### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getIntegrationsApi();

try {
    final response = api.listIntegrations();
    print(response);
} on DioException catch (e) {
    print('Exception when calling IntegrationsApi->listIntegrations: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;Integration&gt;**](Integration.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPlaneStates**
> List<PlaneState> listPlaneStates()

States of the Plane projects linked to repositories, for the status mapping

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getIntegrationsApi();

try {
    final response = api.listPlaneStates();
    print(response);
} on DioException catch (e) {
    print('Exception when calling IntegrationsApi->listPlaneStates: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;PlaneState&gt;**](PlaneState.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listRemoteRepos**
> List<RemoteRepository> listRemoteRepos(provider)

Repositories the connected GitHub or GitLab token can reach, for import

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getIntegrationsApi();
final String provider = provider_example; // String | 

try {
    final response = api.listRemoteRepos(provider);
    print(response);
} on DioException catch (e) {
    print('Exception when calling IntegrationsApi->listRemoteRepos: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **provider** | **String**|  | 

### Return type

[**List&lt;RemoteRepository&gt;**](RemoteRepository.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setPlaneWebhookSecret**
> Integration setPlaneWebhookSecret(setPlaneWebhookSecretRequest)

Store the secret Plane generated for the agnts webhook

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getIntegrationsApi();
final SetPlaneWebhookSecretRequest setPlaneWebhookSecretRequest = ; // SetPlaneWebhookSecretRequest | 

try {
    final response = api.setPlaneWebhookSecret(setPlaneWebhookSecretRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling IntegrationsApi->setPlaneWebhookSecret: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **setPlaneWebhookSecretRequest** | [**SetPlaneWebhookSecretRequest**](SetPlaneWebhookSecretRequest.md)|  | 

### Return type

[**Integration**](Integration.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **syncJira**
> SyncJira200Response syncJira()

Pick up labelled Jira issues now

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getIntegrationsApi();

try {
    final response = api.syncJira();
    print(response);
} on DioException catch (e) {
    print('Exception when calling IntegrationsApi->syncJira: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**SyncJira200Response**](SyncJira200Response.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **syncPlane**
> SyncJira200Response syncPlane()

Pick up labelled Plane work items now

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getIntegrationsApi();

try {
    final response = api.syncPlane();
    print(response);
} on DioException catch (e) {
    print('Exception when calling IntegrationsApi->syncPlane: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**SyncJira200Response**](SyncJira200Response.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **testIntegration**
> Integration testIntegration(provider)



### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getIntegrationsApi();
final String provider = provider_example; // String | 

try {
    final response = api.testIntegration(provider);
    print(response);
} on DioException catch (e) {
    print('Exception when calling IntegrationsApi->testIntegration: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **provider** | **String**|  | 

### Return type

[**Integration**](Integration.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateIntegration**
> Integration updateIntegration(provider, updateIntegrationRequest)

Change an integration's settings (never its token)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getIntegrationsApi();
final String provider = provider_example; // String | 
final UpdateIntegrationRequest updateIntegrationRequest = ; // UpdateIntegrationRequest | 

try {
    final response = api.updateIntegration(provider, updateIntegrationRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling IntegrationsApi->updateIntegration: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **provider** | **String**|  | 
 **updateIntegrationRequest** | [**UpdateIntegrationRequest**](UpdateIntegrationRequest.md)|  | 

### Return type

[**Integration**](Integration.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

