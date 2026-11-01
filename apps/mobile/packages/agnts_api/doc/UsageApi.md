# agnts_api.api.UsageApi

## Load the API package
```dart
import 'package:agnts_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getTicketSpend**](UsageApi.md#getticketspend) | **GET** /usage/tickets | Tickets that used the most of the plan in a period, by Claude Code&#39;s cost estimate
[**getUsage**](UsageApi.md#getusage) | **GET** /usage | Plan usage of one module&#39;s account (Claude or Muse), from the limit events its runs report
[**refreshUsage**](UsageApi.md#refreshusage) | **POST** /usage/refresh | Start a tiny Claude run to read fresh limits; a usage_updated event follows


# **getTicketSpend**
> TicketSpendList getTicketSpend(days, limit)

Tickets that used the most of the plan in a period, by Claude Code's cost estimate

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getUsageApi();
final int days = 56; // int | 
final int limit = 56; // int | 

try {
    final response = api.getTicketSpend(days, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsageApi->getTicketSpend: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **days** | **int**|  | [optional] [default to 30]
 **limit** | **int**|  | [optional] [default to 10]

### Return type

[**TicketSpendList**](TicketSpendList.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getUsage**
> Usage getUsage(provider)

Plan usage of one module's account (Claude or Muse), from the limit events its runs report

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getUsageApi();
final String provider = provider_example; // String | The module whose account it is: muse or claude (Codex runs on the workspace's OpenAI key). Defaults to your default module.

try {
    final response = api.getUsage(provider);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsageApi->getUsage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **provider** | **String**| The module whose account it is: muse or claude (Codex runs on the workspace's OpenAI key). Defaults to your default module. | [optional] 

### Return type

[**Usage**](Usage.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **refreshUsage**
> Usage refreshUsage()

Start a tiny Claude run to read fresh limits; a usage_updated event follows

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getUsageApi();

try {
    final response = api.refreshUsage();
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsageApi->refreshUsage: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**Usage**](Usage.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

