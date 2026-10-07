# agnts_api.model.Toolchain

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**tool** | **String** | mise tool name: go, node, python, rust, java, dotnet, ruby, ... | 
**version** | **String** | Exact, a prefix (20, 3.12), latest, lts or system | 
**source_** | **String** | Where it was found: go.mod, .nvmrc, default, manual | [optional] 
**dir** | **String** | Subdirectory it was found in | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


