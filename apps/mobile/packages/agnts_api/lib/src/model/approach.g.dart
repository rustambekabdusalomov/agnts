// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approach.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApproachCWProxy {
  Approach title(String title);

  Approach sketch(String sketch);

  Approach pros(List<String> pros);

  Approach cons(List<String> cons);

  Approach fit(String? fit);

  Approach chosen(bool chosen);

  Approach why(String? why);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Approach(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Approach(...).copyWith(id: 12, name: "My name")
  /// ````
  Approach call({
    String title,
    String sketch,
    List<String> pros,
    List<String> cons,
    String? fit,
    bool chosen,
    String? why,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApproach.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApproach.copyWith.fieldName(...)`
class _$ApproachCWProxyImpl implements _$ApproachCWProxy {
  const _$ApproachCWProxyImpl(this._value);

  final Approach _value;

  @override
  Approach title(String title) => this(title: title);

  @override
  Approach sketch(String sketch) => this(sketch: sketch);

  @override
  Approach pros(List<String> pros) => this(pros: pros);

  @override
  Approach cons(List<String> cons) => this(cons: cons);

  @override
  Approach fit(String? fit) => this(fit: fit);

  @override
  Approach chosen(bool chosen) => this(chosen: chosen);

  @override
  Approach why(String? why) => this(why: why);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Approach(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Approach(...).copyWith(id: 12, name: "My name")
  /// ````
  Approach call({
    Object? title = const $CopyWithPlaceholder(),
    Object? sketch = const $CopyWithPlaceholder(),
    Object? pros = const $CopyWithPlaceholder(),
    Object? cons = const $CopyWithPlaceholder(),
    Object? fit = const $CopyWithPlaceholder(),
    Object? chosen = const $CopyWithPlaceholder(),
    Object? why = const $CopyWithPlaceholder(),
  }) {
    return Approach(
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      sketch: sketch == const $CopyWithPlaceholder()
          ? _value.sketch
          // ignore: cast_nullable_to_non_nullable
          : sketch as String,
      pros: pros == const $CopyWithPlaceholder()
          ? _value.pros
          // ignore: cast_nullable_to_non_nullable
          : pros as List<String>,
      cons: cons == const $CopyWithPlaceholder()
          ? _value.cons
          // ignore: cast_nullable_to_non_nullable
          : cons as List<String>,
      fit: fit == const $CopyWithPlaceholder()
          ? _value.fit
          // ignore: cast_nullable_to_non_nullable
          : fit as String?,
      chosen: chosen == const $CopyWithPlaceholder()
          ? _value.chosen
          // ignore: cast_nullable_to_non_nullable
          : chosen as bool,
      why: why == const $CopyWithPlaceholder()
          ? _value.why
          // ignore: cast_nullable_to_non_nullable
          : why as String?,
    );
  }
}

extension $ApproachCopyWith on Approach {
  /// Returns a callable class that can be used as follows: `instanceOfApproach.copyWith(...)` or like so:`instanceOfApproach.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApproachCWProxy get copyWith => _$ApproachCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Approach _$ApproachFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Approach', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['title', 'sketch', 'pros', 'cons', 'chosen'],
      );
      final val = Approach(
        title: $checkedConvert('title', (v) => v as String),
        sketch: $checkedConvert('sketch', (v) => v as String),
        pros: $checkedConvert(
          'pros',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        cons: $checkedConvert(
          'cons',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        fit: $checkedConvert('fit', (v) => v as String?),
        chosen: $checkedConvert('chosen', (v) => v as bool),
        why: $checkedConvert('why', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$ApproachToJson(Approach instance) => <String, dynamic>{
  'title': instance.title,
  'sketch': instance.sketch,
  'pros': instance.pros,
  'cons': instance.cons,
  'fit': ?instance.fit,
  'chosen': instance.chosen,
  'why': ?instance.why,
};
