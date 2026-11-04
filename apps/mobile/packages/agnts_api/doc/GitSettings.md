# agnts_api.model.GitSettings

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**authorName** | **String** |  | 
**authorEmail** | **String** |  | 
**coAuthor** | **bool** | Add a Co-authored-by agnts line | 
**prTitle** | **String** | Pull request title template, with the commit template's placeholders {number} {key} {type} {scope} {subject} {title}; must contain {subject} or {title}. A repository's or group's own replaces it | 
**draft** | **bool** |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


