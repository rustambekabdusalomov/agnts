# agnts_api.model.StageSpend

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**stage** | **String** | retry is fix attempts after failed checks and requested changes | 
**model** | **String** |  | 
**calls** | **int** | Claude invocations | 
**turns** | **int** |  | 
**partial** | **bool** | A run was cut off, so its tokens are counted from the messages seen and its cost is unknown | 
**spend** | [**TokenSpend**](TokenSpend.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


