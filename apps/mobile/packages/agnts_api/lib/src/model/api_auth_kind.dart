//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum ApiAuthKind {
      @JsonValue(r'none')
      none(r'none'),
      @JsonValue(r'bearer')
      bearer(r'bearer'),
      @JsonValue(r'header')
      header(r'header'),
      @JsonValue(r'query')
      query(r'query'),
      @JsonValue(r'basic')
      basic(r'basic');

  const ApiAuthKind(this.value);

  final String value;

  @override
  String toString() => value;
}
