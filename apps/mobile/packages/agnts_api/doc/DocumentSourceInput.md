# agnts_api.model.DocumentSourceInput

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**kind** | **String** |  | 
**template** | **String** | Defaults by kind | [optional] 
**documentId** | **int** |  | [optional] 
**documentVersion** | **int** |  | [optional] 
**instruction** | **String** |  | [optional] 
**tickets** | **List&lt;String&gt;** |  | [optional] 
**filter** | [**DocumentSourceInputFilter**](DocumentSourceInputFilter.md) |  | [optional] 
**repoIds** | **List&lt;int&gt;** |  | [optional] 
**branch** | **String** |  | [optional] 
**author** | **String** |  | [optional] 
**prState** | **String** |  | [optional] 
**prNumbers** | **List&lt;int&gt;** |  | [optional] 
**from** | [**DateTime**](DateTime.md) |  | [optional] 
**to** | [**DateTime**](DateTime.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


