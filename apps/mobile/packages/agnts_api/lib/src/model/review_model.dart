//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// auto: opus for complex tickets, sonnet otherwise
enum ReviewModel {
      @JsonValue(r'auto')
      auto(r'auto'),
      @JsonValue(r'haiku')
      haiku(r'haiku'),
      @JsonValue(r'sonnet')
      sonnet(r'sonnet'),
      @JsonValue(r'opus')
      opus(r'opus');

  const ReviewModel(this.value);

  final String value;

  @override
  String toString() => value;
}
