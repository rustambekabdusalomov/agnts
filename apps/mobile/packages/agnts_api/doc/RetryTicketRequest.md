# agnts_api.model.RetryTicketRequest

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**note** | **String** | How to get past the failure. The next coding run gets it with the error, like requested changes. Not allowed when the ticket resumes at pushing, since no Claude run follows. | [optional] 
**attachments** | **List&lt;int&gt;** | Uploads that help get past the failure; the next coding run reads them. Same rule as note. | [optional] 
**skipChecks** | **bool** | Skip the build, lint and test checks (and the proof and coverage that run tests) in this and later coding runs of the ticket, going to review on the code alone; false turns them back on. Left out, the ticket keeps its setting. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


