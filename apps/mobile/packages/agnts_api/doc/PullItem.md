# agnts_api.model.PullItem

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
**author** | **String** |  | 
**headRef** | **String** |  | 
**headSha** | **String** |  | 
**baseRef** | **String** |  | 
**draft** | **bool** |  | 
**state** | **String** |  | 
**why** | **String** | Why it waits for the token's user: assigned, review_requested, open or own (taken because it is open, all), or empty; manual for a review someone asked for from the pull request page | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 
**ticketKey** | **String** | agnts's ticket for it: its own change, or its review | [optional] 
**own** | **bool** | It is agnts's own change | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


