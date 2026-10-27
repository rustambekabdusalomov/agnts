//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/translation_language.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'document_translation.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DocumentTranslation {
  /// Returns a new [DocumentTranslation] instance.
  DocumentTranslation({

    required  this.lang,

    required  this.version,

    required  this.title,

    required  this.body,

    required  this.complete,
  });

  @JsonKey(
    
    name: r'lang',
    required: true,
    includeIfNull: false,
  )


  final TranslationLanguage lang;



      /// The version translated
  @JsonKey(
    
    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final int version;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



      /// The Markdown, rendered like the original
  @JsonKey(
    
    name: r'body',
    required: true,
    includeIfNull: false,
  )


  final String body;



      /// False when some blocks are still as written
  @JsonKey(
    
    name: r'complete',
    required: true,
    includeIfNull: false,
  )


  final bool complete;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DocumentTranslation &&
      other.lang == lang &&
      other.version == version &&
      other.title == title &&
      other.body == body &&
      other.complete == complete;

    @override
    int get hashCode =>
        lang.hashCode +
        version.hashCode +
        title.hashCode +
        body.hashCode +
        complete.hashCode;

  factory DocumentTranslation.fromJson(Map<String, dynamic> json) => _$DocumentTranslationFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentTranslationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

