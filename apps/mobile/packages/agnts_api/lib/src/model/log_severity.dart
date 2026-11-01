//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum LogSeverity {
      @JsonValue(r'low')
      low(r'low'),
      @JsonValue(r'medium')
      medium(r'medium'),
      @JsonValue(r'high')
      high(r'high'),
      @JsonValue(r'critical')
      critical(r'critical');

  const LogSeverity(this.value);

  final String value;

  @override
  String toString() => value;
}
