# agnts_api.model.ReviewSync

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**repos** | **int** | Repositories asked | 
**open** | **int** | Pull requests waiting for you | 
**created** | **int** | New reviews queued | 
**rereview** | **int** | Reviews queued again for new commits | 
**closed** | **int** | Reviews ended because the pull request was merged or closed on the git host | 
**errors** | **List&lt;String&gt;** | Repositories or pull requests that could not be read | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


