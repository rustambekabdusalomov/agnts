# agnts_api.model.PublicMeeting

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**code** | **String** |  | 
**title** | **String** |  | 
**hostName** | **String** |  | 
**workspace** | **String** | The workspace's name | 
**kind** | **String** |  | 
**startsAt** | [**DateTime**](DateTime.md) |  | [optional] 
**endsAt** | [**DateTime**](DateTime.md) |  | [optional] 
**timeZone** | **String** |  | [optional] 
**cancelled** | **bool** |  | 
**guests** | **String** |  | 
**live** | **bool** |  | [optional] 
**inCall** | **int** |  | 
**recording** | **bool** | The call is being recorded | 
**notes** | **bool** | agnts is taking notes of the call | 
**member** | **bool** | You are signed in as a member of its workspace | 
**name** | **String** | Your name, when signed in | [optional] 
**googleClientId** | **String** | For \"Continue with Google\" | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


