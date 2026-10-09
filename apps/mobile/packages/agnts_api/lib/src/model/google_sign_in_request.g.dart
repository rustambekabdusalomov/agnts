// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_sign_in_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GoogleSignInRequestCWProxy {
  GoogleSignInRequest idToken(String idToken);

  GoogleSignInRequest invite(String? invite);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GoogleSignInRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GoogleSignInRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  GoogleSignInRequest call({String idToken, String? invite});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGoogleSignInRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGoogleSignInRequest.copyWith.fieldName(...)`
class _$GoogleSignInRequestCWProxyImpl implements _$GoogleSignInRequestCWProxy {
  const _$GoogleSignInRequestCWProxyImpl(this._value);

  final GoogleSignInRequest _value;

  @override
  GoogleSignInRequest idToken(String idToken) => this(idToken: idToken);

  @override
  GoogleSignInRequest invite(String? invite) => this(invite: invite);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GoogleSignInRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GoogleSignInRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  GoogleSignInRequest call({
    Object? idToken = const $CopyWithPlaceholder(),
    Object? invite = const $CopyWithPlaceholder(),
  }) {
    return GoogleSignInRequest(
      idToken: idToken == const $CopyWithPlaceholder()
          ? _value.idToken
          // ignore: cast_nullable_to_non_nullable
          : idToken as String,
      invite: invite == const $CopyWithPlaceholder()
          ? _value.invite
          // ignore: cast_nullable_to_non_nullable
          : invite as String?,
    );
  }
}

extension $GoogleSignInRequestCopyWith on GoogleSignInRequest {
  /// Returns a callable class that can be used as follows: `instanceOfGoogleSignInRequest.copyWith(...)` or like so:`instanceOfGoogleSignInRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GoogleSignInRequestCWProxy get copyWith =>
      _$GoogleSignInRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleSignInRequest _$GoogleSignInRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('GoogleSignInRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['idToken']);
      final val = GoogleSignInRequest(
        idToken: $checkedConvert('idToken', (v) => v as String),
        invite: $checkedConvert('invite', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$GoogleSignInRequestToJson(
  GoogleSignInRequest instance,
) => <String, dynamic>{'idToken': instance.idToken, 'invite': ?instance.invite};
