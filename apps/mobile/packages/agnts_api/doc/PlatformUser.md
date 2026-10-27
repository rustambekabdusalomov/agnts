# agnts_api.model.PlatformUser

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**user** | [**User**](User.md) |  | 
**hasPassword** | **bool** | Can sign in with a password; false for accounts made with Google sign-in | 
**lastSignInAt** | [**DateTime**](DateTime.md) | The newest session still on record | [optional] 
**workspaces** | [**List&lt;WorkspaceSummary&gt;**](WorkspaceSummary.md) | The workspaces they belong to (not deleted), with their role | 
**freeCredits** | [**FreeCredits**](FreeCredits.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


