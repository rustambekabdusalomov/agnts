# agnts_api.model.MuseProvider

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**mode** | [**MuseProviderMode**](MuseProviderMode.md) |  | 
**fallback** | [**MuseProviderFallback**](MuseProviderFallback.md) |  | [optional] 
**primaryOutUntil** | [**DateTime**](DateTime.md) | agnts's Meta account ran out; in auto mode runs go to the fallback until then | [optional] 
**primaryOutReason** | **String** |  | [optional] 
**setAt** | [**DateTime**](DateTime.md) | When an Admin last chose the mode | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


