# agnts_api.api.AssistantApi

## Load the API package
```dart
import 'package:agnts_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**askAssistant**](AssistantApi.md#askassistant) | **POST** /assistant/conversations/{conversationId}/messages | Ask a follow-up question in one of your conversations
[**cancelAssistantAction**](AssistantApi.md#cancelassistantaction) | **POST** /assistant/actions/{actionId}/cancel | Decline an action the assistant proposed
[**confirmAssistantAction**](AssistantApi.md#confirmassistantaction) | **POST** /assistant/actions/{actionId}/confirm | Do an action the assistant proposed on one of your answers
[**deleteAssistantConversation**](AssistantApi.md#deleteassistantconversation) | **DELETE** /assistant/conversations/{conversationId} | Delete one of your conversations
[**getAssistantConversation**](AssistantApi.md#getassistantconversation) | **GET** /assistant/conversations/{conversationId} | One of your conversations with all its messages
[**getAssistantStats**](AssistantApi.md#getassistantstats) | **GET** /assistant/stats | How the workspace&#39;s assistant did (questions, answer rate, time, ratings, tokens, per prompt version)
[**listAssistantConversations**](AssistantApi.md#listassistantconversations) | **GET** /assistant/conversations | Your assistant conversations, newest first, each with its last message
[**listAssistantRated**](AssistantApi.md#listassistantrated) | **GET** /assistant/rated | Rated answers with their questions, newest rating first
[**rateAssistantAnswer**](AssistantApi.md#rateassistantanswer) | **PUT** /assistant/messages/{messageId}/rating | Rate one of your answers (helpful or not), or take the rating back
[**startAssistantConversation**](AssistantApi.md#startassistantconversation) | **POST** /assistant/conversations | Ask the assistant a question in a new conversation


# **askAssistant**
> AssistantConversation askAssistant(conversationId, assistantAsk)

Ask a follow-up question in one of your conversations

Answered after the conversation's earlier questions, with the last 6 messages as context.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAssistantApi();
final int conversationId = 789; // int | 
final AssistantAsk assistantAsk = ; // AssistantAsk | 

try {
    final response = api.askAssistant(conversationId, assistantAsk);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AssistantApi->askAssistant: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **conversationId** | **int**|  | 
 **assistantAsk** | [**AssistantAsk**](AssistantAsk.md)|  | 

### Return type

[**AssistantConversation**](AssistantConversation.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **cancelAssistantAction**
> AssistantAction cancelAssistantAction(actionId)

Decline an action the assistant proposed

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAssistantApi();
final String actionId = actionId_example; // String | 

try {
    final response = api.cancelAssistantAction(actionId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AssistantApi->cancelAssistantAction: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **actionId** | **String**|  | 

### Return type

[**AssistantAction**](AssistantAction.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **confirmAssistantAction**
> AssistantAction confirmAssistantAction(actionId)

Do an action the assistant proposed on one of your answers

Runs the action once, as you. When agnts cannot do it now (the ticket moved on), the action comes back failed with the reason. Proposed actions expire after 30 minutes.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAssistantApi();
final String actionId = actionId_example; // String | 

try {
    final response = api.confirmAssistantAction(actionId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AssistantApi->confirmAssistantAction: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **actionId** | **String**|  | 

### Return type

[**AssistantAction**](AssistantAction.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteAssistantConversation**
> deleteAssistantConversation(conversationId)

Delete one of your conversations

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAssistantApi();
final int conversationId = 789; // int | 

try {
    api.deleteAssistantConversation(conversationId);
} on DioException catch (e) {
    print('Exception when calling AssistantApi->deleteAssistantConversation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **conversationId** | **int**|  | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAssistantConversation**
> AssistantConversation getAssistantConversation(conversationId)

One of your conversations with all its messages

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAssistantApi();
final int conversationId = 789; // int | 

try {
    final response = api.getAssistantConversation(conversationId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AssistantApi->getAssistantConversation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **conversationId** | **int**|  | 

### Return type

[**AssistantConversation**](AssistantConversation.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAssistantStats**
> AssistantStats getAssistantStats(days)

How the workspace's assistant did (questions, answer rate, time, ratings, tokens, per prompt version)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAssistantApi();
final int days = 56; // int | 

try {
    final response = api.getAssistantStats(days);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AssistantApi->getAssistantStats: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **days** | **int**|  | [optional] [default to 7]

### Return type

[**AssistantStats**](AssistantStats.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listAssistantConversations**
> List<AssistantConversation> listAssistantConversations()

Your assistant conversations, newest first, each with its last message

A conversation belongs to the person who started it; nobody else sees it. Kept for 30 days after its last message.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAssistantApi();

try {
    final response = api.listAssistantConversations();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AssistantApi->listAssistantConversations: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;AssistantConversation&gt;**](AssistantConversation.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listAssistantRated**
> List<AssistantRated> listAssistantRated(rating)

Rated answers with their questions, newest rating first

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAssistantApi();
final String rating = rating_example; // String | up or down; both when left out

try {
    final response = api.listAssistantRated(rating);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AssistantApi->listAssistantRated: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **rating** | **String**| up or down; both when left out | [optional] 

### Return type

[**List&lt;AssistantRated&gt;**](AssistantRated.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rateAssistantAnswer**
> AssistantMessage rateAssistantAnswer(messageId, assistantRating)

Rate one of your answers (helpful or not), or take the rating back

A rating, its comment, the answer and its question are shown to the workspace's owner. With share, the snapshot the answer was made from is kept with it so new prompts can be tried on the question.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAssistantApi();
final int messageId = 789; // int | 
final AssistantRating assistantRating = ; // AssistantRating | 

try {
    final response = api.rateAssistantAnswer(messageId, assistantRating);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AssistantApi->rateAssistantAnswer: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **messageId** | **int**|  | 
 **assistantRating** | [**AssistantRating**](AssistantRating.md)|  | 

### Return type

[**AssistantMessage**](AssistantMessage.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startAssistantConversation**
> AssistantConversation startAssistantConversation(assistantAsk)

Ask the assistant a question in a new conversation

Stores the question and starts answering it from a read-only snapshot of the workspace. Answers take 10-30 seconds: the response has the answer pending; fetch the conversation again, or wait for the assistant_answered (or assistant_failed) event on the event stream. The assistant takes no actions itself: when asked to act it proposes them as actions on its answer, which you confirm.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAssistantApi();
final AssistantAsk assistantAsk = ; // AssistantAsk | 

try {
    final response = api.startAssistantConversation(assistantAsk);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AssistantApi->startAssistantConversation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **assistantAsk** | [**AssistantAsk**](AssistantAsk.md)|  | 

### Return type

[**AssistantConversation**](AssistantConversation.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

