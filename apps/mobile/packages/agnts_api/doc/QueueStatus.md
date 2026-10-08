# agnts_api.model.QueueStatus

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**running** | **int** |  | 
**slots** | **int** |  | 
**waiting** | [**QueueStatusWaiting**](QueueStatusWaiting.md) |  | 
**serverQueue** | [**List&lt;QueueStatusServerQueueInner&gt;**](QueueStatusServerQueueInner.md) | The workspace's tickets waiting for the server | 
**serverQueueLength** | **int** |  | 
**capacity** | [**Capacity**](Capacity.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


