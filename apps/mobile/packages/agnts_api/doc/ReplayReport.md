# agnts_api.model.ReplayReport

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**versions** | [**List&lt;ReplayVersion&gt;**](ReplayVersion.md) | Replays with a change, summed by the prompt version and coding model they ran with | 
**benchmark** | [**List&lt;ReplayVersion&gt;**](ReplayVersion.md) | The same, for the replays of tickets in the benchmark only | [optional] 
**replays** | [**List&lt;ReplayResult&gt;**](ReplayResult.md) | The newest replays first | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


