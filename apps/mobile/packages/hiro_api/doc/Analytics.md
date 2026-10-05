# hiro_api.model.Analytics

## Load the model package
```dart
import 'package:hiro_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**days** | **int** |  | 
**current** | [**PeriodStats**](PeriodStats.md) |  | 
**previous** | [**PeriodStats**](PeriodStats.md) |  | 
**perDay** | [**List&lt;DayStat&gt;**](DayStat.md) |  | 
**steps** | **Map&lt;String, num&gt;** | Average minutes per state | 
**stops** | **Map&lt;String, int&gt;** | Stopped runs by reason: tests, limit, you, turns, other | 
**models** | [**List&lt;AnalyticsModelsInner&gt;**](AnalyticsModelsInner.md) |  | 
**repos** | [**List&lt;AnalyticsReposInner&gt;**](AnalyticsReposInner.md) |  | 
**hours** | **List&lt;int&gt;** | hiro's events per hour of day (server time zone) | 
**insights** | [**List&lt;AnalyticsInsightsInner&gt;**](AnalyticsInsightsInner.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


