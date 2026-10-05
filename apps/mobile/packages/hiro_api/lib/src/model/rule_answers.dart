//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:hiro_api/src/model/rule_answers_answers_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rule_answers.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RuleAnswers {
  /// Returns a new [RuleAnswers] instance.
  RuleAnswers({

    required  this.answers,
  });

  @JsonKey(
    
    name: r'answers',
    required: true,
    includeIfNull: false,
  )


  final List<RuleAnswersAnswersInner> answers;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RuleAnswers &&
      other.answers == answers;

    @override
    int get hashCode =>
        answers.hashCode;

  factory RuleAnswers.fromJson(Map<String, dynamic> json) => _$RuleAnswersFromJson(json);

  Map<String, dynamic> toJson() => _$RuleAnswersToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

