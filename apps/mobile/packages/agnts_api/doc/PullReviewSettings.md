# agnts_api.model.PullReviewSettings

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**enabled** | **bool** | Sync the pull requests waiting for you every few minutes and review the new ones | 
**reviewRequested** | **bool** | Also take pull requests whose review is requested from you, not only those assigned to you | 
**all** | **bool** | Take every open pull request in your repositories, yours included, whether or not it waits for you; left out, it stays as it is | [optional] 
**skipDrafts** | **bool** | Leave draft pull requests alone until they are ready | 
**rereview** | **bool** | Review again when the author pushes new commits while agnts's review waits for you | 
**mergeMethod** | **String** | How an accepted pull request is merged | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


