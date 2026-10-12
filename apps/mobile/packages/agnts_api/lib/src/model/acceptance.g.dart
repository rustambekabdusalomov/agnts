// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'acceptance.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AcceptanceCWProxy {
  Acceptance status(AcceptanceStatusEnum status);

  Acceptance summary(String summary);

  Acceptance criteria(List<AcceptanceCriteriaInner> criteria);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Acceptance(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Acceptance(...).copyWith(id: 12, name: "My name")
  /// ````
  Acceptance call({
    AcceptanceStatusEnum status,
    String summary,
    List<AcceptanceCriteriaInner> criteria,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAcceptance.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAcceptance.copyWith.fieldName(...)`
class _$AcceptanceCWProxyImpl implements _$AcceptanceCWProxy {
  const _$AcceptanceCWProxyImpl(this._value);

  final Acceptance _value;

  @override
  Acceptance status(AcceptanceStatusEnum status) => this(status: status);

  @override
  Acceptance summary(String summary) => this(summary: summary);

  @override
  Acceptance criteria(List<AcceptanceCriteriaInner> criteria) =>
      this(criteria: criteria);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Acceptance(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Acceptance(...).copyWith(id: 12, name: "My name")
  /// ````
  Acceptance call({
    Object? status = const $CopyWithPlaceholder(),
    Object? summary = const $CopyWithPlaceholder(),
    Object? criteria = const $CopyWithPlaceholder(),
  }) {
    return Acceptance(
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as AcceptanceStatusEnum,
      summary: summary == const $CopyWithPlaceholder()
          ? _value.summary
          // ignore: cast_nullable_to_non_nullable
          : summary as String,
      criteria: criteria == const $CopyWithPlaceholder()
          ? _value.criteria
          // ignore: cast_nullable_to_non_nullable
          : criteria as List<AcceptanceCriteriaInner>,
    );
  }
}

extension $AcceptanceCopyWith on Acceptance {
  /// Returns a callable class that can be used as follows: `instanceOfAcceptance.copyWith(...)` or like so:`instanceOfAcceptance.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AcceptanceCWProxy get copyWith => _$AcceptanceCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Acceptance _$AcceptanceFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Acceptance', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['status', 'summary', 'criteria']);
      final val = Acceptance(
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$AcceptanceStatusEnumEnumMap, v),
        ),
        summary: $checkedConvert('summary', (v) => v as String),
        criteria: $checkedConvert(
          'criteria',
          (v) => (v as List<dynamic>)
              .map(
                (e) =>
                    AcceptanceCriteriaInner.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$AcceptanceToJson(Acceptance instance) =>
    <String, dynamic>{
      'status': _$AcceptanceStatusEnumEnumMap[instance.status]!,
      'summary': instance.summary,
      'criteria': instance.criteria.map((e) => e.toJson()).toList(),
    };

const _$AcceptanceStatusEnumEnumMap = {
  AcceptanceStatusEnum.ok: 'ok',
  AcceptanceStatusEnum.partial: 'partial',
  AcceptanceStatusEnum.failed: 'failed',
};
