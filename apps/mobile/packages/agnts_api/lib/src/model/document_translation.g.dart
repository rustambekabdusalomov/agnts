// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_translation.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DocumentTranslationCWProxy {
  DocumentTranslation lang(TranslationLanguage lang);

  DocumentTranslation version(int version);

  DocumentTranslation title(String title);

  DocumentTranslation body(String body);

  DocumentTranslation complete(bool complete);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentTranslation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentTranslation(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentTranslation call({
    TranslationLanguage lang,
    int version,
    String title,
    String body,
    bool complete,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDocumentTranslation.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDocumentTranslation.copyWith.fieldName(...)`
class _$DocumentTranslationCWProxyImpl implements _$DocumentTranslationCWProxy {
  const _$DocumentTranslationCWProxyImpl(this._value);

  final DocumentTranslation _value;

  @override
  DocumentTranslation lang(TranslationLanguage lang) => this(lang: lang);

  @override
  DocumentTranslation version(int version) => this(version: version);

  @override
  DocumentTranslation title(String title) => this(title: title);

  @override
  DocumentTranslation body(String body) => this(body: body);

  @override
  DocumentTranslation complete(bool complete) => this(complete: complete);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentTranslation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentTranslation(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentTranslation call({
    Object? lang = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? body = const $CopyWithPlaceholder(),
    Object? complete = const $CopyWithPlaceholder(),
  }) {
    return DocumentTranslation(
      lang: lang == const $CopyWithPlaceholder()
          ? _value.lang
          // ignore: cast_nullable_to_non_nullable
          : lang as TranslationLanguage,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      body: body == const $CopyWithPlaceholder()
          ? _value.body
          // ignore: cast_nullable_to_non_nullable
          : body as String,
      complete: complete == const $CopyWithPlaceholder()
          ? _value.complete
          // ignore: cast_nullable_to_non_nullable
          : complete as bool,
    );
  }
}

extension $DocumentTranslationCopyWith on DocumentTranslation {
  /// Returns a callable class that can be used as follows: `instanceOfDocumentTranslation.copyWith(...)` or like so:`instanceOfDocumentTranslation.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DocumentTranslationCWProxy get copyWith =>
      _$DocumentTranslationCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentTranslation _$DocumentTranslationFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DocumentTranslation', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['lang', 'version', 'title', 'body', 'complete'],
      );
      final val = DocumentTranslation(
        lang: $checkedConvert(
          'lang',
          (v) => $enumDecode(_$TranslationLanguageEnumMap, v),
        ),
        version: $checkedConvert('version', (v) => (v as num).toInt()),
        title: $checkedConvert('title', (v) => v as String),
        body: $checkedConvert('body', (v) => v as String),
        complete: $checkedConvert('complete', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$DocumentTranslationToJson(
  DocumentTranslation instance,
) => <String, dynamic>{
  'lang': _$TranslationLanguageEnumMap[instance.lang]!,
  'version': instance.version,
  'title': instance.title,
  'body': instance.body,
  'complete': instance.complete,
};

const _$TranslationLanguageEnumMap = {
  TranslationLanguage.en: 'en',
  TranslationLanguage.ru: 'ru',
  TranslationLanguage.uz: 'uz',
  TranslationLanguage.kk: 'kk',
  TranslationLanguage.tr: 'tr',
  TranslationLanguage.de: 'de',
  TranslationLanguage.es: 'es',
  TranslationLanguage.fr: 'fr',
  TranslationLanguage.zh: 'zh',
  TranslationLanguage.ja: 'ja',
  TranslationLanguage.ko: 'ko',
  TranslationLanguage.ar: 'ar',
};
