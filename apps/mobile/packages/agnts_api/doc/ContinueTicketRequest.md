# agnts_api.model.ContinueTicketRequest

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**note** | **String** | What to do differently. The next coding run gets it, like requested changes. Not allowed when the ticket goes back to answers or to a failed state, since no Claude run follows. | [optional] 
**attachments** | **List&lt;int&gt;** | Uploads that go with the note; the next coding run reads them. Same rule as note. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


