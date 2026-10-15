# agnts_api.api.ReposApi

## Load the API package
```dart
import 'package:agnts_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**approveRepoBrief**](ReposApi.md#approverepobrief) | **POST** /repos/{id}/brief/approve | Make the draft the brief that runs read
[**archiveRepo**](ReposApi.md#archiverepo) | **POST** /repos/{id}/archive | Archive the repository; it keeps its history but takes no new tickets or tasks
[**createRepo**](ReposApi.md#createrepo) | **POST** /repos | 
[**createRepoGroup**](ReposApi.md#createrepogroup) | **POST** /repo-groups | Create a repository group
[**deleteRepoGroup**](ReposApi.md#deleterepogroup) | **DELETE** /repo-groups/{id} | Delete a group; its tickets keep their repositories
[**deployRepo**](ReposApi.md#deployrepo) | **POST** /repos/{id}/deploy | Start a deployment (GitLab manual job, or the GitHub deploy workflow). Never available from MCP.
[**detectRepo**](ReposApi.md#detectrepo) | **POST** /repos/detect | Work out a repository&#39;s toolchains and check commands
[**discardRepoBriefDraft**](ReposApi.md#discardrepobriefdraft) | **POST** /repos/{id}/brief/discard | Drop the draft a survey wrote
[**getRepo**](ReposApi.md#getrepo) | **GET** /repos/{id} | 
[**getRepoBrief**](ReposApi.md#getrepobrief) | **GET** /repos/{id}/brief | What agnts knows about how the repository works; empty and idle before the first survey
[**getRepoCommit**](ReposApi.md#getrepocommit) | **GET** /repos/{id}/commits/{sha} | One commit with the files it changes, the CI runs on it and the pull requests that contain it
[**getRepoFile**](ReposApi.md#getrepofile) | **GET** /repos/{id}/file | One file of the repository at a branch; the content is left out for binary files and files over 1 MB
[**getRepoGroup**](ReposApi.md#getrepogroup) | **GET** /repo-groups/{id} | 
[**listRepoBranches**](ReposApi.md#listrepobranches) | **GET** /repos/{id}/branches | Branches with their tip, ahead/behind the default branch and checks
[**listRepoCommits**](ReposApi.md#listrepocommits) | **GET** /repos/{id}/commits | Commits on the default branch, newest first, 50 per page; a shorter page is the last
[**listRepoEnvironments**](ReposApi.md#listrepoenvironments) | **GET** /repos/{id}/environments | Deployment environments and what runs there
[**listRepoGroups**](ReposApi.md#listrepogroups) | **GET** /repo-groups | The workspace&#39;s repository groups
[**listRepoLocalBranches**](ReposApi.md#listrepolocalbranches) | **GET** /repos/{id}/local-branches | Branches in agnts&#39;s own clones on the server, and whether origin has them
[**listRepoMembers**](ReposApi.md#listrepomembers) | **GET** /repos/{id}/members | People with access to the repository on its git host
[**listRepoPipelines**](ReposApi.md#listrepopipelines) | **GET** /repos/{id}/pipelines | CI runs with their stages, newest first, 20 per page; a shorter page is the last
[**listRepoTree**](ReposApi.md#listrepotree) | **GET** /repos/{id}/tree | One directory of the repository at a branch, directories first, up to 1,000 entries
[**listRepos**](ReposApi.md#listrepos) | **GET** /repos | 
[**saveRepoBrief**](ReposApi.md#saverepobrief) | **PUT** /repos/{id}/brief | Replace the approved brief with your text; empty text removes it
[**saveRepoHarness**](ReposApi.md#saverepoharness) | **PUT** /repos/{id}/harness | Set the repository&#39;s guard profile, per-file checks, coverage and acceptance check
[**surveyRepoBrief**](ReposApi.md#surveyrepobrief) | **POST** /repos/{id}/brief/survey | Have Claude survey the repository and write a draft brief (an update when it has one)
[**unarchiveRepo**](ReposApi.md#unarchiverepo) | **POST** /repos/{id}/unarchive | Restore an archived repository
[**updateRepo**](ReposApi.md#updaterepo) | **PUT** /repos/{id} | 
[**updateRepoGroup**](ReposApi.md#updaterepogroup) | **PUT** /repo-groups/{id} | Replace a group&#39;s fields and repositories


# **approveRepoBrief**
> RepoBrief approveRepoBrief(id)

Make the draft the brief that runs read

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
    final response = api.approveRepoBrief(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReposApi->approveRepoBrief: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**RepoBrief**](RepoBrief.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

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

# **createRepoGroup**
> RepoGroup createRepoGroup(repoGroupInput)

Create a repository group

A named set of repositories that tickets can change together. Its repositories must be able to share one run container (the same runner image, no clashing toolchain versions); what they share uneasily comes back in warnings.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReposApi();
final RepoGroupInput repoGroupInput = ; // RepoGroupInput | 

try {
    final response = api.createRepoGroup(repoGroupInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReposApi->createRepoGroup: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **repoGroupInput** | [**RepoGroupInput**](RepoGroupInput.md)|  | 

### Return type

[**RepoGroup**](RepoGroup.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteRepoGroup**
> deleteRepoGroup(id)

Delete a group; its tickets keep their repositories

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
    api.deleteRepoGroup(id);
} on DioException catch (e) {
    print('Exception when calling ReposApi->deleteRepoGroup: $e\n');
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

# **detectRepo**
> RepoDetection detectRepo(repoDetectInput)

Work out a repository's toolchains and check commands

Reads the default branch (of a saved repository by id, or of any clone URL) and returns what it needs, without saving. With deep, Claude also reads the README and CI files when the file scan finds nothing; that takes a minute and uses the Claude plan. 

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReposApi();
final RepoDetectInput repoDetectInput = ; // RepoDetectInput | 

try {
    final response = api.detectRepo(repoDetectInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReposApi->detectRepo: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **repoDetectInput** | [**RepoDetectInput**](RepoDetectInput.md)|  | 

### Return type

[**RepoDetection**](RepoDetection.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **discardRepoBriefDraft**
> RepoBrief discardRepoBriefDraft(id)

Drop the draft a survey wrote

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
    final response = api.discardRepoBriefDraft(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReposApi->discardRepoBriefDraft: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**RepoBrief**](RepoBrief.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
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

# **getRepoBrief**
> RepoBrief getRepoBrief(id)

What agnts knows about how the repository works; empty and idle before the first survey

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
    final response = api.getRepoBrief(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReposApi->getRepoBrief: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**RepoBrief**](RepoBrief.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRepoCommit**
> CommitDetail getRepoCommit(id, sha)

One commit with the files it changes, the CI runs on it and the pull requests that contain it

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReposApi();
final int id = 789; // int | 
final String sha = sha_example; // String | 

try {
    final response = api.getRepoCommit(id, sha);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReposApi->getRepoCommit: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **sha** | **String**|  | 

### Return type

[**CommitDetail**](CommitDetail.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRepoFile**
> RepoFile getRepoFile(id, path, ref)

One file of the repository at a branch; the content is left out for binary files and files over 1 MB

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReposApi();
final int id = 789; // int | 
final String path = path_example; // String | The file from the repository root
final String ref = ref_example; // String | Branch, tag or commit; the default branch when left out

try {
    final response = api.getRepoFile(id, path, ref);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReposApi->getRepoFile: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **path** | **String**| The file from the repository root | 
 **ref** | **String**| Branch, tag or commit; the default branch when left out | [optional] 

### Return type

[**RepoFile**](RepoFile.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRepoGroup**
> RepoGroup getRepoGroup(id)



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
    final response = api.getRepoGroup(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReposApi->getRepoGroup: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**RepoGroup**](RepoGroup.md)

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

# **listRepoGroups**
> List<RepoGroup> listRepoGroups()

The workspace's repository groups

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReposApi();

try {
    final response = api.listRepoGroups();
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReposApi->listRepoGroups: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;RepoGroup&gt;**](RepoGroup.md)

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

# **listRepoTree**
> RepoTree listRepoTree(id, ref, path)

One directory of the repository at a branch, directories first, up to 1,000 entries

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReposApi();
final int id = 789; // int | 
final String ref = ref_example; // String | Branch, tag or commit; the default branch when left out
final String path = path_example; // String | The directory from the repository root; the root when left out

try {
    final response = api.listRepoTree(id, ref, path);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReposApi->listRepoTree: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **ref** | **String**| Branch, tag or commit; the default branch when left out | [optional] 
 **path** | **String**| The directory from the repository root; the root when left out | [optional] 

### Return type

[**RepoTree**](RepoTree.md)

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

# **saveRepoBrief**
> RepoBrief saveRepoBrief(id, repoBriefInput)

Replace the approved brief with your text; empty text removes it

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReposApi();
final int id = 789; // int | 
final RepoBriefInput repoBriefInput = ; // RepoBriefInput | 

try {
    final response = api.saveRepoBrief(id, repoBriefInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReposApi->saveRepoBrief: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **repoBriefInput** | [**RepoBriefInput**](RepoBriefInput.md)|  | 

### Return type

[**RepoBrief**](RepoBrief.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **saveRepoHarness**
> Repository saveRepoHarness(id, repoHarnessInput)

Set the repository's guard profile, per-file checks, coverage and acceptance check

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReposApi();
final int id = 789; // int | 
final RepoHarnessInput repoHarnessInput = ; // RepoHarnessInput | 

try {
    final response = api.saveRepoHarness(id, repoHarnessInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReposApi->saveRepoHarness: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **repoHarnessInput** | [**RepoHarnessInput**](RepoHarnessInput.md)|  | 

### Return type

[**Repository**](Repository.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **surveyRepoBrief**
> RepoBrief surveyRepoBrief(id)

Have Claude survey the repository and write a draft brief (an update when it has one)

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
    final response = api.surveyRepoBrief(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReposApi->surveyRepoBrief: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**RepoBrief**](RepoBrief.md)

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

# **updateRepoGroup**
> RepoGroup updateRepoGroup(id, repoGroupInput)

Replace a group's fields and repositories

Tickets already made from the group keep their repositories.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReposApi();
final int id = 789; // int | 
final RepoGroupInput repoGroupInput = ; // RepoGroupInput | 

try {
    final response = api.updateRepoGroup(id, repoGroupInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReposApi->updateRepoGroup: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **repoGroupInput** | [**RepoGroupInput**](RepoGroupInput.md)|  | 

### Return type

[**RepoGroup**](RepoGroup.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

