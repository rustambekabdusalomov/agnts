# agnts_api.api.MeetingsApi

## Load the API package
```dart
import 'package:agnts_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**actOnMeetingPerson**](MeetingsApi.md#actonmeetingperson) | **POST** /public/meetings/{code}/call/people/{person}/{action} | Hosts: mute someone (source: microphone, camera or screen_share), ask them to unmute, remove them, lower their hand, make them co-host
[**admitAllMeetingKnocks**](MeetingsApi.md#admitallmeetingknocks) | **POST** /public/meetings/{code}/call/admit-all | Let everyone waiting in
[**answerMeeting**](MeetingsApi.md#answermeeting) | **PUT** /meetings/{meetingId}/rsvp | Answer an invitation
[**cancelMeeting**](MeetingsApi.md#cancelmeeting) | **POST** /meetings/{meetingId}/cancel | Cancel a meeting; invitees get the cancellation in their calendar
[**changeMeetingInvitees**](MeetingsApi.md#changemeetinginvitees) | **POST** /meetings/{meetingId}/invitees | Invite more people, or uninvite (the meeting&#39;s hosts)
[**createActionItemTicket**](MeetingsApi.md#createactionitemticket) | **POST** /meetings/{meetingId}/sessions/{sessionId}/action-items/{itemId}/ticket | Make a ticket of an action item, with the words of the meeting that show it
[**createMeeting**](MeetingsApi.md#createmeeting) | **POST** /meetings | Make a meeting you host (instant or scheduled) and invite people
[**decideMeetingKnock**](MeetingsApi.md#decidemeetingknock) | **POST** /public/meetings/{code}/call/knocks/{knockId}/{decision} | Let someone in, or turn them away
[**deleteMeeting**](MeetingsApi.md#deletemeeting) | **DELETE** /meetings/{meetingId} | Delete a meeting with its calls, recordings and transcripts (the host or the owner); notes documents stay
[**deleteMeetingRecording**](MeetingsApi.md#deletemeetingrecording) | **DELETE** /meetings/{meetingId}/sessions/{sessionId}/recordings/{mediaId} | Delete a recording now (the host or the owner)
[**endMeetingCall**](MeetingsApi.md#endmeetingcall) | **POST** /public/meetings/{code}/call/end | End the call for everyone (the host)
[**getMeeting**](MeetingsApi.md#getmeeting) | **GET** /meetings/{meetingId} | A meeting with its invitees
[**getMeetingCall**](MeetingsApi.md#getmeetingcall) | **GET** /public/meetings/{code}/call | The call as you see it in it - people, waiting room, what you may do
[**getMeetingPrefs**](MeetingsApi.md#getmeetingprefs) | **GET** /account/meetings | Your meeting reminders
[**getMeetingRecording**](MeetingsApi.md#getmeetingrecording) | **GET** /meetings/{meetingId}/sessions/{sessionId}/recordings/{mediaId} | Watch or download a call&#39;s recording (MP4; ranges for seeking)
[**getMeetingSession**](MeetingsApi.md#getmeetingsession) | **GET** /meetings/{meetingId}/sessions/{sessionId} | A call&#39;s attendance, recordings, notes and action items
[**getMeetingSettings**](MeetingsApi.md#getmeetingsettings) | **GET** /meetings/settings | The workspace&#39;s rules for meetings, and what this server can do
[**getMeetingTranscript**](MeetingsApi.md#getmeetingtranscript) | **GET** /meetings/{meetingId}/sessions/{sessionId}/transcript | What was said, as Muse heard it
[**getMeetingUsage**](MeetingsApi.md#getmeetingusage) | **GET** /meetings/usage | The workspace&#39;s use of meetings per day (people-minutes, recordings, transcribed audio)
[**getPublicMeeting**](MeetingsApi.md#getpublicmeeting) | **GET** /public/meetings/{code} | What anyone with the link sees before joining
[**joinMeeting**](MeetingsApi.md#joinmeeting) | **POST** /public/meetings/{code}/join | Join a meeting, or knock to be let in
[**listMeetingCallMessages**](MeetingsApi.md#listmeetingcallmessages) | **GET** /public/meetings/{code}/call/messages | The call&#39;s chat after a message
[**listMeetingSessionMessages**](MeetingsApi.md#listmeetingsessionmessages) | **GET** /meetings/{meetingId}/sessions/{sessionId}/messages | A call&#39;s chat
[**listMeetingSessions**](MeetingsApi.md#listmeetingsessions) | **GET** /meetings/{meetingId}/sessions | The times a meeting was live, newest first
[**listMeetings**](MeetingsApi.md#listmeetings) | **GET** /meetings | The meetings you see
[**listPastMeetingSessions**](MeetingsApi.md#listpastmeetingsessions) | **GET** /meetings/past | Calls that happened, newest first, of the meetings you see
[**listTicketMeetings**](MeetingsApi.md#listticketmeetings) | **GET** /tickets/{key}/meetings | The meetings a ticket was discussed in or made from
[**muteAllInMeeting**](MeetingsApi.md#muteallinmeeting) | **POST** /public/meetings/{code}/call/mute-all | Mute everyone&#39;s microphone but yours (hosts)
[**putMeetingPrefs**](MeetingsApi.md#putmeetingprefs) | **PUT** /account/meetings | Change your meeting reminders
[**putMeetingSettings**](MeetingsApi.md#putmeetingsettings) | **PUT** /meetings/settings | Change the workspace&#39;s rules for meetings (the owner)
[**refreshMeetingToken**](MeetingsApi.md#refreshmeetingtoken) | **POST** /public/meetings/{code}/call/token | A new LiveKit token for your seat (to reconnect)
[**regenerateMeetingNotes**](MeetingsApi.md#regeneratemeetingnotes) | **POST** /meetings/{meetingId}/sessions/{sessionId}/notes | Have Muse write a call&#39;s notes again (the meeting&#39;s hosts)
[**ringMeeting**](MeetingsApi.md#ringmeeting) | **POST** /meetings/{meetingId}/ring | Ring members into the meeting now (their phone and open agnts pages, for 30 seconds)
[**searchMeetingTranscripts**](MeetingsApi.md#searchmeetingtranscripts) | **GET** /meetings/search | Find what was said in the meetings you see
[**sendMeetingMessage**](MeetingsApi.md#sendmeetingmessage) | **POST** /public/meetings/{code}/call/messages | Send a chat message to the call (no secrets; at most 30 a minute)
[**setMeetingCallSettings**](MeetingsApi.md#setmeetingcallsettings) | **PUT** /public/meetings/{code}/call/settings | Hosts: lock the meeting, change who may come in, quiet guests, record, take notes
[**setMeetingCohosts**](MeetingsApi.md#setmeetingcohosts) | **PUT** /meetings/{meetingId}/cohosts | Choose a meeting&#39;s co-hosts (the host)
[**setMeetingHost**](MeetingsApi.md#setmeetinghost) | **PUT** /meetings/{meetingId}/host | Hand a meeting to another member (the host or the owner)
[**updateMeeting**](MeetingsApi.md#updatemeeting) | **PATCH** /meetings/{meetingId} | Change a meeting (its hosts and the owner); a new time sends the invitees an update
[**waitMeetingKnock**](MeetingsApi.md#waitmeetingknock) | **GET** /public/meetings/{code}/knocks/{knockId} | Wait (up to 25 seconds) for a knock to be answered


# **actOnMeetingPerson**
> actOnMeetingPerson(code, person, action, xMeetingSeat, actOnMeetingPersonRequest)

Hosts: mute someone (source: microphone, camera or screen_share), ask them to unmute, remove them, lower their hand, make them co-host

### Example
```dart
import 'package:agnts_api/api.dart';

