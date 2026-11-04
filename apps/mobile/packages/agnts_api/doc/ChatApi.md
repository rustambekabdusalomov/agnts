# agnts_api.api.ChatApi

## Load the API package
```dart
import 'package:agnts_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**actOnChatCard**](ChatApi.md#actonchatcard) | **POST** /chat/messages/{messageId}/actions | Press a button on agnts&#39;s card; it runs the real action (approve, merge, fix, …) and returns the card
[**chatMessageToTicket**](ChatApi.md#chatmessagetoticket) | **POST** /chat/messages/{messageId}/ticket | Turn a message into a ticket draft; the draft card arrives in the thread as an event
[**createChatChannel**](ChatApi.md#createchatchannel) | **POST** /chat/channels | Make a channel
[**getChatAudio**](ChatApi.md#getchataudio) | **GET** /chat/messages/{messageId}/audio | A voice message&#39;s recording, to play
[**getChatMessage**](ChatApi.md#getchatmessage) | **GET** /chat/messages/{messageId} | One message with its refs (opens a citation in its channel)
[**getChatStats**](ChatApi.md#getchatstats) | **GET** /chat/stats | What the model did in the team chat today (links, answers, drafts) and its median time
[**listChatChannels**](ChatApi.md#listchatchannels) | **GET** /chat/channels | The workspace&#39;s team chat channels, with your unread counts (makes
[**listChatMessages**](ChatApi.md#listchatmessages) | **GET** /chat/channels/{channelId}/messages | A page of a channel, oldest first (the newest, the ones before &#x60;before&#x60;, or the ones after &#x60;after&#x60; to fill a gap after a reconnect)
[**markChatRead**](ChatApi.md#markchatread) | **PUT** /chat/channels/{channelId}/read | Save how far you have read a channel
[**removeChatRef**](ChatApi.md#removechatref) | **POST** /chat/messages/{messageId}/refs/remove | Remove a wrong link under a message (the linker will not add it back)
[**sendChatMessage**](ChatApi.md#sendchatmessage) | **POST** /chat/channels/{channelId}/messages | Send a message. The same clientMsgId sent again returns the stored message (200) instead of a second one (201)
[**sendChatVoice**](ChatApi.md#sendchatvoice) | **POST** /chat/channels/{channelId}/voice | Send a voice message. Muse hears it after it is stored; its words become the message&#39;s text (an event brings them)
[**updateChatChannel**](ChatApi.md#updatechatchannel) | **PATCH** /chat/channels/{channelId} | Change a channel&#39;s topic, make it agnts&#39;s channel, or archive it


# **actOnChatCard**
> ChatMessage actOnChatCard(messageId, chatActionRequest)

Press a button on agnts's card; it runs the real action (approve, merge, fix, …) and returns the card

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getChatApi();
final int messageId = 789; // int | 
final ChatActionRequest chatActionRequest = ; // ChatActionRequest | 

try {
    final response = api.actOnChatCard(messageId, chatActionRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ChatApi->actOnChatCard: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **messageId** | **int**|  | 
 **chatActionRequest** | [**ChatActionRequest**](ChatActionRequest.md)|  | 

### Return type

[**ChatMessage**](ChatMessage.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **chatMessageToTicket**
> chatMessageToTicket(messageId)

Turn a message into a ticket draft; the draft card arrives in the thread as an event

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getChatApi();
final int messageId = 789; // int | 

try {
    api.chatMessageToTicket(messageId);
} on DioException catch (e) {
    print('Exception when calling ChatApi->chatMessageToTicket: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **messageId** | **int**|  | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createChatChannel**
> ChatChannel createChatChannel(chatChannelInput)

Make a channel

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getChatApi();
final ChatChannelInput chatChannelInput = ; // ChatChannelInput | 

try {
    final response = api.createChatChannel(chatChannelInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ChatApi->createChatChannel: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **chatChannelInput** | [**ChatChannelInput**](ChatChannelInput.md)|  | 

### Return type

[**ChatChannel**](ChatChannel.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getChatAudio**
> Uint8List getChatAudio(messageId)

A voice message's recording, to play

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getChatApi();
final int messageId = 789; // int | 

try {
    final response = api.getChatAudio(messageId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ChatApi->getChatAudio: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **messageId** | **int**|  | 

### Return type

[**Uint8List**](Uint8List.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: audio/*, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getChatMessage**
> ChatMessage getChatMessage(messageId)

One message with its refs (opens a citation in its channel)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getChatApi();
final int messageId = 789; // int | 

try {
    final response = api.getChatMessage(messageId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ChatApi->getChatMessage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **messageId** | **int**|  | 

### Return type

[**ChatMessage**](ChatMessage.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getChatStats**
> ChatStats getChatStats()

What the model did in the team chat today (links, answers, drafts) and its median time

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getChatApi();

try {
    final response = api.getChatStats();
    print(response);
} on DioException catch (e) {
    print('Exception when calling ChatApi->getChatStats: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ChatStats**](ChatStats.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listChatChannels**
> List<ChatChannel> listChatChannels()

The workspace's team chat channels, with your unread counts (makes

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getChatApi();

try {
    final response = api.listChatChannels();
    print(response);
} on DioException catch (e) {
    print('Exception when calling ChatApi->listChatChannels: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;ChatChannel&gt;**](ChatChannel.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listChatMessages**
> List<ChatMessage> listChatMessages(channelId, before, after, limit)

A page of a channel, oldest first (the newest, the ones before `before`, or the ones after `after` to fill a gap after a reconnect)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getChatApi();
final int channelId = 789; // int | 
final int before = 789; // int | 
final int after = 789; // int | 
final int limit = 56; // int | 

try {
    final response = api.listChatMessages(channelId, before, after, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ChatApi->listChatMessages: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **channelId** | **int**|  | 
 **before** | **int**|  | [optional] 
 **after** | **int**|  | [optional] 
 **limit** | **int**|  | [optional] 

### Return type

[**List&lt;ChatMessage&gt;**](ChatMessage.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **markChatRead**
> markChatRead(channelId, markChatReadRequest)

Save how far you have read a channel

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getChatApi();
final int channelId = 789; // int | 
final MarkChatReadRequest markChatReadRequest = ; // MarkChatReadRequest | 

try {
    api.markChatRead(channelId, markChatReadRequest);
} on DioException catch (e) {
    print('Exception when calling ChatApi->markChatRead: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **channelId** | **int**|  | 
 **markChatReadRequest** | [**MarkChatReadRequest**](MarkChatReadRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **removeChatRef**
> ChatMessage removeChatRef(messageId, removeChatRefRequest)

Remove a wrong link under a message (the linker will not add it back)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getChatApi();
final int messageId = 789; // int | 
final RemoveChatRefRequest removeChatRefRequest = ; // RemoveChatRefRequest | 

try {
    final response = api.removeChatRef(messageId, removeChatRefRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ChatApi->removeChatRef: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **messageId** | **int**|  | 
 **removeChatRefRequest** | [**RemoveChatRefRequest**](RemoveChatRefRequest.md)|  | 

### Return type

[**ChatMessage**](ChatMessage.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sendChatMessage**
> ChatMessage sendChatMessage(channelId, chatSendRequest)

Send a message. The same clientMsgId sent again returns the stored message (200) instead of a second one (201)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getChatApi();
final int channelId = 789; // int | 
final ChatSendRequest chatSendRequest = ; // ChatSendRequest | 

try {
    final response = api.sendChatMessage(channelId, chatSendRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ChatApi->sendChatMessage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **channelId** | **int**|  | 
 **chatSendRequest** | [**ChatSendRequest**](ChatSendRequest.md)|  | 

### Return type

[**ChatMessage**](ChatMessage.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sendChatVoice**
> ChatMessage sendChatVoice(channelId, clientMsgId, durationMs, audio, wav, replyTo)

Send a voice message. Muse hears it after it is stored; its words become the message's text (an event brings them)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getChatApi();
final int channelId = 789; // int | 
final String clientMsgId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final int durationMs = 789; // int | The recording's length, at most 2 minutes
final MultipartFile audio = BINARY_DATA_HERE; // MultipartFile | The recording to keep and play (WebM, Ogg, MP4, MP3, AAC or WAV), at most 3 MB
final MultipartFile wav = BINARY_DATA_HERE; // MultipartFile | The same audio as 16-bit PCM WAV for Muse to hear, at most 4 MB
final int replyTo = 789; // int | 

try {
    final response = api.sendChatVoice(channelId, clientMsgId, durationMs, audio, wav, replyTo);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ChatApi->sendChatVoice: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **channelId** | **int**|  | 
 **clientMsgId** | **String**|  | 
 **durationMs** | **int**| The recording's length, at most 2 minutes | 
 **audio** | **MultipartFile**| The recording to keep and play (WebM, Ogg, MP4, MP3, AAC or WAV), at most 3 MB | 
 **wav** | **MultipartFile**| The same audio as 16-bit PCM WAV for Muse to hear, at most 4 MB | 
 **replyTo** | **int**|  | [optional] 

### Return type

[**ChatMessage**](ChatMessage.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateChatChannel**
> ChatChannel updateChatChannel(channelId, chatChannelUpdate)

Change a channel's topic, make it agnts's channel, or archive it

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getChatApi();
final int channelId = 789; // int | 
final ChatChannelUpdate chatChannelUpdate = ; // ChatChannelUpdate | 

try {
    final response = api.updateChatChannel(channelId, chatChannelUpdate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ChatApi->updateChatChannel: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **channelId** | **int**|  | 
 **chatChannelUpdate** | [**ChatChannelUpdate**](ChatChannelUpdate.md)|  | 

### Return type

[**ChatChannel**](ChatChannel.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

