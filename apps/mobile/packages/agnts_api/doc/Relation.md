# agnts_api.model.Relation

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | 
**type** | [**RelationType**](RelationType.md) |  | 
**direction** | **String** | From the ticket asked about: it waits for other, other waits for it, or they conflict | 
**source_** | **String** | Who found it: a Jira link, a person, the analysis, overlapping footprints, or the finished diffs (when nobody predicted it) | 
**status** | **String** | Only active relations hold the queue; proposed ones wait for a person | 
**confidence** | **double** |  | 
**reason** | **String** |  | 
**basis** | **String** | For rule and git relations: files, migrations, lockfile, codegen, i18n or diff | 
**files** | **List&lt;String&gt;** | Files both tickets change, when known | 
**other** | [**RelatedTicket**](RelatedTicket.md) |  | 
**confirmedAt** | [**DateTime**](DateTime.md) | When the finished changes proved the conflict real | [optional] 
**decidedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


