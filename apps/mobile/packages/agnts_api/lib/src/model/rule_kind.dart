//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// rule: an instruction tickets follow. context: business knowledge (a glossary, invariants, roles) that runs read as /agnts/context/business.md.
enum RuleKind {
      @JsonValue(r'rule')
      rule(r'rule'),
      @JsonValue(r'context')
      context(r'context');

  const RuleKind(this.value);

  final String value;

  @override
  String toString() => value;
}
