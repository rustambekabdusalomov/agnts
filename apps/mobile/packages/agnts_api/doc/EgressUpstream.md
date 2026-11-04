# agnts_api.model.EgressUpstream

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**configured** | **bool** | AGNTS_EGRESS_UPSTREAM is set | 
**via** | **String** | The upstream proxy | [optional] 
**hosts** | **List&lt;String&gt;** |  | [optional] 
**target** | **String** | The host each check reaches through it | [optional] 
**ok** | **bool** |  | 
**checkedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**lastOkAt** | [**DateTime**](DateTime.md) |  | [optional] 
**downSince** | [**DateTime**](DateTime.md) |  | [optional] 
**latencyMs** | **int** |  | 
**error** | **String** |  | [optional] 
**exit** | [**EgressUpstreamExit**](EgressUpstreamExit.md) |  | [optional] 
**history** | [**List&lt;EgressUpstreamHistoryInner&gt;**](EgressUpstreamHistoryInner.md) |  | 
**calls** | **int** | Connections runs made through it since egress started | 
**failed** | **int** |  | 
**lastCallError** | **String** |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


