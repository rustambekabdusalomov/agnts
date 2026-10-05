//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'question.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Question {
  /// Returns a new [Question] instance.
  Question({

    required  this.id,

    required  this.position,

    required  this.text,

    required  this.options,

     this.answer,

    required  this.note,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'position',
    required: true,
    includeIfNull: false,
  )


  final int position;



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



  @JsonKey(
    
    name: r'answer',
    required: false,
    includeIfNull: false,
  )


  final String? answer;



  @JsonKey(
    
    name: r'note',
    required: true,
    includeIfNull: false,
  )


  final String note;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Question &&
      other.id == id &&
      other.position == position &&
      other.text == text &&
      other.options == options &&
      other.answer == answer &&
      other.note == note;

    @override
    int get hashCode =>
        id.hashCode +
        position.hashCode +
        text.hashCode +
        options.hashCode +
        answer.hashCode +
        note.hashCode;

  factory Question.fromJson(Map<String, dynamic> json) => _$QuestionFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

