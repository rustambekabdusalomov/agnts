//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/ticket_kind.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'accept_follow_up.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AcceptFollowUp {
  /// Returns a new [AcceptFollowUp] instance.
  AcceptFollowUp({

    required  this.id,

     this.target,

     this.title,

     this.description,

     this.kind,

     this.priority,

     this.repoId,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



      /// local = an agnts task (default), jira = a new issue in the Jira project, plane = a new work item in the Plane project
  @JsonKey(
    
    name: r'target',
    required: false,
    includeIfNull: false,
  )


  final AcceptFollowUpTargetEnum? target;



  @JsonKey(
    
    name: r'title',
    required: false,
    includeIfNull: false,
  )


  final String? title;



  @JsonKey(
    
    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;



  @JsonKey(
    
    name: r'kind',
    required: false,
    includeIfNull: false,
  )


  final TicketKind? kind;



  @JsonKey(
    
    name: r'priority',
    required: false,
    includeIfNull: false,
  )


  final AcceptFollowUpPriorityEnum? priority;



      /// Defaults to the parent ticket's repository
  @JsonKey(
    
    name: r'repoId',
    required: false,
    includeIfNull: false,
  )


  final int? repoId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AcceptFollowUp &&
      other.id == id &&
      other.target == target &&
      other.title == title &&
      other.description == description &&
      other.kind == kind &&
      other.priority == priority &&
      other.repoId == repoId;

    @override
    int get hashCode =>
        id.hashCode +
        target.hashCode +
        title.hashCode +
        description.hashCode +
        kind.hashCode +
        priority.hashCode +
        repoId.hashCode;

  factory AcceptFollowUp.fromJson(Map<String, dynamic> json) => _$AcceptFollowUpFromJson(json);

  Map<String, dynamic> toJson() => _$AcceptFollowUpToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// local = an agnts task (default), jira = a new issue in the Jira project, plane = a new work item in the Plane project
enum AcceptFollowUpTargetEnum {
@JsonValue(r'local')
local(r'local'),
@JsonValue(r'jira')
jira(r'jira'),
@JsonValue(r'plane')
plane(r'plane');

const AcceptFollowUpTargetEnum(this.value);

final String value;

@override
String toString() => value;
}


enum AcceptFollowUpPriorityEnum {
@JsonValue(r'low')
low(r'low'),
@JsonValue(r'medium')
medium(r'medium'),
@JsonValue(r'high')
high(r'high');

const AcceptFollowUpPriorityEnum(this.value);

final String value;

@override
String toString() => value;
}


