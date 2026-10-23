# agnts_api.model.DocumentSummary

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | 
**kind** | [**DocumentKind**](DocumentKind.md) |  | 
**title** | **String** |  | 
**version** | **int** | The current version; 0 while agnts writes the first one | 
**type** | **String** |  | 
**workspaceAccess** | **String** | Everyone in the workspace gets at least this | 
**ownerId** | **int** |  | 
**ownerName** | **String** |  | 
**language** | **String** |  | 
**access** | [**DocumentAccess**](DocumentAccess.md) |  | 
**ticketCount** | **int** |  | 
**generation** | [**DocumentGeneration**](DocumentGeneration.md) |  | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 
**deletedAt** | [**DateTime**](DateTime.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


