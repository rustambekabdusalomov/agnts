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
[**acknowledgeSecrets**](TicketsApi.md#acknowledgesecrets) | **POST** /tickets/{key}/secrets-ack | Confirm that the lines flagged as secrets in the change under review are not real credentials
[**addRelation**](TicketsApi.md#addrelation) | **POST** /tickets/{key}/relations | Make this ticket wait for another, or keep the two from running side by side
[**addressPullComments**](TicketsApi.md#addresspullcomments) | **POST** /tickets/{key}/address-comments | Send reviewers&#39; threads on the ticket&#39;s open pull requests back to coding: the given ones, or every unresolved thread by someone else not sent yet. After the fix is approved and pushed, agnts answers in each thread
[**answerQuestions**](TicketsApi.md#answerquestions) | **PUT** /tickets/{key}/answers | Answer the ticket&#39;s questions; when all are answered, coding starts
[**approveTicket**](TicketsApi.md#approveticket) | **POST** /tickets/{key}/approve | Approve the reviewed work
[**continueTicket**](TicketsApi.md#continueticket) | **POST** /tickets/{key}/continue | Pick a rejected ticket up again where it stopped
[**dismissFollowUp**](TicketsApi.md#dismissfollowup) | **POST** /tickets/{key}/follow-ups/{id}/dismiss | Decline a suggestion; later runs will not suggest it again
[**dismissRelation**](TicketsApi.md#dismissrelation) | **POST** /tickets/{key}/relations/{id}/dismiss | Dismiss a relation (run anyway); agnts does not propose it again
[**editCommitMessage**](TicketsApi.md#editcommitmessage) | **PUT** /tickets/{key}/commit | Change the message of one of agnts&#39;s commits before it pushes them
[**followUpFromFinding**](TicketsApi.md#followupfromfinding) | **POST** /tickets/{key}/review/findings/{index}/follow-up | Turn a code review finding into a follow-up suggestion
[**getPreviewShot**](TicketsApi.md#getpreviewshot) | **GET** /tickets/{key}/preview/{runId}/shots/{shotId} | One preview screenshot, as PNG
[**getTicket**](TicketsApi.md#getticket) | **GET** /tickets/{key} | A ticket with its questions, analysis and latest result
[**implementTicket**](TicketsApi.md#implementticket) | **POST** /tickets/{key}/implement | Make the code task that carries out a done plan or bug investigation
[**keepCurrentVersion**](TicketsApi.md#keepcurrentversion) | **POST** /tickets/{key}/keep-version | Keep working from the version agnts started with; this newer version of the issue is not asked about again
[**listFollowUps**](TicketsApi.md#listfollowups) | **GET** /tickets/{key}/follow-ups | Suggested follow-up tickets and the tickets made from them
[**listRelations**](TicketsApi.md#listrelations) | **GET** /tickets/{key}/relations | The ticket&#39;s ordering constraints and what holds it back now
[**listTicketEvents**](TicketsApi.md#listticketevents) | **GET** /tickets/{key}/events | The ticket&#39;s log, oldest first; poll with &#x60;after&#x60; for live updates
[**listTickets**](TicketsApi.md#listtickets) | **GET** /tickets | Tickets, most recently active first
[**markTicketMerged**](TicketsApi.md#markticketmerged) | **POST** /tickets/{key}/merged | Record that a done ticket&#39;s pull request was merged
[**previewTicket**](TicketsApi.md#previewticket) | **POST** /tickets/{key}/preview | Queue a preview (screenshots of the running app) of a ticket waiting for review, again if one already ran
[**reapplyCommitFormat**](TicketsApi.md#reapplycommitformat) | **POST** /tickets/{key}/commits/reapply | Write agnts&#39;s unpushed commit messages again from the commit format in effect
[**rejectTicket**](TicketsApi.md#rejectticket) | **POST** /tickets/{key}/reject | Stop work on the ticket for good
[**renameTicketBranch**](TicketsApi.md#renameticketbranch) | **PUT** /tickets/{key}/branch | Rename the ticket&#39;s branch before agnts pushes it
[**replayTicket**](TicketsApi.md#replayticket) | **POST** /tickets/{key}/replay | Re-run a done code or test ticket with today&#39;s agnts, from the commit it started from, to compare the two (Analytics → Replay evaluation). The replay is a new local task that is never pushed.
[**requestChanges**](TicketsApi.md#requestchanges) | **POST** /tickets/{key}/request-changes | Send the ticket back to coding with feedback
[**restartWithUpdate**](TicketsApi.md#restartwithupdate) | **POST** /tickets/{key}/restart-update | Start the ticket over from the newer version of its issue; the work so far is dropped
[**retryTicket**](TicketsApi.md#retryticket) | **POST** /tickets/{key}/retry | Resume a failed or rate-limited ticket where it stopped
[**reviewTicket**](TicketsApi.md#reviewticket) | **POST** /tickets/{key}/review | Queue a code review of a ticket waiting for review (again, if one already ran)
[**setFollowUps**](TicketsApi.md#setfollowups) | **PUT** /tickets/{key}/follow-ups | Turn follow-up suggestions on or off for this ticket
[**setTicketKind**](TicketsApi.md#setticketkind) | **PUT** /tickets/{key}/kind | Change what the ticket produces
[**setTicketMember**](TicketsApi.md#setticketmember) | **PUT** /tickets/{key}/member | Make a member the ticket&#39;s member (per-member Claude mode runs it on their account)
[**setTicketModels**](TicketsApi.md#setticketmodels) | **PUT** /tickets/{key}/models | Override models for this ticket; omit a stage to use the default
[**setTicketNumber**](TicketsApi.md#setticketnumber) | **PUT** /tickets/{key}/number | Change the team&#39;s number for the work until the ticket is closed
[**setTicketRepo**](TicketsApi.md#setticketrepo) | **PUT** /tickets/{key}/repo | Link the ticket to a repository
[**setTicketRepos**](TicketsApi.md#setticketrepos) | **PUT** /tickets/{key}/repos | Set the ticket&#39;s repositories (one, several or a group)
[**startTicket**](TicketsApi.md#startticket) | **POST** /tickets/{key}/analyze | Start a held ticket now (it is queued for the next free slot)
[**startTicketOver**](TicketsApi.md#startticketover) | **POST** /tickets/{key}/start-over | Pick a rejected ticket up again from scratch
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

# **acknowledgeSecrets**
> Ticket acknowledgeSecrets(key)

Confirm that the lines flagged as secrets in the change under review are not real credentials

A change with lines agnts's scan flagged as secrets (or a dotenv file) cannot be approved until a person confirms, for that commit, that they are not real credentials.

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
    final response = api.acknowledgeSecrets(key);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->acknowledgeSecrets: $e\n');
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

# **addressPullComments**
> Ticket addressPullComments(key, addressPullCommentsRequest)

Send reviewers' threads on the ticket's open pull requests back to coding: the given ones, or every unresolved thread by someone else not sent yet. After the fix is approved and pushed, agnts answers in each thread

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getTicketsApi();
final String key = key_example; // String | 
final AddressPullCommentsRequest addressPullCommentsRequest = ; // AddressPullCommentsRequest | 

try {
    final response = api.addressPullComments(key, addressPullCommentsRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->addressPullComments: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **addressPullCommentsRequest** | [**AddressPullCommentsRequest**](AddressPullCommentsRequest.md)|  | [optional] 

### Return type

[**Ticket**](Ticket.md)

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

# **continueTicket**
> Ticket continueTicket(key, continueTicketRequest)

Pick a rejected ticket up again where it stopped

Goes back to the stage it was rejected at (the ticket's continueTo). A ticket rejected at review goes back to review, or to coding when a note or files ask for changes. When the work's commits are gone, it starts over from analysis. 

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getTicketsApi();
final String key = key_example; // String | 
final ContinueTicketRequest continueTicketRequest = ; // ContinueTicketRequest | 

try {
    final response = api.continueTicket(key, continueTicketRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->continueTicket: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **continueTicketRequest** | [**ContinueTicketRequest**](ContinueTicketRequest.md)|  | [optional] 

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

# **editCommitMessage**
> Ticket editCommitMessage(key, editCommitMessageRequest)

Change the message of one of agnts's commits before it pushes them

One of the repository's commits (its commits, ticket detail only), under the rules of renameTicketBranch: a branch never pushed, while the ticket waits for review or stopped on an error. The commits after it are made again on top, so the repository's headSha changes; the same message changes nothing. 

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getTicketsApi();
final String key = key_example; // String | 
final EditCommitMessageRequest editCommitMessageRequest = ; // EditCommitMessageRequest | 

try {
    final response = api.editCommitMessage(key, editCommitMessageRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->editCommitMessage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **editCommitMessageRequest** | [**EditCommitMessageRequest**](EditCommitMessageRequest.md)|  | 

### Return type

[**Ticket**](Ticket.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
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

# **keepCurrentVersion**
> Ticket keepCurrentVersion(key)

Keep working from the version agnts started with; this newer version of the issue is not asked about again

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
    final response = api.keepCurrentVersion(key);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->keepCurrentVersion: $e\n');
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

# **reapplyCommitFormat**
> ReapplyCommitFormat200Response reapplyCommitFormat(key, reapplyCommitFormatRequest)

Write agnts's unpushed commit messages again from the commit format in effect

For commits made before a format was set. Each repository's commits (its commits) get the format of the ticket's group, else of the repository, filled with the type, scope and subject the coding run that made the commit gave (the ticket's kind and title when it gave none). Repositories without a format are left as they are. Same rules as editCommitMessage. With dryRun nothing changes: changes lists what would. 

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getTicketsApi();
final String key = key_example; // String | 
final ReapplyCommitFormatRequest reapplyCommitFormatRequest = ; // ReapplyCommitFormatRequest | 

try {
    final response = api.reapplyCommitFormat(key, reapplyCommitFormatRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->reapplyCommitFormat: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **reapplyCommitFormatRequest** | [**ReapplyCommitFormatRequest**](ReapplyCommitFormatRequest.md)|  | [optional] 

### Return type

[**ReapplyCommitFormat200Response**](ReapplyCommitFormat200Response.md)

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

# **renameTicketBranch**
> Ticket renameTicketBranch(key, renameTicketBranchRequest)

Rename the ticket's branch before agnts pushes it

Only a branch that was never pushed (the repository's canRenameBranch), while the ticket waits for review or stopped on an error. The pull request opens from the new name, and later runs keep it. 409 when the name is taken, in agnts or on the git host. 

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getTicketsApi();
final String key = key_example; // String | 
final RenameTicketBranchRequest renameTicketBranchRequest = ; // RenameTicketBranchRequest | 

try {
    final response = api.renameTicketBranch(key, renameTicketBranchRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->renameTicketBranch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **renameTicketBranchRequest** | [**RenameTicketBranchRequest**](RenameTicketBranchRequest.md)|  | 

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

# **restartWithUpdate**
> Ticket restartWithUpdate(key)

Start the ticket over from the newer version of its issue; the work so far is dropped

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
    final response = api.restartWithUpdate(key);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->restartWithUpdate: $e\n');
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

# **setTicketNumber**
> Ticket setTicketNumber(key, setTicketNumberRequest)

Change the team's number for the work until the ticket is closed

The number ({number}) branch and commit names are made from, like AMANAT-2677; empty clears it, so the key stands for it. Any state but done and rejected. Branches and commits made from then on use it; ones already made keep their names until renamed (renameTicketBranch, reapplyCommitFormat). The same number changes nothing. 

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getTicketsApi();
final String key = key_example; // String | 
final SetTicketNumberRequest setTicketNumberRequest = ; // SetTicketNumberRequest | 

try {
    final response = api.setTicketNumber(key, setTicketNumberRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->setTicketNumber: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **setTicketNumberRequest** | [**SetTicketNumberRequest**](SetTicketNumberRequest.md)|  | 

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

Allowed on a new ticket, or a failed or rate-limited one that has not pushed. A stopped ticket starts over from analysis on retry, since its analysis and branch belonged to the old repository. The same as PUT /tickets/{key}/repos with one repository.

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

# **setTicketRepos**
> Ticket setTicketRepos(key, ticketReposInput)

Set the ticket's repositories (one, several or a group)

Allowed while no stage runs and nothing was pushed: on a new ticket, or a failed or rate-limited one. A stopped ticket starts over from analysis on retry. Give repoIds (the first is the primary) or groupId, not both.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getTicketsApi();
final String key = key_example; // String | 
final TicketReposInput ticketReposInput = ; // TicketReposInput | 

try {
    final response = api.setTicketRepos(key, ticketReposInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->setTicketRepos: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **ticketReposInput** | [**TicketReposInput**](TicketReposInput.md)|  | 

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

# **startTicketOver**
> Ticket startTicketOver(key)

Pick a rejected ticket up again from scratch

Drops the analysis, answers and commits and analyses the ticket again. Only when nothing of it was pushed (the ticket's canStartOver).

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
    final response = api.startTicketOver(key);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TicketsApi->startTicketOver: $e\n');
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

