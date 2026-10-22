//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'document_version.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DocumentVersion {
  /// Returns a new [DocumentVersion] instance.
  DocumentVersion({

    required  this.version,

    required  this.title,

     this.body,

    required  this.source_,

    required  this.note,

     this.authorId,

     this.authorName,

    required  this.createdAt,
  });

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



      /// Only when one version is asked for
  @JsonKey(
    
    name: r'body',
    required: false,
    includeIfNull: false,
  )


  final String? body;



  @JsonKey(
    
    name: r'source',
    required: true,
    includeIfNull: false,
  )


  final DocumentVersionSource_Enum source_;



  @JsonKey(
    
    name: r'note',
    required: true,
    includeIfNull: false,
  )


  final String note;



  @JsonKey(
    
    name: r'authorId',
    required: false,
    includeIfNull: false,
  )


  final int? authorId;



  @JsonKey(
    
    name: r'authorName',
    required: false,
    includeIfNull: false,
  )


  final String? authorName;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DocumentVersion &&
      other.version == version &&
      other.title == title &&
      other.body == body &&
      other.source_ == source_ &&
      other.note == note &&
      other.authorId == authorId &&
      other.authorName == authorName &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        version.hashCode +
        title.hashCode +
        body.hashCode +
        source_.hashCode +
        note.hashCode +
        authorId.hashCode +
        authorName.hashCode +
        createdAt.hashCode;

  factory DocumentVersion.fromJson(Map<String, dynamic> json) => _$DocumentVersionFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentVersionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum DocumentVersionSource_Enum {
@JsonValue(r'human')
human(r'human'),
@JsonValue(r'ai')
ai(r'ai'),
@JsonValue(r'restore')
restore(r'restore');

const DocumentVersionSource_Enum(this.value);

final String value;

@override
String toString() => value;
}


