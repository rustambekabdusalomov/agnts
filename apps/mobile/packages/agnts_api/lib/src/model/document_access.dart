//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// What you may do: view reads and downloads; edit also changes the text, regenerates and links tickets; owner also shares, publishes, transfers and deletes
enum DocumentAccess {
      @JsonValue(r'none')
      none(r'none'),
      @JsonValue(r'view')
      view(r'view'),
      @JsonValue(r'edit')
      edit(r'edit'),
      @JsonValue(r'owner')
      owner(r'owner');

  const DocumentAccess(this.value);

  final String value;

  @override
  String toString() => value;
}
