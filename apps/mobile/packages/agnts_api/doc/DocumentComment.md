# agnts_api.model.DocumentComment

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | 
**parentId** | **int** |  | [optional] 
**authorName** | **String** |  | 
**authorKind** | **String** | gone when the member or guest no longer exists | 
**authorVia** | **String** | How a guest said who they are: a typed name, Google, or their agnts account | [optional] 
**authorEmail** | **String** | The email Google or an account gave for a guest; members only see it | [optional] 
**body** | **String** |  | 
**quote** | **String** |  | 
**prefix** | **String** |  | 
**suffix** | **String** |  | 
**slide** | **int** | The slide, from 0, for slides | [optional] 
**version** | **int** | The document's version when it was written | 
**resolvedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**resolvedBy** | **String** |  | [optional] 
**mine** | **bool** | You wrote it | 
**canResolve** | **bool** | You may resolve or reopen this thread | 
**canDelete** | **bool** |  | 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


