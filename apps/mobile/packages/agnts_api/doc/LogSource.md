# agnts_api.model.LogSource

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | 
**name** | **String** |  | 
**kind** | **String** |  | 
**environment** | **String** |  | 
**address** | **String** |  | 
**authKind** | **String** |  | 
**authUser** | **String** |  | [optional] 
**authTenant** | **String** |  | [optional] 
**hasAuth** | **bool** |  | 
**caPem** | **String** |  | 
**scope** | [**LogScope**](LogScope.md) |  | 
**fields** | [**LogFields**](LogFields.md) |  | 
**pollSeconds** | **int** |  | 
**enabled** | **bool** |  | 
**status** | **String** |  | 
**lastError** | **String** |  | 
**lastReadAt** | [**DateTime**](DateTime.md) |  | [optional] 
**gapFrom** | [**DateTime**](DateTime.md) | Start of a range not read after a long outage | [optional] 
**gapTo** | [**DateTime**](DateTime.md) |  | [optional] 
**dropped** | **int** | Entries skipped over the per-minute cap | 
**networkId** | **int** | The private network the last read went through | [optional] 
**hasPushToken** | **bool** |  | 
**pushUrl** | **String** | Where a push source's shipper sends | [optional] 
**services** | [**List&lt;LogService&gt;**](LogService.md) |  | 
**createdAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


