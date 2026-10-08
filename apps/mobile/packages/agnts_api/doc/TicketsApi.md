# agnts_api.api.TicketsApi

## Load the API package
```dart
import 'package:agnts_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**acceptFollowUps**](TicketsApi.md#acceptfollowups) | **POST** /tickets/{key}/follow-ups/accept | Create tickets from chosen suggestions
[**acceptRelation**](TicketsApi.md#acceptrelation) | **POST** /tickets/{key}/relations/{id}/accept | Accept a relation agnts proposed; the queue follows it from now on
[**addRelation**](TicketsApi.md#addrelation) | **POST** /tickets/{key}/relations | Make this ticket wait for another, or keep the two from running side by side
[**answerQuestions**](TicketsApi.md#answerquestions) | **PUT** /tickets/{key}/answers | Answer the ticket&#39;s questions; when all are answered, coding starts
[**approveTicket**](TicketsApi.md#approveticket) | **POST** /tickets/{key}/approve | Approve the reviewed work
[**dismissFollowUp**](TicketsApi.md#dismissfollowup) | **POST** /tickets/{key}/follow-ups/{id}/dismiss | Decline a suggestion; later runs will not suggest it again
[**dismissRelation**](TicketsApi.md#dismissrelation) | **POST** /tickets/{key}/relations/{id}/dismiss | Dismiss a relation (run anyway); agnts does not propose it again
[**followUpFromFinding**](TicketsApi.md#followupfromfinding) | **POST** /tickets/{key}/review/findings/{index}/follow-up | Turn a code review finding into a follow-up suggestion
[**getPreviewShot**](TicketsApi.md#getpreviewshot) | **GET** /tickets/{key}/preview/{runId}/shots/{shotId} | One preview screenshot, as PNG
[**getTicket**](TicketsApi.md#getticket) | **GET** /tickets/{key} | A ticket with its questions, analysis and latest result
[**implementTicket**](TicketsApi.md#implementticket) | **POST** /tickets/{key}/implement | Make the code task that carries out a done plan or bug investigation
[**listFollowUps**](TicketsApi.md#listfollowups) | **GET** /tickets/{key}/follow-ups | Suggested follow-up tickets and the tickets made from them
[**listRelations**](TicketsApi.md#listrelations) | **GET** /tickets/{key}/relations | The ticket&#39;s ordering constraints and what holds it back now
[**listTicketEvents**](TicketsApi.md#listticketevents) | **GET** /tickets/{key}/events | The ticket&#39;s log, oldest first; poll with &#x60;after&#x60; for live updates
[**listTickets**](TicketsApi.md#listtickets) | **GET** /tickets | Tickets, most recently active first
[**markTicketMerged**](TicketsApi.md#markticketmerged) | **POST** /tickets/{key}/merged | Record that a done ticket&#39;s pull request was merged
[**previewTicket**](TicketsApi.md#previewticket) | **POST** /tickets/{key}/preview | Queue a preview (screenshots of the running app) of a ticket waiting for review, again if one already ran
[**rejectTicket**](TicketsApi.md#rejectticket) | **POST** /tickets/{key}/reject | Stop work on the ticket for good
[**replayTicket**](TicketsApi.md#replayticket) | **POST** /tickets/{key}/replay | Re-run a done code or test ticket with today&#39;s agnts, from the commit it started from, to compare the two (Analytics → Replay evaluation). The replay is a new local task that is never pushed.
[**requestChanges**](TicketsApi.md#requestchanges) | **POST** /tickets/{key}/request-changes | Send the ticket back to coding with feedback
[**retryTicket**](TicketsApi.md#retryticket) | **POST** /tickets/{key}/retry | Resume a failed or rate-limited ticket where it stopped
[**reviewTicket**](TicketsApi.md#reviewticket) | **POST** /tickets/{key}/review | Queue a code review of a ticket waiting for review (again, if one already ran)
[**setFollowUps**](TicketsApi.md#setfollowups) | **PUT** /tickets/{key}/follow-ups | Turn follow-up suggestions on or off for this ticket
[**setTicketKind**](TicketsApi.md#setticketkind) | **PUT** /tickets/{key}/kind | Change what the ticket produces
[**setTicketMember**](TicketsApi.md#setticketmember) | **PUT** /tickets/{key}/member | Make a member the ticket&#39;s member (per-member Claude mode runs it on their account)
[**setTicketModels**](TicketsApi.md#setticketmodels) | **PUT** /tickets/{key}/models | Override models for this ticket; omit a stage to use the default
[**setTicketRepo**](TicketsApi.md#setticketrepo) | **PUT** /tickets/{key}/repo | Link the ticket to a repository
[**startTicket**](TicketsApi.md#startticket) | **POST** /tickets/{key}/analyze | Start a held ticket now (it is queued for the next free slot)
[**stopTicket**](TicketsApi.md#stopticket) | **POST** /tickets/{key}/stop | Stop the running stage; the ticket moves to failed and can be retried
[**translateTicket**](TicketsApi.md#translateticket) | **POST** /tickets/{key}/translate | Translate a ticket&#39;s texts (its own and what agnts wrote) into a language


# **acceptFollowUps**
> AcceptFollowUpsResult acceptFollowUps(key, acceptFollowUps)

Create tickets from chosen suggestions

Each chosen suggestion becomes a queued (held) ticket, as a local task, a new Jira issue or a new Plane work item. Nothing runs until it is started. Items are handled one by one; each result says what happened to its suggestion. What the analysis suggested can be created at once; what the work or its review found waits until this ticket is done.

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

# **acceptRelation**
> Relation acceptRelation(key, id)

Accept a relation agnts proposed; the queue follows it from now on

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
    final response = api.acceptRelation(key, id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->acceptRelation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **id** | **int**|  | 

### Return type

[**Relation**](Relation.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **addRelation**
> Relation addRelation(key, relationInput)

Make this ticket wait for another, or keep the two from running side by side

depends_on: this ticket does not start coding until the other is merged (or rejected). conflicts: whichever of the two starts coding second waits until the first is merged. A dependency that would make two tickets wait for each other is refused (400). Adding a relation agnts proposed or someone dismissed makes it active.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getTicketsApi();
final String key = key_example; // String | 
final RelationInput relationInput = ; // RelationInput | 

try {
    final response = api.addRelation(key, relationInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->addRelation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **relationInput** | [**RelationInput**](RelationInput.md)|  | 

### Return type

[**Relation**](Relation.md)

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

# **dismissRelation**
> Relation dismissRelation(key, id)

Dismiss a relation (run anyway); agnts does not propose it again

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
    final response = api.dismissRelation(key, id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->dismissRelation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **id** | **int**|  | 

### Return type

[**Relation**](Relation.md)

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

# **getPreviewShot**
> Uint8List getPreviewShot(key, runId, shotId)

One preview screenshot, as PNG

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getTicketsApi();
final String key = key_example; // String | 
final int runId = 789; // int | 
final String shotId = shotId_example; // String | 

try {
    final response = api.getPreviewShot(key, runId, shotId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->getPreviewShot: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **runId** | **int**|  | 
 **shotId** | **String**|  | 

### Return type

[**Uint8List**](Uint8List.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: image/png, application/json

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

# **listRelations**
> Relations listRelations(key)

The ticket's ordering constraints and what holds it back now

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
    final response = api.listRelations(key);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->listRelations: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 

### Return type

[**Relations**](Relations.md)

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

# **markTicketMerged**
> Ticket markTicketMerged(key)

Record that a done ticket's pull request was merged

For setups without a git host webhook. Tickets waiting for this one may start coding.

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
    final response = api.markTicketMerged(key);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->markTicketMerged: $e\n');
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

# **previewTicket**
> Ticket previewTicket(key, previewInput)

Queue a preview (screenshots of the running app) of a ticket waiting for review, again if one already ran

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getTicketsApi();
final String key = key_example; // String | 
final PreviewInput previewInput = ; // PreviewInput | 

try {
    final response = api.previewTicket(key, previewInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->previewTicket: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **previewInput** | [**PreviewInput**](PreviewInput.md)|  | [optional] 

### Return type

[**Ticket**](Ticket.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
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

# **replayTicket**
> Ticket replayTicket(key)

Re-run a done code or test ticket with today's agnts, from the commit it started from, to compare the two (Analytics → Replay evaluation). The replay is a new local task that is never pushed.

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
    final response = api.replayTicket(key);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->replayTicket: $e\n');
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
> Ticket retryTicket(key, retryTicketRequest)

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
final RetryTicketRequest retryTicketRequest = ; // RetryTicketRequest | 

try {
    final response = api.retryTicket(key, retryTicketRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->retryTicket: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **retryTicketRequest** | [**RetryTicketRequest**](RetryTicketRequest.md)|  | [optional] 

### Return type

[**Ticket**](Ticket.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
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

# **setTicketMember**
> Ticket setTicketMember(key, setTicketMemberRequest)

Make a member the ticket's member (per-member Claude mode runs it on their account)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getTicketsApi();
final String key = key_example; // String | 
final SetTicketMemberRequest setTicketMemberRequest = ; // SetTicketMemberRequest | 

try {
    final response = api.setTicketMember(key, setTicketMemberRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->setTicketMember: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **setTicketMemberRequest** | [**SetTicketMemberRequest**](SetTicketMemberRequest.md)|  | 

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

# **translateTicket**
> Translation translateTicket(key, translateInput)

Translate a ticket's texts (its own and what agnts wrote) into a language

Translations are stored per text, so a text is sent to Claude only once per language; asking again, or for a later revision that keeps most texts, answers from the store. Texts not yet translated are translated in this request, which can take a minute.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getTicketsApi();
final String key = key_example; // String | 
final TranslateInput translateInput = ; // TranslateInput | 

try {
    final response = api.translateTicket(key, translateInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->translateTicket: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **translateInput** | [**TranslateInput**](TranslateInput.md)|  | 

### Return type

[**Translation**](Translation.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

