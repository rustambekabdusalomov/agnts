# agnts_api.model.ModelCatalogModelsInner

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | muse:<model> for Muse Code (muse:spark, muse:wonder), a Claude model (haiku, sonnet, opus), codex:<model> for Codex CLI, or a tier (tier:light, tier:strong): the light or strong model of the module the run lands on. listModels says which this server offers. | 
**label** | **String** |  | 
**provider** | **String** |  | 
**strong** | **bool** | The stronger, dearer tier | 
**inputPerMillionUSD** | **num** |  | [optional] 
**outputPerMillionUSD** | **num** |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


