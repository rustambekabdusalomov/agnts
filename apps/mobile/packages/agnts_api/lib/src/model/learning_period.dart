//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'learning_period.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LearningPeriod {
  /// Returns a new [LearningPeriod] instance.
  LearningPeriod({

    required  this.lessons,

    required  this.lessonsLearned,

    required  this.rulesSuggested,

    required  this.rulesAdopted,

    required  this.rulesManual,

    required  this.reflections,

    required  this.reflectionRules,

    required  this.followUps,

    required  this.accepted,

    required  this.dismissed,

    required  this.reviewerNotes,
  });

  @JsonKey(
    
    name: r'lessons',
    required: true,
    includeIfNull: false,
  )


  final int lessons;



  @JsonKey(
    
    name: r'lessonsLearned',
    required: true,
    includeIfNull: false,
  )


  final int lessonsLearned;



      /// Rules suggested from tickets
  @JsonKey(
    
    name: r'rulesSuggested',
    required: true,
    includeIfNull: false,
  )


  final int rulesSuggested;



      /// Of those, in use now
  @JsonKey(
    
    name: r'rulesAdopted',
    required: true,
    includeIfNull: false,
  )


  final int rulesAdopted;



      /// Rules written by a person
  @JsonKey(
    
    name: r'rulesManual',
    required: true,
    includeIfNull: false,
  )


  final int rulesManual;



  @JsonKey(
    
    name: r'reflections',
    required: true,
    includeIfNull: false,
  )


  final int reflections;



      /// Rules the reflections suggested
  @JsonKey(
    
    name: r'reflectionRules',
    required: true,
    includeIfNull: false,
  )


  final int reflectionRules;



  @JsonKey(
    
    name: r'followUps',
    required: true,
    includeIfNull: false,
  )


  final int followUps;



      /// Follow-ups accepted in the period
  @JsonKey(
    
    name: r'accepted',
    required: true,
    includeIfNull: false,
  )


  final int accepted;



      /// Follow-ups dismissed in the period
  @JsonKey(
    
    name: r'dismissed',
    required: true,
    includeIfNull: false,
  )


  final int dismissed;



  @JsonKey(
    
    name: r'reviewerNotes',
    required: true,
    includeIfNull: false,
  )


  final int reviewerNotes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LearningPeriod &&
      other.lessons == lessons &&
      other.lessonsLearned == lessonsLearned &&
      other.rulesSuggested == rulesSuggested &&
      other.rulesAdopted == rulesAdopted &&
      other.rulesManual == rulesManual &&
      other.reflections == reflections &&
      other.reflectionRules == reflectionRules &&
      other.followUps == followUps &&
      other.accepted == accepted &&
      other.dismissed == dismissed &&
      other.reviewerNotes == reviewerNotes;

    @override
    int get hashCode =>
        lessons.hashCode +
        lessonsLearned.hashCode +
        rulesSuggested.hashCode +
        rulesAdopted.hashCode +
        rulesManual.hashCode +
        reflections.hashCode +
        reflectionRules.hashCode +
        followUps.hashCode +
        accepted.hashCode +
        dismissed.hashCode +
        reviewerNotes.hashCode;

  factory LearningPeriod.fromJson(Map<String, dynamic> json) => _$LearningPeriodFromJson(json);

  Map<String, dynamic> toJson() => _$LearningPeriodToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

