# agnts_api.model.MeetingCall

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**meeting** | [**Meeting**](Meeting.md) |  | 
**sessionId** | **int** |  | 
**me** | [**MeetingPerson**](MeetingPerson.md) |  | 
**rights** | [**MeetingRights**](MeetingRights.md) |  | 
**canAdmit** | **bool** |  | 
**people** | [**List&lt;MeetingPerson&gt;**](MeetingPerson.md) |  | 
**knocks** | [**List&lt;MeetingKnock&gt;**](MeetingKnock.md) |  | 
**recording** | **bool** |  | 
**notes** | **bool** |  | 
**notesStatus** | [**MeetingNotesStatus**](MeetingNotesStatus.md) |  | [optional] 
**recordingAvailable** | **bool** |  | 
**notesAvailable** | **bool** |  | 
**guestsQuiet** | **bool** |  | 
**workspace** | **String** | The workspace's slug, for members | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


