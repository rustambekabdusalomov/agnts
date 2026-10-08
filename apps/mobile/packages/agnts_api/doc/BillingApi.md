# agnts_api.api.BillingApi

## Load the API package
```dart
import 'package:agnts_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**checkoutCredits**](BillingApi.md#checkoutcredits) | **POST** /workspace/billing/checkout | Start buying credits; returns the payment page to open
[**getBilling**](BillingApi.md#getbilling) | **GET** /workspace/billing | The workspace&#39;s plan, slots, members and credits
[**setSlots**](BillingApi.md#setslots) | **PUT** /workspace/billing/slots | Change how many runs the workspace may have at once


# **checkoutCredits**
> CheckoutCredits200Response checkoutCredits(checkoutCreditsRequest)

Start buying credits; returns the payment page to open

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getBillingApi();
final CheckoutCreditsRequest checkoutCreditsRequest = ; // CheckoutCreditsRequest | 

try {
    final response = api.checkoutCredits(checkoutCreditsRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BillingApi->checkoutCredits: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **checkoutCreditsRequest** | [**CheckoutCreditsRequest**](CheckoutCreditsRequest.md)|  | 

### Return type

[**CheckoutCredits200Response**](CheckoutCredits200Response.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getBilling**
> Billing getBilling()

The workspace's plan, slots, members and credits

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getBillingApi();

try {
    final response = api.getBilling();
    print(response);
} on DioException catch (e) {
    print('Exception when calling BillingApi->getBilling: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**Billing**](Billing.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setSlots**
> Billing setSlots(setSlotsRequest)

Change how many runs the workspace may have at once

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getBillingApi();
final SetSlotsRequest setSlotsRequest = ; // SetSlotsRequest | 

try {
    final response = api.setSlots(setSlotsRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BillingApi->setSlots: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **setSlotsRequest** | [**SetSlotsRequest**](SetSlotsRequest.md)|  | 

### Return type

[**Billing**](Billing.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

