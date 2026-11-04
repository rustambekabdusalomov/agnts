# agnts_api.api.SecurityApi

## Load the API package
```dart
import 'package:agnts_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**cancelSecurityScan**](SecurityApi.md#cancelsecurityscan) | **DELETE** /security/scans/{scanId} | Cancel a queued or running scan (a running one saves nothing)
[**dismissSecurityFindings**](SecurityApi.md#dismisssecurityfindings) | **POST** /security/dismiss | Dismiss findings with a reason; they stay dismissed while their fingerprint matches
[**fixSecurityFindings**](SecurityApi.md#fixsecurityfindings) | **POST** /security/fix | Open one ticket that fixes findings of one repository (Fix this, Fix together)
[**getSecurityFinding**](SecurityApi.md#getsecurityfinding) | **GET** /security/findings/{findingId} | One finding
[**getSecurityScan**](SecurityApi.md#getsecurityscan) | **GET** /security/scans/{scanId} | One scan, with what ran and the hits the agent rejected
[**getSecuritySettings**](SecurityApi.md#getsecuritysettings) | **GET** /repos/{id}/security/settings | A repository&#39;s security settings: schedule, exclusions, lowest severity that notifies
[**getSecuritySummary**](SecurityApi.md#getsecuritysummary) | **GET** /security/summary | Open security findings by repository and severity, with each repository&#39;s last scan
[**getTicketSecurityFindings**](SecurityApi.md#getticketsecurityfindings) | **GET** /tickets/{key}/security-findings | The security findings a fix ticket works on
[**listSecurityFindings**](SecurityApi.md#listsecurityfindings) | **GET** /security/findings | Security findings, worst first
[**listSecurityScans**](SecurityApi.md#listsecurityscans) | **GET** /repos/{id}/security/scans | A repository&#39;s security scans, newest first
[**reopenSecurityFinding**](SecurityApi.md#reopensecurityfinding) | **POST** /security/findings/{findingId}/reopen | Open a dismissed or fixed finding again
[**setSecuritySettings**](SecurityApi.md#setsecuritysettings) | **PUT** /repos/{id}/security/settings | Save a repository&#39;s security settings and schedule its next scan
[**startSecurityScan**](SecurityApi.md#startsecurityscan) | **POST** /repos/{id}/security/scans | Scan the repository&#39;s default branch (a scan already queued or running is returned instead)


# **cancelSecurityScan**
> SecurityScan cancelSecurityScan(scanId)

Cancel a queued or running scan (a running one saves nothing)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getSecurityApi();
final int scanId = 789; // int | 

try {
    final response = api.cancelSecurityScan(scanId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SecurityApi->cancelSecurityScan: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **scanId** | **int**|  | 

### Return type

[**SecurityScan**](SecurityScan.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **dismissSecurityFindings**
> List<SecurityFinding> dismissSecurityFindings(dismissSecurityFindingsRequest)

Dismiss findings with a reason; they stay dismissed while their fingerprint matches

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getSecurityApi();
final DismissSecurityFindingsRequest dismissSecurityFindingsRequest = ; // DismissSecurityFindingsRequest | 

try {
    final response = api.dismissSecurityFindings(dismissSecurityFindingsRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SecurityApi->dismissSecurityFindings: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **dismissSecurityFindingsRequest** | [**DismissSecurityFindingsRequest**](DismissSecurityFindingsRequest.md)|  | 

### Return type

[**List&lt;SecurityFinding&gt;**](SecurityFinding.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **fixSecurityFindings**
> Ticket fixSecurityFindings(fixSecurityFindingsRequest)

Open one ticket that fixes findings of one repository (Fix this, Fix together)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getSecurityApi();
final FixSecurityFindingsRequest fixSecurityFindingsRequest = ; // FixSecurityFindingsRequest | 

try {
    final response = api.fixSecurityFindings(fixSecurityFindingsRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SecurityApi->fixSecurityFindings: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **fixSecurityFindingsRequest** | [**FixSecurityFindingsRequest**](FixSecurityFindingsRequest.md)|  | 

### Return type

[**Ticket**](Ticket.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSecurityFinding**
> SecurityFinding getSecurityFinding(findingId)

One finding

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getSecurityApi();
final int findingId = 789; // int | 

try {
    final response = api.getSecurityFinding(findingId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SecurityApi->getSecurityFinding: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **findingId** | **int**|  | 

### Return type

[**SecurityFinding**](SecurityFinding.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSecurityScan**
> SecurityScan getSecurityScan(scanId)

One scan, with what ran and the hits the agent rejected

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getSecurityApi();
final int scanId = 789; // int | 

try {
    final response = api.getSecurityScan(scanId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SecurityApi->getSecurityScan: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **scanId** | **int**|  | 

### Return type

[**SecurityScan**](SecurityScan.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSecuritySettings**
> SecuritySettings getSecuritySettings(id)

A repository's security settings: schedule, exclusions, lowest severity that notifies

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getSecurityApi();
final int id = 789; // int | 

try {
    final response = api.getSecuritySettings(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SecurityApi->getSecuritySettings: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**SecuritySettings**](SecuritySettings.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSecuritySummary**
> List<SecurityRepoSummary> getSecuritySummary()

Open security findings by repository and severity, with each repository's last scan

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getSecurityApi();

try {
    final response = api.getSecuritySummary();
    print(response);
} on DioException catch (e) {
    print('Exception when calling SecurityApi->getSecuritySummary: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;SecurityRepoSummary&gt;**](SecurityRepoSummary.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getTicketSecurityFindings**
> List<SecurityFinding> getTicketSecurityFindings(key)

The security findings a fix ticket works on

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getSecurityApi();
final String key = key_example; // String | 

try {
    final response = api.getTicketSecurityFindings(key);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SecurityApi->getTicketSecurityFindings: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 

### Return type

[**List&lt;SecurityFinding&gt;**](SecurityFinding.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listSecurityFindings**
> List<SecurityFinding> listSecurityFindings(repoId, status, severity, active)

Security findings, worst first

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getSecurityApi();
final int repoId = 789; // int | 
final SecFindingStatus status = ; // SecFindingStatus | 
final SecSeverity severity = ; // SecSeverity | 
final bool active = true; // bool | Only open, fixing, verifying and reopened findings

try {
    final response = api.listSecurityFindings(repoId, status, severity, active);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SecurityApi->listSecurityFindings: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **repoId** | **int**|  | [optional] 
 **status** | [**SecFindingStatus**](.md)|  | [optional] 
 **severity** | [**SecSeverity**](.md)|  | [optional] 
 **active** | **bool**| Only open, fixing, verifying and reopened findings | [optional] 

### Return type

[**List&lt;SecurityFinding&gt;**](SecurityFinding.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listSecurityScans**
> List<SecurityScan> listSecurityScans(id)

A repository's security scans, newest first

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getSecurityApi();
final int id = 789; // int | 

try {
    final response = api.listSecurityScans(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SecurityApi->listSecurityScans: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**List&lt;SecurityScan&gt;**](SecurityScan.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **reopenSecurityFinding**
> SecurityFinding reopenSecurityFinding(findingId)

Open a dismissed or fixed finding again

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getSecurityApi();
final int findingId = 789; // int | 

try {
    final response = api.reopenSecurityFinding(findingId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SecurityApi->reopenSecurityFinding: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **findingId** | **int**|  | 

### Return type

[**SecurityFinding**](SecurityFinding.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setSecuritySettings**
> SecuritySettings setSecuritySettings(id, securitySettings)

Save a repository's security settings and schedule its next scan

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getSecurityApi();
final int id = 789; // int | 
final SecuritySettings securitySettings = ; // SecuritySettings | 

try {
    final response = api.setSecuritySettings(id, securitySettings);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SecurityApi->setSecuritySettings: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **securitySettings** | [**SecuritySettings**](SecuritySettings.md)|  | 

### Return type

[**SecuritySettings**](SecuritySettings.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startSecurityScan**
> StartSecurityScan200Response startSecurityScan(id)

Scan the repository's default branch (a scan already queued or running is returned instead)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getSecurityApi();
final int id = 789; // int | 

try {
    final response = api.startSecurityScan(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SecurityApi->startSecurityScan: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**StartSecurityScan200Response**](StartSecurityScan200Response.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

