# agnts_api.model.RepoGroup

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | 
**name** | **String** |  | 
**description** | **String** |  | 
**instructions** | **String** | How the repositories fit together; added to every prompt of its tickets | 
**taskPrefix** | **String** | Key prefix of tasks made from the group; empty uses the first repository's | 
**members** | [**List&lt;RepoGroupMember&gt;**](RepoGroupMember.md) |  | 
**warnings** | **List&lt;String&gt;** | What the repositories share uneasily in one run container (a build variable both set) | 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


