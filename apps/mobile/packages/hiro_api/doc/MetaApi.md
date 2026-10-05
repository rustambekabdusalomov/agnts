# hiro_api.api.MetaApi

## Load the API package
```dart
import 'package:hiro_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getMeta**](MetaApi.md#getmeta) | **GET** /meta | Server version and build information


# **getMeta**
> Meta getMeta()

Server version and build information

### Example
```dart
import 'package:hiro_api/api.dart';

final api = HiroApi().getMetaApi();

try {
    final response = api.getMeta();
    print(response);
} on DioException catch (e) {
    print('Exception when calling MetaApi->getMeta: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**Meta**](Meta.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

