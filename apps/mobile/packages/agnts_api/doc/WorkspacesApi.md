# agnts_api.api.WorkspacesApi

## Load the API package
```dart
import 'package:agnts_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**acceptInvite**](WorkspacesApi.md#acceptinvite) | **POST** /invites/{token}/accept | Join the workspace an invite is for
[**createWorkspace**](WorkspacesApi.md#createworkspace) | **POST** /workspaces | Create a workspace you own
[**getInvite**](WorkspacesApi.md#getinvite) | **GET** /invites/{token} | What an invite link is for
[**getWorkspaceMuseLogin**](WorkspacesApi.md#getworkspacemuselogin) | **GET** /workspace/muse/login/{id} | How the workspace&#39;s Meta sign-in is going
[**listWorkspaces**](WorkspacesApi.md#listworkspaces) | **GET** /workspaces | The workspaces you are a member of
[**startWorkspaceMuseLogin**](WorkspacesApi.md#startworkspacemuselogin) | **POST** /workspace/muse/login | Connect the workspace&#39;s Muse account by signing in with Meta


# **acceptInvite**
> WorkspaceSummary acceptInvite(token)

Join the workspace an invite is for

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getWorkspacesApi();
final String token = token_example; // String | 

try {
    final response = api.acceptInvite(token);
    print(response);
} on DioException catch (e) {
    print('Exception when calling WorkspacesApi->acceptInvite: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **token** | **String**|  | 

### Return type

[**WorkspaceSummary**](WorkspaceSummary.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createWorkspace**
> WorkspaceSummary createWorkspace(createWorkspaceRequest)

Create a workspace you own

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getWorkspacesApi();
final CreateWorkspaceRequest createWorkspaceRequest = ; // CreateWorkspaceRequest | 

try {
    final response = api.createWorkspace(createWorkspaceRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling WorkspacesApi->createWorkspace: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createWorkspaceRequest** | [**CreateWorkspaceRequest**](CreateWorkspaceRequest.md)|  | 

### Return type

[**WorkspaceSummary**](WorkspaceSummary.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getInvite**
> InvitePreview getInvite(token)

What an invite link is for

### Example
```dart
import 'package:agnts_api/api.dart';

final api = AgntsApi().getWorkspacesApi();
final String token = token_example; // String | 

try {
    final response = api.getInvite(token);
    print(response);
} on DioException catch (e) {
    print('Exception when calling WorkspacesApi->getInvite: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **token** | **String**|  | 

### Return type

[**InvitePreview**](InvitePreview.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getWorkspaceMuseLogin**
> MuseLogin getWorkspaceMuseLogin(id)

How the workspace's Meta sign-in is going

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getWorkspacesApi();
final String id = id_example; // String | 

try {
    final response = api.getWorkspaceMuseLogin(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling WorkspacesApi->getWorkspaceMuseLogin: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**MuseLogin**](MuseLogin.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listWorkspaces**
> List<WorkspaceSummary> listWorkspaces()

The workspaces you are a member of

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getWorkspacesApi();

try {
    final response = api.listWorkspaces();
    print(response);
} on DioException catch (e) {
    print('Exception when calling WorkspacesApi->listWorkspaces: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;WorkspaceSummary&gt;**](WorkspaceSummary.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startWorkspaceMuseLogin**
> MuseLogin startWorkspaceMuseLogin()

Connect the workspace's Muse account by signing in with Meta

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getWorkspacesApi();

try {
    final response = api.startWorkspaceMuseLogin();
    print(response);
} on DioException catch (e) {
    print('Exception when calling WorkspacesApi->startWorkspaceMuseLogin: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**MuseLogin**](MuseLogin.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

