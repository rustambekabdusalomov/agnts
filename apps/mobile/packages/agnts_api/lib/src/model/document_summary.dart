//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/document_access.dart';
import 'package:agnts_api/src/model/document_generation.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'document_summary.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DocumentSummary {
  /// Returns a new [DocumentSummary] instance.
  DocumentSummary({

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


  final DocumentSummaryTypeEnum type;



      /// Everyone in the workspace gets at least this
  @JsonKey(
    
    name: r'workspaceAccess',
    required: true,
    includeIfNull: false,
  )


  final DocumentSummaryWorkspaceAccessEnum workspaceAccess;



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


  final DocumentSummaryLanguageEnum language;



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





    @override
    bool operator ==(Object other) => identical(this, other) || other is DocumentSummary &&
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
      other.deletedAt == deletedAt;

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
        deletedAt.hashCode;

  factory DocumentSummary.fromJson(Map<String, dynamic> json) => _$DocumentSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum DocumentSummaryTypeEnum {
@JsonValue(r'private')
private(r'private'),
@JsonValue(r'public')
public(r'public');

const DocumentSummaryTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


/// Everyone in the workspace gets at least this
enum DocumentSummaryWorkspaceAccessEnum {
@JsonValue(r'none')
none(r'none'),
@JsonValue(r'view')
view(r'view'),
@JsonValue(r'edit')
edit(r'edit');

const DocumentSummaryWorkspaceAccessEnum(this.value);

final String value;

@override
String toString() => value;
}


enum DocumentSummaryLanguageEnum {
@JsonValue(r'en')
en(r'en'),
@JsonValue(r'ru')
ru(r'ru'),
@JsonValue(r'uz')
uz(r'uz');

const DocumentSummaryLanguageEnum(this.value);

final String value;

@override
String toString() => value;
}


