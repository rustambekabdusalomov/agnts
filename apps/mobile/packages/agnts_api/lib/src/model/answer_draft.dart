//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/attachment.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'answer_draft.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnswerDraft {
  /// Returns a new [AnswerDraft] instance.
  AnswerDraft({

    required  this.answer,

    required  this.note,

    required  this.attachments,

    required  this.updatedAt,
  });

      /// As the answer would be sent; may be empty
  @JsonKey(
    
    name: r'answer',
    required: true,
    includeIfNull: false,
  )


  final String answer;



  @JsonKey(
    
    name: r'note',
    required: true,
    includeIfNull: false,
  )


  final String note;



  @JsonKey(
    
    name: r'attachments',
    required: true,
    includeIfNull: false,
  )


  final List<Attachment> attachments;



  @JsonKey(
    
    name: r'updatedAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime updatedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AnswerDraft &&
      other.answer == answer &&
      other.note == note &&
      other.attachments == attachments &&
      other.updatedAt == updatedAt;

    @override
    int get hashCode =>
        answer.hashCode +
        note.hashCode +
        attachments.hashCode +
        updatedAt.hashCode;

  factory AnswerDraft.fromJson(Map<String, dynamic> json) => _$AnswerDraftFromJson(json);

  Map<String, dynamic> toJson() => _$AnswerDraftToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

