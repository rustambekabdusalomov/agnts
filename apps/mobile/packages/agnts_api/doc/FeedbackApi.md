# agnts_api.api.FeedbackApi

## Load the API package
```dart
import 'package:agnts_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**sendFeedback**](FeedbackApi.md#sendfeedback) | **POST** /feedback | Send feedback to the platform&#39;s Admins


# **sendFeedback**
> Feedback sendFeedback(sendFeedbackRequest)

Send feedback to the platform's Admins

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getFeedbackApi();
final SendFeedbackRequest sendFeedbackRequest = ; // SendFeedbackRequest | 

try {
    final response = api.sendFeedback(sendFeedbackRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling FeedbackApi->sendFeedback: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sendFeedbackRequest** | [**SendFeedbackRequest**](SendFeedbackRequest.md)|  | 

### Return type

[**Feedback**](Feedback.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

