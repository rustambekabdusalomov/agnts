# agnts_api.api.ReposApi

## Load the API package
```dart
import 'package:agnts_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**archiveRepo**](ReposApi.md#archiverepo) | **POST** /repos/{id}/archive | Archive the repository; it keeps its history but takes no new tickets or tasks
[**createRepo**](ReposApi.md#createrepo) | **POST** /repos | 
[**deployRepo**](ReposApi.md#deployrepo) | **POST** /repos/{id}/deploy | Start a deployment (GitLab manual job, or the GitHub deploy workflow). Never available from MCP.
[**getRepo**](ReposApi.md#getrepo) | **GET** /repos/{id} | 
[**listRepoBranches**](ReposApi.md#listrepobranches) | **GET** /repos/{id}/branches | Branches with their tip, ahead/behind the default branch and checks
[**listRepoCommits**](ReposApi.md#listrepocommits) | **GET** /repos/{id}/commits | Commits on the default branch, newest first, 50 per page; a shorter page is the last
[**listRepoEnvironments**](ReposApi.md#listrepoenvironments) | **GET** /repos/{id}/environments | Deployment environments and what runs there
[**listRepoLocalBranches**](ReposApi.md#listrepolocalbranches) | **GET** /repos/{id}/local-branches | Branches in agnts&#39;s own clones on the server, and whether origin has them
[**listRepoMembers**](ReposApi.md#listrepomembers) | **GET** /repos/{id}/members | People with access to the repository on its git host
[**listRepoPipelines**](ReposApi.md#listrepopipelines) | **GET** /repos/{id}/pipelines | CI runs with their stages, newest first, 20 per page; a shorter page is the last
[**listRepos**](ReposApi.md#listrepos) | **GET** /repos | 
[**unarchiveRepo**](ReposApi.md#unarchiverepo) | **POST** /repos/{id}/unarchive | Restore an archived repository
[**updateRepo**](ReposApi.md#updaterepo) | **PUT** /repos/{id} | 


# **archiveRepo**
> Repository archiveRepo(id)

Archive the repository; it keeps its history but takes no new tickets or tasks

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReposApi();
final int id = 789; // int | 

try {
    final response = api.archiveRepo(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReposApi->archiveRepo: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**Repository**](Repository.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createRepo**
> Repository createRepo(repositoryInput)



### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReposApi();
final RepositoryInput repositoryInput = ; // RepositoryInput | 

try {
    final response = api.createRepo(repositoryInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReposApi->createRepo: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **repositoryInput** | [**RepositoryInput**](RepositoryInput.md)|  | 

### Return type

[**Repository**](Repository.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deployRepo**
> deployRepo(id, deployRepoRequest)

Start a deployment (GitLab manual job, or the GitHub deploy workflow). Never available from MCP.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReposApi();
final int id = 789; // int | 
final DeployRepoRequest deployRepoRequest = ; // DeployRepoRequest | 

try {
    api.deployRepo(id, deployRepoRequest);
} on DioException catch (e) {
    print('Exception when calling ReposApi->deployRepo: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **deployRepoRequest** | [**DeployRepoRequest**](DeployRepoRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRepo**
> Repository getRepo(id)



### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReposApi();
final int id = 789; // int | 

try {
    final response = api.getRepo(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReposApi->getRepo: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**Repository**](Repository.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listRepoBranches**
> List<Branch> listRepoBranches(id)

Branches with their tip, ahead/behind the default branch and checks

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReposApi();
final int id = 789; // int | 

try {
    final response = api.listRepoBranches(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReposApi->listRepoBranches: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**List&lt;Branch&gt;**](Branch.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listRepoCommits**
> List<Commit> listRepoCommits(id, page)

Commits on the default branch, newest first, 50 per page; a shorter page is the last

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReposApi();
final int id = 789; // int | 
final int page = 56; // int | 

try {
    final response = api.listRepoCommits(id, page);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReposApi->listRepoCommits: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **page** | **int**|  | [optional] [default to 1]

### Return type

[**List&lt;Commit&gt;**](Commit.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listRepoEnvironments**
> List<Environment> listRepoEnvironments(id)

Deployment environments and what runs there

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReposApi();
final int id = 789; // int | 

try {
    final response = api.listRepoEnvironments(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReposApi->listRepoEnvironments: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**List&lt;Environment&gt;**](Environment.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listRepoLocalBranches**
> List<LocalBranch> listRepoLocalBranches(id)

Branches in agnts's own clones on the server, and whether origin has them

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReposApi();
final int id = 789; // int | 

try {
    final response = api.listRepoLocalBranches(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReposApi->listRepoLocalBranches: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**List&lt;LocalBranch&gt;**](LocalBranch.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listRepoMembers**
> List<RepoMember> listRepoMembers(id)

People with access to the repository on its git host

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReposApi();
final int id = 789; // int | 

try {
    final response = api.listRepoMembers(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReposApi->listRepoMembers: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**List&lt;RepoMember&gt;**](RepoMember.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listRepoPipelines**
> List<Pipeline> listRepoPipelines(id, page)

CI runs with their stages, newest first, 20 per page; a shorter page is the last

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReposApi();
final int id = 789; // int | 
final int page = 56; // int | 

try {
    final response = api.listRepoPipelines(id, page);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReposApi->listRepoPipelines: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **page** | **int**|  | [optional] [default to 1]

### Return type

[**List&lt;Pipeline&gt;**](Pipeline.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listRepos**
> List<Repository> listRepos()



### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReposApi();

try {
    final response = api.listRepos();
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReposApi->listRepos: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;Repository&gt;**](Repository.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **unarchiveRepo**
> Repository unarchiveRepo(id)

Restore an archived repository

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReposApi();
final int id = 789; // int | 

try {
    final response = api.unarchiveRepo(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReposApi->unarchiveRepo: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**Repository**](Repository.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateRepo**
> Repository updateRepo(id, repositoryInput)



### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReposApi();
final int id = 789; // int | 
final RepositoryInput repositoryInput = ; // RepositoryInput | 

try {
    final response = api.updateRepo(id, repositoryInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReposApi->updateRepo: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **repositoryInput** | [**RepositoryInput**](RepositoryInput.md)|  | 

### Return type

[**Repository**](Repository.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

