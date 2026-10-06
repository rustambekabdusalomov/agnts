//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// What the work produces. code and test make a change (diff, checks, pull request); plan, analysis and bug write a Markdown report.
enum TicketKind {
      @JsonValue(r'code')
      code(r'code'),
      @JsonValue(r'test')
      test(r'test'),
      @JsonValue(r'plan')
      plan(r'plan'),
      @JsonValue(r'analysis')
      analysis(r'analysis'),
      @JsonValue(r'bug')
      bug(r'bug');

  const TicketKind(this.value);

  final String value;

  @override
  String toString() => value;
}