final api = AgntsApi().getMeetingsApi();
final String code = code_example; // String | The meeting code, abc-defg-hij (dashes optional)
final String person = person_example; // String | u<user id> or g<guest id>
final String action = action_example; // String | 
final String xMeetingSeat = xMeetingSeat_example; // String | The seat a join handed out
final ActOnMeetingPersonRequest actOnMeetingPersonRequest = ; // ActOnMeetingPersonRequest | 

try {
    api.actOnMeetingPerson(code, person, action, xMeetingSeat, actOnMeetingPersonRequest);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->actOnMeetingPerson: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **code** | **String**| The meeting code, abc-defg-hij (dashes optional) | 
 **person** | **String**| u<user id> or g<guest id> | 
 **action** | **String**|  | 
 **xMeetingSeat** | **String**| The seat a join handed out | [optional] 
 **actOnMeetingPersonRequest** | [**ActOnMeetingPersonRequest**](ActOnMeetingPersonRequest.md)|  | [optional] 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **admitAllMeetingKnocks**
> admitAllMeetingKnocks(code, xMeetingSeat)

Let everyone waiting in

### Example
```dart
import 'package:agnts_api/api.dart';

final api = AgntsApi().getMeetingsApi();
final String code = code_example; // String | The meeting code, abc-defg-hij (dashes optional)
final String xMeetingSeat = xMeetingSeat_example; // String | The seat a join handed out

try {
    api.admitAllMeetingKnocks(code, xMeetingSeat);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->admitAllMeetingKnocks: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **code** | **String**| The meeting code, abc-defg-hij (dashes optional) | 
 **xMeetingSeat** | **String**| The seat a join handed out | [optional] 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **answerMeeting**
> answerMeeting(meetingId, answerMeetingRequest)

Answer an invitation

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getMeetingsApi();
final int meetingId = 789; // int | 
final AnswerMeetingRequest answerMeetingRequest = ; // AnswerMeetingRequest | 

try {
    api.answerMeeting(meetingId, answerMeetingRequest);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->answerMeeting: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **meetingId** | **int**|  | 
 **answerMeetingRequest** | [**AnswerMeetingRequest**](AnswerMeetingRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **cancelMeeting**
> cancelMeeting(meetingId)

Cancel a meeting; invitees get the cancellation in their calendar

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getMeetingsApi();
final int meetingId = 789; // int | 

try {
    api.cancelMeeting(meetingId);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->cancelMeeting: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **meetingId** | **int**|  | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **changeMeetingInvitees**
> MeetingDetail changeMeetingInvitees(meetingId, meetingInviteesInput)

Invite more people, or uninvite (the meeting's hosts)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getMeetingsApi();
final int meetingId = 789; // int | 
final MeetingInviteesInput meetingInviteesInput = ; // MeetingInviteesInput | 

try {
    final response = api.changeMeetingInvitees(meetingId, meetingInviteesInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->changeMeetingInvitees: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **meetingId** | **int**|  | 
 **meetingInviteesInput** | [**MeetingInviteesInput**](MeetingInviteesInput.md)|  | 

### Return type

[**MeetingDetail**](MeetingDetail.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createActionItemTicket**
> Ticket createActionItemTicket(meetingId, sessionId, itemId, actionItemTicketInput)

Make a ticket of an action item, with the words of the meeting that show it

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getMeetingsApi();
final int meetingId = 789; // int | 
final int sessionId = 789; // int | 
final int itemId = 789; // int | 
final ActionItemTicketInput actionItemTicketInput = ; // ActionItemTicketInput | 

try {
    final response = api.createActionItemTicket(meetingId, sessionId, itemId, actionItemTicketInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->createActionItemTicket: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **meetingId** | **int**|  | 
 **sessionId** | **int**|  | 
 **itemId** | **int**|  | 
 **actionItemTicketInput** | [**ActionItemTicketInput**](ActionItemTicketInput.md)|  | [optional] 

### Return type

[**Ticket**](Ticket.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createMeeting**
> MeetingDetail createMeeting(meetingInput)

Make a meeting you host (instant or scheduled) and invite people

Scheduled meetings' invitees get an email with the calendar event; members are told in agnts too.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getMeetingsApi();
final MeetingInput meetingInput = ; // MeetingInput | 

try {
    final response = api.createMeeting(meetingInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->createMeeting: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **meetingInput** | [**MeetingInput**](MeetingInput.md)|  | 

### Return type

[**MeetingDetail**](MeetingDetail.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **decideMeetingKnock**
> decideMeetingKnock(code, knockId, decision, xMeetingSeat)

Let someone in, or turn them away

### Example
```dart
import 'package:agnts_api/api.dart';

final api = AgntsApi().getMeetingsApi();
final String code = code_example; // String | The meeting code, abc-defg-hij (dashes optional)
final int knockId = 789; // int | 
final String decision = decision_example; // String | 
final String xMeetingSeat = xMeetingSeat_example; // String | The seat a join handed out

try {
    api.decideMeetingKnock(code, knockId, decision, xMeetingSeat);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->decideMeetingKnock: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **code** | **String**| The meeting code, abc-defg-hij (dashes optional) | 
 **knockId** | **int**|  | 
 **decision** | **String**|  | 
 **xMeetingSeat** | **String**| The seat a join handed out | [optional] 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteMeeting**
> deleteMeeting(meetingId)

Delete a meeting with its calls, recordings and transcripts (the host or the owner); notes documents stay

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getMeetingsApi();
final int meetingId = 789; // int | 

try {
    api.deleteMeeting(meetingId);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->deleteMeeting: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **meetingId** | **int**|  | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteMeetingRecording**
> deleteMeetingRecording(meetingId, sessionId, mediaId)

Delete a recording now (the host or the owner)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getMeetingsApi();
final int meetingId = 789; // int | 
final int sessionId = 789; // int | 
final int mediaId = 789; // int | 

try {
    api.deleteMeetingRecording(meetingId, sessionId, mediaId);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->deleteMeetingRecording: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **meetingId** | **int**|  | 
 **sessionId** | **int**|  | 
 **mediaId** | **int**|  | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **endMeetingCall**
> endMeetingCall(code, xMeetingSeat)

End the call for everyone (the host)

### Example
```dart
import 'package:agnts_api/api.dart';

final api = AgntsApi().getMeetingsApi();
final String code = code_example; // String | The meeting code, abc-defg-hij (dashes optional)
final String xMeetingSeat = xMeetingSeat_example; // String | The seat a join handed out

try {
    api.endMeetingCall(code, xMeetingSeat);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->endMeetingCall: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **code** | **String**| The meeting code, abc-defg-hij (dashes optional) | 
 **xMeetingSeat** | **String**| The seat a join handed out | [optional] 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMeeting**
> MeetingDetail getMeeting(meetingId)

A meeting with its invitees

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getMeetingsApi();
final int meetingId = 789; // int | 

try {
    final response = api.getMeeting(meetingId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->getMeeting: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **meetingId** | **int**|  | 

### Return type

[**MeetingDetail**](MeetingDetail.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMeetingCall**
> MeetingCall getMeetingCall(code, xMeetingSeat)

The call as you see it in it - people, waiting room, what you may do

### Example
```dart
import 'package:agnts_api/api.dart';

final api = AgntsApi().getMeetingsApi();
final String code = code_example; // String | The meeting code, abc-defg-hij (dashes optional)
final String xMeetingSeat = xMeetingSeat_example; // String | The seat a join handed out

try {
    final response = api.getMeetingCall(code, xMeetingSeat);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->getMeetingCall: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **code** | **String**| The meeting code, abc-defg-hij (dashes optional) | 
 **xMeetingSeat** | **String**| The seat a join handed out | [optional] 

### Return type

[**MeetingCall**](MeetingCall.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMeetingPrefs**
> MeetingPrefs getMeetingPrefs()

Your meeting reminders

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getMeetingsApi();

try {
    final response = api.getMeetingPrefs();
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->getMeetingPrefs: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**MeetingPrefs**](MeetingPrefs.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMeetingRecording**
> Uint8List getMeetingRecording(meetingId, sessionId, mediaId, download)

Watch or download a call's recording (MP4; ranges for seeking)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getMeetingsApi();
final int meetingId = 789; // int | 
final int sessionId = 789; // int | 
final int mediaId = 789; // int | 
final bool download = true; // bool | 

try {
    final response = api.getMeetingRecording(meetingId, sessionId, mediaId, download);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->getMeetingRecording: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **meetingId** | **int**|  | 
 **sessionId** | **int**|  | 
 **mediaId** | **int**|  | 
 **download** | **bool**|  | [optional] 

### Return type

[**Uint8List**](Uint8List.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: video/mp4, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMeetingSession**
> MeetingSessionDetail getMeetingSession(meetingId, sessionId)

A call's attendance, recordings, notes and action items

For the people who were in it, the meeting's invitees, its hosts and the owner.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getMeetingsApi();
final int meetingId = 789; // int | 
final int sessionId = 789; // int | 

try {
    final response = api.getMeetingSession(meetingId, sessionId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->getMeetingSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **meetingId** | **int**|  | 
 **sessionId** | **int**|  | 

### Return type

[**MeetingSessionDetail**](MeetingSessionDetail.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMeetingSettings**
> MeetingSettings getMeetingSettings()

The workspace's rules for meetings, and what this server can do

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getMeetingsApi();

try {
    final response = api.getMeetingSettings();
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->getMeetingSettings: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**MeetingSettings**](MeetingSettings.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMeetingTranscript**
> MeetingTranscript getMeetingTranscript(meetingId, sessionId, format)

What was said, as Muse heard it

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getMeetingsApi();
final int meetingId = 789; // int | 
final int sessionId = 789; // int | 
final String format = format_example; // String | 

try {
    final response = api.getMeetingTranscript(meetingId, sessionId, format);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->getMeetingTranscript: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **meetingId** | **int**|  | 
 **sessionId** | **int**|  | 
 **format** | **String**|  | [optional] [default to 'json']

### Return type

[**MeetingTranscript**](MeetingTranscript.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, text/plain, text/vtt

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMeetingUsage**
> List<MeetingUsageDay> getMeetingUsage(days)

The workspace's use of meetings per day (people-minutes, recordings, transcribed audio)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getMeetingsApi();
final int days = 56; // int | 

try {
    final response = api.getMeetingUsage(days);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->getMeetingUsage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **days** | **int**|  | [optional] [default to 30]

### Return type

[**List&lt;MeetingUsageDay&gt;**](MeetingUsageDay.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPublicMeeting**
> PublicMeeting getPublicMeeting(code)

What anyone with the link sees before joining

Title, host, times and whether it is live. Says whether the signed-in person is a member of its workspace.

### Example
```dart
import 'package:agnts_api/api.dart';

final api = AgntsApi().getMeetingsApi();
final String code = code_example; // String | The meeting code, abc-defg-hij (dashes optional)

try {
    final response = api.getPublicMeeting(code);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->getPublicMeeting: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **code** | **String**| The meeting code, abc-defg-hij (dashes optional) | 

### Return type

[**PublicMeeting**](PublicMeeting.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **joinMeeting**
> MeetingJoin joinMeeting(code, meetingJoinInput, xGuestToken)

Join a meeting, or knock to be let in

Members of the meeting's workspace are recognised by their session; everyone else is a guest: by the name they type, Google, their agnts account, or an invitation link's token. A returning guest sends their guest token (X-Guest-Token) to stay the same guest. joined hands out the LiveKit grant and the seat for in-call requests; waiting hands out a knock to poll. Refusals are 403 with the reason as the code (locked, full, removed, guests_off, not_started, cancelled, denied). 

### Example
```dart
import 'package:agnts_api/api.dart';

final api = AgntsApi().getMeetingsApi();
final String code = code_example; // String | The meeting code, abc-defg-hij (dashes optional)
final MeetingJoinInput meetingJoinInput = ; // MeetingJoinInput | 
final String xGuestToken = xGuestToken_example; // String | The guest's secret token from joinPublicDocument

try {
    final response = api.joinMeeting(code, meetingJoinInput, xGuestToken);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->joinMeeting: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **code** | **String**| The meeting code, abc-defg-hij (dashes optional) | 
 **meetingJoinInput** | [**MeetingJoinInput**](MeetingJoinInput.md)|  | 
 **xGuestToken** | **String**| The guest's secret token from joinPublicDocument | [optional] 

### Return type

[**MeetingJoin**](MeetingJoin.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listMeetingCallMessages**
> List<MeetingMessage> listMeetingCallMessages(code, xMeetingSeat, after)

The call's chat after a message

### Example
```dart
import 'package:agnts_api/api.dart';

final api = AgntsApi().getMeetingsApi();
final String code = code_example; // String | The meeting code, abc-defg-hij (dashes optional)
final String xMeetingSeat = xMeetingSeat_example; // String | The seat a join handed out
final int after = 789; // int | 

try {
    final response = api.listMeetingCallMessages(code, xMeetingSeat, after);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->listMeetingCallMessages: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **code** | **String**| The meeting code, abc-defg-hij (dashes optional) | 
 **xMeetingSeat** | **String**| The seat a join handed out | [optional] 
 **after** | **int**|  | [optional] [default to 0]

### Return type

[**List&lt;MeetingMessage&gt;**](MeetingMessage.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listMeetingSessionMessages**
> List<MeetingMessage> listMeetingSessionMessages(meetingId, sessionId)

A call's chat

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getMeetingsApi();
final int meetingId = 789; // int | 
final int sessionId = 789; // int | 

try {
    final response = api.listMeetingSessionMessages(meetingId, sessionId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->listMeetingSessionMessages: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **meetingId** | **int**|  | 
 **sessionId** | **int**|  | 

### Return type

[**List&lt;MeetingMessage&gt;**](MeetingMessage.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listMeetingSessions**
> List<MeetingSessionBrief> listMeetingSessions(meetingId)

The times a meeting was live, newest first

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getMeetingsApi();
final int meetingId = 789; // int | 

try {
    final response = api.listMeetingSessions(meetingId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->listMeetingSessions: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **meetingId** | **int**|  | 

### Return type

[**List&lt;MeetingSessionBrief&gt;**](MeetingSessionBrief.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listMeetings**
> List<Meeting> listMeetings(view)

The meetings you see

upcoming: live ones first, then scheduled ones that have not ended; live: the live ones; mine: the ones you host.

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getMeetingsApi();
final String view = view_example; // String | 

try {
    final response = api.listMeetings(view);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->listMeetings: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **view** | **String**|  | [optional] [default to 'upcoming']

### Return type

[**List&lt;Meeting&gt;**](Meeting.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPastMeetingSessions**
> List<MeetingSessionSummary> listPastMeetingSessions(before, limit)

Calls that happened, newest first, of the meetings you see

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getMeetingsApi();
final DateTime before = 2013-10-20T19:20:30+01:00; // DateTime | Page back from this start time
final int limit = 56; // int | 

try {
    final response = api.listPastMeetingSessions(before, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->listPastMeetingSessions: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **before** | **DateTime**| Page back from this start time | [optional] 
 **limit** | **int**|  | [optional] [default to 30]

### Return type

[**List&lt;MeetingSessionSummary&gt;**](MeetingSessionSummary.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listTicketMeetings**
> List<MeetingTicketLink> listTicketMeetings(key)

The meetings a ticket was discussed in or made from

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getMeetingsApi();
final String key = key_example; // String | 

try {
    final response = api.listTicketMeetings(key);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->listTicketMeetings: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 

### Return type

[**List&lt;MeetingTicketLink&gt;**](MeetingTicketLink.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **muteAllInMeeting**
> muteAllInMeeting(code, xMeetingSeat)

Mute everyone's microphone but yours (hosts)

### Example
```dart
import 'package:agnts_api/api.dart';

final api = AgntsApi().getMeetingsApi();
final String code = code_example; // String | The meeting code, abc-defg-hij (dashes optional)
final String xMeetingSeat = xMeetingSeat_example; // String | The seat a join handed out

try {
    api.muteAllInMeeting(code, xMeetingSeat);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->muteAllInMeeting: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **code** | **String**| The meeting code, abc-defg-hij (dashes optional) | 
 **xMeetingSeat** | **String**| The seat a join handed out | [optional] 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **putMeetingPrefs**
> MeetingPrefs putMeetingPrefs(meetingPrefs)

Change your meeting reminders

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getMeetingsApi();
final MeetingPrefs meetingPrefs = ; // MeetingPrefs | 

try {
    final response = api.putMeetingPrefs(meetingPrefs);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->putMeetingPrefs: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **meetingPrefs** | [**MeetingPrefs**](MeetingPrefs.md)|  | 

### Return type

[**MeetingPrefs**](MeetingPrefs.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **putMeetingSettings**
> MeetingSettings putMeetingSettings(meetingSettingsInput)

Change the workspace's rules for meetings (the owner)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getMeetingsApi();
final MeetingSettingsInput meetingSettingsInput = ; // MeetingSettingsInput | 

try {
    final response = api.putMeetingSettings(meetingSettingsInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->putMeetingSettings: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **meetingSettingsInput** | [**MeetingSettingsInput**](MeetingSettingsInput.md)|  | 

### Return type

[**MeetingSettings**](MeetingSettings.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **refreshMeetingToken**
> MeetingGrant refreshMeetingToken(code, xMeetingSeat)

A new LiveKit token for your seat (to reconnect)

### Example
```dart
import 'package:agnts_api/api.dart';

final api = AgntsApi().getMeetingsApi();
final String code = code_example; // String | The meeting code, abc-defg-hij (dashes optional)
final String xMeetingSeat = xMeetingSeat_example; // String | The seat a join handed out

try {
    final response = api.refreshMeetingToken(code, xMeetingSeat);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->refreshMeetingToken: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **code** | **String**| The meeting code, abc-defg-hij (dashes optional) | 
 **xMeetingSeat** | **String**| The seat a join handed out | [optional] 

### Return type

[**MeetingGrant**](MeetingGrant.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **regenerateMeetingNotes**
> regenerateMeetingNotes(meetingId, sessionId)

Have Muse write a call's notes again (the meeting's hosts)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getMeetingsApi();
final int meetingId = 789; // int | 
final int sessionId = 789; // int | 

try {
    api.regenerateMeetingNotes(meetingId, sessionId);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->regenerateMeetingNotes: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **meetingId** | **int**|  | 
 **sessionId** | **int**|  | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **ringMeeting**
> ringMeeting(meetingId, ringMeetingRequest)

Ring members into the meeting now (their phone and open agnts pages, for 30 seconds)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getMeetingsApi();
final int meetingId = 789; // int | 
final RingMeetingRequest ringMeetingRequest = ; // RingMeetingRequest | 

try {
    api.ringMeeting(meetingId, ringMeetingRequest);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->ringMeeting: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **meetingId** | **int**|  | 
 **ringMeetingRequest** | [**RingMeetingRequest**](RingMeetingRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **searchMeetingTranscripts**
> List<MeetingTranscriptHit> searchMeetingTranscripts(q)

Find what was said in the meetings you see

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getMeetingsApi();
final String q = q_example; // String | 

try {
    final response = api.searchMeetingTranscripts(q);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->searchMeetingTranscripts: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **q** | **String**|  | 

### Return type

[**List&lt;MeetingTranscriptHit&gt;**](MeetingTranscriptHit.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sendMeetingMessage**
> MeetingMessage sendMeetingMessage(code, sendMeetingMessageRequest, xMeetingSeat)

Send a chat message to the call (no secrets; at most 30 a minute)

### Example
```dart
import 'package:agnts_api/api.dart';

final api = AgntsApi().getMeetingsApi();
final String code = code_example; // String | The meeting code, abc-defg-hij (dashes optional)
final SendMeetingMessageRequest sendMeetingMessageRequest = ; // SendMeetingMessageRequest | 
final String xMeetingSeat = xMeetingSeat_example; // String | The seat a join handed out

try {
    final response = api.sendMeetingMessage(code, sendMeetingMessageRequest, xMeetingSeat);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->sendMeetingMessage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **code** | **String**| The meeting code, abc-defg-hij (dashes optional) | 
 **sendMeetingMessageRequest** | [**SendMeetingMessageRequest**](SendMeetingMessageRequest.md)|  | 
 **xMeetingSeat** | **String**| The seat a join handed out | [optional] 

### Return type

[**MeetingMessage**](MeetingMessage.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setMeetingCallSettings**
> setMeetingCallSettings(code, meetingCallSettings, xMeetingSeat)

Hosts: lock the meeting, change who may come in, quiet guests, record, take notes

### Example
```dart
import 'package:agnts_api/api.dart';

final api = AgntsApi().getMeetingsApi();
final String code = code_example; // String | The meeting code, abc-defg-hij (dashes optional)
final MeetingCallSettings meetingCallSettings = ; // MeetingCallSettings | 
final String xMeetingSeat = xMeetingSeat_example; // String | The seat a join handed out

try {
    api.setMeetingCallSettings(code, meetingCallSettings, xMeetingSeat);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->setMeetingCallSettings: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **code** | **String**| The meeting code, abc-defg-hij (dashes optional) | 
 **meetingCallSettings** | [**MeetingCallSettings**](MeetingCallSettings.md)|  | 
 **xMeetingSeat** | **String**| The seat a join handed out | [optional] 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setMeetingCohosts**
> MeetingDetail setMeetingCohosts(meetingId, setMeetingCohostsRequest)

Choose a meeting's co-hosts (the host)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getMeetingsApi();
final int meetingId = 789; // int | 
final SetMeetingCohostsRequest setMeetingCohostsRequest = ; // SetMeetingCohostsRequest | 

try {
    final response = api.setMeetingCohosts(meetingId, setMeetingCohostsRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->setMeetingCohosts: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **meetingId** | **int**|  | 
 **setMeetingCohostsRequest** | [**SetMeetingCohostsRequest**](SetMeetingCohostsRequest.md)|  | 

### Return type

[**MeetingDetail**](MeetingDetail.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setMeetingHost**
> MeetingDetail setMeetingHost(meetingId, transferWorkspaceRequest)

Hand a meeting to another member (the host or the owner)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getMeetingsApi();
final int meetingId = 789; // int | 
final TransferWorkspaceRequest transferWorkspaceRequest = ; // TransferWorkspaceRequest | 

try {
    final response = api.setMeetingHost(meetingId, transferWorkspaceRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->setMeetingHost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **meetingId** | **int**|  | 
 **transferWorkspaceRequest** | [**TransferWorkspaceRequest**](TransferWorkspaceRequest.md)|  | 

### Return type

[**MeetingDetail**](MeetingDetail.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateMeeting**
> MeetingDetail updateMeeting(meetingId, meetingInput)

Change a meeting (its hosts and the owner); a new time sends the invitees an update

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getMeetingsApi();
final int meetingId = 789; // int | 
final MeetingInput meetingInput = ; // MeetingInput | 

try {
    final response = api.updateMeeting(meetingId, meetingInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->updateMeeting: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **meetingId** | **int**|  | 
 **meetingInput** | [**MeetingInput**](MeetingInput.md)|  | 

### Return type

[**MeetingDetail**](MeetingDetail.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **waitMeetingKnock**
> MeetingJoin waitMeetingKnock(code, knockId, xKnockToken)

Wait (up to 25 seconds) for a knock to be answered

joined with the grant once let in, waiting while nobody answered, 403 denied or expired.

### Example
```dart
import 'package:agnts_api/api.dart';

final api = AgntsApi().getMeetingsApi();
final String code = code_example; // String | The meeting code, abc-defg-hij (dashes optional)
final int knockId = 789; // int | 
final String xKnockToken = xKnockToken_example; // String | The knock's secret a join handed out

try {
    final response = api.waitMeetingKnock(code, knockId, xKnockToken);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeetingsApi->waitMeetingKnock: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **code** | **String**| The meeting code, abc-defg-hij (dashes optional) | 
 **knockId** | **int**|  | 
 **xKnockToken** | **String**| The knock's secret a join handed out | [optional] 

### Return type

[**MeetingJoin**](MeetingJoin.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

