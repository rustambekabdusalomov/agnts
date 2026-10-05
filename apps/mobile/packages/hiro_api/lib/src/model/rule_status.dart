//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// Where Claude's review stands. Tickets follow a rule only when it is ready and enabled.
enum RuleStatus {
      @JsonValue(r'pending')
      pending(r'pending'),
      @JsonValue(r'analyzing')
      analyzing(r'analyzing'),
      @JsonValue(r'questions')
      questions(r'questions'),
      @JsonValue(r'ready')
      ready(r'ready'),
      @JsonValue(r'failed')
      failed(r'failed');

  const RuleStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
