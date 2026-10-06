# agnts_api.api.LogsApi

## Load the API package
```dart
import 'package:agnts_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**exportEvents**](LogsApi.md#exportevents) | **GET** /events/export | Download the log (last 90 days) as JSON lines or CSV
[**getEventSummary**](LogsApi.md#geteventsummary) | **GET** /events/summary | Run statistics and time per step, for the Logs page
[**listEvents**](LogsApi.md#listevents) | **GET** /events | The global log, newest first, with filters and a cursor
[**streamEvents**](LogsApi.md#streamevents) | **GET** /events/stream | Server-Sent Events with every new event row (resume with Last-Event-ID)


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

