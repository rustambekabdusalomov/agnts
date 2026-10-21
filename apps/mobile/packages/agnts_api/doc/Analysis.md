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
**patterns** | [**List&lt;Pattern&gt;**](Pattern.md) | For each file the work changes, the existing code it follows (copy, adapt) or that it is new | [optional] 
**reuse** | [**List&lt;AnalysisReuseInner&gt;**](AnalysisReuseInner.md) | Existing helpers the work must use instead of writing its own | [optional] 
**testPlan** | [**List&lt;AnalysisTestPlanInner&gt;**](AnalysisTestPlanInner.md) | Tests the work must add or change | [optional] 
**edgeCases** | **List&lt;String&gt;** | Inputs and failures the work must handle | [optional] 
**repro** | [**AnalysisRepro**](AnalysisRepro.md) |  | [optional] 
**secondOpinion** | [**SecondOpinion**](SecondOpinion.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


