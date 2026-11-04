# agnts_api.model.MeetingSessionDetail

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | 
**meeting** | [**Meeting**](Meeting.md) |  | 
**uploaded** | **bool** | A recording a host uploaded, not a call: it has no attendance | 
**people** | **List&lt;int&gt;** | An uploaded recording: the members the uploader said are in it | 
**startedAt** | [**DateTime**](DateTime.md) |  | 
**endedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**notesStatus** | [**MeetingNotesStatus**](MeetingNotesStatus.md) |  | 
**notesError** | **String** |  | 
**documentId** | **int** |  | [optional] 
**attendees** | [**List&lt;MeetingAttendee&gt;**](MeetingAttendee.md) |  | 
**recordings** | [**List&lt;MeetingRecording&gt;**](MeetingRecording.md) |  | 
**actionItems** | [**List&lt;MeetingActionItem&gt;**](MeetingActionItem.md) |  | 
**messages** | **int** | Chat messages | 
**canManage** | **bool** |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


