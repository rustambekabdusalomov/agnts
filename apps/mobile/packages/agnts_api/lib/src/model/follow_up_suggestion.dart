//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/ticket_kind.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'follow_up_suggestion.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FollowUpSuggestion {
  /// Returns a new [FollowUpSuggestion] instance.
  FollowUpSuggestion({

    required  this.id,

    required  this.source_,

    required  this.type,

    required  this.revision,

    required  this.title,

    required  this.description,

    required  this.serves,

    required  this.kind,

    required  this.priority,

    required  this.status,

    required  this.ready,

     this.after,

     this.childKey,

     this.repoIds,

     this.decidedAt,

    required  this.createdAt,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



      /// The run that suggested it; manual = made from a review finding
  @JsonKey(
    
    name: r'source',
    required: true,
    includeIfNull: false,
  )


  final FollowUpSuggestionSource_Enum source_;



      /// How it serves the parent ticket
  @JsonKey(
    
    name: r'type',
    required: true,
    includeIfNull: false,
  )


  final FollowUpSuggestionTypeEnum type;



      /// The parent's revision when it was suggested
  @JsonKey(
    
    name: r'revision',
    required: true,
    includeIfNull: false,
  )


  final int revision;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(
    
    name: r'description',
    required: true,
    includeIfNull: false,
  )


  final String description;



      /// How it helps finish the parent ticket
  @JsonKey(
    
    name: r'serves',
    required: true,
    includeIfNull: false,
  )


  final String serves;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final TicketKind kind;



  @JsonKey(
    
    name: r'priority',
    required: true,
    includeIfNull: false,
  )


  final FollowUpSuggestionPriorityEnum priority;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final FollowUpSuggestionStatusEnum status;



      /// A ticket can be made from it now (open, and the parent is done unless the analysis suggested it)
  @JsonKey(
    
    name: r'ready',
    required: true,
    includeIfNull: false,
  )


  final bool ready;



      /// Ids of sibling suggestions that must land first; once both are tickets, this one depends on them
  @JsonKey(
    
    name: r'after',
    required: false,
    includeIfNull: false,
  )


  final List<int>? after;



      /// The ticket made from it
  @JsonKey(
    
    name: r'childKey',
    required: false,
    includeIfNull: false,
  )


  final String? childKey;



      /// The parent's repositories it is about; absent for all of them
  @JsonKey(
    
    name: r'repoIds',
    required: false,
    includeIfNull: false,
  )


  final List<int>? repoIds;



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
    bool operator ==(Object other) => identical(this, other) || other is FollowUpSuggestion &&
      other.id == id &&
      other.source_ == source_ &&
      other.type == type &&
      other.revision == revision &&
      other.title == title &&
      other.description == description &&
      other.serves == serves &&
      other.kind == kind &&
      other.priority == priority &&
      other.status == status &&
      other.ready == ready &&
      other.after == after &&
      other.childKey == childKey &&
      other.repoIds == repoIds &&
      other.decidedAt == decidedAt &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        source_.hashCode +
        type.hashCode +
        revision.hashCode +
        title.hashCode +
        description.hashCode +
        serves.hashCode +
        kind.hashCode +
        priority.hashCode +
        status.hashCode +
        ready.hashCode +
        after.hashCode +
        childKey.hashCode +
        repoIds.hashCode +
        decidedAt.hashCode +
        createdAt.hashCode;

  factory FollowUpSuggestion.fromJson(Map<String, dynamic> json) => _$FollowUpSuggestionFromJson(json);

  Map<String, dynamic> toJson() => _$FollowUpSuggestionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// The run that suggested it; manual = made from a review finding
enum FollowUpSuggestionSource_Enum {
@JsonValue(r'analyze')
analyze(r'analyze'),
@JsonValue(r'work')
work(r'work'),
@JsonValue(r'review')
review(r'review'),
@JsonValue(r'manual')
manual(r'manual');

const FollowUpSuggestionSource_Enum(this.value);

final String value;

@override
String toString() => value;
}


/// How it serves the parent ticket
enum FollowUpSuggestionTypeEnum {
@JsonValue(r'prerequisite')
prerequisite(r'prerequisite'),
@JsonValue(r'split')
split(r'split'),
@JsonValue(r'unfinished')
unfinished(r'unfinished'),
@JsonValue(r'gap')
gap(r'gap');

const FollowUpSuggestionTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


enum FollowUpSuggestionPriorityEnum {
@JsonValue(r'low')
low(r'low'),
@JsonValue(r'medium')
medium(r'medium'),
@JsonValue(r'high')
high(r'high');

const FollowUpSuggestionPriorityEnum(this.value);

final String value;

@override
String toString() => value;
}


enum FollowUpSuggestionStatusEnum {
@JsonValue(r'open')
open(r'open'),
@JsonValue(r'accepted')
accepted(r'accepted'),
@JsonValue(r'dismissed')
dismissed(r'dismissed');

const FollowUpSuggestionStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


