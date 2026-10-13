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
**autoBrief** | **bool** | Survey a repository without a brief when its first ticket is analysed, and refresh the brief after merges | [optional] 
**selfReview** | **bool** | Send blocker and major findings of agnts's code review back to the coder once per revision, before a person reviews | [optional] 
**reflect** | **bool** | Learn from change requests and rejections: suggest rules, which apply once someone adopts them | [optional] 
**egressAllow** | **List&lt;String&gt;** | Hosts run containers may reach besides the built-in list, such as a staging API; .example.com matches subdomains | [optional] 
**suggestFollowUps** | **bool** | Runs suggest follow-up tickets (off by default; a ticket can override it) | [optional] 
**pullReviews** | [**PullReviewSettings**](PullReviewSettings.md) |  | [optional] 
**ci** | [**CISettings**](CISettings.md) |  | [optional] 
**guard** | [**GuardSettings**](GuardSettings.md) |  | [optional] 
**stalls** | **String** | What agnts does when a run looks stuck: nothing, note it on the ticket, or also tell Claude to step back (once per run) | [optional] 
**proveFixes** | **bool** | Bug fixes need a test that fails before the change and passes after it; agnts checks it | [optional] 
**methodSkills** | **bool** | Coding runs get agnts's method skills: add one more of something the way the repository does, follow its style, reuse before writing, change a schema safely | [optional] 
**deepReview** | **String** | Specialist passes in the code review (security, silent failures, tests, types); auto: large or complex work | [optional] 
**learnFromRuns** | **bool** | Suggest tips from runs that had trouble (failed checks, a stall) | [optional] 
**secondOpinion** | **String** | A model that critiques the chosen approach of complex tickets (codex:<model> or a Claude model); empty turns it off | [optional] 
**pauseAbove** | **int** |  | 
**parallel** | **int** |  | 
**git** | [**GitSettings**](GitSettings.md) |  | 
**notify** | [**NotifySettings**](NotifySettings.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


