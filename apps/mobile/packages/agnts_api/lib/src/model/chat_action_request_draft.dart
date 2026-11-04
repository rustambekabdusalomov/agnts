//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_action_request_draft.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ChatActionRequestDraft {
  /// Returns a new [ChatActionRequestDraft] instance.
  ChatActionRequestDraft({

     this.title,

     this.description,

     this.repoId,
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
    
    name: r'repoId',
    required: false,
    includeIfNull: false,
  )


  final int? repoId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ChatActionRequestDraft &&
      other.title == title &&
      other.description == description &&
      other.repoId == repoId;

    @override
    int get hashCode =>
        title.hashCode +
        description.hashCode +
        repoId.hashCode;

  factory ChatActionRequestDraft.fromJson(Map<String, dynamic> json) => _$ChatActionRequestDraftFromJson(json);

  Map<String, dynamic> toJson() => _$ChatActionRequestDraftToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

