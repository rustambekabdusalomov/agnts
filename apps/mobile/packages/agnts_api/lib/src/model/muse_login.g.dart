// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'muse_login.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MuseLoginCWProxy {
  MuseLogin id(String id);

  MuseLogin userCode(String userCode);

  MuseLogin verificationUri(String verificationUri);

  MuseLogin verificationUriComplete(String? verificationUriComplete);

  MuseLogin expiresAt(DateTime expiresAt);

  MuseLogin status(MuseLoginStatusEnum status);

  MuseLogin error(String? error);

  MuseLogin account(String? account);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MuseLogin(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MuseLogin(...).copyWith(id: 12, name: "My name")
  /// ````
  MuseLogin call({
    String id,
    String userCode,
    String verificationUri,
    String? verificationUriComplete,
    DateTime expiresAt,
    MuseLoginStatusEnum status,
    String? error,
    String? account,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMuseLogin.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMuseLogin.copyWith.fieldName(...)`
class _$MuseLoginCWProxyImpl implements _$MuseLoginCWProxy {
  const _$MuseLoginCWProxyImpl(this._value);

  final MuseLogin _value;

  @override
  MuseLogin id(String id) => this(id: id);

  @override
  MuseLogin userCode(String userCode) => this(userCode: userCode);

  @override
  MuseLogin verificationUri(String verificationUri) =>
      this(verificationUri: verificationUri);

  @override
  MuseLogin verificationUriComplete(String? verificationUriComplete) =>
      this(verificationUriComplete: verificationUriComplete);

  @override
  MuseLogin expiresAt(DateTime expiresAt) => this(expiresAt: expiresAt);

  @override
  MuseLogin status(MuseLoginStatusEnum status) => this(status: status);

  @override
  MuseLogin error(String? error) => this(error: error);

  @override
  MuseLogin account(String? account) => this(account: account);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MuseLogin(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MuseLogin(...).copyWith(id: 12, name: "My name")
  /// ````
  MuseLogin call({
    Object? id = const $CopyWithPlaceholder(),
    Object? userCode = const $CopyWithPlaceholder(),
    Object? verificationUri = const $CopyWithPlaceholder(),
    Object? verificationUriComplete = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
    Object? account = const $CopyWithPlaceholder(),
  }) {
    return MuseLogin(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      userCode: userCode == const $CopyWithPlaceholder()
          ? _value.userCode
          // ignore: cast_nullable_to_non_nullable
          : userCode as String,
      verificationUri: verificationUri == const $CopyWithPlaceholder()
          ? _value.verificationUri
          // ignore: cast_nullable_to_non_nullable
          : verificationUri as String,
      verificationUriComplete:
          verificationUriComplete == const $CopyWithPlaceholder()
          ? _value.verificationUriComplete
          // ignore: cast_nullable_to_non_nullable
          : verificationUriComplete as String?,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as MuseLoginStatusEnum,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as String?,
      account: account == const $CopyWithPlaceholder()
          ? _value.account
          // ignore: cast_nullable_to_non_nullable
          : account as String?,
    );
  }
}

extension $MuseLoginCopyWith on MuseLogin {
  /// Returns a callable class that can be used as follows: `instanceOfMuseLogin.copyWith(...)` or like so:`instanceOfMuseLogin.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MuseLoginCWProxy get copyWith => _$MuseLoginCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MuseLogin _$MuseLoginFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MuseLogin', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'userCode',
          'verificationUri',
          'expiresAt',
          'status',
        ],
      );
      final val = MuseLogin(
        id: $checkedConvert('id', (v) => v as String),
        userCode: $checkedConvert('userCode', (v) => v as String),
        verificationUri: $checkedConvert('verificationUri', (v) => v as String),
        verificationUriComplete: $checkedConvert(
          'verificationUriComplete',
          (v) => v as String?,
        ),
        expiresAt: $checkedConvert(
          'expiresAt',
          (v) => DateTime.parse(v as String),
        ),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$MuseLoginStatusEnumEnumMap, v),
        ),
        error: $checkedConvert('error', (v) => v as String?),
        account: $checkedConvert('account', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$MuseLoginToJson(MuseLogin instance) => <String, dynamic>{
  'id': instance.id,
  'userCode': instance.userCode,
  'verificationUri': instance.verificationUri,
  'verificationUriComplete': ?instance.verificationUriComplete,
  'expiresAt': instance.expiresAt.toIso8601String(),
  'status': _$MuseLoginStatusEnumEnumMap[instance.status]!,
  'error': ?instance.error,
  'account': ?instance.account,
};

const _$MuseLoginStatusEnumEnumMap = {
  MuseLoginStatusEnum.pending: 'pending',
  MuseLoginStatusEnum.connected: 'connected',
  MuseLoginStatusEnum.denied: 'denied',
  MuseLoginStatusEnum.expired: 'expired',
  MuseLoginStatusEnum.failed: 'failed',
};
