# agnts_api.api.AnalyticsApi

## Load the API package
```dart
import 'package:agnts_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getAnalytics**](AnalyticsApi.md#getanalytics) | **GET** /analytics | Throughput, quality, time and plan statistics for a period
[**getAnalyticsCi**](AnalyticsApi.md#getanalyticsci) | **GET** /analytics/ci | CI failures, fixes and flaky jobs for a period
[**getAnalyticsDelivery**](AnalyticsApi.md#getanalyticsdelivery) | **GET** /analytics/delivery | What happened to agnts pull requests, cycle time and questions for a period
[**getAnalyticsLearning**](AnalyticsApi.md#getanalyticslearning) | **GET** /analytics/learning | Lessons, rules, follow-ups and reviewer notes for a period
[**getReplayReport**](AnalyticsApi.md#getreplayreport) | **GET** /eval/replays | How the newest replays compare with the tickets they re-ran, by prompt version


# **getAnalytics**
> Analytics getAnalytics(days)

Throughput, quality, time and plan statistics for a period

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAnalyticsApi();
final int days = 56; // int | 

try {
    final response = api.getAnalytics(days);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AnalyticsApi->getAnalytics: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **days** | **int**|  | [optional] [default to 30]

### Return type

[**Analytics**](Analytics.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAnalyticsCi**
> AnalyticsCI getAnalyticsCi(days)

CI failures, fixes and flaky jobs for a period

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAnalyticsApi();
final int days = 56; // int | 

try {
    final response = api.getAnalyticsCi(days);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AnalyticsApi->getAnalyticsCi: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **days** | **int**|  | [optional] [default to 30]

### Return type

[**AnalyticsCI**](AnalyticsCI.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAnalyticsDelivery**
> AnalyticsDelivery getAnalyticsDelivery(days)

What happened to agnts pull requests, cycle time and questions for a period

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAnalyticsApi();
final int days = 56; // int | 

try {
    final response = api.getAnalyticsDelivery(days);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AnalyticsApi->getAnalyticsDelivery: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **days** | **int**|  | [optional] [default to 30]

### Return type

[**AnalyticsDelivery**](AnalyticsDelivery.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAnalyticsLearning**
> AnalyticsLearning getAnalyticsLearning(days)

Lessons, rules, follow-ups and reviewer notes for a period

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAnalyticsApi();
final int days = 56; // int | 

try {
    final response = api.getAnalyticsLearning(days);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AnalyticsApi->getAnalyticsLearning: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **days** | **int**|  | [optional] [default to 30]

### Return type

[**AnalyticsLearning**](AnalyticsLearning.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getReplayReport**
> ReplayReport getReplayReport()

How the newest replays compare with the tickets they re-ran, by prompt version

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAnalyticsApi();

try {
    final response = api.getReplayReport();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AnalyticsApi->getReplayReport: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ReplayReport**](ReplayReport.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

