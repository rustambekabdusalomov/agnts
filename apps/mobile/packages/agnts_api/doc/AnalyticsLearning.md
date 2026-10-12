# agnts_api.model.AnalyticsLearning

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**days** | **int** |  | 
**current** | [**LearningPeriod**](LearningPeriod.md) |  | 
**previous** | [**LearningPeriod**](LearningPeriod.md) |  | 
**lessons** | [**List&lt;LessonCount&gt;**](LessonCount.md) |  | 
**followUpTypes** | [**List&lt;FollowUpCount&gt;**](FollowUpCount.md) | Follow-ups suggested in the period by type (prerequisite, split, unfinished, gap) | 
**followUpSources** | [**List&lt;FollowUpCount&gt;**](FollowUpCount.md) | Follow-ups suggested in the period by source (analyze, work, review, manual) | 
**reviewers** | [**List&lt;ReviewerStat&gt;**](ReviewerStat.md) | Reviewers with the most notes in the period | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


