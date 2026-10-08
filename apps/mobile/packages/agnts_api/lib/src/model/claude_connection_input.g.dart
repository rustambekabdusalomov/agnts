// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claude_connection_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ClaudeConnectionInputCWProxy {
  ClaudeConnectionInput kind(ClaudeConnectionInputKindEnum kind);

  ClaudeConnectionInput token(String token);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ClaudeConnectionInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ClaudeConnectionInput(...).copyWith(id: 12, name: "My name")
  /// ````
  ClaudeConnectionInput call({
    ClaudeConnectionInputKindEnum kind,
    String token,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfClaudeConnectionInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfClaudeConnectionInput.copyWith.fieldName(...)`
class _$ClaudeConnectionInputCWProxyImpl
    implements _$ClaudeConnectionInputCWProxy {
  const _$ClaudeConnectionInputCWProxyImpl(this._value);

  final ClaudeConnectionInput _value;

  @override
  ClaudeConnectionInput kind(ClaudeConnectionInputKindEnum kind) =>
      this(kind: kind);

  @override
  ClaudeConnectionInput token(String token) => this(token: token);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ClaudeConnectionInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ClaudeConnectionInput(...).copyWith(id: 12, name: "My name")
  /// ````
  ClaudeConnectionInput call({
    Object? kind = const $CopyWithPlaceholder(),
    Object? token = const $CopyWithPlaceholder(),
  }) {
    return ClaudeConnectionInput(
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as ClaudeConnectionInputKindEnum,
      token: token == const $CopyWithPlaceholder()
          ? _value.token
          // ignore: cast_nullable_to_non_nullable
          : token as String,
    );
  }
}

extension $ClaudeConnectionInputCopyWith on ClaudeConnectionInput {
  /// Returns a callable class that can be used as follows: `instanceOfClaudeConnectionInput.copyWith(...)` or like so:`instanceOfClaudeConnectionInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ClaudeConnectionInputCWProxy get copyWith =>
      _$ClaudeConnectionInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClaudeConnectionInput _$ClaudeConnectionInputFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ClaudeConnectionInput', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['kind', 'token']);
  final val = ClaudeConnectionInput(
    kind: $checkedConvert(
      'kind',
      (v) => $enumDecode(_$ClaudeConnectionInputKindEnumEnumMap, v),
    ),
    token: $checkedConvert('token', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$ClaudeConnectionInputToJson(
  ClaudeConnectionInput instance,
) => <String, dynamic>{
  'kind': _$ClaudeConnectionInputKindEnumEnumMap[instance.kind]!,
  'token': instance.token,
};

const _$ClaudeConnectionInputKindEnumEnumMap = {
  ClaudeConnectionInputKindEnum.subscription: 'subscription',
  ClaudeConnectionInputKindEnum.apiKey: 'api_key',
};
