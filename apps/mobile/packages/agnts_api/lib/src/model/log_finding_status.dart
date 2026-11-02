//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// open: seen, nothing done yet (below the threshold, or off); reported: shown and notified; fixing: a ticket works on it; fixed: the fix merged; resolved: quiet after the fix; muted: ignored; regression: back after the fix
enum LogFindingStatus {
      @JsonValue(r'open')
      open(r'open'),
      @JsonValue(r'reported')
      reported(r'reported'),
      @JsonValue(r'fixing')
      fixing(r'fixing'),
      @JsonValue(r'fixed')
      fixed(r'fixed'),
      @JsonValue(r'resolved')
      resolved(r'resolved'),
      @JsonValue(r'muted')
      muted(r'muted'),
      @JsonValue(r'regression')
      regression(r'regression');

  const LogFindingStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
