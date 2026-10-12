# agnts_api.model.RepoHarnessInput

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**guardProfile** | **String** | Empty follows the workspace | [optional] 
**secretAllow** | **List&lt;String&gt;** | Path globs where example credentials are expected, besides testdata/, fixtures/ and *.example | [optional] 
**editChecks** | [**List&lt;EditCheck&gt;**](EditCheck.md) | Per-file checks after each edit; null uses the ones agnts derives from the toolchains | [optional] 
**editChecksOff** | **bool** |  | [optional] 
**coverage** | [**CoverageConfig**](CoverageConfig.md) |  | [optional] 
**acceptance** | **bool** | Check the ticket's acceptance criteria in the running app after the preview | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


