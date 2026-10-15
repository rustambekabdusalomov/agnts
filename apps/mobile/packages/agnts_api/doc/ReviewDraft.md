# agnts_api.model.ReviewDraft

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | 
**kind** | **String** |  | 
**key** | **String** | Which finding it is across re-reviews (file and title) | 
**severity** | **String** | A finding's severity; for the summary, the verdict | [optional] 
**category** | **String** |  | [optional] 
**title** | **String** |  | [optional] 
**confidence** | **num** |  | [optional] 
**pass** | **String** |  | [optional] 
**path** | **String** |  | [optional] 
**line** | **int** | Line in the new file; it may be outside the diff | [optional] 
**headSha** | **String** | The commit it is about | 
**body** | **String** | Markdown: what is published | 
**edited** | **bool** | A person rewrote it; re-reviews keep their text | 
**state** | **String** |  | 
**dismissReason** | **String** |  | [optional] 
**error** | **String** | Why its last publish failed | [optional] 
**author** | **String** | Who wrote it (comment) | [optional] 
**decidedBy** | **String** |  | [optional] 
**decidedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


