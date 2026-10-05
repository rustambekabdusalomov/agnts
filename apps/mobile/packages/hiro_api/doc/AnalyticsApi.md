# hiro_api.api.AnalyticsApi

## Load the API package
```dart
import 'package:hiro_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getAnalytics**](AnalyticsApi.md#getanalytics) | **GET** /analytics | Throughput, quality, time and plan statistics for a period


# **getAnalytics**
> Analytics getAnalytics(days)

Throughput, quality, time and plan statistics for a period

### Example
```dart
import 'package:hiro_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = HiroApi().getAnalyticsApi();
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

