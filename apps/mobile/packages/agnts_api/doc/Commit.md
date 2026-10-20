# agnts_api.model.Commit

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**sha** | **String** |  | 
**message** | **String** |  | 
**author** | **String** |  | 
**date** | [**DateTime**](DateTime.md) |  | [optional] 
**add** | **int** |  | 
**del** | **int** |  | 
**ci** | [**CI**](CI.md) |  | 
**url** | **String** |  | [optional] 
**ticketKey** | **String** | The first linked ticket's key, else the KEY-1 before the message's colon | [optional] 
**tickets** | [**List&lt;CommitTicket&gt;**](CommitTicket.md) | The tickets the commit is linked to | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


