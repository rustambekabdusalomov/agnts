# agnts_api.api.DocumentsApi

## Load the API package
```dart
import 'package:agnts_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addDocumentComment**](DocumentsApi.md#adddocumentcomment) | **POST** /documents/{id}/comments | Comment on selected text, or reply to a comment (view access is enough)
[**addPublicDocumentComment**](DocumentsApi.md#addpublicdocumentcomment) | **POST** /public/documents/{token}/comments | A guest comments on selected text, or replies
[**createDocument**](DocumentsApi.md#createdocument) | **POST** /documents | Create a document, written by you or by agnts from a source
[**createTicketDocument**](DocumentsApi.md#createticketdocument) | **POST** /tickets/{key}/documents | Have agnts make a document from the ticket&#39;s report, linked to the ticket
[**deleteDocument**](DocumentsApi.md#deletedocument) | **DELETE** /documents/{id} | Move a document to the trash (its owner); restorable for 30 days
[**deleteDocumentComment**](DocumentsApi.md#deletedocumentcomment) | **DELETE** /documents/{id}/comments/{commentId} | Delete a comment, and a thread&#39;s replies with it (its author, or the document&#39;s owner)
[**deletePublicDocumentComment**](DocumentsApi.md#deletepublicdocumentcomment) | **DELETE** /public/documents/{token}/comments/{commentId} | A guest deletes their comment
[**documentPresence**](DocumentsApi.md#documentpresence) | **POST** /documents/{id}/presence | Say you have the document open (every 10 seconds) or are leaving; answers who is viewing it now
[**downloadDocument**](DocumentsApi.md#downloaddocument) | **GET** /documents/{id}/download | Download a version as Markdown or PDF (view access)
[**downloadPublicDocument**](DocumentsApi.md#downloadpublicdocument) | **GET** /public/documents/{token}/download | Download a public document&#39;s current version
[**getDocument**](DocumentsApi.md#getdocument) | **GET** /documents/{id} | A document with your access to it; 404 when you cannot open it
[**getDocumentSharing**](DocumentsApi.md#getdocumentsharing) | **GET** /documents/{id}/sharing | Who can open a document, and its public link
[**getDocumentVersion**](DocumentsApi.md#getdocumentversion) | **GET** /documents/{id}/versions/{version} | One version with its text
[**getPublicDocument**](DocumentsApi.md#getpublicdocument) | **GET** /public/documents/{token} | A public document, for a guest of its link
[**getPublicDocumentInfo**](DocumentsApi.md#getpublicdocumentinfo) | **GET** /public/documents/{token}/info | What a public link opens, before the reader says who they are
[**joinPublicDocument**](DocumentsApi.md#joinpublicdocument) | **POST** /public/documents/{token}/guest | Say who you are to open a public document; signed in, your account says it
[**linkDocumentTicket**](DocumentsApi.md#linkdocumentticket) | **POST** /documents/{id}/tickets/{key} | Link a ticket to a document (edit access on the document)
[**listDocumentComments**](DocumentsApi.md#listdocumentcomments) | **GET** /documents/{id}/comments | The comments on a document, oldest first (view access)
[**listDocumentTickets**](DocumentsApi.md#listdocumenttickets) | **GET** /documents/{id}/tickets | The tickets linked to a document
[**listDocumentVersions**](DocumentsApi.md#listdocumentversions) | **GET** /documents/{id}/versions | Every version of a document, newest first, without their text
[**listDocuments**](DocumentsApi.md#listdocuments) | **GET** /documents | The documents you can open, most recently changed first
[**listPublicDocumentComments**](DocumentsApi.md#listpublicdocumentcomments) | **GET** /public/documents/{token}/comments | The comments on a public document, for its guests
[**listTicketDocuments**](DocumentsApi.md#listticketdocuments) | **GET** /tickets/{key}/documents | The documents linked to the ticket that you can open
[**publicDocumentPresence**](DocumentsApi.md#publicdocumentpresence) | **POST** /public/documents/{token}/presence | A guest says they have the document open, or are leaving; answers who is viewing it now
[**regenerateDocument**](DocumentsApi.md#regeneratedocument) | **POST** /documents/{id}/regenerate | Have agnts write the document again (edit access); the result is a new version
[**resetDocumentLink**](DocumentsApi.md#resetdocumentlink) | **POST** /documents/{id}/reset-link | Give a public document a new link; the old one stops working (its owner)
[**restoreDocumentVersion**](DocumentsApi.md#restoredocumentversion) | **POST** /documents/{id}/versions/{version}/restore | Make an earlier version the current one, as a new version (edit access)
[**saveDocument**](DocumentsApi.md#savedocument) | **PUT** /documents/{id} | Save an edit as a new version (edit access)
[**setDocumentOwner**](DocumentsApi.md#setdocumentowner) | **PUT** /documents/{id}/owner | Give a document to another member (its owner); the old owner keeps edit access
[**shareDocument**](DocumentsApi.md#sharedocument) | **PUT** /documents/{id}/sharing | Set a document&#39;s type, workspace access and grants (its owner)
[**undeleteDocument**](DocumentsApi.md#undeletedocument) | **POST** /documents/{id}/undelete | Take a document out of the trash (its owner or the workspace owner)
[**unlinkDocumentTicket**](DocumentsApi.md#unlinkdocumentticket) | **DELETE** /documents/{id}/tickets/{key} | Remove a link between a ticket and a document
[**updateDocumentComment**](DocumentsApi.md#updatedocumentcomment) | **PATCH** /documents/{id}/comments/{commentId} | Edit your comment, or resolve or reopen a thread (its author, or edit access)
[**updatePublicDocumentComment**](DocumentsApi.md#updatepublicdocumentcomment) | **PATCH** /public/documents/{token}/comments/{commentId} | A guest edits their comment, or resolves or reopens their thread


# **addDocumentComment**
> DocumentComment addDocumentComment(id, documentCommentInput)

Comment on selected text, or reply to a comment (view access is enough)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getDocumentsApi();
final int id = 789; // int | 
final DocumentCommentInput documentCommentInput = ; // DocumentCommentInput | 

try {
    final response = api.addDocumentComment(id, documentCommentInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->addDocumentComment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **documentCommentInput** | [**DocumentCommentInput**](DocumentCommentInput.md)|  | 

### Return type

[**DocumentComment**](DocumentComment.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **addPublicDocumentComment**
> DocumentComment addPublicDocumentComment(token, documentCommentInput, xGuestToken)

A guest comments on selected text, or replies

### Example
```dart
import 'package:agnts_api/api.dart';

