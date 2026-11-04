# agnts_api.model.MeetingActionItem

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | 
**position** | **int** |  | 
**text** | **String** |  | 
**who** | **String** | As named in the meeting | 
**due** | **String** | As said | 
**atMs** | **int** | When it was said, from the start of the call | [optional] 
**quote** | **String** |  | 
**speaker** | **String** | Who said the line where it was taken, as the transcript names them; empty when it does not say | 
**memberId** | **int** | The member who takes it: matched from the name as said, or picked by hand; absent when nobody matched | [optional] 
**memberName** | **String** |  | [optional] 
**memberByHand** | **bool** | The member was picked by hand, not matched | 
**drafted** | **bool** | Its draft ticket was made when the notes were written | 
**ticketKey** | **String** | The ticket made from it | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


