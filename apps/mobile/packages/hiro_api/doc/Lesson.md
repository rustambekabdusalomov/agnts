# hiro_api.model.Lesson

## Load the model package
```dart
import 'package:hiro_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | 
**repoId** | **int** |  | 
**repoName** | **String** |  | 
**ticketKey** | **String** |  | 
**slug** | **String** |  | 
**title** | **String** |  | 
**category** | [**LessonCategory**](LessonCategory.md) |  | 
**level** | [**LessonLevel**](LessonLevel.md) |  | 
**summary** | **String** |  | 
**explanation** | **String** | Plain text; paragraphs are separated by blank lines | 
**whyHere** | **String** | Why this change needed it | 
**readMinutes** | **int** | Estimated minutes to read the lesson and take its quiz | 
**refs** | [**List&lt;LessonRef&gt;**](LessonRef.md) |  | 
**quiz** | [**List&lt;QuizQuestion&gt;**](QuizQuestion.md) |  | 
**reading** | [**List&lt;Link&gt;**](Link.md) |  | 
**learnedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


