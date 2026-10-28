//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/assistant_conversation.dart';
import 'package:agnts_api/src/model/code_approval.dart';
import 'package:agnts_api/src/model/timeline_item.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'code_timeline.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CodeTimeline {
  /// Returns a new [CodeTimeline] instance.
  CodeTimeline({

    required  this.conversation,

    required  this.items,

    required  this.approvals,
  });

  @JsonKey(
    
    name: r'conversation',
    required: true,
    includeIfNull: false,
  )


  final AssistantConversation conversation;



  @JsonKey(
    
    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<TimelineItem> items;



      /// Tool calls waiting for your decision
  @JsonKey(
    
    name: r'approvals',
    required: true,
    includeIfNull: false,
  )


  final List<CodeApproval> approvals;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CodeTimeline &&
      other.conversation == conversation &&
      other.items == items &&
      other.approvals == approvals;

    @override
    int get hashCode =>
        conversation.hashCode +
        items.hashCode +
        approvals.hashCode;

  factory CodeTimeline.fromJson(Map<String, dynamic> json) => _$CodeTimelineFromJson(json);

  Map<String, dynamic> toJson() => _$CodeTimelineToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

