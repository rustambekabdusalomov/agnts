# agnts_api.model.CodeStart

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**text** | **String** | What you want done | [optional] 
**attachments** | **List&lt;int&gt;** |  | [optional] 
**repos** | [**RepoChoice**](RepoChoice.md) |  | [optional] 
**kind** | [**TicketKindChoice**](TicketKindChoice.md) |  | [optional] 
**quick** | **bool** | Tickets skip their checks (build, lint, test) | [optional] 
**ticketKey** | **String** | Work on this existing ticket instead of starting one | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


