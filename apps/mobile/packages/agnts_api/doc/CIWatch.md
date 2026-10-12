# agnts_api.model.CIWatch

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**enabled** | **bool** |  | 
**branches** | **List&lt;String&gt;** | Globs of extra watched branches; the default branch is always watched | 
**ignore** | **List&lt;String&gt;** | Globs of workflow or job names never watched | 
**prs** | **String** | Failures on other people's pull requests: off (ignore) or comment (post one diagnosis comment) | 
**autoFix** | **bool** | Overrides the workspace setting for this repository; null follows it | [optional] 
**problem** | **String** | Why agnts cannot read this repository's CI with the current token, or empty | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


