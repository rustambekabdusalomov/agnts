# agnts_api.model.Analysis

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**summary** | **String** |  | 
**plan** | **List&lt;String&gt;** |  | 
**complexity** | **String** | The analysis's rating; picks the review model on auto | [optional] 
**footprint** | [**Footprint**](Footprint.md) |  | [optional] 
**approaches** | [**List&lt;Approach&gt;**](Approach.md) | Ways to do the work that the analysis weighed; exactly one is chosen | [optional] 
**outOfScope** | **List&lt;String&gt;** | What the work will deliberately not do | [optional] 
**ship** | [**ShipNotes**](ShipNotes.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


