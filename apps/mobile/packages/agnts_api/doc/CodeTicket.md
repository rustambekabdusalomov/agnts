# agnts_api.model.CodeTicket

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**key** | **String** |  | 
**title** | **String** |  | 
**state** | [**TicketState**](TicketState.md) |  | 
**kind** | [**TicketKind**](TicketKind.md) |  | 
**repos** | **List&lt;String&gt;** | Repository names, the primary first | 
**current** | **bool** | New messages go to it | 
**moved** | **bool** | Another of your conversations has it now | 
**attachedAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


