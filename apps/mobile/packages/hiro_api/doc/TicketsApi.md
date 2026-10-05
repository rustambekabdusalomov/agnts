# hiro_api.api.TicketsApi

## Load the API package
```dart
import 'package:hiro_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**answerQuestions**](TicketsApi.md#answerquestions) | **PUT** /tickets/{key}/answers | Answer the ticket&#39;s questions; when all are answered, coding starts
[**approveTicket**](TicketsApi.md#approveticket) | **POST** /tickets/{key}/approve | Approve the reviewed changes; hiro pushes the branch and opens the PR
[**getTicket**](TicketsApi.md#getticket) | **GET** /tickets/{key} | A ticket with its questions, analysis and latest result
[**listTicketEvents**](TicketsApi.md#listticketevents) | **GET** /tickets/{key}/events | The ticket&#39;s log, oldest first; poll with &#x60;after&#x60; for live updates
[**listTickets**](TicketsApi.md#listtickets) | **GET** /tickets | Tickets, most recently active first
[**rejectTicket**](TicketsApi.md#rejectticket) | **POST** /tickets/{key}/reject | Stop work on the ticket for good
[**requestChanges**](TicketsApi.md#requestchanges) | **POST** /tickets/{key}/request-changes | Send the ticket back to coding with feedback
[**retryTicket**](TicketsApi.md#retryticket) | **POST** /tickets/{key}/retry | Resume a failed or rate-limited ticket where it stopped
[**setTicketModels**](TicketsApi.md#setticketmodels) | **PUT** /tickets/{key}/models | Override models for this ticket; omit a stage to use the default
[**setTicketRepo**](TicketsApi.md#setticketrepo) | **PUT** /tickets/{key}/repo | Link the ticket to a repository
[**startTicket**](TicketsApi.md#startticket) | **POST** /tickets/{key}/analyze | Start a held ticket now (it is queued for the next free slot)
[**stopTicket**](TicketsApi.md#stopticket) | **POST** /tickets/{key}/stop | Stop the running stage; the ticket moves to failed and can be retried


# **answerQuestions**
> Ticket answerQuestions(key, answersRequest)

Answer the ticket's questions; when all are answered, coding starts

### Example
```dart
import 'package:hiro_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = HiroApi().getTicketsApi();
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

Approve the reviewed changes; hiro pushes the branch and opens the PR

### Example
```dart
import 'package:hiro_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = HiroApi().getTicketsApi();
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

# **getTicket**
> TicketDetail getTicket(key)

A ticket with its questions, analysis and latest result

### Example
```dart
import 'package:hiro_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = HiroApi().getTicketsApi();
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

# **listTicketEvents**
> List<Event> listTicketEvents(key, after, limit)

The ticket's log, oldest first; poll with `after` for live updates

### Example
```dart
import 'package:hiro_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = HiroApi().getTicketsApi();
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
import 'package:hiro_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = HiroApi().getTicketsApi();
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
import 'package:hiro_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = HiroApi().getTicketsApi();
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
import 'package:hiro_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = HiroApi().getTicketsApi();
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
import 'package:hiro_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = HiroApi().getTicketsApi();
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

# **setTicketModels**
> Ticket setTicketModels(key, modelOverrides)

Override models for this ticket; omit a stage to use the default

### Example
```dart
import 'package:hiro_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = HiroApi().getTicketsApi();
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
import 'package:hiro_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = HiroApi().getTicketsApi();
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
import 'package:hiro_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = HiroApi().getTicketsApi();
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
import 'package:hiro_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = HiroApi().getTicketsApi();
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

