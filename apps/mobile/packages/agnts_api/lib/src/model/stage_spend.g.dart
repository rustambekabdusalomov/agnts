// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stage_spend.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$StageSpendCWProxy {
  StageSpend stage(StageSpendStageEnum stage);

  StageSpend model(String model);

  StageSpend calls(int calls);

  StageSpend turns(int turns);

  StageSpend partial(bool partial);

  StageSpend spend(TokenSpend spend);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StageSpend(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StageSpend(...).copyWith(id: 12, name: "My name")
  /// ````
  StageSpend call({
    StageSpendStageEnum stage,
    String model,
    int calls,
    int turns,
    bool partial,
    TokenSpend spend,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfStageSpend.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfStageSpend.copyWith.fieldName(...)`
class _$StageSpendCWProxyImpl implements _$StageSpendCWProxy {
  const _$StageSpendCWProxyImpl(this._value);

  final StageSpend _value;

  @override
  StageSpend stage(StageSpendStageEnum stage) => this(stage: stage);

  @override
  StageSpend model(String model) => this(model: model);

  @override
  StageSpend calls(int calls) => this(calls: calls);

  @override
  StageSpend turns(int turns) => this(turns: turns);

  @override
  StageSpend partial(bool partial) => this(partial: partial);

  @override
  StageSpend spend(TokenSpend spend) => this(spend: spend);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StageSpend(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StageSpend(...).copyWith(id: 12, name: "My name")
  /// ````
  StageSpend call({
    Object? stage = const $CopyWithPlaceholder(),
    Object? model = const $CopyWithPlaceholder(),
    Object? calls = const $CopyWithPlaceholder(),
    Object? turns = const $CopyWithPlaceholder(),
    Object? partial = const $CopyWithPlaceholder(),
    Object? spend = const $CopyWithPlaceholder(),
  }) {
    return StageSpend(
      stage: stage == const $CopyWithPlaceholder()
          ? _value.stage
          // ignore: cast_nullable_to_non_nullable
          : stage as StageSpendStageEnum,
      model: model == const $CopyWithPlaceholder()
          ? _value.model
          // ignore: cast_nullable_to_non_nullable
          : model as String,
      calls: calls == const $CopyWithPlaceholder()
          ? _value.calls
          // ignore: cast_nullable_to_non_nullable
          : calls as int,
      turns: turns == const $CopyWithPlaceholder()
          ? _value.turns
          // ignore: cast_nullable_to_non_nullable
          : turns as int,
      partial: partial == const $CopyWithPlaceholder()
          ? _value.partial
          // ignore: cast_nullable_to_non_nullable
          : partial as bool,
      spend: spend == const $CopyWithPlaceholder()
          ? _value.spend
          // ignore: cast_nullable_to_non_nullable
          : spend as TokenSpend,
    );
  }
}

extension $StageSpendCopyWith on StageSpend {
  /// Returns a callable class that can be used as follows: `instanceOfStageSpend.copyWith(...)` or like so:`instanceOfStageSpend.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StageSpendCWProxy get copyWith => _$StageSpendCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StageSpend _$StageSpendFromJson(Map<String, dynamic> json) =>
    $checkedCreate('StageSpend', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'stage',
          'model',
          'calls',
          'turns',
          'partial',
          'spend',
        ],
      );
      final val = StageSpend(
        stage: $checkedConvert(
          'stage',
          (v) => $enumDecode(_$StageSpendStageEnumEnumMap, v),
        ),
        model: $checkedConvert('model', (v) => v as String),
        calls: $checkedConvert('calls', (v) => (v as num).toInt()),
        turns: $checkedConvert('turns', (v) => (v as num).toInt()),
        partial: $checkedConvert('partial', (v) => v as bool),
        spend: $checkedConvert(
          'spend',
          (v) => TokenSpend.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$StageSpendToJson(StageSpend instance) =>
    <String, dynamic>{
      'stage': _$StageSpendStageEnumEnumMap[instance.stage]!,
      'model': instance.model,
      'calls': instance.calls,
      'turns': instance.turns,
      'partial': instance.partial,
      'spend': instance.spend.toJson(),
    };

const _$StageSpendStageEnumEnumMap = {
  StageSpendStageEnum.analyze: 'analyze',
  StageSpendStageEnum.coding: 'coding',
  StageSpendStageEnum.retry: 'retry',
  StageSpendStageEnum.helper: 'helper',
  StageSpendStageEnum.learn: 'learn',
  StageSpendStageEnum.review: 'review',
  StageSpendStageEnum.preview: 'preview',
};
