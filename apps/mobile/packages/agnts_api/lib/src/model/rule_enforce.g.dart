// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule_enforce.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RuleEnforceCWProxy {
  RuleEnforce on_(RuleEnforceOn_Enum on_);

  RuleEnforce paths(List<String>? paths);

  RuleEnforce pattern(String? pattern);

  RuleEnforce action(RuleEnforceActionEnum action);

  RuleEnforce message(String? message);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RuleEnforce(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RuleEnforce(...).copyWith(id: 12, name: "My name")
  /// ````
  RuleEnforce call({
    RuleEnforceOn_Enum on_,
    List<String>? paths,
    String? pattern,
    RuleEnforceActionEnum action,
    String? message,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRuleEnforce.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRuleEnforce.copyWith.fieldName(...)`
class _$RuleEnforceCWProxyImpl implements _$RuleEnforceCWProxy {
  const _$RuleEnforceCWProxyImpl(this._value);

  final RuleEnforce _value;

  @override
  RuleEnforce on_(RuleEnforceOn_Enum on_) => this(on_: on_);

  @override
  RuleEnforce paths(List<String>? paths) => this(paths: paths);

  @override
  RuleEnforce pattern(String? pattern) => this(pattern: pattern);

  @override
  RuleEnforce action(RuleEnforceActionEnum action) => this(action: action);

  @override
  RuleEnforce message(String? message) => this(message: message);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RuleEnforce(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RuleEnforce(...).copyWith(id: 12, name: "My name")
  /// ````
  RuleEnforce call({
    Object? on_ = const $CopyWithPlaceholder(),
    Object? paths = const $CopyWithPlaceholder(),
    Object? pattern = const $CopyWithPlaceholder(),
    Object? action = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
  }) {
    return RuleEnforce(
      on_: on_ == const $CopyWithPlaceholder()
          ? _value.on_
          // ignore: cast_nullable_to_non_nullable
          : on_ as RuleEnforceOn_Enum,
      paths: paths == const $CopyWithPlaceholder()
          ? _value.paths
          // ignore: cast_nullable_to_non_nullable
          : paths as List<String>?,
      pattern: pattern == const $CopyWithPlaceholder()
          ? _value.pattern
          // ignore: cast_nullable_to_non_nullable
          : pattern as String?,
      action: action == const $CopyWithPlaceholder()
          ? _value.action
          // ignore: cast_nullable_to_non_nullable
          : action as RuleEnforceActionEnum,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String?,
    );
  }
}

extension $RuleEnforceCopyWith on RuleEnforce {
  /// Returns a callable class that can be used as follows: `instanceOfRuleEnforce.copyWith(...)` or like so:`instanceOfRuleEnforce.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RuleEnforceCWProxy get copyWith => _$RuleEnforceCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RuleEnforce _$RuleEnforceFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RuleEnforce', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['on', 'action']);
      final val = RuleEnforce(
        on_: $checkedConvert(
          'on',
          (v) => $enumDecode(_$RuleEnforceOn_EnumEnumMap, v),
        ),
        paths: $checkedConvert(
          'paths',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
        pattern: $checkedConvert('pattern', (v) => v as String?),
        action: $checkedConvert(
          'action',
          (v) => $enumDecode(_$RuleEnforceActionEnumEnumMap, v),
        ),
        message: $checkedConvert('message', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'on_': 'on'});

Map<String, dynamic> _$RuleEnforceToJson(RuleEnforce instance) =>
    <String, dynamic>{
      'on': _$RuleEnforceOn_EnumEnumMap[instance.on_]!,
      'paths': ?instance.paths,
      'pattern': ?instance.pattern,
      'action': _$RuleEnforceActionEnumEnumMap[instance.action]!,
      'message': ?instance.message,
    };

const _$RuleEnforceOn_EnumEnumMap = {
  RuleEnforceOn_Enum.file: 'file',
  RuleEnforceOn_Enum.bash: 'bash',
  RuleEnforceOn_Enum.diff: 'diff',
};

const _$RuleEnforceActionEnumEnumMap = {
  RuleEnforceActionEnum.block: 'block',
  RuleEnforceActionEnum.warn: 'warn',
};
