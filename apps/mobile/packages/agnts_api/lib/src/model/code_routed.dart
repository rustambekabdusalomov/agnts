//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// What a Code message did: created a ticket, answered its questions, asked for changes, continued or retried it, waits for the running stage (queued; then sent or failed), or went into the running Muse turn (steered)
enum CodeRouted {
      @JsonValue(r'created')
      created(r'created'),
      @JsonValue(r'answered')
      answered(r'answered'),
      @JsonValue(r'changes')
      changes(r'changes'),
      @JsonValue(r'continued')
      continued(r'continued'),
      @JsonValue(r'retried')
      retried(r'retried'),
      @JsonValue(r'queued')
      queued(r'queued'),
      @JsonValue(r'sent')
      sent(r'sent'),
      @JsonValue(r'failed')
      failed(r'failed'),
      @JsonValue(r'steered')
      steered(r'steered');

  const CodeRouted(this.value);

  final String value;

  @override
  String toString() => value;
}
