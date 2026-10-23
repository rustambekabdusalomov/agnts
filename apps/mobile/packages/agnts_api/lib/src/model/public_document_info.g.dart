// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_document_info.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PublicDocumentInfoCWProxy {
  PublicDocumentInfo kind(DocumentKind kind);

  PublicDocumentInfo title(String title);

  PublicDocumentInfo googleClientId(String? googleClientId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicDocumentInfo(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicDocumentInfo(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicDocumentInfo call({
    DocumentKind kind,
    String title,
    String? googleClientId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPublicDocumentInfo.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPublicDocumentInfo.copyWith.fieldName(...)`
class _$PublicDocumentInfoCWProxyImpl implements _$PublicDocumentInfoCWProxy {
  const _$PublicDocumentInfoCWProxyImpl(this._value);

  final PublicDocumentInfo _value;

  @override
  PublicDocumentInfo kind(DocumentKind kind) => this(kind: kind);

  @override
  PublicDocumentInfo title(String title) => this(title: title);

  @override
  PublicDocumentInfo googleClientId(String? googleClientId) =>
      this(googleClientId: googleClientId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicDocumentInfo(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicDocumentInfo(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicDocumentInfo call({
    Object? kind = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? googleClientId = const $CopyWithPlaceholder(),
  }) {
    return PublicDocumentInfo(
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as DocumentKind,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      googleClientId: googleClientId == const $CopyWithPlaceholder()
          ? _value.googleClientId
          // ignore: cast_nullable_to_non_nullable
          : googleClientId as String?,
    );
  }
}

extension $PublicDocumentInfoCopyWith on PublicDocumentInfo {
  /// Returns a callable class that can be used as follows: `instanceOfPublicDocumentInfo.copyWith(...)` or like so:`instanceOfPublicDocumentInfo.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PublicDocumentInfoCWProxy get copyWith =>
      _$PublicDocumentInfoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicDocumentInfo _$PublicDocumentInfoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PublicDocumentInfo', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['kind', 'title']);
      final val = PublicDocumentInfo(
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(_$DocumentKindEnumMap, v),
        ),
        title: $checkedConvert('title', (v) => v as String),
        googleClientId: $checkedConvert('googleClientId', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$PublicDocumentInfoToJson(PublicDocumentInfo instance) =>
    <String, dynamic>{
      'kind': _$DocumentKindEnumMap[instance.kind]!,
      'title': instance.title,
      'googleClientId': ?instance.googleClientId,
    };

const _$DocumentKindEnumMap = {
  DocumentKind.page: 'page',
  DocumentKind.slides: 'slides',
};
