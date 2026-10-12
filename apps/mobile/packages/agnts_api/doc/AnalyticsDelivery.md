# agnts_api.model.AnalyticsDelivery

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**days** | **int** |  | 
**current** | [**DeliveryPeriod**](DeliveryPeriod.md) |  | 
**previous** | [**DeliveryPeriod**](DeliveryPeriod.md) |  | 
**perDay** | [**List&lt;DeliveryDay&gt;**](DeliveryDay.md) |  | 
**slowest** | [**List&lt;SlowTicket&gt;**](SlowTicket.md) | The slowest tickets pushed in the period, and where their time went | 
**stale** | [**List&lt;StalePR&gt;**](StalePR.md) | Pull requests still open after a week, oldest first | 
**unanswered** | **int** | Questions waiting for an answer now | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


