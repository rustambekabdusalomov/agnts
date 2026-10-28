# agnts_api.model.MeetingJoin

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**status** | **String** |  | 
**grant** | [**MeetingGrant**](MeetingGrant.md) |  | [optional] 
**knockId** | **int** |  | [optional] 
**knockToken** | **String** | Send as X-Knock-Token when polling | [optional] 
**guestToken** | **String** | A new guest's token: keep it and send it as X-Guest-Token next time | [optional] 
**guestName** | **String** |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


