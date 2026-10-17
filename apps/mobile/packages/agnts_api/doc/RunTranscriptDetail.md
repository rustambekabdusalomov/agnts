# agnts_api.model.RunTranscriptDetail

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**transcript** | [**RunTranscript**](RunTranscript.md) |  | 
**events** | [**List&lt;RunTranscriptEvent&gt;**](RunTranscriptEvent.md) |  | 
**siblings** | [**List&lt;RunTranscript&gt;**](RunTranscript.md) | The run's other invocations (first pass, fix attempts, second opinion), oldest first | 
**unreadable** | **bool** | Part of the stored body could not be read; events holds what could | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


