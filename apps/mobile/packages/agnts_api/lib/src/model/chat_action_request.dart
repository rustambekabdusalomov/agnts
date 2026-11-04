//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/chat_action_request_draft.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_action_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ChatActionRequest {
  /// Returns a new [ChatActionRequest] instance.
  ChatActionRequest({

    required  this.action,

     this.feedback,

     this.draft,
  });

  @JsonKey(
    
    name: r'action',
    required: true,
    includeIfNull: false,
  )


  final ChatActionRequestActionEnum action;



      /// What to change (request_changes)
  @JsonKey(
    
    name: r'feedback',
    required: false,
    includeIfNull: false,
  )


  final String? feedback;



  @JsonKey(
    
    name: r'draft',
    required: false,
    includeIfNull: false,
  )


  final ChatActionRequestDraft? draft;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ChatActionRequest &&
      other.action == action &&
      other.feedback == feedback &&
      other.draft == draft;

    @override
    int get hashCode =>
        action.hashCode +
        feedback.hashCode +
        draft.hashCode;

  factory ChatActionRequest.fromJson(Map<String, dynamic> json) => _$ChatActionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ChatActionRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum ChatActionRequestActionEnum {
@JsonValue(r'fix')
fix(r'fix'),
@JsonValue(r'mute')
mute(r'mute'),
@JsonValue(r'approve')
approve(r'approve'),
@JsonValue(r'request_changes')
requestChanges(r'request_changes'),
@JsonValue(r'merge')
merge(r'merge'),
@JsonValue(r'create')
create(r'create'),
@JsonValue(r'create_assign')
createAssign(r'create_assign');

const ChatActionRequestActionEnum(this.value);

final String value;

@override
String toString() => value;
}


