# agnts_api.api.TicketsApi

## Load the API package
```dart
import 'package:agnts_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**acceptFollowUps**](TicketsApi.md#acceptfollowups) | **POST** /tickets/{key}/follow-ups/accept | Create tickets from chosen suggestions
[**answerQuestions**](TicketsApi.md#answerquestions) | **PUT** /tickets/{key}/answers | Answer the ticket&#39;s questions; when all are answered, coding starts
[**approveTicket**](TicketsApi.md#approveticket) | **POST** /tickets/{key}/approve | Approve the reviewed work
[**dismissFollowUp**](TicketsApi.md#dismissfollowup) | **POST** /tickets/{key}/follow-ups/{id}/dismiss | Decline a suggestion; later runs will not suggest it again
[**followUpFromFinding**](TicketsApi.md#followupfromfinding) | **POST** /tickets/{key}/review/findings/{index}/follow-up | Turn a code review finding into a follow-up suggestion
[**getTicket**](TicketsApi.md#getticket) | **GET** /tickets/{key} | A ticket with its questions, analysis and latest result
[**implementTicket**](TicketsApi.md#implementticket) | **POST** /tickets/{key}/implement | Make the code task that carries out a done plan or bug investigation
[**listFollowUps**](TicketsApi.md#listfollowups) | **GET** /tickets/{key}/follow-ups | Suggested follow-up tickets and the tickets made from them
[**listTicketEvents**](TicketsApi.md#listticketevents) | **GET** /tickets/{key}/events | The ticket&#39;s log, oldest first; poll with &#x60;after&#x60; for live updates
[**listTickets**](TicketsApi.md#listtickets) | **GET** /tickets | Tickets, most recently active first
[**rejectTicket**](TicketsApi.md#rejectticket) | **POST** /tickets/{key}/reject | Stop work on the ticket for good
[**requestChanges**](TicketsApi.md#requestchanges) | **POST** /tickets/{key}/request-changes | Send the ticket back to coding with feedback
[**retryTicket**](TicketsApi.md#retryticket) | **POST** /tickets/{key}/retry | Resume a failed or rate-limited ticket where it stopped
[**reviewTicket**](TicketsApi.md#reviewticket) | **POST** /tickets/{key}/review | Queue a code review of a ticket waiting for review (again, if one already ran)
[**setFollowUps**](TicketsApi.md#setfollowups) | **PUT** /tickets/{key}/follow-ups | Turn follow-up suggestions on or off for this ticket
[**setTicketKind**](TicketsApi.md#setticketkind) | **PUT** /tickets/{key}/kind | Change what the ticket produces
[**setTicketModels**](TicketsApi.md#setticketmodels) | **PUT** /tickets/{key}/models | Override models for this ticket; omit a stage to use the default
[**setTicketRepo**](TicketsApi.md#setticketrepo) | **PUT** /tickets/{key}/repo | Link the ticket to a repository
[**startTicket**](TicketsApi.md#startticket) | **POST** /tickets/{key}/analyze | Start a held ticket now (it is queued for the next free slot)
[**stopTicket**](TicketsApi.md#stopticket) | **POST** /tickets/{key}/stop | Stop the running stage; the ticket moves to failed and can be retried


# **acceptFollowUps**
> AcceptFollowUpsResult acceptFollowUps(key, acceptFollowUps)

Create tickets from chosen suggestions

Each chosen suggestion becomes a queued (held) ticket, as a local task or a new Jira issue. Nothing runs until it is started. Items are handled one by one; each result says what happened to its suggestion. What the analysis suggested can be created at once; what the work or its review found waits until this ticket is done.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getTicketsApi();
final String key = key_example; // String | 
final AcceptFollowUps acceptFollowUps = ; // AcceptFollowUps | 

try {
    final response = api.acceptFollowUps(key, acceptFollowUps);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->acceptFollowUps: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **acceptFollowUps** | [**AcceptFollowUps**](AcceptFollowUps.md)|  | 

### Return type

[**AcceptFollowUpsResult**](AcceptFollowUpsResult.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **answerQuestions**
> Ticket answerQuestions(key, answersRequest)

Answer the ticket's questions; when all are answered, coding starts

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getTicketsApi();
final String key = key_example; // String | 
final AnswersRequest answersRequest = ; // AnswersRequest | 

try {
    final response = api.answerQuestions(key, answersRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->answerQuestions: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **answersRequest** | [**AnswersRequest**](AnswersRequest.md)|  | 

### Return type

[**Ticket**](Ticket.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **approveTicket**
> Ticket approveTicket(key, approveTicketRequest)

Approve the reviewed work

For a change, agnts pushes the branch and opens the pull request. For a report, the ticket is done; the report is posted to the tracker issue only when postReport is true.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getTicketsApi();
final String key = key_example; // String | 
final ApproveTicketRequest approveTicketRequest = ; // ApproveTicketRequest | 

try {
    final response = api.approveTicket(key, approveTicketRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->approveTicket: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **approveTicketRequest** | [**ApproveTicketRequest**](ApproveTicketRequest.md)|  | [optional] 

### Return type

[**Ticket**](Ticket.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **dismissFollowUp**
> FollowUpSuggestion dismissFollowUp(key, id)

Decline a suggestion; later runs will not suggest it again

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getTicketsApi();
final String key = key_example; // String | 
final int id = 789; // int | 

try {
    final response = api.dismissFollowUp(key, id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->dismissFollowUp: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **id** | **int**|  | 

### Return type

[**FollowUpSuggestion**](FollowUpSuggestion.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **followUpFromFinding**
> FollowUpSuggestion followUpFromFinding(key, index)

Turn a code review finding into a follow-up suggestion

No Claude run is involved.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getTicketsApi();
final String key = key_example; // String | 
final int index = 56; // int | The finding's position in the newest code review

try {
    final response = api.followUpFromFinding(key, index);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->followUpFromFinding: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **index** | **int**| The finding's position in the newest code review | 

### Return type

[**FollowUpSuggestion**](FollowUpSuggestion.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getTicket**
> TicketDetail getTicket(key)

A ticket with its questions, analysis and latest result

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getTicketsApi();
final String key = key_example; // String | 

try {
    final response = api.getTicket(key);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->getTicket: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 

### Return type

[**TicketDetail**](TicketDetail.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **implementTicket**
> Ticket implementTicket(key, implementInput)

Make the code task that carries out a done plan or bug investigation

Creates a local code task linked back to the report (parentKey), with the approved report in its description. A report is implemented once. repoId is needed only when the report has no repository.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getTicketsApi();
final String key = key_example; // String | 
final ImplementInput implementInput = ; // ImplementInput | 

try {
    final response = api.implementTicket(key, implementInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->implementTicket: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **implementInput** | [**ImplementInput**](ImplementInput.md)|  | [optional] 

### Return type

[**Ticket**](Ticket.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listFollowUps**
> FollowUps listFollowUps(key)

Suggested follow-up tickets and the tickets made from them

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getTicketsApi();
final String key = key_example; // String | 

try {
    final response = api.listFollowUps(key);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->listFollowUps: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 

### Return type

[**FollowUps**](FollowUps.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listTicketEvents**
> List<Event> listTicketEvents(key, after, limit)

The ticket's log, oldest first; poll with `after` for live updates

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getTicketsApi();
final String key = key_example; // String | 
final int after = 789; // int | Only events with a larger id
final int limit = 56; // int | 

try {
    final response = api.listTicketEvents(key, after, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->listTicketEvents: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **after** | **int**| Only events with a larger id | [optional] [default to 0]
 **limit** | **int**|  | [optional] [default to 500]

### Return type

[**List&lt;Event&gt;**](Event.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listTickets**
> List<Ticket> listTickets(state)

Tickets, most recently active first

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getTicketsApi();
final List<TicketState> state = ; // List<TicketState> | Only tickets in these states

try {
    final response = api.listTickets(state);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->listTickets: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **state** | [**List&lt;TicketState&gt;**](TicketState.md)| Only tickets in these states | [optional] 

### Return type

[**List&lt;Ticket&gt;**](Ticket.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rejectTicket**
> Ticket rejectTicket(key, rejectTicketRequest)

Stop work on the ticket for good

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getTicketsApi();
final String key = key_example; // String | 
final RejectTicketRequest rejectTicketRequest = ; // RejectTicketRequest | 

try {
    final response = api.rejectTicket(key, rejectTicketRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->rejectTicket: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **rejectTicketRequest** | [**RejectTicketRequest**](RejectTicketRequest.md)|  | [optional] 

### Return type

[**Ticket**](Ticket.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **requestChanges**
> Ticket requestChanges(key, requestChangesRequest)

Send the ticket back to coding with feedback

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getTicketsApi();
final String key = key_example; // String | 
final RequestChangesRequest requestChangesRequest = ; // RequestChangesRequest | 

try {
    final response = api.requestChanges(key, requestChangesRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->requestChanges: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **requestChangesRequest** | [**RequestChangesRequest**](RequestChangesRequest.md)|  | 

### Return type

[**Ticket**](Ticket.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **retryTicket**
> Ticket retryTicket(key)

Resume a failed or rate-limited ticket where it stopped

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getTicketsApi();
final String key = key_example; // String | 

try {
    final response = api.retryTicket(key);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->retryTicket: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 

### Return type

[**Ticket**](Ticket.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **reviewTicket**
> Ticket reviewTicket(key)

Queue a code review of a ticket waiting for review (again, if one already ran)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getTicketsApi();
final String key = key_example; // String | 

try {
    final response = api.reviewTicket(key);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->reviewTicket: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 

### Return type

[**Ticket**](Ticket.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setFollowUps**
> Ticket setFollowUps(key, followUpsSetting)

Turn follow-up suggestions on or off for this ticket

inherit follows Settings (suggestFollowUps). Suggestions add a little to every prompt of the ticket's runs, so they are off unless asked for.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getTicketsApi();
final String key = key_example; // String | 
final FollowUpsSetting followUpsSetting = ; // FollowUpsSetting | 

try {
    final response = api.setFollowUps(key, followUpsSetting);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->setFollowUps: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **followUpsSetting** | [**FollowUpsSetting**](FollowUpsSetting.md)|  | 

### Return type

[**Ticket**](Ticket.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setTicketKind**
> Ticket setTicketKind(key, ticketKindInput)

Change what the ticket produces

Allowed on a new ticket, while agnts waits for answers, and on a failed or rate-limited one that has not pushed. auto lets the analysis pick the kind again; any other kind is final.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getTicketsApi();
final String key = key_example; // String | 
final TicketKindInput ticketKindInput = ; // TicketKindInput | 

try {
    final response = api.setTicketKind(key, ticketKindInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->setTicketKind: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **ticketKindInput** | [**TicketKindInput**](TicketKindInput.md)|  | 

### Return type

[**Ticket**](Ticket.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setTicketModels**
> Ticket setTicketModels(key, modelOverrides)

Override models for this ticket; omit a stage to use the default

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getTicketsApi();
final String key = key_example; // String | 
final ModelOverrides modelOverrides = ; // ModelOverrides | 

try {
    final response = api.setTicketModels(key, modelOverrides);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->setTicketModels: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **modelOverrides** | [**ModelOverrides**](ModelOverrides.md)|  | 

### Return type

[**Ticket**](Ticket.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setTicketRepo**
> Ticket setTicketRepo(key, ticketRepo)

Link the ticket to a repository

Allowed on a new ticket, or a failed or rate-limited one that has not pushed. A stopped ticket starts over from analysis on retry, since its analysis and branch belonged to the old repository.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getTicketsApi();
final String key = key_example; // String | 
final TicketRepo ticketRepo = ; // TicketRepo | 

try {
    final response = api.setTicketRepo(key, ticketRepo);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->setTicketRepo: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **ticketRepo** | [**TicketRepo**](TicketRepo.md)|  | 

### Return type

[**Ticket**](Ticket.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startTicket**
> Ticket startTicket(key)

Start a held ticket now (it is queued for the next free slot)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getTicketsApi();
final String key = key_example; // String | 

try {
    final response = api.startTicket(key);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->startTicket: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 

### Return type

[**Ticket**](Ticket.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **stopTicket**
> Ticket stopTicket(key)

Stop the running stage; the ticket moves to failed and can be retried

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getTicketsApi();
final String key = key_example; // String | 

try {
    final response = api.stopTicket(key);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->stopTicket: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 

### Return type

[**Ticket**](Ticket.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

