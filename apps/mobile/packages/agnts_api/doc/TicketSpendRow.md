# agnts_api.model.TicketSpendRow

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**key** | **String** |  | 
**title** | **String** |  | 
**kind** | [**TicketKind**](TicketKind.md) |  | 
**state** | [**TicketState**](TicketState.md) |  | 
**repoName** | **String** |  | [optional] 
**calls** | **int** | Claude invocations in the period | 
**topStage** | **String** | The stage that cost the most | 
**spend** | [**TokenSpend**](TokenSpend.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


