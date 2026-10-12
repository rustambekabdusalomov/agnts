# agnts_api.api.NetworkApi

## Load the API package
```dart
import 'package:agnts_api/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createPrivateNetwork**](NetworkApi.md#createprivatenetwork) | **POST** /networks | Add a private network
[**deletePrivateNetwork**](NetworkApi.md#deleteprivatenetwork) | **DELETE** /networks/{networkId} | Remove a private network
[**getNetworkActivity**](NetworkApi.md#getnetworkactivity) | **GET** /networks/activity | Connections made through private networks (the last 100, and the day&#39;s counts)
[**getPrivateNetwork**](NetworkApi.md#getprivatenetwork) | **GET** /networks/{networkId} | One private network
[**listPrivateNetworks**](NetworkApi.md#listprivatenetworks) | **GET** /networks | The workspace&#39;s private networks (VPNs and agnts-link connectors)
[**reconnectPrivateNetwork**](NetworkApi.md#reconnectprivatenetwork) | **POST** /networks/{networkId}/reconnect | Restart the tunnel (a new OpenVPN sidecar, a new WireGuard handshake, agnts-link reconnects)
[**rotateLinkToken**](NetworkApi.md#rotatelinktoken) | **POST** /networks/{networkId}/token | Make a new agnts-link token for a connector network (shown once; the old one stops working)
[**testPrivateNetwork**](NetworkApi.md#testprivatenetwork) | **POST** /networks/test | Connect to host:port through the network its routes pick, and check its TLS certificate
[**updatePrivateNetwork**](NetworkApi.md#updateprivatenetwork) | **PUT** /networks/{networkId} | Change a private network


# **createPrivateNetwork**
> PrivateNetworkSaved createPrivateNetwork(privateNetworkInput)

Add a private network

Its routes may not claim a host, domain or range another of the workspace's networks has (on a common port); a route nested inside another network's is fine. A connector's token is returned once. 

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getNetworkApi();
final PrivateNetworkInput privateNetworkInput = ; // PrivateNetworkInput | 

try {
    final response = api.createPrivateNetwork(privateNetworkInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling NetworkApi->createPrivateNetwork: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **privateNetworkInput** | [**PrivateNetworkInput**](PrivateNetworkInput.md)|  | 

### Return type

[**PrivateNetworkSaved**](PrivateNetworkSaved.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deletePrivateNetwork**
> deletePrivateNetwork(networkId)

Remove a private network

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getNetworkApi();
final int networkId = 789; // int | 

try {
    api.deletePrivateNetwork(networkId);
} on DioException catch (e) {
    print('Exception when calling NetworkApi->deletePrivateNetwork: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **networkId** | **int**|  | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getNetworkActivity**
> NetworkActivity getNetworkActivity(network)

Connections made through private networks (the last 100, and the day's counts)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getNetworkApi();
final int network = 789; // int | Only this network's connections

try {
    final response = api.getNetworkActivity(network);
    print(response);
} on DioException catch (e) {
    print('Exception when calling NetworkApi->getNetworkActivity: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **network** | **int**| Only this network's connections | [optional] 

### Return type

[**NetworkActivity**](NetworkActivity.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPrivateNetwork**
> PrivateNetwork getPrivateNetwork(networkId)

One private network

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getNetworkApi();
final int networkId = 789; // int | 

try {
    final response = api.getPrivateNetwork(networkId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling NetworkApi->getPrivateNetwork: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **networkId** | **int**|  | 

### Return type

[**PrivateNetwork**](PrivateNetwork.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPrivateNetworks**
> PrivateNetworkList listPrivateNetworks()

The workspace's private networks (VPNs and agnts-link connectors)

Tunnels into the team's own networks and the routes (hosts, domains, private ranges) that go through each: agnts's calls to a self-hosted GitLab, Jira or Plane, git, and run containers' connections to those hosts. A connection goes through the network whose route matches it most closely. Secrets are never returned. 

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getNetworkApi();

try {
    final response = api.listPrivateNetworks();
    print(response);
} on DioException catch (e) {
    print('Exception when calling NetworkApi->listPrivateNetworks: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**PrivateNetworkList**](PrivateNetworkList.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **reconnectPrivateNetwork**
> PrivateNetwork reconnectPrivateNetwork(networkId)

Restart the tunnel (a new OpenVPN sidecar, a new WireGuard handshake, agnts-link reconnects)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getNetworkApi();
final int networkId = 789; // int | 

try {
    final response = api.reconnectPrivateNetwork(networkId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling NetworkApi->reconnectPrivateNetwork: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **networkId** | **int**|  | 

### Return type

[**PrivateNetwork**](PrivateNetwork.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rotateLinkToken**
> RotateMcpToken200Response rotateLinkToken(networkId)

Make a new agnts-link token for a connector network (shown once; the old one stops working)

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getNetworkApi();
final int networkId = 789; // int | 

try {
    final response = api.rotateLinkToken(networkId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling NetworkApi->rotateLinkToken: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **networkId** | **int**|  | 

### Return type

[**RotateMcpToken200Response**](RotateMcpToken200Response.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **testPrivateNetwork**
> NetworkTest testPrivateNetwork(testPrivateNetworkRequest)

Connect to host:port through the network its routes pick, and check its TLS certificate

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getNetworkApi();
final TestPrivateNetworkRequest testPrivateNetworkRequest = ; // TestPrivateNetworkRequest | 

try {
    final response = api.testPrivateNetwork(testPrivateNetworkRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling NetworkApi->testPrivateNetwork: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **testPrivateNetworkRequest** | [**TestPrivateNetworkRequest**](TestPrivateNetworkRequest.md)|  | 

### Return type

[**NetworkTest**](NetworkTest.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updatePrivateNetwork**
> PrivateNetworkSaved updatePrivateNetwork(networkId, privateNetworkInput)

Change a private network

Left-out secrets (config, password) keep the stored ones. Switching to a connector makes its token, returned once. 

### Example
```dart
import 'package:agnts_api/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AgntsApi().getNetworkApi();
final int networkId = 789; // int | 
final PrivateNetworkInput privateNetworkInput = ; // PrivateNetworkInput | 

try {
    final response = api.updatePrivateNetwork(networkId, privateNetworkInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling NetworkApi->updatePrivateNetwork: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **networkId** | **int**|  | 
 **privateNetworkInput** | [**PrivateNetworkInput**](PrivateNetworkInput.md)|  | 

### Return type

[**PrivateNetworkSaved**](PrivateNetworkSaved.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

