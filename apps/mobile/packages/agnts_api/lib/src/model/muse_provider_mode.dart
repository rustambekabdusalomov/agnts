//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// auto: agnts's Meta key, and the fallback while it is out of allowance or credit; primary: the Meta key only; fallback: the fallback only
enum MuseProviderMode {
      @JsonValue(r'auto')
      auto(r'auto'),
      @JsonValue(r'primary')
      primary(r'primary'),
      @JsonValue(r'fallback')
      fallback(r'fallback');

  const MuseProviderMode(this.value);

  final String value;

  @override
  String toString() => value;
}
