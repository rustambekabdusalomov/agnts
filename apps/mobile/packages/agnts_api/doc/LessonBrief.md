# agnts_api.model.LessonBrief

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | 
**repoId** | **int** |  | 
**repoName** | **String** |  | 
**ticketKey** | **String** |  | 
**slug** | **String** | Concept id, unique per repository | 
**title** | **String** |  | 
**category** | [**LessonCategory**](LessonCategory.md) |  | 
**level** | [**LessonLevel**](LessonLevel.md) |  | 
**summary** | **String** |  | 
**quizCount** | **int** |  | 
**readMinutes** | **int** | Estimated minutes to read the lesson and take its quiz | 
**learnedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


