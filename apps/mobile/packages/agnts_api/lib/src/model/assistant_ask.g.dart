// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_ask.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssistantAskCWProxy {
  AssistantAsk question(String? question);

  AssistantAsk attachments(List<int>? attachments);

  AssistantAsk lang(AssistantLanguage? lang);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantAsk(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantAsk(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantAsk call({
    String? question,
    List<int>? attachments,
    AssistantLanguage? lang,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssistantAsk.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssistantAsk.copyWith.fieldName(...)`
class _$AssistantAskCWProxyImpl implements _$AssistantAskCWProxy {
  const _$AssistantAskCWProxyImpl(this._value);

  final AssistantAsk _value;

  @override
  AssistantAsk question(String? question) => this(question: question);

  @override
  AssistantAsk attachments(List<int>? attachments) =>
      this(attachments: attachments);

  @override
  AssistantAsk lang(AssistantLanguage? lang) => this(lang: lang);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantAsk(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantAsk(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantAsk call({
    Object? question = const $CopyWithPlaceholder(),
    Object? attachments = const $CopyWithPlaceholder(),
    Object? lang = const $CopyWithPlaceholder(),
  }) {
    return AssistantAsk(
      question: question == const $CopyWithPlaceholder()
          ? _value.question
          // ignore: cast_nullable_to_non_nullable
          : question as String?,
      attachments: attachments == const $CopyWithPlaceholder()
          ? _value.attachments
          // ignore: cast_nullable_to_non_nullable
          : attachments as List<int>?,
      lang: lang == const $CopyWithPlaceholder()
          ? _value.lang
          // ignore: cast_nullable_to_non_nullable
          : lang as AssistantLanguage?,
    );
  }
}

extension $AssistantAskCopyWith on AssistantAsk {
  /// Returns a callable class that can be used as follows: `instanceOfAssistantAsk.copyWith(...)` or like so:`instanceOfAssistantAsk.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssistantAskCWProxy get copyWith => _$AssistantAskCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantAsk _$AssistantAskFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AssistantAsk', json, ($checkedConvert) {
      final val = AssistantAsk(
        question: $checkedConvert('question', (v) => v as String?),
        attachments: $checkedConvert(
          'attachments',
          (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
        ),
        lang: $checkedConvert(
          'lang',
          (v) => $enumDecodeNullable(_$AssistantLanguageEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$AssistantAskToJson(AssistantAsk instance) =>
    <String, dynamic>{
      'question': ?instance.question,
      'attachments': ?instance.attachments,
      'lang': ?_$AssistantLanguageEnumMap[instance.lang],
    };

const _$AssistantLanguageEnumMap = {
  AssistantLanguage.en: 'en',
  AssistantLanguage.ru: 'ru',
  AssistantLanguage.uz: 'uz',
};
