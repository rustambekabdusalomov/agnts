# agnts_api.model.PrivateNetworkInput

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**name** | **String** | Unique in the workspace, e.g. the company or office it reaches | 
**kind** | **String** |  | 
**enabled** | **bool** |  | 
**config** | **String** | The WireGuard or OpenVPN config; left out keeps the saved one | [optional] 
**username** | **String** | OpenVPN auth-user-pass | [optional] 
**password** | **String** | OpenVPN auth-user-pass; left out or empty keeps the saved one | [optional] 
**routes** | [**List&lt;NetworkRoute&gt;**](NetworkRoute.md) |  | 
**caPem** | **String** | Company CA certificates (PEM); \"\" removes them, left out keeps them | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