final api = AgntsApi().getDocumentsApi();
final String token = token_example; // String | 
final DocumentCommentInput documentCommentInput = ; // DocumentCommentInput | 
final String xGuestToken = xGuestToken_example; // String | The guest's secret token from joinPublicDocument

try {
    final response = api.addPublicDocumentComment(token, documentCommentInput, xGuestToken);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->addPublicDocumentComment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **token** | **String**|  | 
 **documentCommentInput** | [**DocumentCommentInput**](DocumentCommentInput.md)|  | 
 **xGuestToken** | **String**| The guest's secret token from joinPublicDocument | [optional] 

### Return type

[**DocumentComment**](DocumentComment.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createDocument**
> Document createDocument(documentInput)

Create a document, written by you or by agnts from a source

Without a source the body is yours and becomes version 1. With a source, agnts gathers the facts (a ticket's report, tickets, commits, pull requests or a repository) and writes the body; the document starts at version 0 and its generation shows the progress. Workspace viewers may create documents; they own what they create. 

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getDocumentsApi();
final DocumentInput documentInput = ; // DocumentInput | 

try {
    final response = api.createDocument(documentInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->createDocument: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **documentInput** | [**DocumentInput**](DocumentInput.md)|  | 

### Return type

[**Document**](Document.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createTicketDocument**
> Document createTicketDocument(key, createTicketDocumentRequest)

Have agnts make a document from the ticket's report, linked to the ticket

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getDocumentsApi();
final String key = key_example; // String | 
final CreateTicketDocumentRequest createTicketDocumentRequest = ; // CreateTicketDocumentRequest | 

try {
    final response = api.createTicketDocument(key, createTicketDocumentRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->createTicketDocument: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **createTicketDocumentRequest** | [**CreateTicketDocumentRequest**](CreateTicketDocumentRequest.md)|  | [optional] 

### Return type

[**Document**](Document.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteDocument**
> deleteDocument(id)

Move a document to the trash (its owner); restorable for 30 days

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getDocumentsApi();
final int id = 789; // int | 

try {
    api.deleteDocument(id);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->deleteDocument: $e\n');
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

# **deleteDocumentComment**
> deleteDocumentComment(id, commentId)

Delete a comment, and a thread's replies with it (its author, or the document's owner)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getDocumentsApi();
final int id = 789; // int | 
final int commentId = 789; // int | 

try {
    api.deleteDocumentComment(id, commentId);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->deleteDocumentComment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **commentId** | **int**|  | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deletePublicDocumentComment**
> deletePublicDocumentComment(token, commentId, xGuestToken)

A guest deletes their comment

### Example
```dart
import 'package:agnts_api/api.dart';

final api = AgntsApi().getDocumentsApi();
final String token = token_example; // String | 
final int commentId = 789; // int | 
final String xGuestToken = xGuestToken_example; // String | The guest's secret token from joinPublicDocument

try {
    api.deletePublicDocumentComment(token, commentId, xGuestToken);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->deletePublicDocumentComment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **token** | **String**|  | 
 **commentId** | **int**|  | 
 **xGuestToken** | **String**| The guest's secret token from joinPublicDocument | [optional] 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **documentPresence**
> DocumentPresence documentPresence(id, presenceInput)

Say you have the document open (every 10 seconds) or are leaving; answers who is viewing it now

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getDocumentsApi();
final int id = 789; // int | 
final PresenceInput presenceInput = ; // PresenceInput | 

try {
    final response = api.documentPresence(id, presenceInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->documentPresence: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **presenceInput** | [**PresenceInput**](PresenceInput.md)|  | [optional] 

### Return type

[**DocumentPresence**](DocumentPresence.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **downloadDocument**
> Uint8List downloadDocument(id, format, version)

Download a version as Markdown or PDF (view access)

version 0 (the default) is the current one. The first PDF download of a version starts making it and answers 202 with Retry-After; ask again then. A made PDF is kept: later downloads are instant. 

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getDocumentsApi();
final int id = 789; // int | 
final String format = format_example; // String | 
final int version = 56; // int | 

try {
    final response = api.downloadDocument(id, format, version);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->downloadDocument: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **format** | **String**|  | [optional] [default to 'md']
 **version** | **int**|  | [optional] [default to 0]

### Return type

[**Uint8List**](Uint8List.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/markdown, application/pdf, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **downloadPublicDocument**
> Uint8List downloadPublicDocument(token, format, xGuestToken)

Download a public document's current version

The PDF is made ahead when the document is published or saved; until it is ready the answer is 202. Needs the guest's token.

### Example
```dart
import 'package:agnts_api/api.dart';

final api = AgntsApi().getDocumentsApi();
final String token = token_example; // String | 
final String format = format_example; // String | 
final String xGuestToken = xGuestToken_example; // String | The guest's secret token from joinPublicDocument

try {
    final response = api.downloadPublicDocument(token, format, xGuestToken);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->downloadPublicDocument: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **token** | **String**|  | 
 **format** | **String**|  | [optional] [default to 'md']
 **xGuestToken** | **String**| The guest's secret token from joinPublicDocument | [optional] 

### Return type

[**Uint8List**](Uint8List.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/markdown, application/pdf, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getDocument**
> Document getDocument(id)

A document with your access to it; 404 when you cannot open it

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getDocumentsApi();
final int id = 789; // int | 

try {
    final response = api.getDocument(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->getDocument: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**Document**](Document.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getDocumentSharing**
> DocumentSharing getDocumentSharing(id)

Who can open a document, and its public link

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getDocumentsApi();
final int id = 789; // int | 

try {
    final response = api.getDocumentSharing(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->getDocumentSharing: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**DocumentSharing**](DocumentSharing.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getDocumentVersion**
> DocumentVersion getDocumentVersion(id, version)

One version with its text

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getDocumentsApi();
final int id = 789; // int | 
final int version = 56; // int | 

try {
    final response = api.getDocumentVersion(id, version);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->getDocumentVersion: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **version** | **int**|  | 

### Return type

[**DocumentVersion**](DocumentVersion.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPublicDocument**
> PublicDocument getPublicDocument(token, xGuestToken)

A public document, for a guest of its link

Only the kind, title, text, version and last update. Needs the guest's token (401 guest_required without). Rate limited per address.

### Example
```dart
import 'package:agnts_api/api.dart';

final api = AgntsApi().getDocumentsApi();
final String token = token_example; // String | 
final String xGuestToken = xGuestToken_example; // String | The guest's secret token from joinPublicDocument

try {
    final response = api.getPublicDocument(token, xGuestToken);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->getPublicDocument: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **token** | **String**|  | 
 **xGuestToken** | **String**| The guest's secret token from joinPublicDocument | [optional] 

### Return type

[**PublicDocument**](PublicDocument.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPublicDocumentInfo**
> PublicDocumentInfo getPublicDocumentInfo(token)

What a public link opens, before the reader says who they are

The kind and title only, and Google's client id when \"Continue with Google\" is on.

### Example
```dart
import 'package:agnts_api/api.dart';

final api = AgntsApi().getDocumentsApi();
final String token = token_example; // String | 

try {
    final response = api.getPublicDocumentInfo(token);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->getPublicDocumentInfo: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **token** | **String**|  | 

### Return type

[**PublicDocumentInfo**](PublicDocumentInfo.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **joinPublicDocument**
> GuestSession joinPublicDocument(token, guestJoin)

Say who you are to open a public document; signed in, your account says it

Answers the guest's secret token, sent afterwards as X-Guest-Token. It works only on this document, and only while it is public.

### Example
```dart
import 'package:agnts_api/api.dart';

final api = AgntsApi().getDocumentsApi();
final String token = token_example; // String | 
final GuestJoin guestJoin = ; // GuestJoin | 

try {
    final response = api.joinPublicDocument(token, guestJoin);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->joinPublicDocument: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **token** | **String**|  | 
 **guestJoin** | [**GuestJoin**](GuestJoin.md)|  | 

### Return type

[**GuestSession**](GuestSession.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **linkDocumentTicket**
> linkDocumentTicket(id, key)

Link a ticket to a document (edit access on the document)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getDocumentsApi();
final int id = 789; // int | 
final String key = key_example; // String | 

try {
    api.linkDocumentTicket(id, key);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->linkDocumentTicket: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **key** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listDocumentComments**
> List<DocumentComment> listDocumentComments(id)

The comments on a document, oldest first (view access)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getDocumentsApi();
final int id = 789; // int | 

try {
    final response = api.listDocumentComments(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->listDocumentComments: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**List&lt;DocumentComment&gt;**](DocumentComment.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listDocumentTickets**
> List<DocumentTicket> listDocumentTickets(id)

The tickets linked to a document

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getDocumentsApi();
final int id = 789; // int | 

try {
    final response = api.listDocumentTickets(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->listDocumentTickets: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**List&lt;DocumentTicket&gt;**](DocumentTicket.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listDocumentVersions**
> List<DocumentVersion> listDocumentVersions(id)

Every version of a document, newest first, without their text

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getDocumentsApi();
final int id = 789; // int | 

try {
    final response = api.listDocumentVersions(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->listDocumentVersions: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**List&lt;DocumentVersion&gt;**](DocumentVersion.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listDocuments**
> List<DocumentSummary> listDocuments(scope, q, ticket, kind, derivedFrom)

The documents you can open, most recently changed first

Your own documents, the ones shared with you (by a grant or the workspace default), and for the workspace owner every document. scope=deleted lists the trash: your own deleted documents (all of them for the workspace owner), restorable for 30 days. 

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getDocumentsApi();
final String scope = scope_example; // String | 
final String q = q_example; // String | Words in the title
final String ticket = ticket_example; // String | Only documents linked to this ticket
final DocumentKind kind = ; // DocumentKind | Only pages, or only slide decks
final int derivedFrom = 789; // int | Only the slide decks made from this page

try {
    final response = api.listDocuments(scope, q, ticket, kind, derivedFrom);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->listDocuments: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **scope** | **String**|  | [optional] [default to 'all']
 **q** | **String**| Words in the title | [optional] 
 **ticket** | **String**| Only documents linked to this ticket | [optional] 
 **kind** | [**DocumentKind**](.md)| Only pages, or only slide decks | [optional] 
 **derivedFrom** | **int**| Only the slide decks made from this page | [optional] 

### Return type

[**List&lt;DocumentSummary&gt;**](DocumentSummary.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPublicDocumentComments**
> List<DocumentComment> listPublicDocumentComments(token, xGuestToken)

The comments on a public document, for its guests

### Example
```dart
import 'package:agnts_api/api.dart';

final api = AgntsApi().getDocumentsApi();
final String token = token_example; // String | 
final String xGuestToken = xGuestToken_example; // String | The guest's secret token from joinPublicDocument

try {
    final response = api.listPublicDocumentComments(token, xGuestToken);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->listPublicDocumentComments: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **token** | **String**|  | 
 **xGuestToken** | **String**| The guest's secret token from joinPublicDocument | [optional] 

### Return type

[**List&lt;DocumentComment&gt;**](DocumentComment.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listTicketDocuments**
> List<DocumentSummary> listTicketDocuments(key)

The documents linked to the ticket that you can open

Documents you cannot open are neither listed nor counted.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getDocumentsApi();
final String key = key_example; // String | 

try {
    final response = api.listTicketDocuments(key);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->listTicketDocuments: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 

### Return type

[**List&lt;DocumentSummary&gt;**](DocumentSummary.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **publicDocumentPresence**
> DocumentPresence publicDocumentPresence(token, xGuestToken, presenceInput)

A guest says they have the document open, or are leaving; answers who is viewing it now

### Example
```dart
import 'package:agnts_api/api.dart';

final api = AgntsApi().getDocumentsApi();
final String token = token_example; // String | 
final String xGuestToken = xGuestToken_example; // String | The guest's secret token from joinPublicDocument
final PresenceInput presenceInput = ; // PresenceInput | 

try {
    final response = api.publicDocumentPresence(token, xGuestToken, presenceInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->publicDocumentPresence: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **token** | **String**|  | 
 **xGuestToken** | **String**| The guest's secret token from joinPublicDocument | [optional] 
 **presenceInput** | [**PresenceInput**](PresenceInput.md)|  | [optional] 

### Return type

[**DocumentPresence**](DocumentPresence.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **regenerateDocument**
> Document regenerateDocument(id, documentRegenerate)

Have agnts write the document again (edit access); the result is a new version

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getDocumentsApi();
final int id = 789; // int | 
final DocumentRegenerate documentRegenerate = ; // DocumentRegenerate | 

try {
    final response = api.regenerateDocument(id, documentRegenerate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->regenerateDocument: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **documentRegenerate** | [**DocumentRegenerate**](DocumentRegenerate.md)|  | [optional] 

### Return type

[**Document**](Document.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **resetDocumentLink**
> DocumentSharing resetDocumentLink(id)

Give a public document a new link; the old one stops working (its owner)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getDocumentsApi();
final int id = 789; // int | 

try {
    final response = api.resetDocumentLink(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->resetDocumentLink: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**DocumentSharing**](DocumentSharing.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **restoreDocumentVersion**
> Document restoreDocumentVersion(id, version)

Make an earlier version the current one, as a new version (edit access)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getDocumentsApi();
final int id = 789; // int | 
final int version = 56; // int | 

try {
    final response = api.restoreDocumentVersion(id, version);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->restoreDocumentVersion: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **version** | **int**|  | 

### Return type

[**Document**](Document.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **saveDocument**
> Document saveDocument(id, documentSave)

Save an edit as a new version (edit access)

baseVersion is the version the edit started from. When someone saved in between, the answer is 409 with the document as it is now, so the editor can show both texts. While agnts writes the body only the title changes. 

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getDocumentsApi();
final int id = 789; // int | 
final DocumentSave documentSave = ; // DocumentSave | 

try {
    final response = api.saveDocument(id, documentSave);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->saveDocument: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **documentSave** | [**DocumentSave**](DocumentSave.md)|  | 

### Return type

[**Document**](Document.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setDocumentOwner**
> Document setDocumentOwner(id, transferWorkspaceRequest)

Give a document to another member (its owner); the old owner keeps edit access

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getDocumentsApi();
final int id = 789; // int | 
final TransferWorkspaceRequest transferWorkspaceRequest = ; // TransferWorkspaceRequest | 

try {
    final response = api.setDocumentOwner(id, transferWorkspaceRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->setDocumentOwner: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **transferWorkspaceRequest** | [**TransferWorkspaceRequest**](TransferWorkspaceRequest.md)|  | 

### Return type

[**Document**](Document.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **shareDocument**
> DocumentSharing shareDocument(id, documentShareInput)

Set a document's type, workspace access and grants (its owner)

Grants replace the current ones. Workspace viewers can only be given view. Going public needs public documents on in Settings and a text without secrets: when the scan finds some, the answer is 422 with the lines. A document that goes public gets a new link; one made private loses its link at once. 

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getDocumentsApi();
final int id = 789; // int | 
final DocumentShareInput documentShareInput = ; // DocumentShareInput | 

try {
    final response = api.shareDocument(id, documentShareInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->shareDocument: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **documentShareInput** | [**DocumentShareInput**](DocumentShareInput.md)|  | 

### Return type

[**DocumentSharing**](DocumentSharing.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **undeleteDocument**
> Document undeleteDocument(id)

Take a document out of the trash (its owner or the workspace owner)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getDocumentsApi();
final int id = 789; // int | 

try {
    final response = api.undeleteDocument(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->undeleteDocument: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**Document**](Document.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **unlinkDocumentTicket**
> unlinkDocumentTicket(id, key)

Remove a link between a ticket and a document

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getDocumentsApi();
final int id = 789; // int | 
final String key = key_example; // String | 

try {
    api.unlinkDocumentTicket(id, key);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->unlinkDocumentTicket: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **key** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateDocumentComment**
> DocumentComment updateDocumentComment(id, commentId, documentCommentPatch)

Edit your comment, or resolve or reopen a thread (its author, or edit access)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getDocumentsApi();
final int id = 789; // int | 
final int commentId = 789; // int | 
final DocumentCommentPatch documentCommentPatch = ; // DocumentCommentPatch | 

try {
    final response = api.updateDocumentComment(id, commentId, documentCommentPatch);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->updateDocumentComment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **commentId** | **int**|  | 
 **documentCommentPatch** | [**DocumentCommentPatch**](DocumentCommentPatch.md)|  | 

### Return type

[**DocumentComment**](DocumentComment.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updatePublicDocumentComment**
> DocumentComment updatePublicDocumentComment(token, commentId, documentCommentPatch, xGuestToken)

A guest edits their comment, or resolves or reopens their thread

### Example
```dart
import 'package:agnts_api/api.dart';

final api = AgntsApi().getDocumentsApi();
final String token = token_example; // String | 
final int commentId = 789; // int | 
final DocumentCommentPatch documentCommentPatch = ; // DocumentCommentPatch | 
final String xGuestToken = xGuestToken_example; // String | The guest's secret token from joinPublicDocument

try {
    final response = api.updatePublicDocumentComment(token, commentId, documentCommentPatch, xGuestToken);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DocumentsApi->updatePublicDocumentComment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **token** | **String**|  | 
 **commentId** | **int**|  | 
 **documentCommentPatch** | [**DocumentCommentPatch**](DocumentCommentPatch.md)|  | 
 **xGuestToken** | **String**| The guest's secret token from joinPublicDocument | [optional] 

### Return type

[**DocumentComment**](DocumentComment.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

