# agnts_api.model.Dashboard

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**counts** | [**DashboardCounts**](DashboardCounts.md) |  | 
**waiting** | [**List&lt;Ticket&gt;**](Ticket.md) |  | 
**live** | [**List&lt;LiveRun&gt;**](LiveRun.md) |  | 
**pipeline** | **Map&lt;String, int&gt;** | Open tickets per state | 
**todayByHour** | [**List&lt;HourBucket&gt;**](HourBucket.md) |  | 
**week** | [**WeekStats**](WeekStats.md) |  | 
**lastWeek** | [**WeekStats**](WeekStats.md) |  | 
**repos** | [**List&lt;RepoActivity&gt;**](RepoActivity.md) |  | 
**recent** | [**List&lt;Event&gt;**](Event.md) |  | 
**usage** | [**Usage**](Usage.md) |  | 
**parallel** | **int** |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


