# agnts_api.model.CISettings

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**autoFix** | **bool** | Open a ticket for every confirmed failure on a watched branch; off, failures wait for Fix it | 
**maxAutoPerDay** | **int** | Automatic CI tickets a day at most | 
**retryFlaky** | **bool** | Re-run the failed jobs of a new failure once before believing it | 
**feedbackRounds** | **int** | How many times a red check sends one of agnts's pull requests back to coding; 0 turns it off | 
**infraPatterns** | **List&lt;String&gt;** | Extra regular expressions that mark a failure as infra (not the code) | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


