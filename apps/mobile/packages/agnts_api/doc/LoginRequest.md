# agnts_api.model.LoginRequest

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**username** | **String** | Username or email | 
**password** | **String** |  | 
**code** | **String** | Six-digit code from the authenticator app, when two-factor sign-in is on | [optional] 
**totpSecret** | **String** | An Admin finishing two-factor setup at sign-in (beginLoginTotp's secret); code must match it | [optional] 
**client** | **String** |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


