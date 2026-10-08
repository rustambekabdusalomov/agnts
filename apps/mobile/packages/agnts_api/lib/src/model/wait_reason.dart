//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// Why a ticket waits for a worker: blocked (related tickets or held, for the team), slots (the workspace's runs are in use), server (no memory left on the server, for the platform), claude (the Claude account is at its limit or missing).
enum WaitReason {
      @JsonValue(r'blocked')
      blocked(r'blocked'),
      @JsonValue(r'slots')
      slots(r'slots'),
      @JsonValue(r'server')
      server(r'server'),
      @JsonValue(r'claude')
      claude(r'claude');

  const WaitReason(this.value);

  final String value;

  @override
  String toString() => value;
}
