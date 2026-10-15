# agnts_api.model.SwaggerResults

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**test** | [**SwaggerTestView**](SwaggerTestView.md) |  | 
**runId** | **int** | Absent until a run finished | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | [optional] 
**status** | **String** |  | [optional] 
**summary** | **String** |  | [optional] 
**counts** | [**ApiCounts**](ApiCounts.md) |  | [optional] 
**cases** | [**List&lt;ApiCase&gt;**](ApiCase.md) |  | 
**requests** | [**List&lt;ApiRequestRow&gt;**](ApiRequestRow.md) |  | 
**notes** | **List&lt;String&gt;** | What agnts dropped or added while checking | 
**previous** | [**ApiCounts**](ApiCounts.md) |  | [optional] 
**newFailures** | **List&lt;String&gt;** | Cases failing now that did not fail in the run before | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


