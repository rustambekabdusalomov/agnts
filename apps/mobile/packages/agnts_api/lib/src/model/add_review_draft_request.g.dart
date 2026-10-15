// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_review_draft_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AddReviewDraftRequestCWProxy {
  AddReviewDraftRequest body(String body);

  AddReviewDraftRequest path(String? path);

  AddReviewDraftRequest line(int? line);

  AddReviewDraftRequest headSha(String? headSha);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AddReviewDraftRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AddReviewDraftRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AddReviewDraftRequest call({
    String body,
    String? path,
    int? line,
    String? headSha,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAddReviewDraftRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAddReviewDraftRequest.copyWith.fieldName(...)`
class _$AddReviewDraftRequestCWProxyImpl
    implements _$AddReviewDraftRequestCWProxy {
  const _$AddReviewDraftRequestCWProxyImpl(this._value);

  final AddReviewDraftRequest _value;

  @override
  AddReviewDraftRequest body(String body) => this(body: body);

  @override
  AddReviewDraftRequest path(String? path) => this(path: path);

  @override
  AddReviewDraftRequest line(int? line) => this(line: line);

  @override
  AddReviewDraftRequest headSha(String? headSha) => this(headSha: headSha);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AddReviewDraftRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AddReviewDraftRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AddReviewDraftRequest call({
    Object? body = const $CopyWithPlaceholder(),
    Object? path = const $CopyWithPlaceholder(),
    Object? line = const $CopyWithPlaceholder(),
    Object? headSha = const $CopyWithPlaceholder(),
  }) {
    return AddReviewDraftRequest(
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
      headSha: headSha == const $CopyWithPlaceholder()
          ? _value.headSha
          // ignore: cast_nullable_to_non_nullable
          : headSha as String?,
    );
  }
}

extension $AddReviewDraftRequestCopyWith on AddReviewDraftRequest {
  /// Returns a callable class that can be used as follows: `instanceOfAddReviewDraftRequest.copyWith(...)` or like so:`instanceOfAddReviewDraftRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AddReviewDraftRequestCWProxy get copyWith =>
      _$AddReviewDraftRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddReviewDraftRequest _$AddReviewDraftRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AddReviewDraftRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['body']);
  final val = AddReviewDraftRequest(
    body: $checkedConvert('body', (v) => v as String),
    path: $checkedConvert('path', (v) => v as String?),
    line: $checkedConvert('line', (v) => (v as num?)?.toInt()),
    headSha: $checkedConvert('headSha', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$AddReviewDraftRequestToJson(
  AddReviewDraftRequest instance,
) => <String, dynamic>{
  'body': instance.body,
  'path': ?instance.path,
  'line': ?instance.line,
  'headSha': ?instance.headSha,
};
