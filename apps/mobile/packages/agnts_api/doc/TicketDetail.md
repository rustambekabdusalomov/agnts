# agnts_api.model.TicketDetail

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**ticket** | [**Ticket**](Ticket.md) |  | 
**questions** | [**List&lt;Question&gt;**](Question.md) |  | 
**attachments** | [**List&lt;Attachment&gt;**](Attachment.md) | Files attached to the task, its answers and retry notes, oldest first | 
**analysis** | [**Analysis**](Analysis.md) |  | [optional] 
**result** | [**Result**](Result.md) |  | [optional] 
**childKey** | **String** | The code task that implements this report, if any | [optional] 
**followUps** | [**FollowUps**](FollowUps.md) |  | [optional] 
**relations** | [**Relations**](Relations.md) |  | [optional] 
**review** | [**CodeReview**](CodeReview.md) |  | [optional] 
**preview** | [**TicketPreview**](TicketPreview.md) |  | [optional] 
**history** | [**List&lt;HistoryItem&gt;**](HistoryItem.md) |  | [optional] 
**maxTurns** | **int** |  | [optional] 
**effectiveModels** | [**StageModels**](StageModels.md) |  | [optional] 
**spendByStage** | [**List&lt;StageSpend&gt;**](StageSpend.md) | Empty until a Claude run is recorded | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


