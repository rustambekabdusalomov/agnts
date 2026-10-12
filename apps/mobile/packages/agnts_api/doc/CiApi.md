# agnts_api.api.CiApi

## Load the API package
```dart
import 'package:agnts_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**fixCIFailure**](CiApi.md#fixcifailure) | **POST** /ci/failures/{failureId}/fix | Open a ticket that fixes the failure now (ignores the auto-fix setting and the daily budget)
[**getCIFailure**](CiApi.md#getcifailure) | **GET** /ci/failures/{failureId} | One CI failure group with its redacted log excerpt
[**getRepoCIWatch**](CiApi.md#getrepociwatch) | **GET** /repos/{id}/ci-watch | How agnts watches this repository&#39;s CI, and whether the git token can read it
[**getTicketCIFailure**](CiApi.md#getticketcifailure) | **GET** /tickets/{key}/ci | The CI failure a CI ticket fixes (404 for other tickets)
[**listCIFailures**](CiApi.md#listcifailures) | **GET** /ci/failures | CI failure groups, newest occurrence first
[**muteCIFailure**](CiApi.md#mutecifailure) | **POST** /ci/failures/{failureId}/mute | Ignore this failure (no tickets, no notifications)
[**putRepoCIWatch**](CiApi.md#putrepociwatch) | **PUT** /repos/{id}/ci-watch | Change how agnts watches this repository&#39;s CI
[**rerunCIFailure**](CiApi.md#reruncifailure) | **POST** /ci/failures/{failureId}/rerun | Re-run the failed jobs of the newest failing run on the git host
[**unmuteCIFailure**](CiApi.md#unmutecifailure) | **POST** /ci/failures/{failureId}/unmute | Watch a muted failure again


# **fixCIFailure**
> Ticket fixCIFailure(failureId)

Open a ticket that fixes the failure now (ignores the auto-fix setting and the daily budget)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getCiApi();
final int failureId = 789; // int | 

try {
    final response = api.fixCIFailure(failureId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CiApi->fixCIFailure: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **failureId** | **int**|  | 

### Return type

[**Ticket**](Ticket.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCIFailure**
> CIFailure getCIFailure(failureId)

One CI failure group with its redacted log excerpt

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getCiApi();
final int failureId = 789; // int | 

try {
    final response = api.getCIFailure(failureId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CiApi->getCIFailure: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **failureId** | **int**|  | 

### Return type

[**CIFailure**](CIFailure.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRepoCIWatch**
> CIWatch getRepoCIWatch(id)

How agnts watches this repository's CI, and whether the git token can read it

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getCiApi();
final int id = 789; // int | 

try {
    final response = api.getRepoCIWatch(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CiApi->getRepoCIWatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**CIWatch**](CIWatch.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getTicketCIFailure**
> CIFailure getTicketCIFailure(key)

The CI failure a CI ticket fixes (404 for other tickets)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getCiApi();
final String key = key_example; // String | 

try {
    final response = api.getTicketCIFailure(key);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CiApi->getTicketCIFailure: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 

### Return type

[**CIFailure**](CIFailure.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listCIFailures**
> List<CIFailure> listCIFailures(repoId, status)

CI failure groups, newest occurrence first

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getCiApi();
final int repoId = 789; // int | 
final String status = status_example; // String | Comma-separated statuses; empty for all

try {
    final response = api.listCIFailures(repoId, status);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CiApi->listCIFailures: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **repoId** | **int**|  | [optional] 
 **status** | **String**| Comma-separated statuses; empty for all | [optional] 

### Return type

[**List&lt;CIFailure&gt;**](CIFailure.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **muteCIFailure**
> CIFailure muteCIFailure(failureId)

Ignore this failure (no tickets, no notifications)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getCiApi();
final int failureId = 789; // int | 

try {
    final response = api.muteCIFailure(failureId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CiApi->muteCIFailure: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **failureId** | **int**|  | 

### Return type

[**CIFailure**](CIFailure.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **putRepoCIWatch**
> CIWatch putRepoCIWatch(id, cIWatch)

Change how agnts watches this repository's CI

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getCiApi();
final int id = 789; // int | 
final CIWatch cIWatch = ; // CIWatch | 

try {
    final response = api.putRepoCIWatch(id, cIWatch);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CiApi->putRepoCIWatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **cIWatch** | [**CIWatch**](CIWatch.md)|  | 

### Return type

[**CIWatch**](CIWatch.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rerunCIFailure**
> rerunCIFailure(failureId)

Re-run the failed jobs of the newest failing run on the git host

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getCiApi();
final int failureId = 789; // int | 

try {
    api.rerunCIFailure(failureId);
} on DioException catch (e) {
    print('Exception when calling CiApi->rerunCIFailure: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **failureId** | **int**|  | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **unmuteCIFailure**
> CIFailure unmuteCIFailure(failureId)

Watch a muted failure again

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getCiApi();
final int failureId = 789; // int | 

try {
    final response = api.unmuteCIFailure(failureId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CiApi->unmuteCIFailure: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **failureId** | **int**|  | 

### Return type

[**CIFailure**](CIFailure.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

