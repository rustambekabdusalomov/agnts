// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_document.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PublicDocumentCWProxy {
  PublicDocument kind(DocumentKind kind);

  PublicDocument title(String title);

  PublicDocument body(String body);

  PublicDocument version(int version);

  PublicDocument updatedAt(DateTime updatedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicDocument(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicDocument(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicDocument call({
    DocumentKind kind,
    String title,
    String body,
    int version,
    DateTime updatedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPublicDocument.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPublicDocument.copyWith.fieldName(...)`
class _$PublicDocumentCWProxyImpl implements _$PublicDocumentCWProxy {
  const _$PublicDocumentCWProxyImpl(this._value);

  final PublicDocument _value;

  @override
  PublicDocument kind(DocumentKind kind) => this(kind: kind);

  @override
  PublicDocument title(String title) => this(title: title);

  @override
  PublicDocument body(String body) => this(body: body);

  @override
  PublicDocument version(int version) => this(version: version);

  @override
  PublicDocument updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicDocument(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicDocument(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicDocument call({
    Object? kind = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? body = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
  }) {
    return PublicDocument(
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as DocumentKind,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      body: body == const $CopyWithPlaceholder()
          ? _value.body
          // ignore: cast_nullable_to_non_nullable
          : body as String,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
    );
  }
}

extension $PublicDocumentCopyWith on PublicDocument {
  /// Returns a callable class that can be used as follows: `instanceOfPublicDocument.copyWith(...)` or like so:`instanceOfPublicDocument.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PublicDocumentCWProxy get copyWith => _$PublicDocumentCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicDocument _$PublicDocumentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PublicDocument', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['kind', 'title', 'body', 'version', 'updatedAt'],
  );
  final val = PublicDocument(
    kind: $checkedConvert('kind', (v) => $enumDecode(_$DocumentKindEnumMap, v)),
    title: $checkedConvert('title', (v) => v as String),
    body: $checkedConvert('body', (v) => v as String),
    version: $checkedConvert('version', (v) => (v as num).toInt()),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$PublicDocumentToJson(PublicDocument instance) =>
    <String, dynamic>{
      'kind': _$DocumentKindEnumMap[instance.kind]!,
      'title': instance.title,
      'body': instance.body,
      'version': instance.version,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$DocumentKindEnumMap = {
  DocumentKind.page: 'page',
  DocumentKind.slides: 'slides',
};
