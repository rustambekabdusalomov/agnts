# agnts_api.model.CommitDetail

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**sha** | **String** |  | 
**message** | **String** | The full commit message | 
**author** | **String** |  | 
**authorEmail** | **String** |  | [optional] 
**authorLogin** | **String** | The git host account, when the author's email maps to one | [optional] 
**authorAvatar** | **String** |  | [optional] 
**date** | [**DateTime**](DateTime.md) | Authored | [optional] 
**committer** | **String** |  | [optional] 
**committerEmail** | **String** |  | [optional] 
**committedDate** | [**DateTime**](DateTime.md) |  | [optional] 
**parents** | **List&lt;String&gt;** |  | 
**url** | **String** |  | 
**add** | **int** |  | 
**del** | **int** |  | 
**files** | [**List&lt;FileChange&gt;**](FileChange.md) |  | 
**filesCapped** | **bool** | More files changed than are listed | [optional] 
**pipelines** | [**List&lt;Pipeline&gt;**](Pipeline.md) |  | 
**pulls** | [**List&lt;CommitPull&gt;**](CommitPull.md) |  | 
**ticketKey** | **String** | The first linked ticket's key, else the KEY-1 before the message's colon | [optional] 
**tickets** | [**List&lt;CommitTicket&gt;**](CommitTicket.md) | The tickets the commit is linked to | [optional] 
**provider** | **String** |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


