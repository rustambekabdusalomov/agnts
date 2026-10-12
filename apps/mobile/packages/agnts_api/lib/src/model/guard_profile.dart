//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum GuardProfile {
      @JsonValue(r'minimal')
      minimal(r'minimal'),
      @JsonValue(r'standard')
      standard(r'standard'),
      @JsonValue(r'strict')
      strict(r'strict');

  const GuardProfile(this.value);

  final String value;

  @override
  String toString() => value;
}
