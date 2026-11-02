# agnts_api.model.LogWatchSettings

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**errors** | [**LogMode**](LogMode.md) |  | 
**security** | [**LogMode**](LogMode.md) |  | 
**alwaysNotifyLeaks** | **bool** | Notify a high-severity secret leak even when Security is off | 
**minSeverity** | [**LogSeverity**](LogSeverity.md) |  | 
**threshold** | **int** | Occurrences within the hour before a plain error acts | 
**maxAutoPerDay** | **int** | Automatic log tickets a day at most | 
**attackTicketAfter** | **int** | Bursts of the same attack within 7 days before a hardening ticket; 0 never | 
**resolveAfterDays** | **int** |  | 
**digest** | **bool** | One daily summary instead of a message per finding | 
**triagePerDay** | **int** | Model triage calls a day for new findings; 0 off | 
**patterns** | [**List&lt;LogPattern&gt;**](LogPattern.md) |  | 
**overrides** | [**List&lt;LogOverride&gt;**](LogOverride.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


