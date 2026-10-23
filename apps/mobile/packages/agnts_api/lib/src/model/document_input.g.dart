// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DocumentInputCWProxy {
  DocumentInput kind(DocumentKind? kind);

  DocumentInput title(String title);

  DocumentInput body(String? body);

  DocumentInput language(DocumentInputLanguageEnum? language);

  DocumentInput source_(DocumentSourceInput? source_);

  DocumentInput linkTickets(List<String>? linkTickets);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentInput(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentInput call({
    DocumentKind? kind,
    String title,
    String? body,
    DocumentInputLanguageEnum? language,
    DocumentSourceInput? source_,
    List<String>? linkTickets,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDocumentInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDocumentInput.copyWith.fieldName(...)`
class _$DocumentInputCWProxyImpl implements _$DocumentInputCWProxy {
  const _$DocumentInputCWProxyImpl(this._value);

  final DocumentInput _value;

  @override
  DocumentInput kind(DocumentKind? kind) => this(kind: kind);

  @override
  DocumentInput title(String title) => this(title: title);

  @override
  DocumentInput body(String? body) => this(body: body);

  @override
  DocumentInput language(DocumentInputLanguageEnum? language) =>
      this(language: language);

  @override
  DocumentInput source_(DocumentSourceInput? source_) => this(source_: source_);

  @override
  DocumentInput linkTickets(List<String>? linkTickets) =>
      this(linkTickets: linkTickets);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentInput(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentInput call({
    Object? kind = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? body = const $CopyWithPlaceholder(),
    Object? language = const $CopyWithPlaceholder(),
    Object? source_ = const $CopyWithPlaceholder(),
    Object? linkTickets = const $CopyWithPlaceholder(),
  }) {
    return DocumentInput(
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as DocumentKind?,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      body: body == const $CopyWithPlaceholder()
          ? _value.body
          // ignore: cast_nullable_to_non_nullable
          : body as String?,
      language: language == const $CopyWithPlaceholder()
          ? _value.language
          // ignore: cast_nullable_to_non_nullable
          : language as DocumentInputLanguageEnum?,
      source_: source_ == const $CopyWithPlaceholder()
          ? _value.source_
          // ignore: cast_nullable_to_non_nullable
          : source_ as DocumentSourceInput?,
      linkTickets: linkTickets == const $CopyWithPlaceholder()
          ? _value.linkTickets
          // ignore: cast_nullable_to_non_nullable
          : linkTickets as List<String>?,
    );
  }
}

extension $DocumentInputCopyWith on DocumentInput {
  /// Returns a callable class that can be used as follows: `instanceOfDocumentInput.copyWith(...)` or like so:`instanceOfDocumentInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DocumentInputCWProxy get copyWith => _$DocumentInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentInput _$DocumentInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DocumentInput', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['title']);
      final val = DocumentInput(
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecodeNullable(_$DocumentKindEnumMap, v),
        ),
        title: $checkedConvert('title', (v) => v as String),
        body: $checkedConvert('body', (v) => v as String?),
        language: $checkedConvert(
          'language',
          (v) => $enumDecodeNullable(_$DocumentInputLanguageEnumEnumMap, v),
        ),
        source_: $checkedConvert(
          'source',
          (v) => v == null
              ? null
              : DocumentSourceInput.fromJson(v as Map<String, dynamic>),
        ),
        linkTickets: $checkedConvert(
          'linkTickets',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
      );
      return val;
    }, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$DocumentInputToJson(DocumentInput instance) =>
    <String, dynamic>{
      'kind': ?_$DocumentKindEnumMap[instance.kind],
      'title': instance.title,
      'body': ?instance.body,
      'language': ?_$DocumentInputLanguageEnumEnumMap[instance.language],
      'source': ?instance.source_?.toJson(),
      'linkTickets': ?instance.linkTickets,
    };

const _$DocumentKindEnumMap = {
  DocumentKind.page: 'page',
  DocumentKind.slides: 'slides',
};

const _$DocumentInputLanguageEnumEnumMap = {
  DocumentInputLanguageEnum.en: 'en',
  DocumentInputLanguageEnum.ru: 'ru',
  DocumentInputLanguageEnum.uz: 'uz',
};
