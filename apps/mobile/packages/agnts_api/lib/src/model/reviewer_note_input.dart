//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reviewer_note_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReviewerNoteInput {
  /// Returns a new [ReviewerNoteInput] instance.
  ReviewerNoteInput({

    required  this.login,

    required  this.note,
  });

  @JsonKey(
    
    name: r'login',
    required: true,
    includeIfNull: false,
  )


  final String login;



  @JsonKey(
    
    name: r'note',
    required: true,
    includeIfNull: false,
  )


  final String note;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ReviewerNoteInput &&
      other.login == login &&
      other.note == note;

    @override
    int get hashCode =>
        login.hashCode +
        note.hashCode;

  factory ReviewerNoteInput.fromJson(Map<String, dynamic> json) => _$ReviewerNoteInputFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewerNoteInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

