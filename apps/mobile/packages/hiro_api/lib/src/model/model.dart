//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum Model {
      @JsonValue(r'haiku')
      haiku(r'haiku'),
      @JsonValue(r'sonnet')
      sonnet(r'sonnet'),
      @JsonValue(r'opus')
      opus(r'opus');

  const Model(this.value);

  final String value;

  @override
  String toString() => value;
}
