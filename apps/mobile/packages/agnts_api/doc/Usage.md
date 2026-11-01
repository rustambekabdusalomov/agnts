# agnts_api.model.Usage

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**fiveHour** | [**UsageWindow**](UsageWindow.md) |  | 
**sevenDay** | [**UsageWindow**](UsageWindow.md) |  | 
**status** | **String** |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**paused** | **bool** | New runs are held back | 
**pausedUntil** | [**DateTime**](DateTime.md) |  | [optional] 
**pauseAbove** | **int** |  | 
**refreshing** | **bool** |  | 
**provider** | **String** | The module whose account this is | [optional] 
**connected** | **bool** | An account of this module is connected for you (in per-member mode, your own; else the workspace's). False: nothing to read. | [optional] 
**account** | **String** | The account's label | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


