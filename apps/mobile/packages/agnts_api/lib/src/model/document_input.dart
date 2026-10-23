//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/document_source_input.dart';
import 'package:agnts_api/src/model/document_kind.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'document_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DocumentInput {
  /// Returns a new [DocumentInput] instance.
  DocumentInput({

     this.kind,

    required  this.title,

     this.body,

     this.language,

     this.source_,

     this.linkTickets,
  });

  @JsonKey(
    
    name: r'kind',
    required: false,
    includeIfNull: false,
  )


  final DocumentKind? kind;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(
    
    name: r'body',
    required: false,
    includeIfNull: false,
  )


  final String? body;



  @JsonKey(
    
    name: r'language',
    required: false,
    includeIfNull: false,
  )


  final DocumentInputLanguageEnum? language;



  @JsonKey(
    
    name: r'source',
    required: false,
    includeIfNull: false,
  )


  final DocumentSourceInput? source_;



  @JsonKey(
    
    name: r'linkTickets',
    required: false,
    includeIfNull: false,
  )


  final List<String>? linkTickets;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DocumentInput &&
      other.kind == kind &&
      other.title == title &&
      other.body == body &&
      other.language == language &&
      other.source_ == source_ &&
      other.linkTickets == linkTickets;

    @override
    int get hashCode =>
        kind.hashCode +
        title.hashCode +
        body.hashCode +
        language.hashCode +
        source_.hashCode +
        linkTickets.hashCode;

  factory DocumentInput.fromJson(Map<String, dynamic> json) => _$DocumentInputFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum DocumentInputLanguageEnum {
@JsonValue(r'en')
en(r'en'),
@JsonValue(r'ru')
ru(r'ru'),
@JsonValue(r'uz')
uz(r'uz');

const DocumentInputLanguageEnum(this.value);

final String value;

@override
String toString() => value;
}


