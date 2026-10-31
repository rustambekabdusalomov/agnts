//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// A coding module: Muse Code (Meta), Claude Code (Anthropic) or Codex (OpenAI)
enum Module {
      @JsonValue(r'muse')
      muse(r'muse'),
      @JsonValue(r'claude')
      claude(r'claude'),
      @JsonValue(r'codex')
      codex(r'codex');

  const Module(this.value);

  final String value;

  @override
  String toString() => value;
}
