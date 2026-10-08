# agnts_api.model.SignupInfo

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**open** | **bool** | Anyone can register; otherwise only with an invite link | 
**firstUser** | **bool** | No account exists yet; the first one becomes Admin | 
**emailEnabled** | **bool** | The server can send email (verification, invites, resets) | 
**googleClientId** | **String** | OAuth client id for \"Continue with Google\" (a form post to /auth/google); absent when it is off | [optional] 
**passwordSignup** | **bool** | Registering with a password works; when only Admins sign in with one, only for the first account | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


