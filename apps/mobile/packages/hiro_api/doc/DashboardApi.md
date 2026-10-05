# hiro_api.api.DashboardApi

## Load the API package
```dart
import 'package:hiro_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getDashboard**](DashboardApi.md#getdashboard) | **GET** /dashboard | Everything the dashboard shows, in one call


# **getDashboard**
> Dashboard getDashboard()

Everything the dashboard shows, in one call

### Example
```dart
import 'package:hiro_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = HiroApi().getDashboardApi();

try {
    final response = api.getDashboard();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DashboardApi->getDashboard: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**Dashboard**](Dashboard.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

