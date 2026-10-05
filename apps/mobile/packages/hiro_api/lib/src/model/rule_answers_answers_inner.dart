//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rule_answers_answers_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RuleAnswersAnswersInner {
  /// Returns a new [RuleAnswersAnswersInner] instance.
  RuleAnswersAnswersInner({

    required  this.index,

    required  this.answer,

     this.note,
  });

          // minimum: 0
  @JsonKey(
    
    name: r'index',
    required: true,
    includeIfNull: false,
  )


  final int index;



  @JsonKey(
    
    name: r'answer',
    required: true,
    includeIfNull: false,
  )


  final String answer;



  @JsonKey(
    
    name: r'note',
    required: false,
    includeIfNull: false,
  )


  final String? note;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RuleAnswersAnswersInner &&
      other.index == index &&
      other.answer == answer &&
      other.note == note;

    @override
    int get hashCode =>
        index.hashCode +
        answer.hashCode +
        note.hashCode;

  factory RuleAnswersAnswersInner.fromJson(Map<String, dynamic> json) => _$RuleAnswersAnswersInnerFromJson(json);

  Map<String, dynamic> toJson() => _$RuleAnswersAnswersInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

