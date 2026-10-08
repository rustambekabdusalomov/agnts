# agnts_api.model.Analytics

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**days** | **int** |  | 
**quality** | [**List&lt;QualityStat&gt;**](QualityStat.md) | How the tickets whose first coding run started in the period went, by prompt version, oldest first | 
**current** | [**PeriodStats**](PeriodStats.md) |  | 
**previous** | [**PeriodStats**](PeriodStats.md) |  | 
**perDay** | [**List&lt;DayStat&gt;**](DayStat.md) |  | 
**steps** | **Map&lt;String, num&gt;** | Average minutes per state | 
**stops** | **Map&lt;String, int&gt;** | Stopped runs by reason: tests, limit, you, turns, other | 
**models** | [**List&lt;AnalyticsModelsInner&gt;**](AnalyticsModelsInner.md) |  | 
**repos** | [**List&lt;AnalyticsReposInner&gt;**](AnalyticsReposInner.md) |  | 
**hours** | **List&lt;int&gt;** | agnts's events per hour of day (server time zone) | 
**spendByStage** | [**List&lt;StageSpend&gt;**](StageSpend.md) | Spend of every ticket in the period by stage and model, costliest first | 
**insights** | [**List&lt;AnalyticsInsightsInner&gt;**](AnalyticsInsightsInner.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


