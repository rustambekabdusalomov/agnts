# agnts_api.model.Billing

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**plan** | **String** |  | 
**slots** | **int** |  | 
**maxSlots** | **int** |  | 
**memberLimit** | **int** |  | 
**members** | **int** |  | 
**creditsBalance** | **int** |  | 
**trialEndsAt** | [**DateTime**](DateTime.md) |  | [optional] 
**monthlyUzs** | **int** | What the plan, extra slots and extra members cost a month | [optional] 
**ledger** | [**List&lt;LedgerEntry&gt;**](LedgerEntry.md) |  | 
**prices** | [**BillingPrices**](BillingPrices.md) |  | 
**paymentsEnabled** | **bool** |  | 
**selfHosted** | **bool** | No billing: slots and members are set by the Admin | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


