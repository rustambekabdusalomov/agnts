// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_count.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LessonCountCWProxy {
  LessonCount category(String category);

  LessonCount created(int created);

  LessonCount learned(int learned);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LessonCount(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LessonCount(...).copyWith(id: 12, name: "My name")
  /// ````
  LessonCount call({String category, int created, int learned});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLessonCount.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLessonCount.copyWith.fieldName(...)`
class _$LessonCountCWProxyImpl implements _$LessonCountCWProxy {
  const _$LessonCountCWProxyImpl(this._value);

  final LessonCount _value;

  @override
  LessonCount category(String category) => this(category: category);

  @override
  LessonCount created(int created) => this(created: created);

  @override
  LessonCount learned(int learned) => this(learned: learned);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LessonCount(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LessonCount(...).copyWith(id: 12, name: "My name")
  /// ````
  LessonCount call({
    Object? category = const $CopyWithPlaceholder(),
    Object? created = const $CopyWithPlaceholder(),
    Object? learned = const $CopyWithPlaceholder(),
  }) {
    return LessonCount(
      category: category == const $CopyWithPlaceholder()
          ? _value.category
          // ignore: cast_nullable_to_non_nullable
          : category as String,
      created: created == const $CopyWithPlaceholder()
          ? _value.created
          // ignore: cast_nullable_to_non_nullable
          : created as int,
      learned: learned == const $CopyWithPlaceholder()
          ? _value.learned
          // ignore: cast_nullable_to_non_nullable
          : learned as int,
    );
  }
}

extension $LessonCountCopyWith on LessonCount {
  /// Returns a callable class that can be used as follows: `instanceOfLessonCount.copyWith(...)` or like so:`instanceOfLessonCount.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LessonCountCWProxy get copyWith => _$LessonCountCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LessonCount _$LessonCountFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LessonCount', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['category', 'created', 'learned']);
      final val = LessonCount(
        category: $checkedConvert('category', (v) => v as String),
        created: $checkedConvert('created', (v) => (v as num).toInt()),
        learned: $checkedConvert('learned', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$LessonCountToJson(LessonCount instance) =>
    <String, dynamic>{
      'category': instance.category,
      'created': instance.created,
      'learned': instance.learned,
    };
