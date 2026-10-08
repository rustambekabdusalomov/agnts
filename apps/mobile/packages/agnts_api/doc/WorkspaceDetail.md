# agnts_api.model.WorkspaceDetail

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | 
**slug** | **String** |  | 
**name** | **String** |  | 
**role** | [**WorkspaceRole**](WorkspaceRole.md) |  | 
**ownerId** | **int** |  | 
**plan** | **String** |  | 
**slots** | **int** |  | 
**memberLimit** | **int** | 0 means no limit | 
**members** | **int** |  | 
**claudeMode** | **String** |  | 
**claudeFallback** | **bool** |  | 
**defaultMemberId** | **int** |  | [optional] 
**creditsBalance** | **int** |  | 
**trialEndsAt** | [**DateTime**](DateTime.md) |  | [optional] 
**suspended** | **bool** |  | [optional] 
**deletedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


