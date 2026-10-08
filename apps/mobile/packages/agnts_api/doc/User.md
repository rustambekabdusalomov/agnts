# agnts_api.model.User

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | 
**username** | **String** |  | 
**displayName** | **String** |  | [optional] 
**email** | **String** |  | [optional] 
**emailVerified** | **bool** |  | [optional] 
**isAdmin** | **bool** | The platform operator (system role Admin) | [optional] 
**hasTotp** | **bool** | Signs in with a second factor | [optional] 
**lastWorkspace** | **String** | The slug of the workspace opened last | [optional] 
**workspaces** | [**List&lt;WorkspaceSummary&gt;**](WorkspaceSummary.md) | The workspaces the user is a member of (on /auth/me only) | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


