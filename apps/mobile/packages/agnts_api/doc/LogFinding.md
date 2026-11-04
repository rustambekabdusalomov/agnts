# agnts_api.model.LogFinding

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | 
**service** | **String** |  | 
**repoIds** | **List&lt;int&gt;** |  | 
**repos** | **List&lt;String&gt;** |  | 
**category** | **String** |  | 
**detector** | **String** |  | 
**class_** | **String** | code, config, infra, dependency, leak, exposure, weakness, attack or noise | 
**severity** | [**LogSeverity**](LogSeverity.md) |  | 
**title** | **String** |  | 
**remediation** | **String** |  | 
**status** | [**LogFindingStatus**](LogFindingStatus.md) |  | 
**reason** | **String** | Why a finding that could have been a ticket is only reported | 
**count** | **int** |  | 
**hourCount** | **int** |  | 
**firstSeenAt** | [**DateTime**](DateTime.md) |  | 
**lastSeenAt** | [**DateTime**](DateTime.md) |  | 
**revision** | **String** |  | 
**route** | **String** |  | 
**secretMask** | **String** | A leaked secret's first and last characters; never the value | 
**occurrences** | [**List&lt;LogOccurrence&gt;**](LogOccurrence.md) |  | 
**reportedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**ticketKey** | **String** |  | 
**ticketState** | [**TicketState**](TicketState.md) |  | [optional] 
**fixedSha** | **String** |  | [optional] 
**fixedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**sample** | **String** | Redacted log excerpt (single reads only) | [optional] 
**traceId** | **String** | The trace the sample came from, when the logs carry one (single reads only) | [optional] 
**traceUrl** | **String** | The trace in the source's tracing UI, when the source has a trace link (single reads only) | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


