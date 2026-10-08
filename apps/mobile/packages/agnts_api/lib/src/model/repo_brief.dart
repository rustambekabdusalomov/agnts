//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'repo_brief.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RepoBrief {
  /// Returns a new [RepoBrief] instance.
  RepoBrief({

    required  this.repoId,

    required  this.repoName,

    required  this.body,

    required  this.bodySha,

    required  this.draft,

    required  this.draftSha,

    required  this.status,

    required  this.mergesSince,

    required  this.refreshAfter,

    required  this.error,

     this.surveyedAt,

     this.approvedAt,

    required  this.updatedAt,
  });

  @JsonKey(
    
    name: r'repoId',
    required: true,
    includeIfNull: false,
  )


  final int repoId;



  @JsonKey(
    
    name: r'repoName',
    required: true,
    includeIfNull: false,
  )


  final String repoName;



      /// The approved brief, Markdown; empty when there is none
  @JsonKey(
    
    name: r'body',
    required: true,
    includeIfNull: false,
  )


  final String body;



      /// The commit the approved brief describes
  @JsonKey(
    
    name: r'bodySha',
    required: true,
    includeIfNull: false,
  )


  final String bodySha;



      /// The latest survey, waiting for approval; empty when there is none
  @JsonKey(
    
    name: r'draft',
    required: true,
    includeIfNull: false,
  )


  final String draft;



  @JsonKey(
    
    name: r'draftSha',
    required: true,
    includeIfNull: false,
  )


  final String draftSha;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final RepoBriefStatusEnum status;



      /// Tickets merged since the brief was approved
  @JsonKey(
    
    name: r'mergesSince',
    required: true,
    includeIfNull: false,
  )


  final int mergesSince;



      /// Merges after which agnts surveys again, when Settings allow
  @JsonKey(
    
    name: r'refreshAfter',
    required: true,
    includeIfNull: false,
  )


  final int refreshAfter;



      /// Why the last survey failed
  @JsonKey(
    
    name: r'error',
    required: true,
    includeIfNull: false,
  )


  final String error;



  @JsonKey(
    
    name: r'surveyedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? surveyedAt;



  @JsonKey(
    
    name: r'approvedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? approvedAt;



  @JsonKey(
    
    name: r'updatedAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime updatedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RepoBrief &&
      other.repoId == repoId &&
      other.repoName == repoName &&
      other.body == body &&
      other.bodySha == bodySha &&
      other.draft == draft &&
      other.draftSha == draftSha &&
      other.status == status &&
      other.mergesSince == mergesSince &&
      other.refreshAfter == refreshAfter &&
      other.error == error &&
      other.surveyedAt == surveyedAt &&
      other.approvedAt == approvedAt &&
      other.updatedAt == updatedAt;

    @override
    int get hashCode =>
        repoId.hashCode +
        repoName.hashCode +
        body.hashCode +
        bodySha.hashCode +
        draft.hashCode +
        draftSha.hashCode +
        status.hashCode +
        mergesSince.hashCode +
        refreshAfter.hashCode +
        error.hashCode +
        surveyedAt.hashCode +
        approvedAt.hashCode +
        updatedAt.hashCode;

  factory RepoBrief.fromJson(Map<String, dynamic> json) => _$RepoBriefFromJson(json);

  Map<String, dynamic> toJson() => _$RepoBriefToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum RepoBriefStatusEnum {
@JsonValue(r'idle')
idle(r'idle'),
@JsonValue(r'pending')
pending(r'pending'),
@JsonValue(r'surveying')
surveying(r'surveying'),
@JsonValue(r'failed')
failed(r'failed');

const RepoBriefStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


