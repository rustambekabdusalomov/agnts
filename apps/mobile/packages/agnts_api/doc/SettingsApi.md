# agnts_api.api.SettingsApi

## Load the API package
```dart
import 'package:agnts_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getSettings**](SettingsApi.md#getsettings) | **GET** /settings | 
[**listModels**](SettingsApi.md#listmodels) | **GET** /models | The coding modules and models you may use
[**putSettings**](SettingsApi.md#putsettings) | **PUT** /settings | 


# **getSettings**
> Settings getSettings()



### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getSettingsApi();

try {
    final response = api.getSettings();
    print(response);
} on DioException catch (e) {
    print('Exception when calling SettingsApi->getSettings: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**Settings**](Settings.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listModels**
> ModelCatalog listModels()

The coding modules and models you may use

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getSettingsApi();

try {
    final response = api.listModels();
    print(response);
} on DioException catch (e) {
    print('Exception when calling SettingsApi->listModels: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ModelCatalog**](ModelCatalog.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **putSettings**
> Settings putSettings(settings)



### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getSettingsApi();
final Settings settings = ; // Settings | 

try {
    final response = api.putSettings(settings);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SettingsApi->putSettings: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **settings** | [**Settings**](Settings.md)|  | 

### Return type

[**Settings**](Settings.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

