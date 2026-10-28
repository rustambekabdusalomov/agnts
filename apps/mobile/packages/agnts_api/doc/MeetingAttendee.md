# agnts_api.model.MeetingAttendee

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**person** | **String** | u<id> or g<id> | 
**name** | **String** |  | 
**guest** | **bool** |  | 
**email** | **String** | A guest's, when Google or an invitation gave it | [optional] 
**firstIn** | [**DateTime**](DateTime.md) |  | 
**lastOut** | [**DateTime**](DateTime.md) | Absent while still in the call | [optional] 
**seconds** | **int** |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


