// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claude_connection_state.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ClaudeConnectionStateCWProxy {
  ClaudeConnectionState connected(bool connected);

  ClaudeConnectionState kind(ClaudeConnectionStateKindEnum? kind);

  ClaudeConnectionState tokenHint(String? tokenHint);

  ClaudeConnectionState account(String? account);

  ClaudeConnectionState lastError(String? lastError);

  ClaudeConnectionState pausedUntil(DateTime? pausedUntil);

  ClaudeConnectionState usage(Usage? usage);

  ClaudeConnectionState checkedAt(DateTime? checkedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ClaudeConnectionState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ClaudeConnectionState(...).copyWith(id: 12, name: "My name")
  /// ````
  ClaudeConnectionState call({
    bool connected,
    ClaudeConnectionStateKindEnum? kind,
    String? tokenHint,
    String? account,
    String? lastError,
    DateTime? pausedUntil,
    Usage? usage,
    DateTime? checkedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfClaudeConnectionState.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfClaudeConnectionState.copyWith.fieldName(...)`
class _$ClaudeConnectionStateCWProxyImpl
    implements _$ClaudeConnectionStateCWProxy {
  const _$ClaudeConnectionStateCWProxyImpl(this._value);

  final ClaudeConnectionState _value;

  @override
  ClaudeConnectionState connected(bool connected) => this(connected: connected);

  @override
  ClaudeConnectionState kind(ClaudeConnectionStateKindEnum? kind) =>
      this(kind: kind);

  @override
  ClaudeConnectionState tokenHint(String? tokenHint) =>
      this(tokenHint: tokenHint);

  @override
  ClaudeConnectionState account(String? account) => this(account: account);

  @override
  ClaudeConnectionState lastError(String? lastError) =>
      this(lastError: lastError);

  @override
  ClaudeConnectionState pausedUntil(DateTime? pausedUntil) =>
      this(pausedUntil: pausedUntil);

  @override
  ClaudeConnectionState usage(Usage? usage) => this(usage: usage);

  @override
  ClaudeConnectionState checkedAt(DateTime? checkedAt) =>
      this(checkedAt: checkedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ClaudeConnectionState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ClaudeConnectionState(...).copyWith(id: 12, name: "My name")
  /// ````
  ClaudeConnectionState call({
    Object? connected = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? tokenHint = const $CopyWithPlaceholder(),
    Object? account = const $CopyWithPlaceholder(),
    Object? lastError = const $CopyWithPlaceholder(),
    Object? pausedUntil = const $CopyWithPlaceholder(),
    Object? usage = const $CopyWithPlaceholder(),
    Object? checkedAt = const $CopyWithPlaceholder(),
  }) {
    return ClaudeConnectionState(
      connected: connected == const $CopyWithPlaceholder()
          ? _value.connected
          // ignore: cast_nullable_to_non_nullable
          : connected as bool,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as ClaudeConnectionStateKindEnum?,
      tokenHint: tokenHint == const $CopyWithPlaceholder()
          ? _value.tokenHint
          // ignore: cast_nullable_to_non_nullable
          : tokenHint as String?,
      account: account == const $CopyWithPlaceholder()
          ? _value.account
          // ignore: cast_nullable_to_non_nullable
          : account as String?,
      lastError: lastError == const $CopyWithPlaceholder()
          ? _value.lastError
          // ignore: cast_nullable_to_non_nullable
          : lastError as String?,
      pausedUntil: pausedUntil == const $CopyWithPlaceholder()
          ? _value.pausedUntil
          // ignore: cast_nullable_to_non_nullable
          : pausedUntil as DateTime?,
      usage: usage == const $CopyWithPlaceholder()
          ? _value.usage
          // ignore: cast_nullable_to_non_nullable
          : usage as Usage?,
      checkedAt: checkedAt == const $CopyWithPlaceholder()
          ? _value.checkedAt
          // ignore: cast_nullable_to_non_nullable
          : checkedAt as DateTime?,
    );
  }
}

extension $ClaudeConnectionStateCopyWith on ClaudeConnectionState {
  /// Returns a callable class that can be used as follows: `instanceOfClaudeConnectionState.copyWith(...)` or like so:`instanceOfClaudeConnectionState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ClaudeConnectionStateCWProxy get copyWith =>
      _$ClaudeConnectionStateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClaudeConnectionState _$ClaudeConnectionStateFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ClaudeConnectionState', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['connected']);
  final val = ClaudeConnectionState(
    connected: $checkedConvert('connected', (v) => v as bool),
    kind: $checkedConvert(
      'kind',
      (v) => $enumDecodeNullable(_$ClaudeConnectionStateKindEnumEnumMap, v),
    ),
    tokenHint: $checkedConvert('tokenHint', (v) => v as String?),
    account: $checkedConvert('account', (v) => v as String?),
    lastError: $checkedConvert('lastError', (v) => v as String?),
    pausedUntil: $checkedConvert(
      'pausedUntil',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    usage: $checkedConvert(
      'usage',
      (v) => v == null ? null : Usage.fromJson(v as Map<String, dynamic>),
    ),
    checkedAt: $checkedConvert(
      'checkedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
  );
  return val;
});

Map<String, dynamic> _$ClaudeConnectionStateToJson(
  ClaudeConnectionState instance,
) => <String, dynamic>{
  'connected': instance.connected,
  'kind': ?_$ClaudeConnectionStateKindEnumEnumMap[instance.kind],
  'tokenHint': ?instance.tokenHint,
  'account': ?instance.account,
  'lastError': ?instance.lastError,
  'pausedUntil': ?instance.pausedUntil?.toIso8601String(),
  'usage': ?instance.usage?.toJson(),
  'checkedAt': ?instance.checkedAt?.toIso8601String(),
};

const _$ClaudeConnectionStateKindEnumEnumMap = {
  ClaudeConnectionStateKindEnum.subscription: 'subscription',
  ClaudeConnectionStateKindEnum.apiKey: 'api_key',
};
