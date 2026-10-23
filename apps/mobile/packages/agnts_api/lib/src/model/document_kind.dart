//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// page: a document to read; slides: a deck to present, Markdown with a line --- between slides and \"Notes:\" starting a slide's speaker notes
enum DocumentKind {
      @JsonValue(r'page')
      page(r'page'),
      @JsonValue(r'slides')
      slides(r'slides');

  const DocumentKind(this.value);

  final String value;

  @override
  String toString() => value;
}
