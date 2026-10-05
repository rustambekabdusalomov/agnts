//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rule_question.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RuleQuestion {
  /// Returns a new [RuleQuestion] instance.
  RuleQuestion({

    required  this.index,

    required  this.text,

    required  this.options,

     this.answer,

     this.note,

    required  this.round,
  });

      /// Position in the rule's questions; answers refer to it
  @JsonKey(
    
    name: r'index',
    required: true,
    includeIfNull: false,
  )


  final int index;



  @JsonKey(
    
    name: r'text',
    required: true,
    includeIfNull: false,
  )


  final String text;



  @JsonKey(
    
    name: r'options',
    required: true,
    includeIfNull: false,
  )


  final List<String> options;



      /// Empty while the question is open
  @JsonKey(
    
    name: r'answer',
    required: false,
    includeIfNull: false,
  )


  final String? answer;



  @JsonKey(
    
    name: r'note',
    required: false,
    includeIfNull: false,
  )


  final String? note;



      /// The review round that asked it
  @JsonKey(
    
    name: r'round',
    required: true,
    includeIfNull: false,
  )


  final int round;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RuleQuestion &&
      other.index == index &&
      other.text == text &&
      other.options == options &&
      other.answer == answer &&
      other.note == note &&
      other.round == round;

    @override
    int get hashCode =>
        index.hashCode +
        text.hashCode +
        options.hashCode +
        answer.hashCode +
        note.hashCode +
        round.hashCode;

  factory RuleQuestion.fromJson(Map<String, dynamic> json) => _$RuleQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$RuleQuestionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

