// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'decide_consent_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DecideConsentRequestCWProxy {
  DecideConsentRequest clientId(String clientId);

  DecideConsentRequest redirectUri(String redirectUri);

  DecideConsentRequest codeChallenge(String codeChallenge);

  DecideConsentRequest codeChallengeMethod(String codeChallengeMethod);

  DecideConsentRequest state(String? state);

  DecideConsentRequest resource(String? resource);

  DecideConsentRequest approve(bool approve);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DecideConsentRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DecideConsentRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  DecideConsentRequest call({
    String clientId,
    String redirectUri,
    String codeChallenge,
    String codeChallengeMethod,
    String? state,
    String? resource,
    bool approve,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDecideConsentRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDecideConsentRequest.copyWith.fieldName(...)`
class _$DecideConsentRequestCWProxyImpl
    implements _$DecideConsentRequestCWProxy {
  const _$DecideConsentRequestCWProxyImpl(this._value);

  final DecideConsentRequest _value;

  @override
  DecideConsentRequest clientId(String clientId) => this(clientId: clientId);

  @override
  DecideConsentRequest redirectUri(String redirectUri) =>
      this(redirectUri: redirectUri);

  @override
  DecideConsentRequest codeChallenge(String codeChallenge) =>
      this(codeChallenge: codeChallenge);

  @override
  DecideConsentRequest codeChallengeMethod(String codeChallengeMethod) =>
      this(codeChallengeMethod: codeChallengeMethod);

  @override
  DecideConsentRequest state(String? state) => this(state: state);

  @override
  DecideConsentRequest resource(String? resource) => this(resource: resource);

  @override
  DecideConsentRequest approve(bool approve) => this(approve: approve);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DecideConsentRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DecideConsentRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  DecideConsentRequest call({
    Object? clientId = const $CopyWithPlaceholder(),
    Object? redirectUri = const $CopyWithPlaceholder(),
    Object? codeChallenge = const $CopyWithPlaceholder(),
    Object? codeChallengeMethod = const $CopyWithPlaceholder(),
    Object? state = const $CopyWithPlaceholder(),
    Object? resource = const $CopyWithPlaceholder(),
    Object? approve = const $CopyWithPlaceholder(),
  }) {
    return DecideConsentRequest(
      clientId: clientId == const $CopyWithPlaceholder()
          ? _value.clientId
          // ignore: cast_nullable_to_non_nullable
          : clientId as String,
      redirectUri: redirectUri == const $CopyWithPlaceholder()
          ? _value.redirectUri
          // ignore: cast_nullable_to_non_nullable
          : redirectUri as String,
      codeChallenge: codeChallenge == const $CopyWithPlaceholder()
          ? _value.codeChallenge
          // ignore: cast_nullable_to_non_nullable
          : codeChallenge as String,
      codeChallengeMethod: codeChallengeMethod == const $CopyWithPlaceholder()
          ? _value.codeChallengeMethod
          // ignore: cast_nullable_to_non_nullable
          : codeChallengeMethod as String,
      state: state == const $CopyWithPlaceholder()
          ? _value.state
          // ignore: cast_nullable_to_non_nullable
          : state as String?,
      resource: resource == const $CopyWithPlaceholder()
          ? _value.resource
          // ignore: cast_nullable_to_non_nullable
          : resource as String?,
      approve: approve == const $CopyWithPlaceholder()
          ? _value.approve
          // ignore: cast_nullable_to_non_nullable
          : approve as bool,
    );
  }
}

extension $DecideConsentRequestCopyWith on DecideConsentRequest {
  /// Returns a callable class that can be used as follows: `instanceOfDecideConsentRequest.copyWith(...)` or like so:`instanceOfDecideConsentRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DecideConsentRequestCWProxy get copyWith =>
      _$DecideConsentRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DecideConsentRequest _$DecideConsentRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DecideConsentRequest', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'clientId',
      'redirectUri',
      'codeChallenge',
      'codeChallengeMethod',
      'approve',
    ],
  );
  final val = DecideConsentRequest(
    clientId: $checkedConvert('clientId', (v) => v as String),
    redirectUri: $checkedConvert('redirectUri', (v) => v as String),
    codeChallenge: $checkedConvert('codeChallenge', (v) => v as String),
    codeChallengeMethod: $checkedConvert(
      'codeChallengeMethod',
      (v) => v as String,
    ),
    state: $checkedConvert('state', (v) => v as String?),
    resource: $checkedConvert('resource', (v) => v as String?),
    approve: $checkedConvert('approve', (v) => v as bool),
  );
  return val;
});

Map<String, dynamic> _$DecideConsentRequestToJson(
  DecideConsentRequest instance,
) => <String, dynamic>{
  'clientId': instance.clientId,
  'redirectUri': instance.redirectUri,
  'codeChallenge': instance.codeChallenge,
  'codeChallengeMethod': instance.codeChallengeMethod,
  'state': ?instance.state,
  'resource': ?instance.resource,
  'approve': instance.approve,
};
