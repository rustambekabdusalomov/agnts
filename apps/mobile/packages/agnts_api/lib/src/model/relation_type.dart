//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// depends_on: one waits for the other to merge; conflicts: both change the same code, so they do not run side by side
enum RelationType {
      @JsonValue(r'depends_on')
      dependsOn(r'depends_on'),
      @JsonValue(r'conflicts')
      conflicts(r'conflicts');

  const RelationType(this.value);

  final String value;

  @override
  String toString() => value;
}
