# hiro_api.model.LocalBranch

## Load the model package
```dart
import 'package:hiro_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**name** | **String** |  | 
**sha** | **String** |  | 
**message** | **String** |  | 
**author** | **String** |  | 
**date** | [**DateTime**](DateTime.md) |  | [optional] 
**ahead** | **int** | Commits not on the default branch | 
**behind** | **int** | Default branch commits the branch lacks | 
**status** | **String** | local: not on origin; pushed: origin has the same commit; unpushed: origin is behind; differs: origin has commits the local branch lacks | 
**unpushed** | **int** | Commits origin lacks (status unpushed) | 
**ticketKey** | **String** |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


