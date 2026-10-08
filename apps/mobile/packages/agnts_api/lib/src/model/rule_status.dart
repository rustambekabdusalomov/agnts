//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// Where Claude's review stands. Tickets follow a rule only when it is ready and enabled. A suggested rule is one agnts proposed from feedback: adopt it with a review or as written, or delete it to dismiss it (it is then not suggested again).
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
      failed(r'failed'),
      @JsonValue(r'suggested')
      suggested(r'suggested');

  const RuleStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
