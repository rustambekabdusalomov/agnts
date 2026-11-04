# agnts_api.model.ChatSendRequest

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**clientMsgId** | **String** | Made on the device; a resend with the same id returns the stored message | 
**body** | **String** | May be empty when files are sent | [optional] 
**files** | **List&lt;int&gt;** | The sender's pending uploads (uploadAttachment) to send with it | [optional] 
**replyTo** | **int** |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


