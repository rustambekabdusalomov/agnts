# agnts_api.model.RunHistorySummary

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**count** | **int** |  | 
**errors** | **int** | Ended in error, timeout or out of memory | 
**stalled** | **int** | Had at least one stall | 
**costUsd** | **num** |  | 
**backgroundCostUsd** | **num** | The part of costUsd spent outside a ticket's stages | 
**inputTokens** | **int** |  | 
**outputTokens** | **int** |  | 
**p50Ms** | **int** | Median duration of finished invocations | 
**p95Ms** | **int** |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


