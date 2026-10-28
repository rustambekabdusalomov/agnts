# agnts_api.model.Meeting

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | 
**code** | **String** | abc-defg-hij | 
**link** | **String** | The meeting's public link | 
**title** | **String** |  | 
**description** | **String** |  | 
**hostId** | **int** |  | [optional] 
**hostName** | **String** |  | 
**kind** | **String** |  | 
**startsAt** | [**DateTime**](DateTime.md) |  | [optional] 
**endsAt** | [**DateTime**](DateTime.md) |  | [optional] 
**durationMin** | **int** |  | 
**timeZone** | **String** |  | 
**access** | **String** | workspace: every member joins; invited: only invitees, other members knock | 
**guests** | **String** | What people without a membership may do | 
**locked** | **bool** |  | 
**autoRecord** | **bool** |  | 
**autoNotes** | **bool** |  | 
**language** | **String** |  | 
**cohostIds** | **List&lt;int&gt;** |  | 
**cancelledAt** | [**DateTime**](DateTime.md) |  | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**live** | [**MeetingLive**](MeetingLive.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


