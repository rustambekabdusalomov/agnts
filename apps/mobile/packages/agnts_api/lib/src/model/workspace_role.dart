//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// owner runs the workspace; user works in it; viewer sees everything and changes nothing
enum WorkspaceRole {
      @JsonValue(r'owner')
      owner(r'owner'),
      @JsonValue(r'user')
      user(r'user'),
      @JsonValue(r'viewer')
      viewer(r'viewer');

  const WorkspaceRole(this.value);

  final String value;

  @override
  String toString() => value;
}
