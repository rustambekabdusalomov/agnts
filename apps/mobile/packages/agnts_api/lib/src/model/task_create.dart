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

     this.kind,

    required  this.title,

     this.description,

    required  this.priority,

    required  this.afterApprove,

    required  this.start,

     this.followUps,
  });

      /// Omit for a task without a repository (report kinds or auto)
  @JsonKey(
    
    name: r'repoId',
    required: false,
    includeIfNull: false,
  )


  final int? repoId;



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





    @override
    bool operator ==(Object other) => identical(this, other) || other is TaskCreate &&
      other.repoId == repoId &&
      other.kind == kind &&
      other.title == title &&
      other.description == description &&
      other.priority == priority &&
      other.afterApprove == afterApprove &&
      other.start == start &&
      other.followUps == followUps;

    @override
    int get hashCode =>
        repoId.hashCode +
        kind.hashCode +
        title.hashCode +
        description.hashCode +
        priority.hashCode +
        afterApprove.hashCode +
        start.hashCode +
        followUps.hashCode;

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


