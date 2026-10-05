# hiro_api.api.LearnApi

## Load the API package
```dart
import 'package:hiro_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getLearnQueue**](LearnApi.md#getlearnqueue) | **GET** /lessons/queue | Done tickets whose learn run is running, queued, failed or never happened
[**getLesson**](LearnApi.md#getlesson) | **GET** /lessons/{id} | One lesson with its explanation, code references, quiz and reading
[**learnFromTicket**](LearnApi.md#learnfromticket) | **POST** /tickets/{key}/learn | Queue a learn run for a pushed ticket (again, if it already ran)
[**listLessons**](LearnApi.md#listlessons) | **GET** /lessons | Lessons hiro learned from pushed tickets, newest first
[**markLessonLearned**](LearnApi.md#marklessonlearned) | **PUT** /lessons/{id}/learned | Mark a lesson learned
[**unmarkLessonLearned**](LearnApi.md#unmarklessonlearned) | **DELETE** /lessons/{id}/learned | Mark a lesson as not learned yet


# **getLearnQueue**
> List<LearnQueueItem> getLearnQueue()

Done tickets whose learn run is running, queued, failed or never happened

### Example
```dart
import 'package:hiro_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = HiroApi().getLearnApi();

try {
    final response = api.getLearnQueue();
    print(response);
} on DioException catch (e) {
    print('Exception when calling LearnApi->getLearnQueue: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;LearnQueueItem&gt;**](LearnQueueItem.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getLesson**
> Lesson getLesson(id)

One lesson with its explanation, code references, quiz and reading

### Example
```dart
import 'package:hiro_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = HiroApi().getLearnApi();
final int id = 789; // int | 

try {
    final response = api.getLesson(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LearnApi->getLesson: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**Lesson**](Lesson.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **learnFromTicket**
> Ticket learnFromTicket(key)

Queue a learn run for a pushed ticket (again, if it already ran)

### Example
```dart
import 'package:hiro_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = HiroApi().getLearnApi();
final String key = key_example; // String | 

try {
    final response = api.learnFromTicket(key);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LearnApi->learnFromTicket: $e\n');
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

# **listLessons**
> LessonList listLessons(repo, ticket, status, q, limit)

Lessons hiro learned from pushed tickets, newest first

### Example
```dart
import 'package:hiro_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = HiroApi().getLearnApi();
final int repo = 789; // int | 
final String ticket = ticket_example; // String | 
final String status = status_example; // String | new (not learned yet), learned, or all (default)
final String q = q_example; // String | Search in titles and summaries
final int limit = 56; // int | 

try {
    final response = api.listLessons(repo, ticket, status, q, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LearnApi->listLessons: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **repo** | **int**|  | [optional] 
 **ticket** | **String**|  | [optional] 
 **status** | **String**| new (not learned yet), learned, or all (default) | [optional] 
 **q** | **String**| Search in titles and summaries | [optional] 
 **limit** | **int**|  | [optional] 

### Return type

[**LessonList**](LessonList.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **markLessonLearned**
> Lesson markLessonLearned(id)

Mark a lesson learned

### Example
```dart
import 'package:hiro_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = HiroApi().getLearnApi();
final int id = 789; // int | 

try {
    final response = api.markLessonLearned(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LearnApi->markLessonLearned: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**Lesson**](Lesson.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **unmarkLessonLearned**
> Lesson unmarkLessonLearned(id)

Mark a lesson as not learned yet

### Example
```dart
import 'package:hiro_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = HiroApi().getLearnApi();
final int id = 789; // int | 

try {
    final response = api.unmarkLessonLearned(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LearnApi->unmarkLessonLearned: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**Lesson**](Lesson.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

