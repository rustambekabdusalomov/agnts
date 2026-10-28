# agnts_api.model.MeetingInput

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**title** | **String** |  | [optional] 
**description** | **String** |  | [optional] 
**kind** | **String** | instant when absent | [optional] 
**startsAt** | [**DateTime**](DateTime.md) |  | [optional] 
**durationMin** | **int** |  | [optional] 
**timeZone** | **String** | IANA, e.g. Asia/Tashkent | [optional] 
**access** | **String** |  | [optional] 
**guests** | **String** |  | [optional] 
**autoRecord** | **bool** |  | [optional] 
**autoNotes** | **bool** |  | [optional] 
**language** | **String** |  | [optional] 
**invite** | [**MeetingInvites**](MeetingInvites.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


