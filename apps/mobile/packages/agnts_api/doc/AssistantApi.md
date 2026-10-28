# agnts_api.api.AssistantApi

## Load the API package
```dart
import 'package:agnts_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**askAssistant**](AssistantApi.md#askassistant) | **POST** /assistant/conversations/{conversationId}/messages | Ask a follow-up question in one of your conversations
[**attachCodeTicket**](AssistantApi.md#attachcodeticket) | **PUT** /assistant/conversations/{conversationId}/ticket | Make an existing ticket the one a Code conversation works on
[**cancelAssistantAction**](AssistantApi.md#cancelassistantaction) | **POST** /assistant/actions/{actionId}/cancel | Decline an action the assistant proposed
[**confirmAssistantAction**](AssistantApi.md#confirmassistantaction) | **POST** /assistant/actions/{actionId}/confirm | Do an action the assistant proposed on one of your answers
[**decideCodeApproval**](AssistantApi.md#decidecodeapproval) | **POST** /assistant/approvals/{approvalId} | Allow or deny a tool call the agent asked you about
[**deleteAssistantConversation**](AssistantApi.md#deleteassistantconversation) | **DELETE** /assistant/conversations/{conversationId} | Delete one of your conversations
[**getAssistantConversation**](AssistantApi.md#getassistantconversation) | **GET** /assistant/conversations/{conversationId} | One of your conversations with all its messages
[**getAssistantStats**](AssistantApi.md#getassistantstats) | **GET** /assistant/stats | How the workspace&#39;s assistant did (questions, answer rate, time, ratings, tokens, per prompt version)
[**getCodeTimeline**](AssistantApi.md#getcodetimeline) | **GET** /assistant/conversations/{conversationId}/timeline | A Code conversation with its timeline
[**getTicketChat**](AssistantApi.md#getticketchat) | **GET** /tickets/{key}/chat | Your Code conversation that works on this ticket
[**listAssistantConversations**](AssistantApi.md#listassistantconversations) | **GET** /assistant/conversations | Your assistant conversations, newest first, each with its last message
[**listAssistantRated**](AssistantApi.md#listassistantrated) | **GET** /assistant/rated | Rated answers with their questions, newest rating first
[**rateAssistantAnswer**](AssistantApi.md#rateassistantanswer) | **PUT** /assistant/messages/{messageId}/rating | Rate one of your answers (helpful or not), or take the rating back
[**sendCodeMessage**](AssistantApi.md#sendcodemessage) | **POST** /assistant/conversations/{conversationId}/code | Send a message in a Code conversation
[**sendCodeQueuedNow**](AssistantApi.md#sendcodequeuednow) | **POST** /assistant/conversations/{conversationId}/send-now | Stop the running stage and send the queued messages now
[**setCodeRepos**](AssistantApi.md#setcoderepos) | **PUT** /assistant/conversations/{conversationId}/repos | Change the repositories of a Code conversation
[**startAssistantConversation**](AssistantApi.md#startassistantconversation) | **POST** /assistant/conversations | Ask the assistant a question in a new conversation
[**startCodeConversation**](AssistantApi.md#startcodeconversation) | **POST** /assistant/code | Start a Code conversation
[**transcribeAssistantQuestion**](AssistantApi.md#transcribeassistantquestion) | **POST** /assistant/transcribe | Turn a spoken question into text


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

# **attachCodeTicket**
> AssistantConversation attachCodeTicket(conversationId, attachCodeTicketRequest)

Make an existing ticket the one a Code conversation works on

The next message goes to it. Another of your conversations that had it lets it go.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAssistantApi();
final int conversationId = 789; // int | 
final AttachCodeTicketRequest attachCodeTicketRequest = ; // AttachCodeTicketRequest | 

try {
    final response = api.attachCodeTicket(conversationId, attachCodeTicketRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AssistantApi->attachCodeTicket: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **conversationId** | **int**|  | 
 **attachCodeTicketRequest** | [**AttachCodeTicketRequest**](AttachCodeTicketRequest.md)|  | 

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

# **decideCodeApproval**
> CodeApproval decideCodeApproval(approvalId, decideCodeApprovalRequest)

Allow or deny a tool call the agent asked you about

A Muse run in one of your Code conversations wants to run a command a rule says to ask about (installing a dependency, say). It waits for your answer; with none in 5 minutes the call is denied.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAssistantApi();
final String approvalId = approvalId_example; // String | 
final DecideCodeApprovalRequest decideCodeApprovalRequest = ; // DecideCodeApprovalRequest | 

try {
    final response = api.decideCodeApproval(approvalId, decideCodeApprovalRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AssistantApi->decideCodeApproval: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **approvalId** | **String**|  | 
 **decideCodeApprovalRequest** | [**DecideCodeApprovalRequest**](DecideCodeApprovalRequest.md)|  | 

### Return type

[**CodeApproval**](CodeApproval.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
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

# **getCodeTimeline**
> CodeTimeline getCodeTimeline(conversationId)

A Code conversation with its timeline

Your messages and its tickets' events (the newest 600), oldest first, and the tool calls waiting for your decision. Live updates come on the event stream: the tickets' own events, code_message and code_approval.

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
    final response = api.getCodeTimeline(conversationId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AssistantApi->getCodeTimeline: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **conversationId** | **int**|  | 

### Return type

[**CodeTimeline**](CodeTimeline.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getTicketChat**
> GetTicketChat200Response getTicketChat(key)

Your Code conversation that works on this ticket

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAssistantApi();
final String key = key_example; // String | 

try {
    final response = api.getTicketChat(key);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AssistantApi->getTicketChat: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 

### Return type

[**GetTicketChat200Response**](GetTicketChat200Response.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listAssistantConversations**
> List<AssistantConversation> listAssistantConversations(mode)

Your assistant conversations, newest first, each with its last message

A conversation belongs to the person who started it; nobody else sees it. Kept for 30 days after its last message; a Code conversation stays while one of its tickets is open.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAssistantApi();
final ChatMode mode = ; // ChatMode | Only Chat or only Code conversations

try {
    final response = api.listAssistantConversations(mode);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AssistantApi->listAssistantConversations: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **mode** | [**ChatMode**](.md)| Only Chat or only Code conversations | [optional] 

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

# **sendCodeMessage**
> AssistantMessage sendCodeMessage(conversationId, codeSend)

Send a message in a Code conversation

What it does depends on the current ticket's state, shown as routed: a new ticket when there is none or it is done; answers while it waits for answers; requested changes while it waits for review; continue or retry when it stopped. While a stage runs the message is queued and sent when the stage ends (a Muse run takes it at once: steered). Approve and reject are the ticket's own endpoints.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAssistantApi();
final int conversationId = 789; // int | 
final CodeSend codeSend = ; // CodeSend | 

try {
    final response = api.sendCodeMessage(conversationId, codeSend);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AssistantApi->sendCodeMessage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **conversationId** | **int**|  | 
 **codeSend** | [**CodeSend**](CodeSend.md)|  | 

### Return type

[**AssistantMessage**](AssistantMessage.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sendCodeQueuedNow**
> AssistantConversation sendCodeQueuedNow(conversationId)

Stop the running stage and send the queued messages now

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
    final response = api.sendCodeQueuedNow(conversationId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AssistantApi->sendCodeQueuedNow: $e\n');
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

# **setCodeRepos**
> AssistantConversation setCodeRepos(conversationId, repoChoice)

Change the repositories of a Code conversation

The next ticket works in them; the current one moves too while it has not started on code.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAssistantApi();
final int conversationId = 789; // int | 
final RepoChoice repoChoice = ; // RepoChoice | 

try {
    final response = api.setCodeRepos(conversationId, repoChoice);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AssistantApi->setCodeRepos: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **conversationId** | **int**|  | 
 **repoChoice** | [**RepoChoice**](RepoChoice.md)|  | 

### Return type

[**AssistantConversation**](AssistantConversation.md)

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

# **startCodeConversation**
> AssistantConversation startCodeConversation(codeStart)

Start a Code conversation

Code mode: pick the repositories (or an existing ticket with ticketKey) and say what you want done. The work runs as an ordinary ticket the conversation drives; its progress is the ticket's events (see getCodeTimeline). Owners and editors only.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAssistantApi();
final CodeStart codeStart = ; // CodeStart | 

try {
    final response = api.startCodeConversation(codeStart);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AssistantApi->startCodeConversation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **codeStart** | [**CodeStart**](CodeStart.md)|  | 

### Return type

[**AssistantConversation**](AssistantConversation.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **transcribeAssistantQuestion**
> AssistantTranscript transcribeAssistantQuestion(file)

Turn a spoken question into text

Muse Code hears the recording (`muse voice transcribe`) on the account your answers run on, and returns its words; ask them with startAssistantConversation or askAssistant as you would typed ones. The recording is 16-bit PCM WAV (16 kHz mono is plenty), at most 2 minutes; it is not kept. One recording at a time per person.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAssistantApi();
final MultipartFile file = BINARY_DATA_HERE; // MultipartFile | The recording, WAV, at most 4 MB

try {
    final response = api.transcribeAssistantQuestion(file);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AssistantApi->transcribeAssistantQuestion: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **file** | **MultipartFile**| The recording, WAV, at most 4 MB | 

### Return type

[**AssistantTranscript**](AssistantTranscript.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

