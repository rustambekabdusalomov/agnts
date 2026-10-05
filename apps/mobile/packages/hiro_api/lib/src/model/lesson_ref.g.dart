// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_ref.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LessonRefCWProxy {
  LessonRef path(String path);

  LessonRef line(int? line);

  LessonRef note(String? note);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LessonRef(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LessonRef(...).copyWith(id: 12, name: "My name")
  /// ````
  LessonRef call({String path, int? line, String? note});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLessonRef.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLessonRef.copyWith.fieldName(...)`
class _$LessonRefCWProxyImpl implements _$LessonRefCWProxy {
  const _$LessonRefCWProxyImpl(this._value);

  final LessonRef _value;

  @override
  LessonRef path(String path) => this(path: path);

  @override
  LessonRef line(int? line) => this(line: line);

  @override
  LessonRef note(String? note) => this(note: note);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LessonRef(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LessonRef(...).copyWith(id: 12, name: "My name")
  /// ````
  LessonRef call({
    Object? path = const $CopyWithPlaceholder(),
    Object? line = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
  }) {
    return LessonRef(
      path: path == const $CopyWithPlaceholder()
          ? _value.path
          // ignore: cast_nullable_to_non_nullable
          : path as String,
      line: line == const $CopyWithPlaceholder()
          ? _value.line
          // ignore: cast_nullable_to_non_nullable
          : line as int?,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
    );
  }
}

extension $LessonRefCopyWith on LessonRef {
  /// Returns a callable class that can be used as follows: `instanceOfLessonRef.copyWith(...)` or like so:`instanceOfLessonRef.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LessonRefCWProxy get copyWith => _$LessonRefCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LessonRef _$LessonRefFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LessonRef', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['path']);
      final val = LessonRef(
        path: $checkedConvert('path', (v) => v as String),
        line: $checkedConvert('line', (v) => (v as num?)?.toInt()),
        note: $checkedConvert('note', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$LessonRefToJson(LessonRef instance) => <String, dynamic>{
  'path': instance.path,
  'line': ?instance.line,
  'note': ?instance.note,
};
