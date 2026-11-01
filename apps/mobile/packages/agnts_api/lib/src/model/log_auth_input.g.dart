// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_auth_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LogAuthInputCWProxy {
  LogAuthInput kind(LogAuthInputKindEnum kind);

  LogAuthInput user(String? user);

  LogAuthInput password(String? password);

  LogAuthInput token(String? token);

  LogAuthInput tenant(String? tenant);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LogAuthInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LogAuthInput(...).copyWith(id: 12, name: "My name")
  /// ````
  LogAuthInput call({
    LogAuthInputKindEnum kind,
    String? user,
    String? password,
    String? token,
    String? tenant,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLogAuthInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLogAuthInput.copyWith.fieldName(...)`
class _$LogAuthInputCWProxyImpl implements _$LogAuthInputCWProxy {
  const _$LogAuthInputCWProxyImpl(this._value);

  final LogAuthInput _value;

  @override
  LogAuthInput kind(LogAuthInputKindEnum kind) => this(kind: kind);

  @override
  LogAuthInput user(String? user) => this(user: user);

  @override
  LogAuthInput password(String? password) => this(password: password);

  @override
  LogAuthInput token(String? token) => this(token: token);

  @override
  LogAuthInput tenant(String? tenant) => this(tenant: tenant);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LogAuthInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LogAuthInput(...).copyWith(id: 12, name: "My name")
  /// ````
  LogAuthInput call({
    Object? kind = const $CopyWithPlaceholder(),
    Object? user = const $CopyWithPlaceholder(),
    Object? password = const $CopyWithPlaceholder(),
    Object? token = const $CopyWithPlaceholder(),
    Object? tenant = const $CopyWithPlaceholder(),
  }) {
    return LogAuthInput(
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as LogAuthInputKindEnum,
      user: user == const $CopyWithPlaceholder()
          ? _value.user
          // ignore: cast_nullable_to_non_nullable
          : user as String?,
      password: password == const $CopyWithPlaceholder()
          ? _value.password
          // ignore: cast_nullable_to_non_nullable
          : password as String?,
      token: token == const $CopyWithPlaceholder()
          ? _value.token
          // ignore: cast_nullable_to_non_nullable
          : token as String?,
      tenant: tenant == const $CopyWithPlaceholder()
          ? _value.tenant
          // ignore: cast_nullable_to_non_nullable
          : tenant as String?,
    );
  }
}

extension $LogAuthInputCopyWith on LogAuthInput {
  /// Returns a callable class that can be used as follows: `instanceOfLogAuthInput.copyWith(...)` or like so:`instanceOfLogAuthInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LogAuthInputCWProxy get copyWith => _$LogAuthInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogAuthInput _$LogAuthInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LogAuthInput', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['kind']);
      final val = LogAuthInput(
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(_$LogAuthInputKindEnumEnumMap, v),
        ),
        user: $checkedConvert('user', (v) => v as String?),
        password: $checkedConvert('password', (v) => v as String?),
        token: $checkedConvert('token', (v) => v as String?),
        tenant: $checkedConvert('tenant', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$LogAuthInputToJson(LogAuthInput instance) =>
    <String, dynamic>{
      'kind': _$LogAuthInputKindEnumEnumMap[instance.kind]!,
      'user': ?instance.user,
      'password': ?instance.password,
      'token': ?instance.token,
      'tenant': ?instance.tenant,
    };

const _$LogAuthInputKindEnumEnumMap = {
  LogAuthInputKindEnum.none: 'none',
  LogAuthInputKindEnum.basic: 'basic',
  LogAuthInputKindEnum.bearer: 'bearer',
  LogAuthInputKindEnum.apikey: 'apikey',
  LogAuthInputKindEnum.aws: 'aws',
};
