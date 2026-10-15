# agnts_api.model.NewPullComment

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**body** | **String** |  | 
**path** | **String** | The file, for a comment on a line | [optional] 
**line** | **int** | Line in the new file (an added or unchanged line) | [optional] 
**oldLine** | **int** | Line in the old file: a removed line, or with line an unchanged one | [optional] 
**startLine** | **int** | First line of a range (GitHub) | [optional] 
**headSha** | **String** | The commit the line is in; the newest when empty | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


