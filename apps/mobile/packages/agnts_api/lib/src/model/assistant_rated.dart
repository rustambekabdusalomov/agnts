//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/assistant_action.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_rated.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantRated {
  /// Returns a new [AssistantRated] instance.
  AssistantRated({

    required  this.messageId,

    required  this.user,

    required  this.question,

    required  this.answer,

    required  this.rating,

    required  this.comment,

    required  this.promptVersion,

    required  this.shared,

     this.actions,

    required  this.ratedAt,
  });

  @JsonKey(
    
    name: r'messageId',
    required: true,
    includeIfNull: false,
  )


  final int messageId;



  @JsonKey(
    
    name: r'user',
    required: true,
    includeIfNull: false,
  )


  final String user;



  @JsonKey(
    
    name: r'question',
    required: true,
    includeIfNull: false,
  )


  final String question;



  @JsonKey(
    
    name: r'answer',
    required: true,
    includeIfNull: false,
  )


  final String answer;



  @JsonKey(
    
    name: r'rating',
    required: true,
    includeIfNull: false,
  )


  final AssistantRatedRatingEnum rating;



  @JsonKey(
    
    name: r'comment',
    required: true,
    includeIfNull: false,
  )


  final String comment;



  @JsonKey(
    
    name: r'promptVersion',
    required: true,
    includeIfNull: false,
  )


  final String promptVersion;



  @JsonKey(
    
    name: r'shared',
    required: true,
    includeIfNull: false,
  )


  final bool shared;



      /// The actions the answer proposed, and what became of them
  @JsonKey(
    
    name: r'actions',
    required: false,
    includeIfNull: false,
  )


  final List<AssistantAction>? actions;



  @JsonKey(
    
    name: r'ratedAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime ratedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssistantRated &&
      other.messageId == messageId &&
      other.user == user &&
      other.question == question &&
      other.answer == answer &&
      other.rating == rating &&
      other.comment == comment &&
      other.promptVersion == promptVersion &&
      other.shared == shared &&
      other.actions == actions &&
      other.ratedAt == ratedAt;

    @override
    int get hashCode =>
        messageId.hashCode +
        user.hashCode +
        question.hashCode +
        answer.hashCode +
        rating.hashCode +
        comment.hashCode +
        promptVersion.hashCode +
        shared.hashCode +
        actions.hashCode +
        ratedAt.hashCode;

  factory AssistantRated.fromJson(Map<String, dynamic> json) => _$AssistantRatedFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantRatedToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum AssistantRatedRatingEnum {
@JsonValue(-1)
numberNegative1('-1'),
@JsonValue(1)
number1('1');

const AssistantRatedRatingEnum(this.value);

final String value;

@override
String toString() => value;
}


