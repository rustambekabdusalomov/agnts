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
**defect** | **bool** | The work fixes broken behaviour; with proveFixes on it must prove the fix | [optional] 
**acceptance** | [**List&lt;AnalysisAcceptanceInner&gt;**](AnalysisAcceptanceInner.md) | What the finished work must do, as checks | [optional] 
**secondOpinion** | [**SecondOpinion**](SecondOpinion.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


