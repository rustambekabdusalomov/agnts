# agnts_api.model.SkillStat

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**skill** | **String** | A method skill (agnts-method-…); empty for the tickets whose coding runs had no method skills | 
**tickets** | **int** | Tickets with a coding run that had the skill | 
**loaded** | **int** | Of those, tickets where Claude loaded it | 
**done** | **int** |  | 
**firstTry** | **int** | Done without a person asking for changes | 
**loadedDone** | **int** | Done, of the tickets where Claude loaded it | 
**loadedFirstTry** | **int** | Done first try, of the tickets where Claude loaded it | 
**findings** | **int** | Review findings the method skills target: architecture and maintainability, or any on a migration file | 
**tokens** | **num** | Average tokens of a done ticket, all stages | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


