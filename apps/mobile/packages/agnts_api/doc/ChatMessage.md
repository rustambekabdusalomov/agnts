# agnts_api.model.ChatMessage

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | 
**channelId** | **int** |  | 
**replyTo** | **int** |  | [optional] 
**authorId** | **int** |  | [optional] 
**author** | **String** | The person's username | 
**kind** | **String** |  | 
**body** | **String** |  | 
**card** | [**ChatCard**](ChatCard.md) |  | [optional] 
**ai** | [**ChatAI**](ChatAI.md) |  | [optional] 
**ticketKey** | **String** |  | [optional] 
**audio** | [**ChatAudio**](ChatAudio.md) |  | [optional] 
**clientMsgId** | **String** |  | [optional] 
**refs** | [**List&lt;ChatRef&gt;**](ChatRef.md) |  | 
**createdAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


