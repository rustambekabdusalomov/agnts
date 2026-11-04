# agnts_api.model.SecurityScan

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | 
**repoId** | **int** |  | 
**repo** | **String** |  | 
**trigger** | **String** |  | 
**status** | **String** |  | 
**commit** | **String** |  | 
**findingIds** | **List&lt;int&gt;** | A verify scan: the findings it checks | [optional] 
**fullHistory** | **bool** |  | [optional] 
**tools** | [**List&lt;SecToolRun&gt;**](SecToolRun.md) | What actually ran | 
**agent** | **String** | done, limit (stopped at its turn or time limit), failed, skipped, or empty when it has not run | 
**history** | **int** | Commits the secret scan read | 
**commits** | **int** | Commits the checkout had | 
**dbVersions** | **Map&lt;String, String&gt;** |  | [optional] 
**new_** | **int** |  | 
**seen** | **int** |  | 
**fixed** | **int** |  | 
**reopened** | **int** |  | 
**unchecked** | **int** | Active findings this scan could not recheck | 
**rejectedCount** | **int** |  | 
**rejected** | [**List&lt;SecRejectedHit&gt;**](SecRejectedHit.md) |  | [optional] 
**open** | [**SecSeverityCounts**](SecSeverityCounts.md) |  | 
**summary** | **String** |  | 
**error** | **String** |  | 
**provider** | **String** | The agent's module (claude, muse) | 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**startedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**finishedAt** | [**DateTime**](DateTime.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


