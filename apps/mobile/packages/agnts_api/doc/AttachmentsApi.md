# agnts_api.api.AttachmentsApi

## Load the API package
```dart
import 'package:agnts_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**deleteAttachment**](AttachmentsApi.md#deleteattachment) | **DELETE** /attachments/{id} | Delete an upload that nothing uses yet
[**getAttachment**](AttachmentsApi.md#getattachment) | **GET** /attachments/{id} | An attached file&#39;s bytes
[**uploadAttachment**](AttachmentsApi.md#uploadattachment) | **POST** /attachments | Upload a file to attach to a task, an answer, a retry note or a chat message


# **deleteAttachment**
> deleteAttachment(id)

Delete an upload that nothing uses yet

Viewers delete only their own uploads; editors any pending one.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAttachmentsApi();
final int id = 789; // int | 

try {
    api.deleteAttachment(id);
} on DioException catch (e) {
    print('Exception when calling AttachmentsApi->deleteAttachment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAttachment**
> Uint8List getAttachment(id)

An attached file's bytes

An AI chat (Ask) question's file is only its asker's; anyone else gets 404.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAttachmentsApi();
final int id = 789; // int | 

try {
    final response = api.getAttachment(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AttachmentsApi->getAttachment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**Uint8List**](Uint8List.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/octet-stream, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **uploadAttachment**
> Attachment uploadAttachment(file)

Upload a file to attach to a task, an answer, a retry note or a chat message

The upload stays pending until the request that uses it (createTask, updateTask, answerQuestions, retryTicket, requestChanges, sendChatMessage, askAssistant, Code mode) lists its id; pending uploads nobody used are deleted after a day. Pictures (PNG, JPEG, GIF, WebP) are shown in place; other files download. Claude reads every attached file, pictures and PDFs included. Viewers may upload too, for the chats.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAttachmentsApi();
final MultipartFile file = BINARY_DATA_HERE; // MultipartFile | At most 10 MB

try {
    final response = api.uploadAttachment(file);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AttachmentsApi->uploadAttachment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **file** | **MultipartFile**| At most 10 MB | 

### Return type

[**Attachment**](Attachment.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

