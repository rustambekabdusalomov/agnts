# agnts_api.model.RequestChangesRequest

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**feedback** | **String** |  | 
**shots** | [**List&lt;ShotRef&gt;**](ShotRef.md) | Preview screenshots the feedback points at; the coding run gets them | [optional] 
**attachments** | **List&lt;int&gt;** | Uploads that go with the feedback (mockups, logs, screenshots); the coding run reads them | [optional] 
**skipChecks** | **bool** | Skip the build, lint and test checks (and the proof and coverage that run tests) in this and later coding runs of the ticket, going to review on the code alone; false turns them back on. Left out, the ticket keeps its setting. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


