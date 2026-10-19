# agnts_api.api.ReviewsApi

## Load the API package
```dart
import 'package:agnts_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**acceptAllReviewDrafts**](ReviewsApi.md#acceptallreviewdrafts) | **POST** /tickets/{key}/drafts/accept-all | Accept the summary and every open finding at least as severe as minSeverity (every one when left out)
[**addReviewDraft**](ReviewsApi.md#addreviewdraft) | **POST** /tickets/{key}/drafts | Add your own comment to the review, on a line of the new version or on the pull request; it is published with the accepted drafts
[**addReviewerNote**](ReviewsApi.md#addreviewernote) | **POST** /reviews/notes | Tell agnts something about how you review; the next review for that user reads it
[**deleteReviewDraft**](ReviewsApi.md#deletereviewdraft) | **DELETE** /tickets/{key}/drafts/{draftId} | Delete your own draft comment (agnts&#39;s drafts are dismissed instead)
[**deleteReviewerNote**](ReviewsApi.md#deletereviewernote) | **DELETE** /reviews/notes/{id} | Forget a note (one already folded into a profile stays there until the profile is edited)
[**listReviewDrafts**](ReviewsApi.md#listreviewdrafts) | **GET** /tickets/{key}/drafts | The draft comments of a pull request review: agnts&#39;s summary and findings, and people&#39;s own comments, with what was decided about each
[**listReviewPulls**](ReviewsApi.md#listreviewpulls) | **GET** /reviews/pulls | The open pull requests of every repository (as pullReviews settings pick them), most recently updated first, each with agnts&#39;s newest review of it. Nothing is reviewed: a review starts from the pull request
[**listReviewers**](ReviewsApi.md#listreviewers) | **GET** /reviews/reviewers | How each person agnts reviews pull requests for reviews, as it learned from their notes
[**postPullReview**](ReviewsApi.md#postpullreview) | **POST** /tickets/{key}/post-review | Post agnts&#39;s latest review of a pull request on it: accepts the drafts of the summary (with the findings not on a changed line) and of the chosen findings, then publishes every accepted draft (see publishReviewDrafts). Kept for older clients
[**publishReviewDrafts**](ReviewsApi.md#publishreviewdrafts) | **POST** /tickets/{key}/drafts/publish | Publish the accepted drafts on the pull request as one review, as the git host token&#39;s user: comments on their lines, the summary (edited in place when agnts posted one before) with the accepted findings not on a changed line. Also answers in the threads of findings agnts posted before that are still there, and resolves the ones that are gone. Drafts not accepted stay in agnts
[**saveReviewerProfile**](ReviewsApi.md#savereviewerprofile) | **PUT** /reviews/reviewers/{login} | Replace a reviewer profile with your text; empty text clears it
[**syncReviews**](ReviewsApi.md#syncreviews) | **POST** /reviews/sync | Bring agnts&#39;s open reviews up to date with the git host: end those whose pull request was merged or closed. It starts no review
[**updateReviewDraft**](ReviewsApi.md#updatereviewdraft) | **PATCH** /tickets/{key}/drafts/{draftId} | Accept, dismiss or reopen a draft, or rewrite its text before it is published


# **acceptAllReviewDrafts**
> List<ReviewDraft> acceptAllReviewDrafts(key, acceptAllReviewDraftsRequest)

Accept the summary and every open finding at least as severe as minSeverity (every one when left out)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReviewsApi();
final String key = key_example; // String | 
final AcceptAllReviewDraftsRequest acceptAllReviewDraftsRequest = ; // AcceptAllReviewDraftsRequest | 

try {
    final response = api.acceptAllReviewDrafts(key, acceptAllReviewDraftsRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReviewsApi->acceptAllReviewDrafts: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **acceptAllReviewDraftsRequest** | [**AcceptAllReviewDraftsRequest**](AcceptAllReviewDraftsRequest.md)|  | [optional] 

### Return type

[**List&lt;ReviewDraft&gt;**](ReviewDraft.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **addReviewDraft**
> ReviewDraft addReviewDraft(key, addReviewDraftRequest)

Add your own comment to the review, on a line of the new version or on the pull request; it is published with the accepted drafts

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReviewsApi();
final String key = key_example; // String | 
final AddReviewDraftRequest addReviewDraftRequest = ; // AddReviewDraftRequest | 

try {
    final response = api.addReviewDraft(key, addReviewDraftRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReviewsApi->addReviewDraft: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **addReviewDraftRequest** | [**AddReviewDraftRequest**](AddReviewDraftRequest.md)|  | 

### Return type

[**ReviewDraft**](ReviewDraft.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **addReviewerNote**
> ReviewerNote addReviewerNote(reviewerNoteInput)

Tell agnts something about how you review; the next review for that user reads it

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReviewsApi();
final ReviewerNoteInput reviewerNoteInput = ; // ReviewerNoteInput | 

try {
    final response = api.addReviewerNote(reviewerNoteInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReviewsApi->addReviewerNote: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **reviewerNoteInput** | [**ReviewerNoteInput**](ReviewerNoteInput.md)|  | 

### Return type

[**ReviewerNote**](ReviewerNote.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteReviewDraft**
> deleteReviewDraft(key, draftId)

Delete your own draft comment (agnts's drafts are dismissed instead)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReviewsApi();
final String key = key_example; // String | 
final int draftId = 789; // int | 

try {
    api.deleteReviewDraft(key, draftId);
} on DioException catch (e) {
    print('Exception when calling ReviewsApi->deleteReviewDraft: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **draftId** | **int**|  | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteReviewerNote**
> deleteReviewerNote(id)

Forget a note (one already folded into a profile stays there until the profile is edited)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReviewsApi();
final int id = 789; // int | 

try {
    api.deleteReviewerNote(id);
} on DioException catch (e) {
    print('Exception when calling ReviewsApi->deleteReviewerNote: $e\n');
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

# **listReviewDrafts**
> List<ReviewDraft> listReviewDrafts(key)

The draft comments of a pull request review: agnts's summary and findings, and people's own comments, with what was decided about each

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReviewsApi();
final String key = key_example; // String | 

try {
    final response = api.listReviewDrafts(key);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReviewsApi->listReviewDrafts: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 

### Return type

[**List&lt;ReviewDraft&gt;**](ReviewDraft.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listReviewPulls**
> ReviewPullList listReviewPulls()

The open pull requests of every repository (as pullReviews settings pick them), most recently updated first, each with agnts's newest review of it. Nothing is reviewed: a review starts from the pull request

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReviewsApi();

try {
    final response = api.listReviewPulls();
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReviewsApi->listReviewPulls: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ReviewPullList**](ReviewPullList.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listReviewers**
> Reviewers listReviewers()

How each person agnts reviews pull requests for reviews, as it learned from their notes

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReviewsApi();

try {
    final response = api.listReviewers();
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReviewsApi->listReviewers: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**Reviewers**](Reviewers.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **postPullReview**
> Ticket postPullReview(key, postReviewInput)

Post agnts's latest review of a pull request on it: accepts the drafts of the summary (with the findings not on a changed line) and of the chosen findings, then publishes every accepted draft (see publishReviewDrafts). Kept for older clients

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReviewsApi();
final String key = key_example; // String | 
final PostReviewInput postReviewInput = ; // PostReviewInput | 

try {
    final response = api.postPullReview(key, postReviewInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReviewsApi->postPullReview: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **postReviewInput** | [**PostReviewInput**](PostReviewInput.md)|  | [optional] 

### Return type

[**Ticket**](Ticket.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **publishReviewDrafts**
> PublishedReview publishReviewDrafts(key, publishReviewDraftsRequest)

Publish the accepted drafts on the pull request as one review, as the git host token's user: comments on their lines, the summary (edited in place when agnts posted one before) with the accepted findings not on a changed line. Also answers in the threads of findings agnts posted before that are still there, and resolves the ones that are gone. Drafts not accepted stay in agnts

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReviewsApi();
final String key = key_example; // String | 
final PublishReviewDraftsRequest publishReviewDraftsRequest = ; // PublishReviewDraftsRequest | 

try {
    final response = api.publishReviewDrafts(key, publishReviewDraftsRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReviewsApi->publishReviewDrafts: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **publishReviewDraftsRequest** | [**PublishReviewDraftsRequest**](PublishReviewDraftsRequest.md)|  | [optional] 

### Return type

[**PublishedReview**](PublishedReview.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **saveReviewerProfile**
> Reviewer saveReviewerProfile(login, reviewerProfileInput)

Replace a reviewer profile with your text; empty text clears it

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReviewsApi();
final String login = login_example; // String | 
final ReviewerProfileInput reviewerProfileInput = ; // ReviewerProfileInput | 

try {
    final response = api.saveReviewerProfile(login, reviewerProfileInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReviewsApi->saveReviewerProfile: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **login** | **String**|  | 
 **reviewerProfileInput** | [**ReviewerProfileInput**](ReviewerProfileInput.md)|  | 

### Return type

[**Reviewer**](Reviewer.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **syncReviews**
> ReviewSync syncReviews()

Bring agnts's open reviews up to date with the git host: end those whose pull request was merged or closed. It starts no review

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReviewsApi();

try {
    final response = api.syncReviews();
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReviewsApi->syncReviews: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ReviewSync**](ReviewSync.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateReviewDraft**
> ReviewDraft updateReviewDraft(key, draftId, updateReviewDraftRequest)

Accept, dismiss or reopen a draft, or rewrite its text before it is published

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getReviewsApi();
final String key = key_example; // String | 
final int draftId = 789; // int | 
final UpdateReviewDraftRequest updateReviewDraftRequest = ; // UpdateReviewDraftRequest | 

try {
    final response = api.updateReviewDraft(key, draftId, updateReviewDraftRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReviewsApi->updateReviewDraft: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **draftId** | **int**|  | 
 **updateReviewDraftRequest** | [**UpdateReviewDraftRequest**](UpdateReviewDraftRequest.md)|  | 

### Return type

[**ReviewDraft**](ReviewDraft.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

