// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_comment_patch.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DocumentCommentPatchCWProxy {
  DocumentCommentPatch body(String? body);

  DocumentCommentPatch resolved(bool? resolved);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentCommentPatch(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentCommentPatch(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentCommentPatch call({String? body, bool? resolved});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDocumentCommentPatch.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDocumentCommentPatch.copyWith.fieldName(...)`
class _$DocumentCommentPatchCWProxyImpl
    implements _$DocumentCommentPatchCWProxy {
  const _$DocumentCommentPatchCWProxyImpl(this._value);

  final DocumentCommentPatch _value;

  @override
  DocumentCommentPatch body(String? body) => this(body: body);

  @override
  DocumentCommentPatch resolved(bool? resolved) => this(resolved: resolved);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentCommentPatch(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentCommentPatch(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentCommentPatch call({
    Object? body = const $CopyWithPlaceholder(),
    Object? resolved = const $CopyWithPlaceholder(),
  }) {
    return DocumentCommentPatch(
      body: body == const $CopyWithPlaceholder()
          ? _value.body
          // ignore: cast_nullable_to_non_nullable
          : body as String?,
      resolved: resolved == const $CopyWithPlaceholder()
          ? _value.resolved
          // ignore: cast_nullable_to_non_nullable
          : resolved as bool?,
    );
  }
}

extension $DocumentCommentPatchCopyWith on DocumentCommentPatch {
  /// Returns a callable class that can be used as follows: `instanceOfDocumentCommentPatch.copyWith(...)` or like so:`instanceOfDocumentCommentPatch.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DocumentCommentPatchCWProxy get copyWith =>
      _$DocumentCommentPatchCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentCommentPatch _$DocumentCommentPatchFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DocumentCommentPatch', json, ($checkedConvert) {
  final val = DocumentCommentPatch(
    body: $checkedConvert('body', (v) => v as String?),
    resolved: $checkedConvert('resolved', (v) => v as bool?),
  );
  return val;
});

Map<String, dynamic> _$DocumentCommentPatchToJson(
  DocumentCommentPatch instance,
) => <String, dynamic>{'body': ?instance.body, 'resolved': ?instance.resolved};
