// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_pull_comment.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NewPullCommentCWProxy {
  NewPullComment body(String body);

  NewPullComment path(String? path);

  NewPullComment line(int? line);

  NewPullComment oldLine(int? oldLine);

  NewPullComment startLine(int? startLine);

  NewPullComment headSha(String? headSha);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NewPullComment(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NewPullComment(...).copyWith(id: 12, name: "My name")
  /// ````
  NewPullComment call({
    String body,
    String? path,
    int? line,
    int? oldLine,
    int? startLine,
    String? headSha,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNewPullComment.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNewPullComment.copyWith.fieldName(...)`
class _$NewPullCommentCWProxyImpl implements _$NewPullCommentCWProxy {
  const _$NewPullCommentCWProxyImpl(this._value);

  final NewPullComment _value;

  @override
  NewPullComment body(String body) => this(body: body);

  @override
  NewPullComment path(String? path) => this(path: path);

  @override
  NewPullComment line(int? line) => this(line: line);

  @override
  NewPullComment oldLine(int? oldLine) => this(oldLine: oldLine);

  @override
  NewPullComment startLine(int? startLine) => this(startLine: startLine);

  @override
  NewPullComment headSha(String? headSha) => this(headSha: headSha);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NewPullComment(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NewPullComment(...).copyWith(id: 12, name: "My name")
  /// ````
  NewPullComment call({
    Object? body = const $CopyWithPlaceholder(),
    Object? path = const $CopyWithPlaceholder(),
    Object? line = const $CopyWithPlaceholder(),
    Object? oldLine = const $CopyWithPlaceholder(),
    Object? startLine = const $CopyWithPlaceholder(),
    Object? headSha = const $CopyWithPlaceholder(),
  }) {
    return NewPullComment(
      body: body == const $CopyWithPlaceholder()
          ? _value.body
          // ignore: cast_nullable_to_non_nullable
          : body as String,
      path: path == const $CopyWithPlaceholder()
          ? _value.path
          // ignore: cast_nullable_to_non_nullable
          : path as String?,
      line: line == const $CopyWithPlaceholder()
          ? _value.line
          // ignore: cast_nullable_to_non_nullable
          : line as int?,
      oldLine: oldLine == const $CopyWithPlaceholder()
          ? _value.oldLine
          // ignore: cast_nullable_to_non_nullable
          : oldLine as int?,
      startLine: startLine == const $CopyWithPlaceholder()
          ? _value.startLine
          // ignore: cast_nullable_to_non_nullable
          : startLine as int?,
      headSha: headSha == const $CopyWithPlaceholder()
          ? _value.headSha
          // ignore: cast_nullable_to_non_nullable
          : headSha as String?,
    );
  }
}

extension $NewPullCommentCopyWith on NewPullComment {
  /// Returns a callable class that can be used as follows: `instanceOfNewPullComment.copyWith(...)` or like so:`instanceOfNewPullComment.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NewPullCommentCWProxy get copyWith => _$NewPullCommentCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewPullComment _$NewPullCommentFromJson(Map<String, dynamic> json) =>
    $checkedCreate('NewPullComment', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['body']);
      final val = NewPullComment(
        body: $checkedConvert('body', (v) => v as String),
        path: $checkedConvert('path', (v) => v as String?),
        line: $checkedConvert('line', (v) => (v as num?)?.toInt()),
        oldLine: $checkedConvert('oldLine', (v) => (v as num?)?.toInt()),
        startLine: $checkedConvert('startLine', (v) => (v as num?)?.toInt()),
        headSha: $checkedConvert('headSha', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$NewPullCommentToJson(NewPullComment instance) =>
    <String, dynamic>{
      'body': instance.body,
      'path': ?instance.path,
      'line': ?instance.line,
      'oldLine': ?instance.oldLine,
      'startLine': ?instance.startLine,
      'headSha': ?instance.headSha,
    };
