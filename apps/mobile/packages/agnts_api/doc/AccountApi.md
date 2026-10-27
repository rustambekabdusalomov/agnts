# agnts_api.api.AccountApi

## Load the API package
```dart
import 'package:agnts_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**beginTotp**](AccountApi.md#begintotp) | **POST** /account/totp/setup | Start turning on two-factor sign-in (a new secret, not saved yet)
[**changePassword**](AccountApi.md#changepassword) | **PUT** /account/password | Change the password
[**confirmTotp**](AccountApi.md#confirmtotp) | **POST** /account/totp/confirm | Turn two-factor sign-in on with a code from the new secret
[**deleteMyClaude**](AccountApi.md#deletemyclaude) | **DELETE** /account/claude | Disconnect your Claude account
[**disableTotp**](AccountApi.md#disabletotp) | **POST** /account/totp/disable | Turn two-factor sign-in off
[**getMyClaude**](AccountApi.md#getmyclaude) | **GET** /account/claude | Your personal Claude connection (used by workspaces in per-member mode)
[**getMyFreeCredits**](AccountApi.md#getmyfreecredits) | **GET** /account/free-credits | Free credits an Admin gave you; runs on agnts&#39;s Muse key spend them before your workspace&#39;s credits
[**getMyMuseLogin**](AccountApi.md#getmymuselogin) | **GET** /account/muse/login/{id} | How your Meta sign-in is going
[**resendVerification**](AccountApi.md#resendverification) | **POST** /account/verify | Send the email verification link again
[**setMyClaude**](AccountApi.md#setmyclaude) | **PUT** /account/claude | Connect your Claude account
[**startMyMuseLogin**](AccountApi.md#startmymuselogin) | **POST** /account/muse/login | Connect your Muse account by signing in with Meta (shows a code to confirm on Meta&#39;s page)
[**updateProfile**](AccountApi.md#updateprofile) | **PUT** /account/profile | Change the display name or email


# **beginTotp**
> BeginTotp200Response beginTotp()

Start turning on two-factor sign-in (a new secret, not saved yet)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAccountApi();

try {
    final response = api.beginTotp();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AccountApi->beginTotp: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BeginTotp200Response**](BeginTotp200Response.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **changePassword**
> changePassword(changePasswordRequest)

Change the password

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAccountApi();
final ChangePasswordRequest changePasswordRequest = ; // ChangePasswordRequest | 

try {
    api.changePassword(changePasswordRequest);
} on DioException catch (e) {
    print('Exception when calling AccountApi->changePassword: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **changePasswordRequest** | [**ChangePasswordRequest**](ChangePasswordRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **confirmTotp**
> confirmTotp(confirmTotpRequest)

Turn two-factor sign-in on with a code from the new secret

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAccountApi();
final ConfirmTotpRequest confirmTotpRequest = ; // ConfirmTotpRequest | 

try {
    api.confirmTotp(confirmTotpRequest);
} on DioException catch (e) {
    print('Exception when calling AccountApi->confirmTotp: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **confirmTotpRequest** | [**ConfirmTotpRequest**](ConfirmTotpRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteMyClaude**
> deleteMyClaude()

Disconnect your Claude account

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAccountApi();

try {
    api.deleteMyClaude();
} on DioException catch (e) {
    print('Exception when calling AccountApi->deleteMyClaude: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **disableTotp**
> disableTotp(disableTotpRequest)

Turn two-factor sign-in off

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAccountApi();
final DisableTotpRequest disableTotpRequest = ; // DisableTotpRequest | 

try {
    api.disableTotp(disableTotpRequest);
} on DioException catch (e) {
    print('Exception when calling AccountApi->disableTotp: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **disableTotpRequest** | [**DisableTotpRequest**](DisableTotpRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMyClaude**
> ClaudeConnectionState getMyClaude()

Your personal Claude connection (used by workspaces in per-member mode)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAccountApi();

try {
    final response = api.getMyClaude();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AccountApi->getMyClaude: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ClaudeConnectionState**](ClaudeConnectionState.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMyFreeCredits**
> FreeCredits getMyFreeCredits()

Free credits an Admin gave you; runs on agnts's Muse key spend them before your workspace's credits

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAccountApi();

try {
    final response = api.getMyFreeCredits();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AccountApi->getMyFreeCredits: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**FreeCredits**](FreeCredits.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMyMuseLogin**
> MuseLogin getMyMuseLogin(id)

How your Meta sign-in is going

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAccountApi();
final String id = id_example; // String | 

try {
    final response = api.getMyMuseLogin(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AccountApi->getMyMuseLogin: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**MuseLogin**](MuseLogin.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **resendVerification**
> resendVerification()

Send the email verification link again

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAccountApi();

try {
    api.resendVerification();
} on DioException catch (e) {
    print('Exception when calling AccountApi->resendVerification: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setMyClaude**
> ClaudeConnectionState setMyClaude(claudeConnectionInput)

Connect your Claude account

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAccountApi();
final ClaudeConnectionInput claudeConnectionInput = ; // ClaudeConnectionInput | 

try {
    final response = api.setMyClaude(claudeConnectionInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AccountApi->setMyClaude: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **claudeConnectionInput** | [**ClaudeConnectionInput**](ClaudeConnectionInput.md)|  | 

### Return type

[**ClaudeConnectionState**](ClaudeConnectionState.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startMyMuseLogin**
> MuseLogin startMyMuseLogin()

Connect your Muse account by signing in with Meta (shows a code to confirm on Meta's page)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAccountApi();

try {
    final response = api.startMyMuseLogin();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AccountApi->startMyMuseLogin: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**MuseLogin**](MuseLogin.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateProfile**
> User updateProfile(updateProfileRequest)

Change the display name or email

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAccountApi();
final UpdateProfileRequest updateProfileRequest = ; // UpdateProfileRequest | 

try {
    final response = api.updateProfile(updateProfileRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AccountApi->updateProfile: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **updateProfileRequest** | [**UpdateProfileRequest**](UpdateProfileRequest.md)|  | 

### Return type

[**User**](User.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

