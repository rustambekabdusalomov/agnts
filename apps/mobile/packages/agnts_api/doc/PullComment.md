# agnts_api.model.PullComment

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | Opaque: pass it back to edit or delete | 
**author** | **String** |  | 
**avatarUrl** | **String** |  | [optional] 
**body** | **String** | Markdown, as the git host stores it | 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 
**url** | **String** |  | [optional] 
**mine** | **bool** | Written by the git host token's user, who may edit and delete it | 
**system** | **bool** | A note the git host wrote (\"added 2 commits\") | 
**agnts** | **bool** | agnts posted it | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


