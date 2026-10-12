//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// rule: an instruction tickets follow. context: business knowledge (a glossary, invariants, roles) that runs read as /agnts/context/business.md. tip: a practical lesson about working in a repository, learned from runs that had trouble; runs get tips as skills.
enum RuleKind {
      @JsonValue(r'rule')
      rule(r'rule'),
      @JsonValue(r'context')
      context(r'context'),
      @JsonValue(r'tip')
      tip(r'tip');

  const RuleKind(this.value);

  final String value;

  @override
  String toString() => value;
}
