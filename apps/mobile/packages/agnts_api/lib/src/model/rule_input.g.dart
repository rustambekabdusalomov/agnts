// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RuleInputCWProxy {
  RuleInput title(String title);

  RuleInput body(String body);

  RuleInput repoId(int? repoId);

  RuleInput enabled(bool? enabled);

  RuleInput kind(RuleKind? kind);

  RuleInput enforce(RuleEnforce? enforce);

  RuleInput removeEnforce(bool? removeEnforce);

  RuleInput delivery(RuleInputDeliveryEnum? delivery);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RuleInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RuleInput(...).copyWith(id: 12, name: "My name")
  /// ````
  RuleInput call({
    String title,
    String body,
    int? repoId,
    bool? enabled,
    RuleKind? kind,
    RuleEnforce? enforce,
    bool? removeEnforce,
    RuleInputDeliveryEnum? delivery,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRuleInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRuleInput.copyWith.fieldName(...)`
class _$RuleInputCWProxyImpl implements _$RuleInputCWProxy {
  const _$RuleInputCWProxyImpl(this._value);

  final RuleInput _value;

  @override
  RuleInput title(String title) => this(title: title);

  @override
  RuleInput body(String body) => this(body: body);

  @override
  RuleInput repoId(int? repoId) => this(repoId: repoId);

  @override
  RuleInput enabled(bool? enabled) => this(enabled: enabled);

  @override
  RuleInput kind(RuleKind? kind) => this(kind: kind);

  @override
  RuleInput enforce(RuleEnforce? enforce) => this(enforce: enforce);

  @override
  RuleInput removeEnforce(bool? removeEnforce) =>
      this(removeEnforce: removeEnforce);

  @override
  RuleInput delivery(RuleInputDeliveryEnum? delivery) =>
      this(delivery: delivery);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RuleInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RuleInput(...).copyWith(id: 12, name: "My name")
  /// ````
  RuleInput call({
    Object? title = const $CopyWithPlaceholder(),
    Object? body = const $CopyWithPlaceholder(),
    Object? repoId = const $CopyWithPlaceholder(),
    Object? enabled = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? enforce = const $CopyWithPlaceholder(),
    Object? removeEnforce = const $CopyWithPlaceholder(),
    Object? delivery = const $CopyWithPlaceholder(),
  }) {
    return RuleInput(
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      body: body == const $CopyWithPlaceholder()
          ? _value.body
          // ignore: cast_nullable_to_non_nullable
          : body as String,
      repoId: repoId == const $CopyWithPlaceholder()
          ? _value.repoId
          // ignore: cast_nullable_to_non_nullable
          : repoId as int?,
      enabled: enabled == const $CopyWithPlaceholder()
          ? _value.enabled
          // ignore: cast_nullable_to_non_nullable
          : enabled as bool?,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as RuleKind?,
      enforce: enforce == const $CopyWithPlaceholder()
          ? _value.enforce
          // ignore: cast_nullable_to_non_nullable
          : enforce as RuleEnforce?,
      removeEnforce: removeEnforce == const $CopyWithPlaceholder()
          ? _value.removeEnforce
          // ignore: cast_nullable_to_non_nullable
          : removeEnforce as bool?,
      delivery: delivery == const $CopyWithPlaceholder()
          ? _value.delivery
          // ignore: cast_nullable_to_non_nullable
          : delivery as RuleInputDeliveryEnum?,
    );
  }
}

extension $RuleInputCopyWith on RuleInput {
  /// Returns a callable class that can be used as follows: `instanceOfRuleInput.copyWith(...)` or like so:`instanceOfRuleInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RuleInputCWProxy get copyWith => _$RuleInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RuleInput _$RuleInputFromJson(Map<String, dynamic> json) => $checkedCreate(
  'RuleInput',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['title', 'body']);
    final val = RuleInput(
      title: $checkedConvert('title', (v) => v as String),
      body: $checkedConvert('body', (v) => v as String),
      repoId: $checkedConvert('repoId', (v) => (v as num?)?.toInt()),
      enabled: $checkedConvert('enabled', (v) => v as bool? ?? true),
      kind: $checkedConvert(
        'kind',
        (v) => $enumDecodeNullable(_$RuleKindEnumMap, v),
      ),
      enforce: $checkedConvert(
        'enforce',
        (v) =>
            v == null ? null : RuleEnforce.fromJson(v as Map<String, dynamic>),
      ),
      removeEnforce: $checkedConvert('removeEnforce', (v) => v as bool?),
      delivery: $checkedConvert(
        'delivery',
        (v) => $enumDecodeNullable(_$RuleInputDeliveryEnumEnumMap, v),
      ),
    );
    return val;
  },
);

Map<String, dynamic> _$RuleInputToJson(RuleInput instance) => <String, dynamic>{
  'title': instance.title,
  'body': instance.body,
  'repoId': ?instance.repoId,
  'enabled': ?instance.enabled,
  'kind': ?_$RuleKindEnumMap[instance.kind],
  'enforce': ?instance.enforce?.toJson(),
  'removeEnforce': ?instance.removeEnforce,
  'delivery': ?_$RuleInputDeliveryEnumEnumMap[instance.delivery],
};

const _$RuleKindEnumMap = {
  RuleKind.rule: 'rule',
  RuleKind.context: 'context',
  RuleKind.tip: 'tip',
};

const _$RuleInputDeliveryEnumEnumMap = {
  RuleInputDeliveryEnum.prompt: 'prompt',
  RuleInputDeliveryEnum.skill: 'skill',
};
