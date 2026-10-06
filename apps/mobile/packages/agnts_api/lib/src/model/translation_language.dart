//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// A language agnts can translate into
enum TranslationLanguage {
      @JsonValue(r'en')
      en(r'en'),
      @JsonValue(r'ru')
      ru(r'ru'),
      @JsonValue(r'uz')
      uz(r'uz'),
      @JsonValue(r'kk')
      kk(r'kk'),
      @JsonValue(r'tr')
      tr(r'tr'),
      @JsonValue(r'de')
      de(r'de'),
      @JsonValue(r'es')
      es(r'es'),
      @JsonValue(r'fr')
      fr(r'fr'),
      @JsonValue(r'zh')
      zh(r'zh'),
      @JsonValue(r'ja')
      ja(r'ja'),
      @JsonValue(r'ko')
      ko(r'ko'),
      @JsonValue(r'ar')
      ar(r'ar');

  const TranslationLanguage(this.value);

  final String value;

  @override
  String toString() => value;
}
