# hiro_api.api.McpApi

## Load the API package
```dart
import 'package:hiro_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**decideConsent**](McpApi.md#decideconsent) | **POST** /oauth/consent | Approve or deny a Claude connection; returns where to send the browser
[**getConsent**](McpApi.md#getconsent) | **GET** /oauth/consent | Details of a pending Claude connection request, for the consent page
[**getMcpSettings**](McpApi.md#getmcpsettings) | **GET** /mcp-settings | The MCP connector URL and current connections
[**revokeMcp**](McpApi.md#revokemcp) | **POST** /mcp-settings/revoke | Disconnect every Claude connection and delete the static token
[**rotateMcpToken**](McpApi.md#rotatemcptoken) | **POST** /mcp-settings/token | Create a new static MCP bearer token (shown once; the old one stops working)


# **decideConsent**
> DecideConsent200Response decideConsent(decideConsentRequest)

Approve or deny a Claude connection; returns where to send the browser

### Example
```dart
import 'package:hiro_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = HiroApi().getMcpApi();
final DecideConsentRequest decideConsentRequest = ; // DecideConsentRequest | 

try {
    final response = api.decideConsent(decideConsentRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling McpApi->decideConsent: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **decideConsentRequest** | [**DecideConsentRequest**](DecideConsentRequest.md)|  | 

### Return type

[**DecideConsent200Response**](DecideConsent200Response.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getConsent**
> GetConsent200Response getConsent(clientId, redirectUri, codeChallenge, codeChallengeMethod, resource)

Details of a pending Claude connection request, for the consent page

### Example
```dart
import 'package:hiro_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = HiroApi().getMcpApi();
final String clientId = clientId_example; // String | 
final String redirectUri = redirectUri_example; // String | 
final String codeChallenge = codeChallenge_example; // String | 
final String codeChallengeMethod = codeChallengeMethod_example; // String | 
final String resource = resource_example; // String | 

try {
    final response = api.getConsent(clientId, redirectUri, codeChallenge, codeChallengeMethod, resource);
    print(response);
} on DioException catch (e) {
    print('Exception when calling McpApi->getConsent: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **clientId** | **String**|  | 
 **redirectUri** | **String**|  | 
 **codeChallenge** | **String**|  | 
 **codeChallengeMethod** | **String**|  | 
 **resource** | **String**|  | [optional] 

### Return type

[**GetConsent200Response**](GetConsent200Response.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMcpSettings**
> McpStatus getMcpSettings()

The MCP connector URL and current connections

### Example
```dart
import 'package:hiro_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = HiroApi().getMcpApi();

try {
    final response = api.getMcpSettings();
    print(response);
} on DioException catch (e) {
    print('Exception when calling McpApi->getMcpSettings: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**McpStatus**](McpStatus.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **revokeMcp**
> revokeMcp()

Disconnect every Claude connection and delete the static token

### Example
```dart
import 'package:hiro_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = HiroApi().getMcpApi();

try {
    api.revokeMcp();
} on DioException catch (e) {
    print('Exception when calling McpApi->revokeMcp: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rotateMcpToken**
> RotateMcpToken200Response rotateMcpToken()

Create a new static MCP bearer token (shown once; the old one stops working)

### Example
```dart
import 'package:hiro_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = HiroApi().getMcpApi();

try {
    final response = api.rotateMcpToken();
    print(response);
} on DioException catch (e) {
    print('Exception when calling McpApi->rotateMcpToken: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**RotateMcpToken200Response**](RotateMcpToken200Response.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

