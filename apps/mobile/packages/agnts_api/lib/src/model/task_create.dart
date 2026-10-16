//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/follow_ups_mode.dart';
import 'package:agnts_api/src/model/ticket_kind_choice.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'task_create.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TaskCreate {
  /// Returns a new [TaskCreate] instance.
  TaskCreate({

     this.repoId,

     this.repoIds,

     this.groupId,

     this.kind,

    required  this.title,

     this.description,

     this.ticketNumber,

    required  this.priority,

    required  this.afterApprove,

    required  this.start,

     this.followUps,

     this.attachments,
  });

      /// Omit for a task without a repository (report kinds or auto)
  @JsonKey(
    
    name: r'repoId',
    required: false,
    includeIfNull: false,
  )


  final int? repoId;



      /// Several repositories instead of repoId; the first is the primary. Give one of repoId, repoIds and groupId.
  @JsonKey(
    
    name: r'repoIds',
    required: false,
    includeIfNull: false,
  )


  final List<int>? repoIds;



      /// A repository group: the task works in its repositories (copied now)
  @JsonKey(
    
    name: r'groupId',
    required: false,
    includeIfNull: false,
  )


  final int? groupId;



  @JsonKey(
    
    name: r'kind',
    required: false,
    includeIfNull: false,
  )


  final TicketKindChoice? kind;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(
    
    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;



      /// The team's number for the work (AMANAT-2288), used in branch and commit names
  @JsonKey(
    
    name: r'ticketNumber',
    required: false,
    includeIfNull: false,
  )


  final String? ticketNumber;



  @JsonKey(
    
    name: r'priority',
    required: true,
    includeIfNull: false,
  )


  final TaskCreatePriorityEnum priority;



  @JsonKey(
    
    name: r'afterApprove',
    required: true,
    includeIfNull: false,
  )


  final TaskCreateAfterApproveEnum afterApprove;



      /// ask = analyse and ask first, code = no questions, queue = keep until started
  @JsonKey(
    
    name: r'start',
    required: true,
    includeIfNull: false,
  )


  final TaskCreateStartEnum start;



  @JsonKey(
    
    name: r'followUps',
    required: false,
    includeIfNull: false,
  )


  final FollowUpsMode? followUps;



      /// Uploads to attach to the description
  @JsonKey(
    
    name: r'attachments',
    required: false,
    includeIfNull: false,
  )


  final List<int>? attachments;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TaskCreate &&
      other.repoId == repoId &&
      other.repoIds == repoIds &&
      other.groupId == groupId &&
      other.kind == kind &&
      other.title == title &&
      other.description == description &&
      other.ticketNumber == ticketNumber &&
      other.priority == priority &&
      other.afterApprove == afterApprove &&
      other.start == start &&
      other.followUps == followUps &&
      other.attachments == attachments;

    @override
    int get hashCode =>
        repoId.hashCode +
        repoIds.hashCode +
        groupId.hashCode +
        kind.hashCode +
        title.hashCode +
        description.hashCode +
        ticketNumber.hashCode +
        priority.hashCode +
        afterApprove.hashCode +
        start.hashCode +
        followUps.hashCode +
        attachments.hashCode;

  factory TaskCreate.fromJson(Map<String, dynamic> json) => _$TaskCreateFromJson(json);

  Map<String, dynamic> toJson() => _$TaskCreateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum TaskCreatePriorityEnum {
@JsonValue(r'low')
low(r'low'),
@JsonValue(r'medium')
medium(r'medium'),
@JsonValue(r'high')
high(r'high');

const TaskCreatePriorityEnum(this.value);

final String value;

@override
String toString() => value;
}


enum TaskCreateAfterApproveEnum {
@JsonValue(r'pr')
pr(r'pr'),
@JsonValue(r'main')
main(r'main');

const TaskCreateAfterApproveEnum(this.value);

final String value;

@override
String toString() => value;
}


/// ask = analyse and ask first, code = no questions, queue = keep until started
enum TaskCreateStartEnum {
@JsonValue(r'ask')
ask(r'ask'),
@JsonValue(r'code')
code(r'code'),
@JsonValue(r'queue')
queue(r'queue');

const TaskCreateStartEnum(this.value);

final String value;

@override
String toString() => value;
}


