# agnts_api.model.CIPeriod

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**seen** | **int** | Failure groups that failed in the period | 
**new_** | **int** | First seen in the period | 
**fixed** | **int** |  | 
**autoFixed** | **int** | Fixed by an agnts ticket | 
**flaky** | **int** |  | 
**fixMin** | [**Spread**](Spread.md) |  | 
**ownFixes** | **int** | Times red CI sent agnts's own pull request back to coding | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


