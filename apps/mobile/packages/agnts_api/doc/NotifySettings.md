# agnts_api.model.NotifySettings

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**push** | **bool** |  | 
**telegram** | **bool** |  | 
**needsYou** | **bool** |  | 
**stopped** | **bool** |  | 
**done** | **bool** |  | 
**progress** | **bool** | An agent finished a step (analysis, code); push only, silent | [optional] 
**lessons** | **bool** | New lessons were found | [optional] 
**review** | **bool** | A code review finished | [optional] 
**preview** | **bool** | Preview screenshots are ready | [optional] 
**previewPhotos** | **bool** | Send phone screenshots to Telegram with the message | [optional] 
**followUps** | **bool** | Follow-up tickets were suggested | [optional] 
**ci** | **bool** | A watched branch went red | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


