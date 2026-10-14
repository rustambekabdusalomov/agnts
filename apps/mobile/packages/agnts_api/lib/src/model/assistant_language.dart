//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// The language the assistant answers in (the app's)
enum AssistantLanguage {
      @JsonValue(r'en')
      en(r'en'),
      @JsonValue(r'ru')
      ru(r'ru'),
      @JsonValue(r'uz')
      uz(r'uz');

  const AssistantLanguage(this.value);

  final String value;

  @override
  String toString() => value;
}
