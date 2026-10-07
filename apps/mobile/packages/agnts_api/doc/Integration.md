# agnts_api.model.Integration

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**provider** | **String** |  | 
**connected** | **bool** |  | 
**checkedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**account** | **String** |  | [optional] 
**tokenHint** | **String** | Last four characters | [optional] 
**lastError** | **String** |  | [optional] 
**settings** | **Map&lt;String, String&gt;** |  | 
**webhookUrl** | **String** |  | [optional] 
**webhookSecret** | **String** | GitHub and GitLab: secret to enter in the webhook settings | [optional] 
**webhookSecretSet** | **bool** | Plane: a webhook secret is stored (deliveries are accepted) | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


