# agnts_api.model.PostReviewInput

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**summary** | **bool** | Post the summary (verdict and every finding) | [optional] [default to true]
**findings** | **List&lt;int&gt;** | Indexes of the findings to post on their lines; left out, every finding on a line of the diff | [optional] 
**requestChanges** | **bool** | Post it as a request for changes (GitHub) | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


