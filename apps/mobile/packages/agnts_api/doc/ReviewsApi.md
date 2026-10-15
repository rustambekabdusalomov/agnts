# agnts_api.api.ReviewsApi

## Load the API package
```dart
import 'package:agnts_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addReviewerNote**](ReviewsApi.md#addreviewernote) | **POST** /reviews/notes | Tell agnts something about how you review; the next review for that user reads it
[**deleteReviewerNote**](ReviewsApi.md#deletereviewernote) | **DELETE** /reviews/notes/{id} | Forget a note (one already folded into a profile stays there until the profile is edited)
[**listReviewers**](ReviewsApi.md#listreviewers) | **GET** /reviews/reviewers | How each person agnts reviews pull requests for reviews, as it learned from their notes
[**postPullReview**](ReviewsApi.md#postpullreview) | **POST** /tickets/{key}/post-review | Post agnts&#39;s latest review of a pull request on it (once per reviewed commit): the summary, and the chosen findings on their lines in one review. Posting the review of new commits edits agnts&#39;s earlier summary, answers its findings that are still there and resolves the ones that are gone
[**saveReviewerProfile**](ReviewsApi.md#savereviewerprofile) | **PUT** /reviews/reviewers/{login} | Replace a reviewer profile with your text; empty text clears it
[**syncReviews**](ReviewsApi.md#syncreviews) | **POST** /reviews/sync | Ask the git host for the pull requests waiting for you and queue reviews of the new ones


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

Post agnts's latest review of a pull request on it (once per reviewed commit): the summary, and the chosen findings on their lines in one review. Posting the review of new commits edits agnts's earlier summary, answers its findings that are still there and resolves the ones that are gone

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

Ask the git host for the pull requests waiting for you and queue reviews of the new ones

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

