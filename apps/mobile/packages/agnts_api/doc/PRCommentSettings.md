# agnts_api.model.PRCommentSettings

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**attribution** | **bool** | Add \"via agnts · <person>\" to comments written through agnts (they all go out as the git host token's user) | 
**learnFromComments** | **bool** | Keep the comments you write on others' pull requests on the git host as notes on how you review | 
**resolveFixed** | **bool** | Resolve a reviewer's thread once agnts pushed the fix and answered it | 
**autoAddress** | **bool** | Send the unresolved threads back to the ticket when a reviewer requests changes on agnts's pull request (the fix still waits for your approval) | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


