//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum LessonCategory {
      @JsonValue(r'pattern')
      pattern(r'pattern'),
      @JsonValue(r'architecture')
      architecture(r'architecture'),
      @JsonValue(r'algorithm')
      algorithm(r'algorithm'),
      @JsonValue(r'library')
      library_(r'library'),
      @JsonValue(r'language')
      language(r'language'),
      @JsonValue(r'testing')
      testing(r'testing'),
      @JsonValue(r'security')
      security(r'security'),
      @JsonValue(r'performance')
      performance(r'performance'),
      @JsonValue(r'tooling')
      tooling(r'tooling'),
      @JsonValue(r'other')
      other(r'other');

  const LessonCategory(this.value);

  final String value;

  @override
  String toString() => value;
}
