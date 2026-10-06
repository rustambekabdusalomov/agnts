# agnts_api.model.Settings

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**models** | [**StageModels**](StageModels.md) |  | 
**maxTurns** | **int** |  | 
**timeoutMin** | **int** |  | 
**allow** | **List&lt;String&gt;** |  | 
**deny** | **List&lt;String&gt;** |  | 
**askFirst** | **bool** |  | 
**autoResume** | **bool** |  | 
**autoLearn** | **bool** | Learn from every pushed ticket | [optional] 
**autoReview** | **bool** | Review every result while it waits for review | [optional] 
**autoPreview** | **bool** | Take screenshots of every UI change in repositories with a preview command | [optional] 
**visualCheck** | **bool** | Coding runs may start the app and look at the pages they changed | [optional] 
**egressAllow** | **List&lt;String&gt;** | Hosts run containers may reach besides the built-in list, such as a staging API; .example.com matches subdomains | [optional] 
**suggestFollowUps** | **bool** | Runs suggest follow-up tickets (off by default; a ticket can override it) | [optional] 
**pauseAbove** | **int** |  | 
**parallel** | **int** |  | 
**git** | [**GitSettings**](GitSettings.md) |  | 
**notify** | [**NotifySettings**](NotifySettings.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


