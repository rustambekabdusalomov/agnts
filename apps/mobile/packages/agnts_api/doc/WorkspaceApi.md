# agnts_api.api.WorkspaceApi

## Load the API package
```dart
import 'package:agnts_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createInvite**](WorkspaceApi.md#createinvite) | **POST** /workspace/invites | Invite someone by email or by a link (valid 7 days)
[**deleteWorkspace**](WorkspaceApi.md#deleteworkspace) | **DELETE** /workspace | Delete the workspace (kept 7 days for undo, then purged)
[**deleteWorkspaceClaudeConnection**](WorkspaceApi.md#deleteworkspaceclaudeconnection) | **DELETE** /workspace/claude/connection | Disconnect the workspace&#39;s shared Claude or Muse account
[**getQueue**](WorkspaceApi.md#getqueue) | **GET** /workspace/queue | Where the workspace&#39;s tickets stand in the queue
[**getWorkspace**](WorkspaceApi.md#getworkspace) | **GET** /workspace | The current workspace and your role in it
[**getWorkspaceClaude**](WorkspaceApi.md#getworkspaceclaude) | **GET** /workspace/claude | Which Claude or Muse account the workspace&#39;s runs use
[**leaveWorkspace**](WorkspaceApi.md#leaveworkspace) | **POST** /workspace/leave | Leave the workspace
[**listInvites**](WorkspaceApi.md#listinvites) | **GET** /workspace/invites | Open invites
[**listMembers**](WorkspaceApi.md#listmembers) | **GET** /workspace/members | The workspace&#39;s members
[**removeMember**](WorkspaceApi.md#removemember) | **DELETE** /workspace/members/{userId} | Remove a member
[**revokeInvite**](WorkspaceApi.md#revokeinvite) | **DELETE** /workspace/invites/{id} | Revoke an open invite
[**setMemberRole**](WorkspaceApi.md#setmemberrole) | **PUT** /workspace/members/{userId}/role | Make a member (not the owner) a user or a viewer
[**setWorkspaceClaudeConnection**](WorkspaceApi.md#setworkspaceclaudeconnection) | **PUT** /workspace/claude/connection | Connect the workspace&#39;s shared Claude account
[**transferWorkspace**](WorkspaceApi.md#transferworkspace) | **POST** /workspace/transfer | Make another member the owner
[**updateWorkspace**](WorkspaceApi.md#updateworkspace) | **PUT** /workspace | Rename the workspace or change its address
[**updateWorkspaceClaude**](WorkspaceApi.md#updateworkspaceclaude) | **PUT** /workspace/claude | Choose the Claude mode, the fallback and the default member


# **createInvite**
> CreateInvite201Response createInvite(createInviteRequest)

Invite someone by email or by a link (valid 7 days)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getWorkspaceApi();
final CreateInviteRequest createInviteRequest = ; // CreateInviteRequest | 

try {
    final response = api.createInvite(createInviteRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling WorkspaceApi->createInvite: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createInviteRequest** | [**CreateInviteRequest**](CreateInviteRequest.md)|  | 

### Return type

[**CreateInvite201Response**](CreateInvite201Response.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteWorkspace**
> deleteWorkspace(deleteWorkspaceRequest)

Delete the workspace (kept 7 days for undo, then purged)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getWorkspaceApi();
final DeleteWorkspaceRequest deleteWorkspaceRequest = ; // DeleteWorkspaceRequest | 

try {
    api.deleteWorkspace(deleteWorkspaceRequest);
} on DioException catch (e) {
    print('Exception when calling WorkspaceApi->deleteWorkspace: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deleteWorkspaceRequest** | [**DeleteWorkspaceRequest**](DeleteWorkspaceRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteWorkspaceClaudeConnection**
> deleteWorkspaceClaudeConnection(provider)

Disconnect the workspace's shared Claude or Muse account

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getWorkspaceApi();
final String provider = provider_example; // String | The module whose account it is: muse or claude (Codex runs on the workspace's OpenAI key). Defaults to your default module.

try {
    api.deleteWorkspaceClaudeConnection(provider);
} on DioException catch (e) {
    print('Exception when calling WorkspaceApi->deleteWorkspaceClaudeConnection: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **provider** | **String**| The module whose account it is: muse or claude (Codex runs on the workspace's OpenAI key). Defaults to your default module. | [optional] 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getQueue**
> QueueStatus getQueue()

Where the workspace's tickets stand in the queue

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getWorkspaceApi();

try {
    final response = api.getQueue();
    print(response);
} on DioException catch (e) {
    print('Exception when calling WorkspaceApi->getQueue: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**QueueStatus**](QueueStatus.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getWorkspace**
> WorkspaceDetail getWorkspace()

The current workspace and your role in it

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getWorkspaceApi();

try {
    final response = api.getWorkspace();
    print(response);
} on DioException catch (e) {
    print('Exception when calling WorkspaceApi->getWorkspace: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**WorkspaceDetail**](WorkspaceDetail.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getWorkspaceClaude**
> WorkspaceClaude getWorkspaceClaude(provider)

Which Claude or Muse account the workspace's runs use

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getWorkspaceApi();
final String provider = provider_example; // String | The module whose account it is: muse or claude (Codex runs on the workspace's OpenAI key). Defaults to your default module.

try {
    final response = api.getWorkspaceClaude(provider);
    print(response);
} on DioException catch (e) {
    print('Exception when calling WorkspaceApi->getWorkspaceClaude: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **provider** | **String**| The module whose account it is: muse or claude (Codex runs on the workspace's OpenAI key). Defaults to your default module. | [optional] 

### Return type

[**WorkspaceClaude**](WorkspaceClaude.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **leaveWorkspace**
> leaveWorkspace()

Leave the workspace

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getWorkspaceApi();

try {
    api.leaveWorkspace();
} on DioException catch (e) {
    print('Exception when calling WorkspaceApi->leaveWorkspace: $e\n');
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

# **listInvites**
> List<Invite> listInvites()

Open invites

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getWorkspaceApi();

try {
    final response = api.listInvites();
    print(response);
} on DioException catch (e) {
    print('Exception when calling WorkspaceApi->listInvites: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;Invite&gt;**](Invite.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listMembers**
> List<Member> listMembers()

The workspace's members

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getWorkspaceApi();

try {
    final response = api.listMembers();
    print(response);
} on DioException catch (e) {
    print('Exception when calling WorkspaceApi->listMembers: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;Member&gt;**](Member.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **removeMember**
> removeMember(userId)

Remove a member

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getWorkspaceApi();
final int userId = 789; // int | 

try {
    api.removeMember(userId);
} on DioException catch (e) {
    print('Exception when calling WorkspaceApi->removeMember: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **int**|  | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **revokeInvite**
> revokeInvite(id)

Revoke an open invite

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getWorkspaceApi();
final int id = 789; // int | 

try {
    api.revokeInvite(id);
} on DioException catch (e) {
    print('Exception when calling WorkspaceApi->revokeInvite: $e\n');
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

# **setMemberRole**
> setMemberRole(userId, setMemberRoleRequest)

Make a member (not the owner) a user or a viewer

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getWorkspaceApi();
final int userId = 789; // int | 
final SetMemberRoleRequest setMemberRoleRequest = ; // SetMemberRoleRequest | 

try {
    api.setMemberRole(userId, setMemberRoleRequest);
} on DioException catch (e) {
    print('Exception when calling WorkspaceApi->setMemberRole: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **int**|  | 
 **setMemberRoleRequest** | [**SetMemberRoleRequest**](SetMemberRoleRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setWorkspaceClaudeConnection**
> WorkspaceClaude setWorkspaceClaudeConnection(claudeConnectionInput)

Connect the workspace's shared Claude account

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getWorkspaceApi();
final ClaudeConnectionInput claudeConnectionInput = ; // ClaudeConnectionInput | 

try {
    final response = api.setWorkspaceClaudeConnection(claudeConnectionInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling WorkspaceApi->setWorkspaceClaudeConnection: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **claudeConnectionInput** | [**ClaudeConnectionInput**](ClaudeConnectionInput.md)|  | 

### Return type

[**WorkspaceClaude**](WorkspaceClaude.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **transferWorkspace**
> transferWorkspace(transferWorkspaceRequest)

Make another member the owner

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getWorkspaceApi();
final TransferWorkspaceRequest transferWorkspaceRequest = ; // TransferWorkspaceRequest | 

try {
    api.transferWorkspace(transferWorkspaceRequest);
} on DioException catch (e) {
    print('Exception when calling WorkspaceApi->transferWorkspace: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **transferWorkspaceRequest** | [**TransferWorkspaceRequest**](TransferWorkspaceRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateWorkspace**
> WorkspaceDetail updateWorkspace(updateWorkspaceRequest)

Rename the workspace or change its address

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getWorkspaceApi();
final UpdateWorkspaceRequest updateWorkspaceRequest = ; // UpdateWorkspaceRequest | 

try {
    final response = api.updateWorkspace(updateWorkspaceRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling WorkspaceApi->updateWorkspace: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **updateWorkspaceRequest** | [**UpdateWorkspaceRequest**](UpdateWorkspaceRequest.md)|  | 

### Return type

[**WorkspaceDetail**](WorkspaceDetail.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateWorkspaceClaude**
> WorkspaceClaude updateWorkspaceClaude(updateWorkspaceClaudeRequest)

Choose the Claude mode, the fallback and the default member

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getWorkspaceApi();
final UpdateWorkspaceClaudeRequest updateWorkspaceClaudeRequest = ; // UpdateWorkspaceClaudeRequest | 

try {
    final response = api.updateWorkspaceClaude(updateWorkspaceClaudeRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling WorkspaceApi->updateWorkspaceClaude: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **updateWorkspaceClaudeRequest** | [**UpdateWorkspaceClaudeRequest**](UpdateWorkspaceClaudeRequest.md)|  | 

### Return type

[**WorkspaceClaude**](WorkspaceClaude.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

