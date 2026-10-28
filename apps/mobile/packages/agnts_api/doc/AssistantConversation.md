# agnts_api.model.AssistantConversation

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | 
**title** | **String** | The first question, cut | 
**mode** | [**ChatMode**](ChatMode.md) |  | 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 
**messages** | [**List&lt;AssistantMessage&gt;**](AssistantMessage.md) | Oldest first; in lists, only the last message | 
**repos** | [**RepoChoice**](RepoChoice.md) |  | [optional] 
**kind** | [**TicketKindChoice**](TicketKindChoice.md) |  | [optional] 
**quick** | **bool** | Code mode: its tickets skip their checks | [optional] 
**tickets** | [**List&lt;CodeTicket&gt;**](CodeTicket.md) | Code mode: its tickets, oldest first; in lists, only the current one | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


