// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_comment_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DocumentCommentInputCWProxy {
  DocumentCommentInput body(String body);

  DocumentCommentInput parentId(int? parentId);

  DocumentCommentInput quote(String? quote);

  DocumentCommentInput prefix(String? prefix);

  DocumentCommentInput suffix(String? suffix);

  DocumentCommentInput slide(int? slide);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentCommentInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentCommentInput(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentCommentInput call({
    String body,
    int? parentId,
    String? quote,
    String? prefix,
    String? suffix,
    int? slide,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDocumentCommentInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDocumentCommentInput.copyWith.fieldName(...)`
class _$DocumentCommentInputCWProxyImpl
    implements _$DocumentCommentInputCWProxy {
  const _$DocumentCommentInputCWProxyImpl(this._value);

  final DocumentCommentInput _value;

  @override
  DocumentCommentInput body(String body) => this(body: body);

  @override
  DocumentCommentInput parentId(int? parentId) => this(parentId: parentId);

  @override
  DocumentCommentInput quote(String? quote) => this(quote: quote);

  @override
  DocumentCommentInput prefix(String? prefix) => this(prefix: prefix);

  @override
  DocumentCommentInput suffix(String? suffix) => this(suffix: suffix);

  @override
  DocumentCommentInput slide(int? slide) => this(slide: slide);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentCommentInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentCommentInput(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentCommentInput call({
    Object? body = const $CopyWithPlaceholder(),
    Object? parentId = const $CopyWithPlaceholder(),
    Object? quote = const $CopyWithPlaceholder(),
    Object? prefix = const $CopyWithPlaceholder(),
    Object? suffix = const $CopyWithPlaceholder(),
    Object? slide = const $CopyWithPlaceholder(),
  }) {
    return DocumentCommentInput(
      body: body == const $CopyWithPlaceholder()
          ? _value.body
          // ignore: cast_nullable_to_non_nullable
          : body as String,
      parentId: parentId == const $CopyWithPlaceholder()
          ? _value.parentId
          // ignore: cast_nullable_to_non_nullable
          : parentId as int?,
      quote: quote == const $CopyWithPlaceholder()
          ? _value.quote
          // ignore: cast_nullable_to_non_nullable
          : quote as String?,
      prefix: prefix == const $CopyWithPlaceholder()
          ? _value.prefix
          // ignore: cast_nullable_to_non_nullable
          : prefix as String?,
      suffix: suffix == const $CopyWithPlaceholder()
          ? _value.suffix
          // ignore: cast_nullable_to_non_nullable
          : suffix as String?,
      slide: slide == const $CopyWithPlaceholder()
          ? _value.slide
          // ignore: cast_nullable_to_non_nullable
          : slide as int?,
    );
  }
}

extension $DocumentCommentInputCopyWith on DocumentCommentInput {
  /// Returns a callable class that can be used as follows: `instanceOfDocumentCommentInput.copyWith(...)` or like so:`instanceOfDocumentCommentInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DocumentCommentInputCWProxy get copyWith =>
      _$DocumentCommentInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentCommentInput _$DocumentCommentInputFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DocumentCommentInput', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['body']);
  final val = DocumentCommentInput(
    body: $checkedConvert('body', (v) => v as String),
    parentId: $checkedConvert('parentId', (v) => (v as num?)?.toInt()),
    quote: $checkedConvert('quote', (v) => v as String?),
    prefix: $checkedConvert('prefix', (v) => v as String?),
    suffix: $checkedConvert('suffix', (v) => v as String?),
    slide: $checkedConvert('slide', (v) => (v as num?)?.toInt()),
  );
  return val;
});

Map<String, dynamic> _$DocumentCommentInputToJson(
  DocumentCommentInput instance,
) => <String, dynamic>{
  'body': instance.body,
  'parentId': ?instance.parentId,
  'quote': ?instance.quote,
  'prefix': ?instance.prefix,
  'suffix': ?instance.suffix,
  'slide': ?instance.slide,
};
