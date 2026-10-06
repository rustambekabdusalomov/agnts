# agnts_api.api.DevicesApi

## Load the API package
```dart
import 'package:agnts_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**registerDevice**](DevicesApi.md#registerdevice) | **POST** /devices | Register this phone for push notifications (call again when the token changes)
[**unregisterDevice**](DevicesApi.md#unregisterdevice) | **POST** /devices/unregister | Stop push notifications to this phone (on sign-out)


# **registerDevice**
> registerDevice(deviceRegistration)

Register this phone for push notifications (call again when the token changes)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getDevicesApi();
final DeviceRegistration deviceRegistration = ; // DeviceRegistration | 

try {
    api.registerDevice(deviceRegistration);
} on DioException catch (e) {
    print('Exception when calling DevicesApi->registerDevice: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deviceRegistration** | [**DeviceRegistration**](DeviceRegistration.md)|  | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **unregisterDevice**
> unregisterDevice(unregisterDeviceRequest)

Stop push notifications to this phone (on sign-out)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getDevicesApi();
final UnregisterDeviceRequest unregisterDeviceRequest = ; // UnregisterDeviceRequest | 

try {
    api.unregisterDevice(unregisterDeviceRequest);
} on DioException catch (e) {
    print('Exception when calling DevicesApi->unregisterDevice: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **unregisterDeviceRequest** | [**UnregisterDeviceRequest**](UnregisterDeviceRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

