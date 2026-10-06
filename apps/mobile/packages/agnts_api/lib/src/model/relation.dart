//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/relation_type.dart';
import 'package:agnts_api/src/model/related_ticket.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'relation.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Relation {
  /// Returns a new [Relation] instance.
  Relation({

    required  this.id,

    required  this.type,

    required  this.direction,

    required  this.source_,

    required  this.status,

    required  this.confidence,

    required  this.reason,

    required  this.basis,

    required  this.files,

    required  this.other,

     this.confirmedAt,

     this.decidedAt,

    required  this.createdAt,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'type',
    required: true,
    includeIfNull: false,
  )


  final RelationType type;



      /// From the ticket asked about: it waits for other, other waits for it, or they conflict
  @JsonKey(
    
    name: r'direction',
    required: true,
    includeIfNull: false,
  )


  final RelationDirectionEnum direction;



      /// Who found it: a Jira link, a person, the analysis, overlapping footprints, or the finished diffs (when nobody predicted it)
  @JsonKey(
    
    name: r'source',
    required: true,
    includeIfNull: false,
  )


  final RelationSource_Enum source_;



      /// Only active relations hold the queue; proposed ones wait for a person
  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final RelationStatusEnum status;



  @JsonKey(
    
    name: r'confidence',
    required: true,
    includeIfNull: false,
  )


  final double confidence;



  @JsonKey(
    
    name: r'reason',
    required: true,
    includeIfNull: false,
  )


  final String reason;



      /// For rule and git relations: files, migrations, lockfile, codegen, i18n or diff
  @JsonKey(
    
    name: r'basis',
    required: true,
    includeIfNull: false,
  )


  final String basis;



      /// Files both tickets change, when known
  @JsonKey(
    
    name: r'files',
    required: true,
    includeIfNull: false,
  )


  final List<String> files;



  @JsonKey(
    
    name: r'other',
    required: true,
    includeIfNull: false,
  )


  final RelatedTicket other;



      /// When the finished changes proved the conflict real
  @JsonKey(
    
    name: r'confirmedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? confirmedAt;



  @JsonKey(
    
    name: r'decidedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? decidedAt;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Relation &&
      other.id == id &&
      other.type == type &&
      other.direction == direction &&
      other.source_ == source_ &&
      other.status == status &&
      other.confidence == confidence &&
      other.reason == reason &&
      other.basis == basis &&
      other.files == files &&
      other.other == other &&
      other.confirmedAt == confirmedAt &&
      other.decidedAt == decidedAt &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        type.hashCode +
        direction.hashCode +
        source_.hashCode +
        status.hashCode +
        confidence.hashCode +
        reason.hashCode +
        basis.hashCode +
        files.hashCode +
        other.hashCode +
        confirmedAt.hashCode +
        decidedAt.hashCode +
        createdAt.hashCode;

  factory Relation.fromJson(Map<String, dynamic> json) => _$RelationFromJson(json);

  Map<String, dynamic> toJson() => _$RelationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// From the ticket asked about: it waits for other, other waits for it, or they conflict
enum RelationDirectionEnum {
@JsonValue(r'waits_for')
waitsFor(r'waits_for'),
@JsonValue(r'waited_by')
waitedBy(r'waited_by'),
@JsonValue(r'conflicts')
conflicts(r'conflicts');

const RelationDirectionEnum(this.value);

final String value;

@override
String toString() => value;
}


/// Who found it: a Jira link, a person, the analysis, overlapping footprints, or the finished diffs (when nobody predicted it)
enum RelationSource_Enum {
@JsonValue(r'jira')
jira(r'jira'),
@JsonValue(r'user')
user(r'user'),
@JsonValue(r'agnts')
agnts(r'agnts'),
@JsonValue(r'rule')
rule(r'rule'),
@JsonValue(r'git')
git(r'git');

const RelationSource_Enum(this.value);

final String value;

@override
String toString() => value;
}


/// Only active relations hold the queue; proposed ones wait for a person
enum RelationStatusEnum {
@JsonValue(r'active')
active(r'active'),
@JsonValue(r'proposed')
proposed(r'proposed'),
@JsonValue(r'dismissed')
dismissed(r'dismissed');

const RelationStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


