# agnts_api.model.Result

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**summary** | **String** |  | 
**notes** | **List&lt;String&gt;** |  | 
**checks** | [**List&lt;CheckStep&gt;**](CheckStep.md) |  | 
**files** | [**List&lt;FileChange&gt;**](FileChange.md) |  | 
**report** | **String** | The Markdown report, for report kinds | [optional] 
**deviations** | **List&lt;String&gt;** | Where the work departed from the chosen approach or the plan, and why | [optional] 
**redFlags** | [**List&lt;RedFlag&gt;**](RedFlag.md) | Lines agnts's scan of the change flagged for the reviewer: skipped tests, removed assertions, silenced linters and the like | [optional] 
**proof** | [**Proof**](Proof.md) |  | [optional] 
**coverage** | [**Coverage**](Coverage.md) |  | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


