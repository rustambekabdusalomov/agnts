# agnts_api.model.SecurityFinding

## Load the model package
```dart
import 'package:agnts_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | 
**repoId** | **int** |  | 
**repo** | **String** |  | 
**severity** | [**SecSeverity**](SecSeverity.md) |  | 
**category** | **String** |  | 
**source_** | **String** |  | 
**symbol** | **String** | The enclosing function | [optional] 
**status** | [**SecFindingStatus**](SecFindingStatus.md) |  | 
**title** | **String** |  | 
**cwe** | **String** |  | [optional] 
**owasp** | **String** |  | [optional] 
**location** | [**SecurityFindingLocation**](SecurityFindingLocation.md) |  | 
**tool** | **String** |  | [optional] 
**rules** | **List&lt;String&gt;** |  | 
**confidence** | **String** |  | 
**evidence** | **String** |  | [optional] 
**impact** | **String** |  | [optional] 
**fixExplanation** | **String** |  | [optional] 
**fixPatch** | **String** |  | [optional] 
**references** | **List&lt;String&gt;** |  | 
**package** | **String** |  | [optional] 
**version** | **String** |  | [optional] 
**ecosystem** | **String** |  | [optional] 
**fixedIn** | **String** |  | [optional] 
**advisories** | **List&lt;String&gt;** |  | [optional] 
**cvss** | **String** |  | [optional] 
**secretMask** | **String** | The secret's first characters; agnts never stores the value | [optional] 
**commit** | **String** |  | [optional] 
**note** | **String** | What the last recheck said | [optional] 
**ticketKey** | **String** |  | 
**ticketState** | [**TicketState**](TicketState.md) |  | [optional] 
**dismissReason** | **String** |  | 
**dismissNote** | **String** |  | 
**firstSeen** | [**DateTime**](DateTime.md) |  | 
**lastSeen** | [**DateTime**](DateTime.md) |  | 
**lastChecked** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


