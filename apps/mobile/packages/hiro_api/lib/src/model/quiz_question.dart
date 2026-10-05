//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'quiz_question.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class QuizQuestion {
  /// Returns a new [QuizQuestion] instance.
  QuizQuestion({

    required  this.question,

    required  this.options,

    required  this.answer,

     this.explanation,
  });

  @JsonKey(
    
    name: r'question',
    required: true,
    includeIfNull: false,
  )


  final String question;



  @JsonKey(
    
    name: r'options',
    required: true,
    includeIfNull: false,
  )


  final List<String> options;



      /// Index of the correct option
  @JsonKey(
    
    name: r'answer',
    required: true,
    includeIfNull: false,
  )


  final int answer;



  @JsonKey(
    
    name: r'explanation',
    required: false,
    includeIfNull: false,
  )


  final String? explanation;





    @override
    bool operator ==(Object other) => identical(this, other) || other is QuizQuestion &&
      other.question == question &&
      other.options == options &&
      other.answer == answer &&
      other.explanation == explanation;

    @override
    int get hashCode =>
        question.hashCode +
        options.hashCode +
        answer.hashCode +
        explanation.hashCode;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => _$QuizQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$QuizQuestionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

