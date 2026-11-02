# agnts_api.model.LogService

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | [optional] 
**name** | **String** |  | 
**selector** | **String** | Loki: a matcher like {app=\"api\"}; Elasticsearch: the service field's value; Graylog: a stream id | 
**repoIds** | **List&lt;int&gt;** | The repositories the service runs on; none means its findings are only reported | 
**groupId** | **int** |  | [optional] 
**enabled** | **bool** |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


