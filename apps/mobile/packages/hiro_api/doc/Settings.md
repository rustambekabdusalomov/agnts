# hiro_api.model.Settings

## Load the model package
```dart
import 'package:hiro_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**models** | [**StageModels**](StageModels.md) |  | 
**maxTurns** | **int** |  | 
**timeoutMin** | **int** |  | 
**allow** | **List&lt;String&gt;** |  | 
**deny** | **List&lt;String&gt;** |  | 
**askFirst** | **bool** |  | 
**autoResume** | **bool** |  | 
**autoLearn** | **bool** | Learn from every pushed ticket | [optional] 
**autoReview** | **bool** | Review every result while it waits for review | [optional] 
**pauseAbove** | **int** |  | 
**parallel** | **int** |  | 
**git** | [**GitSettings**](GitSettings.md) |  | 
**notify** | [**NotifySettings**](NotifySettings.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


