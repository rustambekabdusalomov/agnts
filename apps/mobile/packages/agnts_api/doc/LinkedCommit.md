# agnts_api.model.LinkedCommit

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**sha** | **String** |  | 
**shortSha** | **String** |  | 
**subject** | **String** | The message's first line | 
**author** | **String** |  | 
**authorLogin** | **String** | The git host account, when known | [optional] 
**branch** | **String** | The branch it was first seen on | 
**repoId** | **int** |  | 
**repo** | **String** |  | 
**url** | **String** | The commit on the git host | 
**committedAt** | [**DateTime**](DateTime.md) |  | 
**matchedOn** | **List&lt;String&gt;** | Where the ticket's number was found | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


