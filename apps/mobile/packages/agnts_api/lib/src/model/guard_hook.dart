//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum GuardHook {
      @JsonValue(r'pre:secret')
      preColonSecret(r'pre:secret'),
      @JsonValue(r'pre:redflags')
      preColonRedflags(r'pre:redflags'),
      @JsonValue(r'pre:rules')
      preColonRules(r'pre:rules'),
      @JsonValue(r'pre:fact-check')
      preColonFactCheck(r'pre:fact-check'),
      @JsonValue(r'pre:destructive')
      preColonDestructive(r'pre:destructive'),
      @JsonValue(r'post:edit-check')
      postColonEditCheck(r'post:edit-check'),
      @JsonValue(r'stop:gate')
      stopColonGate(r'stop:gate'),
      @JsonValue(r'session:progress')
      sessionColonProgress(r'session:progress');

  const GuardHook(this.value);

  final String value;

  @override
  String toString() => value;
}
