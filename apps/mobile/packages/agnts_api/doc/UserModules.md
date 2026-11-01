# agnts_api.model.UserModules

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**own** | [**List&lt;Module&gt;**](Module.md) | The list an Admin set; absent or null follows the default | [optional] 
**effective** | [**List&lt;Module&gt;**](Module.md) | What the person may use now, in their order, the default module first | 
**order** | [**List&lt;Module&gt;**](Module.md) | The order the person put their modules in themselves; absent or null keeps the Admin's | [optional] 
**setAt** | [**DateTime**](DateTime.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


