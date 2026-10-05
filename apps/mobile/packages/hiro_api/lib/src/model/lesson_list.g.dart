// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_list.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LessonListCWProxy {
  LessonList items(List<LessonBrief> items);

  LessonList total(int total);

  LessonList unlearned(int unlearned);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LessonList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LessonList(...).copyWith(id: 12, name: "My name")
  /// ````
  LessonList call({List<LessonBrief> items, int total, int unlearned});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLessonList.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLessonList.copyWith.fieldName(...)`
class _$LessonListCWProxyImpl implements _$LessonListCWProxy {
  const _$LessonListCWProxyImpl(this._value);

  final LessonList _value;

  @override
  LessonList items(List<LessonBrief> items) => this(items: items);

  @override
  LessonList total(int total) => this(total: total);

  @override
  LessonList unlearned(int unlearned) => this(unlearned: unlearned);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LessonList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LessonList(...).copyWith(id: 12, name: "My name")
  /// ````
  LessonList call({
    Object? items = const $CopyWithPlaceholder(),
    Object? total = const $CopyWithPlaceholder(),
    Object? unlearned = const $CopyWithPlaceholder(),
  }) {
    return LessonList(
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<LessonBrief>,
      total: total == const $CopyWithPlaceholder()
          ? _value.total
          // ignore: cast_nullable_to_non_nullable
          : total as int,
      unlearned: unlearned == const $CopyWithPlaceholder()
          ? _value.unlearned
          // ignore: cast_nullable_to_non_nullable
          : unlearned as int,
    );
  }
}

extension $LessonListCopyWith on LessonList {
  /// Returns a callable class that can be used as follows: `instanceOfLessonList.copyWith(...)` or like so:`instanceOfLessonList.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LessonListCWProxy get copyWith => _$LessonListCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LessonList _$LessonListFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LessonList', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['items', 'total', 'unlearned']);
      final val = LessonList(
        items: $checkedConvert(
          'items',
          (v) => (v as List<dynamic>)
              .map((e) => LessonBrief.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        total: $checkedConvert('total', (v) => (v as num).toInt()),
        unlearned: $checkedConvert('unlearned', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$LessonListToJson(LessonList instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'total': instance.total,
      'unlearned': instance.unlearned,
    };
