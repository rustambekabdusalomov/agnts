//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/follow_up_count.dart';
import 'package:agnts_api/src/model/lesson_count.dart';
import 'package:agnts_api/src/model/reviewer_stat.dart';
import 'package:agnts_api/src/model/learning_period.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analytics_learning.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnalyticsLearning {
  /// Returns a new [AnalyticsLearning] instance.
  AnalyticsLearning({

    required  this.days,

    required  this.current,

    required  this.previous,

    required  this.lessons,

    required  this.followUpTypes,

    required  this.followUpSources,

    required  this.reviewers,
  });

  @JsonKey(
    
    name: r'days',
    required: true,
    includeIfNull: false,
  )


  final int days;



  @JsonKey(
    
    name: r'current',
    required: true,
    includeIfNull: false,
  )


  final LearningPeriod current;



  @JsonKey(
    
    name: r'previous',
    required: true,
    includeIfNull: false,
  )


  final LearningPeriod previous;



  @JsonKey(
    
    name: r'lessons',
    required: true,
    includeIfNull: false,
  )


  final List<LessonCount> lessons;



      /// Follow-ups suggested in the period by type (prerequisite, split, unfinished, gap)
  @JsonKey(
    
    name: r'followUpTypes',
    required: true,
    includeIfNull: false,
  )


  final List<FollowUpCount> followUpTypes;



      /// Follow-ups suggested in the period by source (analyze, work, review, manual)
  @JsonKey(
    
    name: r'followUpSources',
    required: true,
    includeIfNull: false,
  )


  final List<FollowUpCount> followUpSources;



      /// Reviewers with the most notes in the period
  @JsonKey(
    
    name: r'reviewers',
    required: true,
    includeIfNull: false,
  )


  final List<ReviewerStat> reviewers;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AnalyticsLearning &&
      other.days == days &&
      other.current == current &&
      other.previous == previous &&
      other.lessons == lessons &&
      other.followUpTypes == followUpTypes &&
      other.followUpSources == followUpSources &&
      other.reviewers == reviewers;

    @override
    int get hashCode =>
        days.hashCode +
        current.hashCode +
        previous.hashCode +
        lessons.hashCode +
        followUpTypes.hashCode +
        followUpSources.hashCode +
        reviewers.hashCode;

  factory AnalyticsLearning.fromJson(Map<String, dynamic> json) => _$AnalyticsLearningFromJson(json);

  Map<String, dynamic> toJson() => _$AnalyticsLearningToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

