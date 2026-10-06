# agnts_api.api.RulesApi

## Load the API package
```dart
import 'package:agnts_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**acceptRule**](RulesApi.md#acceptrule) | **POST** /rules/{id}/accept | Apply a rule as written, skipping its open questions or a failed review
[**answerRule**](RulesApi.md#answerrule) | **PUT** /rules/{id}/answers | Answer every open question of a rule; Claude then reviews it again
[**createRule**](RulesApi.md#createrule) | **POST** /rules | Add a rule; Claude reviews it before tickets follow it
[**deleteRule**](RulesApi.md#deleterule) | **DELETE** /rules/{id} | 
[**getRule**](RulesApi.md#getrule) | **GET** /rules/{id} | 
[**listRules**](RulesApi.md#listrules) | **GET** /rules | Every rule, global ones first, then by repository
[**reviewRule**](RulesApi.md#reviewrule) | **POST** /rules/{id}/review | Have Claude review a rule again, keeping its answers
[**updateRule**](RulesApi.md#updaterule) | **PUT** /rules/{id} | Edit a rule. Changing its text or repository starts a new review; turning it on or off does not.


# **acceptRule**
> Rule acceptRule(id)

Apply a rule as written, skipping its open questions or a failed review

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getRulesApi();
final int id = 789; // int | 

try {
    final response = api.acceptRule(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RulesApi->acceptRule: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**Rule**](Rule.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **answerRule**
> Rule answerRule(id, ruleAnswers)

Answer every open question of a rule; Claude then reviews it again

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getRulesApi();
final int id = 789; // int | 
final RuleAnswers ruleAnswers = ; // RuleAnswers | 

try {
    final response = api.answerRule(id, ruleAnswers);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RulesApi->answerRule: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **ruleAnswers** | [**RuleAnswers**](RuleAnswers.md)|  | 

### Return type

[**Rule**](Rule.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createRule**
> Rule createRule(ruleInput)

Add a rule; Claude reviews it before tickets follow it

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getRulesApi();
final RuleInput ruleInput = ; // RuleInput | 

try {
    final response = api.createRule(ruleInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RulesApi->createRule: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ruleInput** | [**RuleInput**](RuleInput.md)|  | 

### Return type

[**Rule**](Rule.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteRule**
> deleteRule(id)



### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getRulesApi();
final int id = 789; // int | 

try {
    api.deleteRule(id);
} on DioException catch (e) {
    print('Exception when calling RulesApi->deleteRule: $e\n');
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

# **getRule**
> Rule getRule(id)



### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getRulesApi();
final int id = 789; // int | 

try {
    final response = api.getRule(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RulesApi->getRule: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**Rule**](Rule.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listRules**
> List<Rule> listRules()

Every rule, global ones first, then by repository

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getRulesApi();

try {
    final response = api.listRules();
    print(response);
} on DioException catch (e) {
    print('Exception when calling RulesApi->listRules: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;Rule&gt;**](Rule.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **reviewRule**
> Rule reviewRule(id)

Have Claude review a rule again, keeping its answers

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getRulesApi();
final int id = 789; // int | 

try {
    final response = api.reviewRule(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RulesApi->reviewRule: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**Rule**](Rule.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateRule**
> Rule updateRule(id, ruleInput)

Edit a rule. Changing its text or repository starts a new review; turning it on or off does not.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getRulesApi();
final int id = 789; // int | 
final RuleInput ruleInput = ; // RuleInput | 

try {
    final response = api.updateRule(id, ruleInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RulesApi->updateRule: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **ruleInput** | [**RuleInput**](RuleInput.md)|  | 

### Return type

[**Rule**](Rule.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

