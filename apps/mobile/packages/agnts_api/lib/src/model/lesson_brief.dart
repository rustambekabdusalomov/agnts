//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/lesson_level.dart';
import 'package:agnts_api/src/model/lesson_category.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lesson_brief.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LessonBrief {
  /// Returns a new [LessonBrief] instance.
  LessonBrief({

    required  this.id,

    required  this.repoId,

    required  this.repoName,

    required  this.ticketKey,

    required  this.slug,

    required  this.title,

    required  this.category,

    required  this.level,

    required  this.summary,

    required  this.quizCount,

    required  this.readMinutes,

     this.learnedAt,

    required  this.createdAt,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'repoId',
    required: true,
    includeIfNull: false,
  )


  final int repoId;



  @JsonKey(
    
    name: r'repoName',
    required: true,
    includeIfNull: false,
  )


  final String repoName;



  @JsonKey(
    
    name: r'ticketKey',
    required: true,
    includeIfNull: false,
  )


  final String ticketKey;



      /// Concept id, unique per repository
  @JsonKey(
    
    name: r'slug',
    required: true,
    includeIfNull: false,
  )


  final String slug;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(
    
    name: r'category',
    required: true,
    includeIfNull: false,
  )


  final LessonCategory category;



  @JsonKey(
    
    name: r'level',
    required: true,
    includeIfNull: false,
  )


  final LessonLevel level;



  @JsonKey(
    
    name: r'summary',
    required: true,
    includeIfNull: false,
  )


  final String summary;



  @JsonKey(
    
    name: r'quizCount',
    required: true,
    includeIfNull: false,
  )


  final int quizCount;



      /// Estimated minutes to read the lesson and take its quiz
  @JsonKey(
    
    name: r'readMinutes',
    required: true,
    includeIfNull: false,
  )


  final int readMinutes;



  @JsonKey(
    
    name: r'learnedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? learnedAt;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LessonBrief &&
      other.id == id &&
      other.repoId == repoId &&
      other.repoName == repoName &&
      other.ticketKey == ticketKey &&
      other.slug == slug &&
      other.title == title &&
      other.category == category &&
      other.level == level &&
      other.summary == summary &&
      other.quizCount == quizCount &&
      other.readMinutes == readMinutes &&
      other.learnedAt == learnedAt &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        repoId.hashCode +
        repoName.hashCode +
        ticketKey.hashCode +
        slug.hashCode +
        title.hashCode +
        category.hashCode +
        level.hashCode +
        summary.hashCode +
        quizCount.hashCode +
        readMinutes.hashCode +
        learnedAt.hashCode +
        createdAt.hashCode;

  factory LessonBrief.fromJson(Map<String, dynamic> json) => _$LessonBriefFromJson(json);

  Map<String, dynamic> toJson() => _$LessonBriefToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

