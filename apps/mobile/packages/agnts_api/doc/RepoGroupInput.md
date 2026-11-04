# agnts_api.model.RepoGroupInput

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**name** | **String** |  | 
**description** | **String** |  | [optional] 
**instructions** | **String** |  | [optional] 
**taskPrefix** | **String** |  | [optional] 
**branchTemplate** | **String** | Branch name template (as a repository's); must contain {key} or {number}. Empty keeps each repository's own | [optional] 
**commitTemplate** | **String** | Commit message template (as a repository's); must contain {subject} or {title}. Empty keeps each repository's own | [optional] 
**prTemplate** | **String** | Pull request title template (as a repository's); must contain {subject} or {title}. Empty keeps each repository's own | [optional] 
**members** | [**List&lt;RepoGroupInputMembersInner&gt;**](RepoGroupInputMembersInner.md) | In order; the first is the primary repository of the group's tickets | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


