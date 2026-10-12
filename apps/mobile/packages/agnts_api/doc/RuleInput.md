# agnts_api.model.RuleInput

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**title** | **String** |  | 
**body** | **String** |  | 
**repoId** | **int** | Leave out for a rule every repository follows | [optional] 
**enabled** | **bool** |  | [optional] [default to true]
**kind** | [**RuleKind**](RuleKind.md) |  | [optional] 
**enforce** | [**RuleEnforce**](RuleEnforce.md) |  | [optional] 
**removeEnforce** | **bool** | Remove the enforcement; enforce left out keeps it | [optional] 
**delivery** | **String** | Left out keeps the rule's | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


