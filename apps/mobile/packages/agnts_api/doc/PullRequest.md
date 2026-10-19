# agnts_api.model.PullRequest

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**number** | **int** | The pull request number (GitLab: the IID) | 
**url** | **String** |  | 
**title** | **String** |  | 
**author** | **String** | Git host username of the author | 
**headRef** | **String** | The branch it comes from | 
**headSha** | **String** | Its newest commit on the git host | 
**baseRef** | **String** | The branch it goes into | 
**draft** | **bool** |  | 
**state** | **String** |  | 
**login** | **String** | The git host user it waits for; their reviewer profile shapes its reviews | 
**why** | **String** | open: taken because it is open in the repository (all); own: the token's user opened it (all); manual: asked for from the pull request page | 
**additions** | **int** |  | [optional] 
**deletions** | **int** |  | [optional] 
**updatedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**postedSha** | **String** | The reviewed commit whose review agnts last posted on the pull request | [optional] 
**postedAt** | [**DateTime**](DateTime.md) | When agnts last posted its review on the pull request | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


