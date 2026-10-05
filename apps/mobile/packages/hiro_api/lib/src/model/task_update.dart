//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:hiro_api/src/model/ticket_kind_choice.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'task_update.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TaskUpdate {
  /// Returns a new [TaskUpdate] instance.
  TaskUpdate({

     this.title,

     this.description,

     this.priority,

     this.afterApprove,

     this.kind,
  });

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
    
    name: r'priority',
    required: false,
    includeIfNull: false,
  )


  final TaskUpdatePriorityEnum? priority;



  @JsonKey(
    
    name: r'afterApprove',
    required: false,
    includeIfNull: false,
  )


  final TaskUpdateAfterApproveEnum? afterApprove;



  @JsonKey(
    
    name: r'kind',
    required: false,
    includeIfNull: false,
  )


  final TicketKindChoice? kind;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TaskUpdate &&
      other.title == title &&
      other.description == description &&
      other.priority == priority &&
      other.afterApprove == afterApprove &&
      other.kind == kind;

    @override
    int get hashCode =>
        title.hashCode +
        description.hashCode +
        priority.hashCode +
        afterApprove.hashCode +
        kind.hashCode;

  factory TaskUpdate.fromJson(Map<String, dynamic> json) => _$TaskUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$TaskUpdateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum TaskUpdatePriorityEnum {
@JsonValue(r'low')
low(r'low'),
@JsonValue(r'medium')
medium(r'medium'),
@JsonValue(r'high')
high(r'high');

const TaskUpdatePriorityEnum(this.value);

final String value;

@override
String toString() => value;
}


enum TaskUpdateAfterApproveEnum {
@JsonValue(r'pr')
pr(r'pr'),
@JsonValue(r'main')
main(r'main');

const TaskUpdateAfterApproveEnum(this.value);

final String value;

@override
String toString() => value;
}


