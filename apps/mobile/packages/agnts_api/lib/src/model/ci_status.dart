//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// triage: new, waiting for a re-run; open: confirmed, no ticket working on it; fixing: a ticket works on it; fixed: the fix is merged, waiting for a green run; resolved: green again; flaky: passed on re-run; infra: the runner or the network, not the code; muted: ignored; regression: failed again after the fix was merged
enum CIStatus {
      @JsonValue(r'triage')
      triage(r'triage'),
      @JsonValue(r'open')
      open(r'open'),
      @JsonValue(r'fixing')
      fixing(r'fixing'),
      @JsonValue(r'fixed')
      fixed(r'fixed'),
      @JsonValue(r'resolved')
      resolved(r'resolved'),
      @JsonValue(r'flaky')
      flaky(r'flaky'),
      @JsonValue(r'infra')
      infra(r'infra'),
      @JsonValue(r'muted')
      muted(r'muted'),
      @JsonValue(r'regression')
      regression(r'regression');

  const CIStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
