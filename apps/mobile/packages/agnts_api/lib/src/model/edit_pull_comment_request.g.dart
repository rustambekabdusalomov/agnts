// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_pull_comment_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EditPullCommentRequestCWProxy {
  EditPullCommentRequest commentId(String commentId);

  EditPullCommentRequest body(String body);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EditPullCommentRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EditPullCommentRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  EditPullCommentRequest call({String commentId, String body});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEditPullCommentRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEditPullCommentRequest.copyWith.fieldName(...)`
class _$EditPullCommentRequestCWProxyImpl
    implements _$EditPullCommentRequestCWProxy {
  const _$EditPullCommentRequestCWProxyImpl(this._value);

  final EditPullCommentRequest _value;

  @override
  EditPullCommentRequest commentId(String commentId) =>
      this(commentId: commentId);

  @override
  EditPullCommentRequest body(String body) => this(body: body);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EditPullCommentRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EditPullCommentRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  EditPullCommentRequest call({
    Object? commentId = const $CopyWithPlaceholder(),
    Object? body = const $CopyWithPlaceholder(),
  }) {
    return EditPullCommentRequest(
      commentId: commentId == const $CopyWithPlaceholder()
          ? _value.commentId
          // ignore: cast_nullable_to_non_nullable
          : commentId as String,
      body: body == const $CopyWithPlaceholder()
          ? _value.body
          // ignore: cast_nullable_to_non_nullable
          : body as String,
    );
  }
}

extension $EditPullCommentRequestCopyWith on EditPullCommentRequest {
  /// Returns a callable class that can be used as follows: `instanceOfEditPullCommentRequest.copyWith(...)` or like so:`instanceOfEditPullCommentRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EditPullCommentRequestCWProxy get copyWith =>
      _$EditPullCommentRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditPullCommentRequest _$EditPullCommentRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('EditPullCommentRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['commentId', 'body']);
  final val = EditPullCommentRequest(
    commentId: $checkedConvert('commentId', (v) => v as String),
    body: $checkedConvert('body', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$EditPullCommentRequestToJson(
  EditPullCommentRequest instance,
) => <String, dynamic>{'commentId': instance.commentId, 'body': instance.body};
