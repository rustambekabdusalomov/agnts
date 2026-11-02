# agnts_api.api.LogsApi

## Load the API package
```dart
import 'package:agnts_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createLogPushToken**](LogsApi.md#createlogpushtoken) | **POST** /log-sources/{sourceId}/push-token | Make a push source&#39;s token (again); it is shown once
[**createLogSource**](LogsApi.md#createlogsource) | **POST** /log-sources | Add a log source; a pulling source must pass the connection test
[**deleteLogSource**](LogsApi.md#deletelogsource) | **DELETE** /log-sources/{sourceId} | Remove a log source (its findings stay)
[**discoverLogServices**](LogsApi.md#discoverlogservices) | **GET** /log-sources/{sourceId}/discover | The services the source&#39;s logs hold (watched ones as saved, new ones with a suggested repository)
[**exportEvents**](LogsApi.md#exportevents) | **GET** /events/export | Download the log (last 90 days) as JSON lines or CSV
[**fixLogFinding**](LogsApi.md#fixlogfinding) | **POST** /log-findings/{findingId}/fix | Open a ticket for the finding now, on the service&#39;s repositories (ignores the mode and the daily budget)
[**getEventSummary**](LogsApi.md#geteventsummary) | **GET** /events/summary | Run statistics and time per step, for the Logs page
[**getLogFinding**](LogsApi.md#getlogfinding) | **GET** /log-findings/{findingId} | One finding with its redacted log excerpt
[**getLogSource**](LogsApi.md#getlogsource) | **GET** /log-sources/{sourceId} | One log source
[**getTicketLogFinding**](LogsApi.md#getticketlogfinding) | **GET** /tickets/{key}/log-finding | The log finding a log ticket fixes (404 for other tickets)
[**listEvents**](LogsApi.md#listevents) | **GET** /events | The global log, newest first, with filters and a cursor
[**listLogFindings**](LogsApi.md#listlogfindings) | **GET** /log-findings | Findings of the log watcher, newest sighting first
[**listLogSources**](LogsApi.md#listlogsources) | **GET** /log-sources | The logging systems agnts reads, and the push sources, with their services and health
[**muteLogFinding**](LogsApi.md#mutelogfinding) | **POST** /log-findings/{findingId}/mute | Ignore this finding (no tickets, no notifications)
[**notifyLogFinding**](LogsApi.md#notifylogfinding) | **POST** /log-findings/{findingId}/notify | Send the finding&#39;s notification now, whatever the mode
[**rotateLogKey**](LogsApi.md#rotatelogkey) | **POST** /log-sources/rotate-key | Replace the key that hashes secrets found in logs (findings of one secret before and after are then two)
[**setLogServices**](LogsApi.md#setlogservices) | **PUT** /log-sources/{sourceId}/services | Replace the services agnts watches in this source and the repositories each runs on
[**streamEvents**](LogsApi.md#streamevents) | **GET** /events/stream | Server-Sent Events with every new event row (resume with Last-Event-ID)
[**testLogSource**](LogsApi.md#testlogsource) | **POST** /log-sources/test | Test a log source as the form has it (with id and no auth, the saved credentials)
[**unmuteLogFinding**](LogsApi.md#unmutelogfinding) | **POST** /log-findings/{findingId}/unmute | Watch a muted finding again
[**updateLogSource**](LogsApi.md#updatelogsource) | **PUT** /log-sources/{sourceId} | Change a log source; auth left out keeps the saved credentials


# **createLogPushToken**
> LogPushToken createLogPushToken(sourceId)

Make a push source's token (again); it is shown once

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getLogsApi();
final int sourceId = 789; // int | 

try {
    final response = api.createLogPushToken(sourceId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LogsApi->createLogPushToken: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sourceId** | **int**|  | 

### Return type

[**LogPushToken**](LogPushToken.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createLogSource**
> LogSource createLogSource(logSourceInput)

Add a log source; a pulling source must pass the connection test

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getLogsApi();
final LogSourceInput logSourceInput = ; // LogSourceInput | 

try {
    final response = api.createLogSource(logSourceInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LogsApi->createLogSource: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **logSourceInput** | [**LogSourceInput**](LogSourceInput.md)|  | 

### Return type

[**LogSource**](LogSource.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteLogSource**
> deleteLogSource(sourceId)

Remove a log source (its findings stay)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getLogsApi();
final int sourceId = 789; // int | 

try {
    api.deleteLogSource(sourceId);
} on DioException catch (e) {
    print('Exception when calling LogsApi->deleteLogSource: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sourceId** | **int**|  | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **discoverLogServices**
> List<LogService> discoverLogServices(sourceId)

The services the source's logs hold (watched ones as saved, new ones with a suggested repository)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getLogsApi();
final int sourceId = 789; // int | 

try {
    final response = api.discoverLogServices(sourceId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LogsApi->discoverLogServices: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sourceId** | **int**|  | 

### Return type

[**List&lt;LogService&gt;**](LogService.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **exportEvents**
> String exportEvents(format)

Download the log (last 90 days) as JSON lines or CSV

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getLogsApi();
final String format = format_example; // String | 

try {
    final response = api.exportEvents(format);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LogsApi->exportEvents: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **format** | **String**|  | [optional] [default to 'json']

### Return type

**String**

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/x-ndjson, text/csv, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **fixLogFinding**
> Ticket fixLogFinding(findingId)

Open a ticket for the finding now, on the service's repositories (ignores the mode and the daily budget)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getLogsApi();
final int findingId = 789; // int | 

try {
    final response = api.fixLogFinding(findingId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LogsApi->fixLogFinding: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **findingId** | **int**|  | 

### Return type

[**Ticket**](Ticket.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getEventSummary**
> EventSummary getEventSummary()

Run statistics and time per step, for the Logs page

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getLogsApi();

try {
    final response = api.getEventSummary();
    print(response);
} on DioException catch (e) {
    print('Exception when calling LogsApi->getEventSummary: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**EventSummary**](EventSummary.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getLogFinding**
> LogFinding getLogFinding(findingId)

One finding with its redacted log excerpt

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getLogsApi();
final int findingId = 789; // int | 

try {
    final response = api.getLogFinding(findingId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LogsApi->getLogFinding: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **findingId** | **int**|  | 

### Return type

[**LogFinding**](LogFinding.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getLogSource**
> LogSource getLogSource(sourceId)

One log source

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getLogsApi();
final int sourceId = 789; // int | 

try {
    final response = api.getLogSource(sourceId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LogsApi->getLogSource: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sourceId** | **int**|  | 

### Return type

[**LogSource**](LogSource.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getTicketLogFinding**
> LogFinding getTicketLogFinding(key)

The log finding a log ticket fixes (404 for other tickets)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getLogsApi();
final String key = key_example; // String | 

try {
    final response = api.getTicketLogFinding(key);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LogsApi->getTicketLogFinding: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 

### Return type

[**LogFinding**](LogFinding.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listEvents**
> EventPage listEvents(type, key, errors, before, limit)

The global log, newest first, with filters and a cursor

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getLogsApi();
final String type = type_example; // String | 
final String key = key_example; // String | Ticket key, or a prefix of one
final bool errors = true; // bool | 
final int before = 789; // int | Only events with a smaller id (pagination)
final int limit = 56; // int | 

try {
    final response = api.listEvents(type, key, errors, before, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LogsApi->listEvents: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **type** | **String**|  | [optional] [default to 'all']
 **key** | **String**| Ticket key, or a prefix of one | [optional] 
 **errors** | **bool**|  | [optional] [default to false]
 **before** | **int**| Only events with a smaller id (pagination) | [optional] 
 **limit** | **int**|  | [optional] [default to 100]

### Return type

[**EventPage**](EventPage.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listLogFindings**
> List<LogFinding> listLogFindings(category, status, severity, repoId, sourceId, active)

Findings of the log watcher, newest sighting first

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getLogsApi();
final String category = category_example; // String | 
final LogFindingStatus status = ; // LogFindingStatus | 
final LogSeverity severity = ; // LogSeverity | 
final int repoId = 789; // int | 
final int sourceId = 789; // int | 
final bool active = true; // bool | Only findings that still need attention

try {
    final response = api.listLogFindings(category, status, severity, repoId, sourceId, active);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LogsApi->listLogFindings: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **category** | **String**|  | [optional] 
 **status** | [**LogFindingStatus**](.md)|  | [optional] 
 **severity** | [**LogSeverity**](.md)|  | [optional] 
 **repoId** | **int**|  | [optional] 
 **sourceId** | **int**|  | [optional] 
 **active** | **bool**| Only findings that still need attention | [optional] 

### Return type

[**List&lt;LogFinding&gt;**](LogFinding.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listLogSources**
> List<LogSource> listLogSources()

The logging systems agnts reads, and the push sources, with their services and health

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getLogsApi();

try {
    final response = api.listLogSources();
    print(response);
} on DioException catch (e) {
    print('Exception when calling LogsApi->listLogSources: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;LogSource&gt;**](LogSource.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **muteLogFinding**
> LogFinding muteLogFinding(findingId)

Ignore this finding (no tickets, no notifications)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getLogsApi();
final int findingId = 789; // int | 

try {
    final response = api.muteLogFinding(findingId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LogsApi->muteLogFinding: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **findingId** | **int**|  | 

### Return type

[**LogFinding**](LogFinding.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **notifyLogFinding**
> LogFinding notifyLogFinding(findingId)

Send the finding's notification now, whatever the mode

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getLogsApi();
final int findingId = 789; // int | 

try {
    final response = api.notifyLogFinding(findingId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LogsApi->notifyLogFinding: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **findingId** | **int**|  | 

### Return type

[**LogFinding**](LogFinding.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rotateLogKey**
> rotateLogKey()

Replace the key that hashes secrets found in logs (findings of one secret before and after are then two)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getLogsApi();

try {
    api.rotateLogKey();
} on DioException catch (e) {
    print('Exception when calling LogsApi->rotateLogKey: $e\n');
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

# **setLogServices**
> List<LogService> setLogServices(sourceId, logService)

Replace the services agnts watches in this source and the repositories each runs on

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getLogsApi();
final int sourceId = 789; // int | 
final List<LogService> logService = ; // List<LogService> | 

try {
    final response = api.setLogServices(sourceId, logService);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LogsApi->setLogServices: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sourceId** | **int**|  | 
 **logService** | [**List&lt;LogService&gt;**](LogService.md)|  | 

### Return type

[**List&lt;LogService&gt;**](LogService.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **streamEvents**
> String streamEvents()

Server-Sent Events with every new event row (resume with Last-Event-ID)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getLogsApi();

try {
    final response = api.streamEvents();
    print(response);
} on DioException catch (e) {
    print('Exception when calling LogsApi->streamEvents: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

**String**

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/event-stream, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **testLogSource**
> LogSourceTest testLogSource(logSourceInput)

Test a log source as the form has it (with id and no auth, the saved credentials)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getLogsApi();
final LogSourceInput logSourceInput = ; // LogSourceInput | 

try {
    final response = api.testLogSource(logSourceInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LogsApi->testLogSource: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **logSourceInput** | [**LogSourceInput**](LogSourceInput.md)|  | 

### Return type

[**LogSourceTest**](LogSourceTest.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **unmuteLogFinding**
> LogFinding unmuteLogFinding(findingId)

Watch a muted finding again

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getLogsApi();
final int findingId = 789; // int | 

try {
    final response = api.unmuteLogFinding(findingId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LogsApi->unmuteLogFinding: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **findingId** | **int**|  | 

### Return type

[**LogFinding**](LogFinding.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateLogSource**
> LogSource updateLogSource(sourceId, logSourceInput)

Change a log source; auth left out keeps the saved credentials

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getLogsApi();
final int sourceId = 789; // int | 
final LogSourceInput logSourceInput = ; // LogSourceInput | 

try {
    final response = api.updateLogSource(sourceId, logSourceInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LogsApi->updateLogSource: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sourceId** | **int**|  | 
 **logSourceInput** | [**LogSourceInput**](LogSourceInput.md)|  | 

### Return type

[**LogSource**](LogSource.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

