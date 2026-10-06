//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum CI {
      @JsonValue(r'ok')
      ok(r'ok'),
      @JsonValue(r'fail')
      fail(r'fail'),
      @JsonValue(r'run')
      run(r'run'),
      @JsonValue(r'pending')
      pending(r'pending'),
      @JsonValue(r'manual')
      manual(r'manual'),
      @JsonValue(r'skip')
      skip(r'skip'),
      @JsonValue(r'canceled')
      canceled(r'canceled'),
      @JsonValue(r'none')
      none(r'none');

  const CI(this.value);

  final String value;

  @override
  String toString() => value;
}
