# agnts_api.model.PullThread

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | Opaque: pass it back to reply or resolve | 
**kind** | **String** |  | 
**path** | **String** |  | [optional] 
**line** | **int** | Line in the new file | [optional] 
**oldLine** | **int** | Line in the old file, for a removed line | [optional] 
**startLine** | **int** | First line of a range | [optional] 
**diffHunk** | **String** |  | [optional] 
**commitSha** | **String** |  | [optional] 
**outdated** | **bool** | The line changed since the thread started | 
**resolvable** | **bool** |  | 
**resolved** | **bool** |  | 
**reviewState** | **String** | A review's verdict: APPROVED, CHANGES_REQUESTED or COMMENTED | [optional] 
**sent** | **bool** | On agnts's own pull request: sent back to the ticket as feedback, with no newer comment since | [optional] 
**replied** | **bool** | agnts answered it after pushing the fix | [optional] 
**comments** | [**List&lt;PullComment&gt;**](PullComment.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


