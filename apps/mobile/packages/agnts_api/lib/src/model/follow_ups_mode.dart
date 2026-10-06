//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// Follow-up suggestions for one ticket: inherit follows Settings
enum FollowUpsMode {
      @JsonValue(r'inherit')
      inherit(r'inherit'),
      @JsonValue(r'on')
      on_(r'on'),
      @JsonValue(r'off')
      off(r'off');

  const FollowUpsMode(this.value);

  final String value;

  @override
  String toString() => value;
}
