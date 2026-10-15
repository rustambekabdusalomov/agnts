# agnts_api.api.PullsApi

## Load the API package
```dart
import 'package:agnts_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addPullComment**](PullsApi.md#addpullcomment) | **POST** /repos/{id}/pulls/{number}/comments | Comment on a pull request, or on a line of its diff, as the git host token&#39;s user
[**deletePullComment**](PullsApi.md#deletepullcomment) | **DELETE** /repos/{id}/pulls/{number}/comments | Delete a comment (your own, on the git host)
[**editPullComment**](PullsApi.md#editpullcomment) | **PATCH** /repos/{id}/pulls/{number}/comments | Replace the text of a comment (your own, on the git host)
[**getRepoPull**](PullsApi.md#getrepopull) | **GET** /repos/{id}/pulls/{number} | A pull request as it stands on the git host, with the files it changes
[**listPullThreads**](PullsApi.md#listpullthreads) | **GET** /repos/{id}/pulls/{number}/threads | A pull request&#39;s conversation: general comments, review summaries and threads on diff lines, oldest first
[**listRepoPulls**](PullsApi.md#listrepopulls) | **GET** /repos/{id}/pulls | The repository&#39;s pull requests (GitLab merge requests), most recently updated first, 30 per page; a shorter page is the last
[**replyPullThread**](PullsApi.md#replypullthread) | **POST** /repos/{id}/pulls/{number}/replies | Answer in a thread of a pull request
[**resolvePullThread**](PullsApi.md#resolvepullthread) | **POST** /repos/{id}/pulls/{number}/resolve | Resolve or reopen a thread on a diff line


# **addPullComment**
> PullThread addPullComment(id, number, newPullComment)

Comment on a pull request, or on a line of its diff, as the git host token's user

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getPullsApi();
final int id = 789; // int | 
final int number = 56; // int | 
final NewPullComment newPullComment = ; // NewPullComment | 

try {
    final response = api.addPullComment(id, number, newPullComment);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PullsApi->addPullComment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **number** | **int**|  | 
 **newPullComment** | [**NewPullComment**](NewPullComment.md)|  | 

### Return type

[**PullThread**](PullThread.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deletePullComment**
> deletePullComment(id, number, commentId)

Delete a comment (your own, on the git host)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getPullsApi();
final int id = 789; // int | 
final int number = 56; // int | 
final String commentId = commentId_example; // String | 

try {
    api.deletePullComment(id, number, commentId);
} on DioException catch (e) {
    print('Exception when calling PullsApi->deletePullComment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **number** | **int**|  | 
 **commentId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **editPullComment**
> PullComment editPullComment(id, number, editPullCommentRequest)

Replace the text of a comment (your own, on the git host)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getPullsApi();
final int id = 789; // int | 
final int number = 56; // int | 
final EditPullCommentRequest editPullCommentRequest = ; // EditPullCommentRequest | 

try {
    final response = api.editPullComment(id, number, editPullCommentRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PullsApi->editPullComment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **number** | **int**|  | 
 **editPullCommentRequest** | [**EditPullCommentRequest**](EditPullCommentRequest.md)|  | 

### Return type

[**PullComment**](PullComment.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRepoPull**
> PullDetail getRepoPull(id, number)

A pull request as it stands on the git host, with the files it changes

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getPullsApi();
final int id = 789; // int | 
final int number = 56; // int | 

try {
    final response = api.getRepoPull(id, number);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PullsApi->getRepoPull: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **number** | **int**|  | 

### Return type

[**PullDetail**](PullDetail.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPullThreads**
> List<PullThread> listPullThreads(id, number)

A pull request's conversation: general comments, review summaries and threads on diff lines, oldest first

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getPullsApi();
final int id = 789; // int | 
final int number = 56; // int | 

try {
    final response = api.listPullThreads(id, number);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PullsApi->listPullThreads: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **number** | **int**|  | 

### Return type

[**List&lt;PullThread&gt;**](PullThread.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listRepoPulls**
> List<PullItem> listRepoPulls(id, state, page)

The repository's pull requests (GitLab merge requests), most recently updated first, 30 per page; a shorter page is the last

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getPullsApi();
final int id = 789; // int | 
final String state = state_example; // String | 
final int page = 56; // int | 

try {
    final response = api.listRepoPulls(id, state, page);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PullsApi->listRepoPulls: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **state** | **String**|  | [optional] [default to 'open']
 **page** | **int**|  | [optional] [default to 1]

### Return type

[**List&lt;PullItem&gt;**](PullItem.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **replyPullThread**
> PullComment replyPullThread(id, number, replyPullThreadRequest)

Answer in a thread of a pull request

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getPullsApi();
final int id = 789; // int | 
final int number = 56; // int | 
final ReplyPullThreadRequest replyPullThreadRequest = ; // ReplyPullThreadRequest | 

try {
    final response = api.replyPullThread(id, number, replyPullThreadRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PullsApi->replyPullThread: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **number** | **int**|  | 
 **replyPullThreadRequest** | [**ReplyPullThreadRequest**](ReplyPullThreadRequest.md)|  | 

### Return type

[**PullComment**](PullComment.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **resolvePullThread**
> resolvePullThread(id, number, resolvePullThreadRequest)

Resolve or reopen a thread on a diff line

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getPullsApi();
final int id = 789; // int | 
final int number = 56; // int | 
final ResolvePullThreadRequest resolvePullThreadRequest = ; // ResolvePullThreadRequest | 

try {
    api.resolvePullThread(id, number, resolvePullThreadRequest);
} on DioException catch (e) {
    print('Exception when calling PullsApi->resolvePullThread: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **number** | **int**|  | 
 **resolvePullThreadRequest** | [**ResolvePullThreadRequest**](ResolvePullThreadRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

