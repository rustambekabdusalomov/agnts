# agnts_api.model.Reviewer

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**login** | **String** |  | 
**profile** | **String** | Markdown; empty until a review folds notes in or someone writes it | 
**notesFolded** | **int** | Notes folded into the profile so far | 
**updatedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**pending** | [**List&lt;ReviewerNote&gt;**](ReviewerNote.md) | Notes the next review folds in, newest first | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


