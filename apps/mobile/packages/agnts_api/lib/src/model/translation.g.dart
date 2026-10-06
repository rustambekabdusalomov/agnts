// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TranslationCWProxy {
  Translation lang(TranslationLanguage lang);

  Translation items(List<TranslationItemsInner> items);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Translation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Translation(...).copyWith(id: 12, name: "My name")
  /// ````
  Translation call({
    TranslationLanguage lang,
    List<TranslationItemsInner> items,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTranslation.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTranslation.copyWith.fieldName(...)`
class _$TranslationCWProxyImpl implements _$TranslationCWProxy {
  const _$TranslationCWProxyImpl(this._value);

  final Translation _value;

  @override
  Translation lang(TranslationLanguage lang) => this(lang: lang);

  @override
  Translation items(List<TranslationItemsInner> items) => this(items: items);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Translation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Translation(...).copyWith(id: 12, name: "My name")
  /// ````
  Translation call({
    Object? lang = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
  }) {
    return Translation(
      lang: lang == const $CopyWithPlaceholder()
          ? _value.lang
          // ignore: cast_nullable_to_non_nullable
          : lang as TranslationLanguage,
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<TranslationItemsInner>,
    );
  }
}

extension $TranslationCopyWith on Translation {
  /// Returns a callable class that can be used as follows: `instanceOfTranslation.copyWith(...)` or like so:`instanceOfTranslation.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TranslationCWProxy get copyWith => _$TranslationCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Translation _$TranslationFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Translation', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['lang', 'items']);
      final val = Translation(
        lang: $checkedConvert(
          'lang',
          (v) => $enumDecode(_$TranslationLanguageEnumMap, v),
        ),
        items: $checkedConvert(
          'items',
          (v) => (v as List<dynamic>)
              .map(
                (e) =>
                    TranslationItemsInner.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$TranslationToJson(Translation instance) =>
    <String, dynamic>{
      'lang': _$TranslationLanguageEnumMap[instance.lang]!,
      'items': instance.items.map((e) => e.toJson()).toList(),
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
