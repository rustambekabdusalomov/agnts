# agnts_api.model.AnalyticsCI

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**days** | **int** |  | 
**watching** | **bool** | CI watching is set up for at least one repository | 
**current** | [**CIPeriod**](CIPeriod.md) |  | 
**previous** | [**CIPeriod**](CIPeriod.md) |  | 
**byClass** | **Map&lt;String, int&gt;** | Failure groups seen in the period by class: code, test, config, dependency, infra, flaky, unknown | 
**perDay** | [**List&lt;CIDay&gt;**](CIDay.md) |  | 
**flakiest** | [**List&lt;FlakyJob&gt;**](FlakyJob.md) |  | 
**open** | **int** | Failure groups that need attention now | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


