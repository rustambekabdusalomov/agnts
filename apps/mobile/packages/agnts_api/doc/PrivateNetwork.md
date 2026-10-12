# agnts_api.model.PrivateNetwork

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
**enabled** | **bool** |  | 
**summary** | **String** | The config without its keys, e.g. peer vpn.corp.com:51820 | [optional] 
**routes** | [**List&lt;NetworkRoute&gt;**](NetworkRoute.md) |  | 
**ca** | [**PrivateNetworkCa**](PrivateNetworkCa.md) |  | [optional] 
**status** | **String** |  | 
**lastError** | **String** |  | [optional] 
**upAt** | [**DateTime**](DateTime.md) |  | [optional] 
**handshakeAt** | [**DateTime**](DateTime.md) | WireGuard's last handshake, or agnts-link's last heartbeat | [optional] 
**detail** | **String** |  | [optional] 
**tokenSet** | **bool** | An agnts-link token exists | 
**webhooks** | **String** | relay — agnts-link forwards webhooks; polling — trackers reached through it are read every pollMinutes | 
**pollMinutes** | **int** |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


