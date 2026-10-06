// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translate_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TranslateInputCWProxy {
  TranslateInput lang(TranslationLanguage lang);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TranslateInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TranslateInput(...).copyWith(id: 12, name: "My name")
  /// ````
  TranslateInput call({TranslationLanguage lang});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTranslateInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTranslateInput.copyWith.fieldName(...)`
class _$TranslateInputCWProxyImpl implements _$TranslateInputCWProxy {
  const _$TranslateInputCWProxyImpl(this._value);

  final TranslateInput _value;

  @override
  TranslateInput lang(TranslationLanguage lang) => this(lang: lang);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TranslateInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TranslateInput(...).copyWith(id: 12, name: "My name")
  /// ````
  TranslateInput call({Object? lang = const $CopyWithPlaceholder()}) {
    return TranslateInput(
      lang: lang == const $CopyWithPlaceholder()
          ? _value.lang
          // ignore: cast_nullable_to_non_nullable
          : lang as TranslationLanguage,
    );
  }
}

extension $TranslateInputCopyWith on TranslateInput {
  /// Returns a callable class that can be used as follows: `instanceOfTranslateInput.copyWith(...)` or like so:`instanceOfTranslateInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TranslateInputCWProxy get copyWith => _$TranslateInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TranslateInput _$TranslateInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TranslateInput', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['lang']);
      final val = TranslateInput(
        lang: $checkedConvert(
          'lang',
          (v) => $enumDecode(_$TranslationLanguageEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$TranslateInputToJson(TranslateInput instance) =>
    <String, dynamic>{'lang': _$TranslationLanguageEnumMap[instance.lang]!};

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
