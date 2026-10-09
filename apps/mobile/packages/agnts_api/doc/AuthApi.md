# agnts_api.api.AuthApi

## Load the API package
```dart
import 'package:agnts_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**beginLoginTotp**](AuthApi.md#beginlogintotp) | **POST** /auth/login/totp | Start the two-factor setup an Admin without it does at sign-in
[**forgotPassword**](AuthApi.md#forgotpassword) | **POST** /auth/password/forgot | Email a password reset link (always answers 204)
[**getMe**](AuthApi.md#getme) | **GET** /auth/me | The signed-in user
[**getSignupInfo**](AuthApi.md#getsignupinfo) | **GET** /auth/signup | Whether people can register, and whether this install has no user yet
[**login**](AuthApi.md#login) | **POST** /auth/login | Sign in with password and TOTP code
[**logout**](AuthApi.md#logout) | **POST** /auth/logout | End the current session
[**register**](AuthApi.md#register) | **POST** /auth/signup | Create an account (and its first workspace, unless joining by invite)
[**resetPassword**](AuthApi.md#resetpassword) | **POST** /auth/password/reset | Set a new password with a reset link&#39;s token
[**signInWithGoogle**](AuthApi.md#signinwithgoogle) | **POST** /auth/google | Sign in with a Google ID token (the mobile app)
[**verifyEmail**](AuthApi.md#verifyemail) | **POST** /auth/verify | Confirm an email address with the link&#39;s token


# **beginLoginTotp**
> BeginLoginTotp200Response beginLoginTotp(beginLoginTotpRequest)

Start the two-factor setup an Admin without it does at sign-in

Two-factor sign-in is mandatory for Admins. When login answers 401 totp_setup_required, this returns a new secret (after checking the password again); signing in with it as totpSecret and a matching code saves it and starts the session.

### Example
```dart
import 'package:agnts_api/api.dart';

final api = AgntsApi().getAuthApi();
final BeginLoginTotpRequest beginLoginTotpRequest = ; // BeginLoginTotpRequest | 

try {
    final response = api.beginLoginTotp(beginLoginTotpRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->beginLoginTotp: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **beginLoginTotpRequest** | [**BeginLoginTotpRequest**](BeginLoginTotpRequest.md)|  | 

### Return type

[**BeginLoginTotp200Response**](BeginLoginTotp200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **forgotPassword**
> forgotPassword(forgotPasswordRequest)

Email a password reset link (always answers 204)

### Example
```dart
import 'package:agnts_api/api.dart';

final api = AgntsApi().getAuthApi();
final ForgotPasswordRequest forgotPasswordRequest = ; // ForgotPasswordRequest | 

try {
    api.forgotPassword(forgotPasswordRequest);
} on DioException catch (e) {
    print('Exception when calling AuthApi->forgotPassword: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **forgotPasswordRequest** | [**ForgotPasswordRequest**](ForgotPasswordRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMe**
> User getMe()

The signed-in user

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAuthApi();

try {
    final response = api.getMe();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->getMe: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**User**](User.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSignupInfo**
> SignupInfo getSignupInfo()

Whether people can register, and whether this install has no user yet

### Example
```dart
import 'package:agnts_api/api.dart';

final api = AgntsApi().getAuthApi();

try {
    final response = api.getSignupInfo();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->getSignupInfo: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**SignupInfo**](SignupInfo.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **login**
> LoginResponse login(loginRequest)

Sign in with password and TOTP code

### Example
```dart
import 'package:agnts_api/api.dart';

final api = AgntsApi().getAuthApi();
final LoginRequest loginRequest = ; // LoginRequest | 

try {
    final response = api.login(loginRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->login: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loginRequest** | [**LoginRequest**](LoginRequest.md)|  | 

### Return type

[**LoginResponse**](LoginResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **logout**
> logout()

End the current session

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getAuthApi();

try {
    api.logout();
} on DioException catch (e) {
    print('Exception when calling AuthApi->logout: $e\n');
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

# **register**
> LoginResponse register(registerRequest)

Create an account (and its first workspace, unless joining by invite)

### Example
```dart
import 'package:agnts_api/api.dart';

final api = AgntsApi().getAuthApi();
final RegisterRequest registerRequest = ; // RegisterRequest | 

try {
    final response = api.register(registerRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->register: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **registerRequest** | [**RegisterRequest**](RegisterRequest.md)|  | 

### Return type

[**LoginResponse**](LoginResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **resetPassword**
> resetPassword(resetPasswordRequest)

Set a new password with a reset link's token

### Example
```dart
import 'package:agnts_api/api.dart';

final api = AgntsApi().getAuthApi();
final ResetPasswordRequest resetPasswordRequest = ; // ResetPasswordRequest | 

try {
    api.resetPassword(resetPasswordRequest);
} on DioException catch (e) {
    print('Exception when calling AuthApi->resetPassword: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **resetPasswordRequest** | [**ResetPasswordRequest**](ResetPasswordRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **signInWithGoogle**
> LoginResponse signInWithGoogle(googleSignInRequest)

Sign in with a Google ID token (the mobile app)

The phone signs in with Google itself and sends the ID token here. Like \"Continue with Google\" on the website, a new account starts as a solo developer with a workspace of its own, or joins the workspace of an invite. Always a mobile session: the token comes back in the body. 

### Example
```dart
import 'package:agnts_api/api.dart';

final api = AgntsApi().getAuthApi();
final GoogleSignInRequest googleSignInRequest = ; // GoogleSignInRequest | 

try {
    final response = api.signInWithGoogle(googleSignInRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->signInWithGoogle: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **googleSignInRequest** | [**GoogleSignInRequest**](GoogleSignInRequest.md)|  | 

### Return type

[**LoginResponse**](LoginResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **verifyEmail**
> verifyEmail(tokenRequest)

Confirm an email address with the link's token

### Example
```dart
import 'package:agnts_api/api.dart';

final api = AgntsApi().getAuthApi();
final TokenRequest tokenRequest = ; // TokenRequest | 

try {
    api.verifyEmail(tokenRequest);
} on DioException catch (e) {
    print('Exception when calling AuthApi->verifyEmail: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tokenRequest** | [**TokenRequest**](TokenRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

