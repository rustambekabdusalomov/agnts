# agnts_api.api.PlatformApi

## Load the API package
```dart
import 'package:agnts_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createPlatformAdmin**](PlatformApi.md#createplatformadmin) | **POST** /platform/admins | Create an Admin account that signs in with a password (Admin)
[**deletePlatformAdmin**](PlatformApi.md#deleteplatformadmin) | **DELETE** /platform/admins/{id} | Delete an Admin account; not your own (Admin)
[**getPlatformOverview**](PlatformApi.md#getplatformoverview) | **GET** /platform/overview | Servers, runs and the queue across every workspace (Admin)
[**grantCredits**](PlatformApi.md#grantcredits) | **POST** /platform/workspaces/{id}/credits | Grant (or take back, when negative) credits (Admin)
[**listPlatformFeedback**](PlatformApi.md#listplatformfeedback) | **GET** /platform/feedback | Every feedback people sent, newest first (Admin)
[**listPlatformUsers**](PlatformApi.md#listplatformusers) | **GET** /platform/users | Every user, with their workspaces and last sign-in (Admin)
[**listPlatformWorkspaces**](PlatformApi.md#listplatformworkspaces) | **GET** /platform/workspaces | Every workspace, metadata only (Admin)
[**updatePlatformFeedback**](PlatformApi.md#updateplatformfeedback) | **PUT** /platform/feedback/{id} | Mark a feedback done, or new again (Admin)
[**updatePlatformUser**](PlatformApi.md#updateplatformuser) | **PUT** /platform/users/{id} | Grant or remove the Admin role (Admin); refused when Admins and Users are separate accounts
[**updatePlatformWorkspace**](PlatformApi.md#updateplatformworkspace) | **PUT** /platform/workspaces/{id} | Change a workspace&#39;s plan, slots, member limit, or suspend it (Admin)


# **createPlatformAdmin**
> User createPlatformAdmin(createPlatformAdminRequest)

Create an Admin account that signs in with a password (Admin)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getPlatformApi();
final CreatePlatformAdminRequest createPlatformAdminRequest = ; // CreatePlatformAdminRequest | 

try {
    final response = api.createPlatformAdmin(createPlatformAdminRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PlatformApi->createPlatformAdmin: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createPlatformAdminRequest** | [**CreatePlatformAdminRequest**](CreatePlatformAdminRequest.md)|  | 

### Return type

[**User**](User.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deletePlatformAdmin**
> deletePlatformAdmin(id)

Delete an Admin account; not your own (Admin)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getPlatformApi();
final int id = 789; // int | 

try {
    api.deletePlatformAdmin(id);
} on DioException catch (e) {
    print('Exception when calling PlatformApi->deletePlatformAdmin: $e\n');
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

# **getPlatformOverview**
> PlatformOverview getPlatformOverview()

Servers, runs and the queue across every workspace (Admin)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getPlatformApi();

try {
    final response = api.getPlatformOverview();
    print(response);
} on DioException catch (e) {
    print('Exception when calling PlatformApi->getPlatformOverview: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**PlatformOverview**](PlatformOverview.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **grantCredits**
> PlatformWorkspace grantCredits(id, grantCreditsRequest)

Grant (or take back, when negative) credits (Admin)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getPlatformApi();
final int id = 789; // int | 
final GrantCreditsRequest grantCreditsRequest = ; // GrantCreditsRequest | 

try {
    final response = api.grantCredits(id, grantCreditsRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PlatformApi->grantCredits: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **grantCreditsRequest** | [**GrantCreditsRequest**](GrantCreditsRequest.md)|  | 

### Return type

[**PlatformWorkspace**](PlatformWorkspace.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPlatformFeedback**
> List<Feedback> listPlatformFeedback()

Every feedback people sent, newest first (Admin)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getPlatformApi();

try {
    final response = api.listPlatformFeedback();
    print(response);
} on DioException catch (e) {
    print('Exception when calling PlatformApi->listPlatformFeedback: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;Feedback&gt;**](Feedback.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPlatformUsers**
> List<PlatformUser> listPlatformUsers()

Every user, with their workspaces and last sign-in (Admin)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getPlatformApi();

try {
    final response = api.listPlatformUsers();
    print(response);
} on DioException catch (e) {
    print('Exception when calling PlatformApi->listPlatformUsers: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;PlatformUser&gt;**](PlatformUser.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPlatformWorkspaces**
> List<PlatformWorkspace> listPlatformWorkspaces()

Every workspace, metadata only (Admin)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getPlatformApi();

try {
    final response = api.listPlatformWorkspaces();
    print(response);
} on DioException catch (e) {
    print('Exception when calling PlatformApi->listPlatformWorkspaces: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;PlatformWorkspace&gt;**](PlatformWorkspace.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updatePlatformFeedback**
> Feedback updatePlatformFeedback(id, updatePlatformFeedbackRequest)

Mark a feedback done, or new again (Admin)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getPlatformApi();
final int id = 789; // int | 
final UpdatePlatformFeedbackRequest updatePlatformFeedbackRequest = ; // UpdatePlatformFeedbackRequest | 

try {
    final response = api.updatePlatformFeedback(id, updatePlatformFeedbackRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PlatformApi->updatePlatformFeedback: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **updatePlatformFeedbackRequest** | [**UpdatePlatformFeedbackRequest**](UpdatePlatformFeedbackRequest.md)|  | 

### Return type

[**Feedback**](Feedback.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updatePlatformUser**
> User updatePlatformUser(id, updatePlatformUserRequest)

Grant or remove the Admin role (Admin); refused when Admins and Users are separate accounts

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getPlatformApi();
final int id = 789; // int | 
final UpdatePlatformUserRequest updatePlatformUserRequest = ; // UpdatePlatformUserRequest | 

try {
    final response = api.updatePlatformUser(id, updatePlatformUserRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PlatformApi->updatePlatformUser: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **updatePlatformUserRequest** | [**UpdatePlatformUserRequest**](UpdatePlatformUserRequest.md)|  | 

### Return type

[**User**](User.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updatePlatformWorkspace**
> PlatformWorkspace updatePlatformWorkspace(id, updatePlatformWorkspaceRequest)

Change a workspace's plan, slots, member limit, or suspend it (Admin)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getPlatformApi();
final int id = 789; // int | 
final UpdatePlatformWorkspaceRequest updatePlatformWorkspaceRequest = ; // UpdatePlatformWorkspaceRequest | 

try {
    final response = api.updatePlatformWorkspace(id, updatePlatformWorkspaceRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PlatformApi->updatePlatformWorkspace: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **updatePlatformWorkspaceRequest** | [**UpdatePlatformWorkspaceRequest**](UpdatePlatformWorkspaceRequest.md)|  | 

### Return type

[**PlatformWorkspace**](PlatformWorkspace.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

