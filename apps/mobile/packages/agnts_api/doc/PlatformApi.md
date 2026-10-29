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
[**downloadPlatformRun**](PlatformApi.md#downloadplatformrun) | **GET** /platform/runs/{id}/download | The transcript as JSON lines, the stored normalised events, not Claude Code&#39;s raw output (Admin). Audited.
[**getPlatformOverview**](PlatformApi.md#getplatformoverview) | **GET** /platform/overview | Servers, runs and the queue across every workspace (Admin)
[**getPlatformRun**](PlatformApi.md#getplatformrun) | **GET** /platform/runs/{id} | One transcript with its whole timeline (Admin). Customer content; the read is written to the audit log first.
[**getPlatformRunPrompt**](PlatformApi.md#getplatformrunprompt) | **GET** /platform/runs/{id}/prompt | The prompt agnts sent (Admin). Audited.
[**getPlatformRunSummary**](PlatformApi.md#getplatformrunsummary) | **GET** /platform/runs/summary | Totals of the run history matching the filters (Admin)
[**getRunHistorySettings**](PlatformApi.md#getrunhistorysettings) | **GET** /platform/settings/run-history | How long run history is kept, and its size limits (Admin)
[**grantCredits**](PlatformApi.md#grantcredits) | **POST** /platform/workspaces/{id}/credits | Grant (or take back, when negative) credits (Admin)
[**listPlatformAudit**](PlatformApi.md#listplatformaudit) | **GET** /platform/audit | What Admins read of customer content, newest first (Admin)
[**listPlatformFeedback**](PlatformApi.md#listplatformfeedback) | **GET** /platform/feedback | Every feedback people sent, newest first (Admin)
[**listPlatformRuns**](PlatformApi.md#listplatformruns) | **GET** /platform/runs | Run history across every workspace, newest first, without prompts or transcripts (Admin)
[**listPlatformUsers**](PlatformApi.md#listplatformusers) | **GET** /platform/users | Every user, with their workspaces and last sign-in (Admin)
[**listPlatformWorkspaces**](PlatformApi.md#listplatformworkspaces) | **GET** /platform/workspaces | Every workspace, metadata only (Admin)
[**setCreditLimit**](PlatformApi.md#setcreditlimit) | **PUT** /platform/users/{id}/credit-limit | Set the most credits a person may spend on agnts&#39;s Muse key per calendar month, free and bought together (Admin); 0 is no limit
[**setFreeCredits**](PlatformApi.md#setfreecredits) | **PUT** /platform/users/{id}/free-credits | Set how many free credits a person may spend on agnts&#39;s Muse key (Admin); 0 gives none
[**setRunHistorySettings**](PlatformApi.md#setrunhistorysettings) | **PUT** /platform/settings/run-history | Change how long run history is kept, and its size limits (Admin)
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

# **downloadPlatformRun**
> String downloadPlatformRun(id)

The transcript as JSON lines, the stored normalised events, not Claude Code's raw output (Admin). Audited.

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
    final response = api.downloadPlatformRun(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PlatformApi->downloadPlatformRun: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

**String**

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/x-ndjson, application/json

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

# **getPlatformRun**
> RunTranscriptDetail getPlatformRun(id)

One transcript with its whole timeline (Admin). Customer content; the read is written to the audit log first.

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
    final response = api.getPlatformRun(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PlatformApi->getPlatformRun: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**RunTranscriptDetail**](RunTranscriptDetail.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPlatformRunPrompt**
> GetPlatformRunPrompt200Response getPlatformRunPrompt(id)

The prompt agnts sent (Admin). Audited.

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
    final response = api.getPlatformRunPrompt(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PlatformApi->getPlatformRunPrompt: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**GetPlatformRunPrompt200Response**](GetPlatformRunPrompt200Response.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPlatformRunSummary**
> RunHistorySummary getPlatformRunSummary(workspace, purpose, status, engine, model, ticket, stalled, from, to, minCost)

Totals of the run history matching the filters (Admin)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getPlatformApi();
final int workspace = 789; // int | 
final String purpose = purpose_example; // String | A stage (analyze, code, review…), a background call (assistant, brief, detect, reflect, rules, translate), second_opinion, or the groups stages and background
final String status = status_example; // String | 
final String engine = engine_example; // String | 
final String model = model_example; // String | Part of a model name
final String ticket = ticket_example; // String | A ticket key, or its start
final bool stalled = true; // bool | Only invocations that had stalls
final DateTime from = 2013-10-20T19:20:30+01:00; // DateTime | 
final DateTime to = 2013-10-20T19:20:30+01:00; // DateTime | 
final num minCost = 8.14; // num | Only invocations that cost at least this many USD

try {
    final response = api.getPlatformRunSummary(workspace, purpose, status, engine, model, ticket, stalled, from, to, minCost);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PlatformApi->getPlatformRunSummary: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **workspace** | **int**|  | [optional] 
 **purpose** | **String**| A stage (analyze, code, review…), a background call (assistant, brief, detect, reflect, rules, translate), second_opinion, or the groups stages and background | [optional] 
 **status** | **String**|  | [optional] 
 **engine** | **String**|  | [optional] 
 **model** | **String**| Part of a model name | [optional] 
 **ticket** | **String**| A ticket key, or its start | [optional] 
 **stalled** | **bool**| Only invocations that had stalls | [optional] 
 **from** | **DateTime**|  | [optional] 
 **to** | **DateTime**|  | [optional] 
 **minCost** | **num**| Only invocations that cost at least this many USD | [optional] 

### Return type

[**RunHistorySummary**](RunHistorySummary.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRunHistorySettings**
> RunHistorySettings getRunHistorySettings()

How long run history is kept, and its size limits (Admin)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getPlatformApi();

try {
    final response = api.getRunHistorySettings();
    print(response);
} on DioException catch (e) {
    print('Exception when calling PlatformApi->getRunHistorySettings: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**RunHistorySettings**](RunHistorySettings.md)

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

# **listPlatformAudit**
> List<AdminAuditEntry> listPlatformAudit(admin, action, workspace, before, limit)

What Admins read of customer content, newest first (Admin)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getPlatformApi();
final int admin = 789; // int | 
final String action = action_example; // String | 
final int workspace = 789; // int | 
final int before = 789; // int | Only rows with a smaller id (pagination)
final int limit = 56; // int | 

try {
    final response = api.listPlatformAudit(admin, action, workspace, before, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PlatformApi->listPlatformAudit: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **admin** | **int**|  | [optional] 
 **action** | **String**|  | [optional] 
 **workspace** | **int**|  | [optional] 
 **before** | **int**| Only rows with a smaller id (pagination) | [optional] 
 **limit** | **int**|  | [optional] [default to 100]

### Return type

[**List&lt;AdminAuditEntry&gt;**](AdminAuditEntry.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
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

# **listPlatformRuns**
> RunHistoryPage listPlatformRuns(workspace, purpose, status, engine, model, ticket, stalled, from, to, minCost, cursor, limit)

Run history across every workspace, newest first, without prompts or transcripts (Admin)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getPlatformApi();
final int workspace = 789; // int | 
final String purpose = purpose_example; // String | A stage (analyze, code, review…), a background call (assistant, brief, detect, reflect, rules, translate), second_opinion, or the groups stages and background
final String status = status_example; // String | 
final String engine = engine_example; // String | 
final String model = model_example; // String | Part of a model name
final String ticket = ticket_example; // String | A ticket key, or its start
final bool stalled = true; // bool | Only invocations that had stalls
final DateTime from = 2013-10-20T19:20:30+01:00; // DateTime | 
final DateTime to = 2013-10-20T19:20:30+01:00; // DateTime | 
final num minCost = 8.14; // num | Only invocations that cost at least this many USD
final String cursor = cursor_example; // String | nextCursor of the previous page
final int limit = 56; // int | 

try {
    final response = api.listPlatformRuns(workspace, purpose, status, engine, model, ticket, stalled, from, to, minCost, cursor, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PlatformApi->listPlatformRuns: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **workspace** | **int**|  | [optional] 
 **purpose** | **String**| A stage (analyze, code, review…), a background call (assistant, brief, detect, reflect, rules, translate), second_opinion, or the groups stages and background | [optional] 
 **status** | **String**|  | [optional] 
 **engine** | **String**|  | [optional] 
 **model** | **String**| Part of a model name | [optional] 
 **ticket** | **String**| A ticket key, or its start | [optional] 
 **stalled** | **bool**| Only invocations that had stalls | [optional] 
 **from** | **DateTime**|  | [optional] 
 **to** | **DateTime**|  | [optional] 
 **minCost** | **num**| Only invocations that cost at least this many USD | [optional] 
 **cursor** | **String**| nextCursor of the previous page | [optional] 
 **limit** | **int**|  | [optional] [default to 50]

### Return type

[**RunHistoryPage**](RunHistoryPage.md)

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

# **setCreditLimit**
> CreditUsage setCreditLimit(id, setCreditLimitRequest)

Set the most credits a person may spend on agnts's Muse key per calendar month, free and bought together (Admin); 0 is no limit

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getPlatformApi();
final int id = 789; // int | 
final SetCreditLimitRequest setCreditLimitRequest = ; // SetCreditLimitRequest | 

try {
    final response = api.setCreditLimit(id, setCreditLimitRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PlatformApi->setCreditLimit: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **setCreditLimitRequest** | [**SetCreditLimitRequest**](SetCreditLimitRequest.md)|  | 

### Return type

[**CreditUsage**](CreditUsage.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setFreeCredits**
> FreeCredits setFreeCredits(id, setFreeCreditsRequest)

Set how many free credits a person may spend on agnts's Muse key (Admin); 0 gives none

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getPlatformApi();
final int id = 789; // int | 
final SetFreeCreditsRequest setFreeCreditsRequest = ; // SetFreeCreditsRequest | 

try {
    final response = api.setFreeCredits(id, setFreeCreditsRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PlatformApi->setFreeCredits: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **setFreeCreditsRequest** | [**SetFreeCreditsRequest**](SetFreeCreditsRequest.md)|  | 

### Return type

[**FreeCredits**](FreeCredits.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setRunHistorySettings**
> RunHistorySettings setRunHistorySettings(runHistorySettings)

Change how long run history is kept, and its size limits (Admin)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getPlatformApi();
final RunHistorySettings runHistorySettings = ; // RunHistorySettings | 

try {
    final response = api.setRunHistorySettings(runHistorySettings);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PlatformApi->setRunHistorySettings: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **runHistorySettings** | [**RunHistorySettings**](RunHistorySettings.md)|  | 

### Return type

[**RunHistorySettings**](RunHistorySettings.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
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

