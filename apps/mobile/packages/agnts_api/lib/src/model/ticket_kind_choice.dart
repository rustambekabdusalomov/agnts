//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// A kind, or auto for agnts to pick one during analysis
enum TicketKindChoice {
      @JsonValue(r'auto')
      auto(r'auto'),
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

  const TicketKindChoice(this.value);

  final String value;

  @override
  String toString() => value;
}
