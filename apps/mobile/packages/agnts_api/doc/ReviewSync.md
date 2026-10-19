# agnts_api.model.ReviewSync

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**repos** | **int** | Repositories with an open review | 
**open** | **int** | Open reviews checked | 
**created** | **int** | Always 0; reviews start from the pull request | 
**rereview** | **int** | Always 0; reviewing again is your call | 
**closed** | **int** | Reviews ended because the pull request was merged or closed on the git host | 
**errors** | **List&lt;String&gt;** | Repositories or pull requests that could not be read | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


