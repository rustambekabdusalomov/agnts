# hiro_api.api.DocsApi

## Load the API package
```dart
import 'package:hiro_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getPageDoc**](DocsApi.md#getpagedoc) | **GET** /docs/{page} | The \&quot;How this page works\&quot; text, as Markdown


# **getPageDoc**
> String getPageDoc(page, lang)

The \"How this page works\" text, as Markdown

### Example
```dart
import 'package:hiro_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = HiroApi().getDocsApi();
final String page = page_example; // String | 
final String lang = lang_example; // String | 

try {
    final response = api.getPageDoc(page, lang);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DocsApi->getPageDoc: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **page** | **String**|  | 
 **lang** | **String**|  | [optional] [default to 'en']

### Return type

**String**

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/markdown, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

