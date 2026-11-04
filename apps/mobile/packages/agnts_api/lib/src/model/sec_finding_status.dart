//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum SecFindingStatus {
      @JsonValue(r'open')
      open(r'open'),
      @JsonValue(r'fixing')
      fixing(r'fixing'),
      @JsonValue(r'verifying')
      verifying(r'verifying'),
      @JsonValue(r'fixed')
      fixed(r'fixed'),
      @JsonValue(r'dismissed')
      dismissed(r'dismissed'),
      @JsonValue(r'reopened')
      reopened(r'reopened');

  const SecFindingStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
