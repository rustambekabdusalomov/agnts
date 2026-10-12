# agnts_api.model.CIFailure

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
**branch** | **String** | The branch, or pr/<number> for a failure on someone else's pull request | 
**workflow** | **String** |  | 
**job** | **String** |  | 
**title** | **String** |  | 
**class_** | **String** | code, test, config, dependency, infra, flaky, report, or empty while unknown | 
**status** | [**CIStatus**](CIStatus.md) |  | 
**count** | **int** |  | 
**flakyCount** | **int** |  | 
**firstSeenAt** | [**DateTime**](DateTime.md) |  | 
**lastSeenAt** | [**DateTime**](DateTime.md) |  | 
**firstSha** | **String** |  | 
**lastSha** | **String** |  | 
**occurrences** | [**List&lt;CIOccurrence&gt;**](CIOccurrence.md) |  | 
**ticketKey** | **String** | The ticket fixing it, or empty | 
**ticketState** | [**TicketState**](TicketState.md) |  | [optional] 
**fixedSha** | **String** |  | [optional] 
**fixedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**prNumber** | **int** | Someone else's pull request (diagnosis comment only), 0 otherwise | 
**sample** | **String** | Redacted log excerpt (single reads only) | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


