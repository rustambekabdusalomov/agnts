//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/document_source_input.dart';
import 'package:agnts_api/src/model/document_access.dart';
import 'package:agnts_api/src/model/document_generation.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'document.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Document {
  /// Returns a new [Document] instance.
  Document({

    required  this.id,

    required  this.title,

    required  this.version,

    required  this.type,

    required  this.workspaceAccess,

    required  this.ownerId,

    required  this.ownerName,

    required  this.language,

    required  this.access,

    required  this.ticketCount,

     this.generation,

    required  this.createdAt,

    required  this.updatedAt,

     this.deletedAt,

    required  this.body,

     this.publicUrl,

     this.source_,

     this.dataAsOf,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



      /// The current version; 0 while agnts writes the first one
  @JsonKey(
    
    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final int version;



  @JsonKey(
    
    name: r'type',
    required: true,
    includeIfNull: false,
  )


  final DocumentTypeEnum type;



      /// Everyone in the workspace gets at least this
  @JsonKey(
    
    name: r'workspaceAccess',
    required: true,
    includeIfNull: false,
  )


  final DocumentWorkspaceAccessEnum workspaceAccess;



  @JsonKey(
    
    name: r'ownerId',
    required: true,
    includeIfNull: false,
  )


  final int ownerId;



  @JsonKey(
    
    name: r'ownerName',
    required: true,
    includeIfNull: false,
  )


  final String ownerName;



  @JsonKey(
    
    name: r'language',
    required: true,
    includeIfNull: false,
  )


  final DocumentLanguageEnum language;



  @JsonKey(
    
    name: r'access',
    required: true,
    includeIfNull: false,
  )


  final DocumentAccess access;



  @JsonKey(
    
    name: r'ticketCount',
    required: true,
    includeIfNull: false,
  )


  final int ticketCount;



  @JsonKey(
    
    name: r'generation',
    required: false,
    includeIfNull: false,
  )


  final DocumentGeneration? generation;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;



  @JsonKey(
    
    name: r'updatedAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime updatedAt;



  @JsonKey(
    
    name: r'deletedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? deletedAt;



      /// Markdown
  @JsonKey(
    
    name: r'body',
    required: true,
    includeIfNull: false,
  )


  final String body;



      /// The public link, while the document is public
  @JsonKey(
    
    name: r'publicUrl',
    required: false,
    includeIfNull: false,
  )


  final String? publicUrl;



  @JsonKey(
    
    name: r'source',
    required: false,
    includeIfNull: false,
  )


  final DocumentSourceInput? source_;



      /// When agnts gathered the facts of the current AI version
  @JsonKey(
    
    name: r'dataAsOf',
    required: false,
    includeIfNull: false,
  )


  final DateTime? dataAsOf;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Document &&
      other.id == id &&
      other.title == title &&
      other.version == version &&
      other.type == type &&
      other.workspaceAccess == workspaceAccess &&
      other.ownerId == ownerId &&
      other.ownerName == ownerName &&
      other.language == language &&
      other.access == access &&
      other.ticketCount == ticketCount &&
      other.generation == generation &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.deletedAt == deletedAt &&
      other.body == body &&
      other.publicUrl == publicUrl &&
      other.source_ == source_ &&
      other.dataAsOf == dataAsOf;

    @override
    int get hashCode =>
        id.hashCode +
        title.hashCode +
        version.hashCode +
        type.hashCode +
        workspaceAccess.hashCode +
        ownerId.hashCode +
        ownerName.hashCode +
        language.hashCode +
        access.hashCode +
        ticketCount.hashCode +
        generation.hashCode +
        createdAt.hashCode +
        updatedAt.hashCode +
        deletedAt.hashCode +
        body.hashCode +
        publicUrl.hashCode +
        source_.hashCode +
        dataAsOf.hashCode;

  factory Document.fromJson(Map<String, dynamic> json) => _$DocumentFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum DocumentTypeEnum {
@JsonValue(r'private')
private(r'private'),
@JsonValue(r'public')
public(r'public');

const DocumentTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


/// Everyone in the workspace gets at least this
enum DocumentWorkspaceAccessEnum {
@JsonValue(r'none')
none(r'none'),
@JsonValue(r'view')
view(r'view'),
@JsonValue(r'edit')
edit(r'edit');

const DocumentWorkspaceAccessEnum(this.value);

final String value;

@override
String toString() => value;
}


enum DocumentLanguageEnum {
@JsonValue(r'en')
en(r'en'),
@JsonValue(r'ru')
ru(r'ru'),
@JsonValue(r'uz')
uz(r'uz');

const DocumentLanguageEnum(this.value);

final String value;

@override
String toString() => value;
}


