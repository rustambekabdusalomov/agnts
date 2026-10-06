//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/lesson_level.dart';
import 'package:agnts_api/src/model/lesson_category.dart';
import 'package:agnts_api/src/model/quiz_question.dart';
import 'package:agnts_api/src/model/link.dart';
import 'package:agnts_api/src/model/lesson_ref.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lesson.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Lesson {
  /// Returns a new [Lesson] instance.
  Lesson({

    required  this.id,

    required  this.repoId,

    required  this.repoName,

    required  this.ticketKey,

    required  this.slug,

    required  this.title,

    required  this.category,

    required  this.level,

    required  this.summary,

    required  this.explanation,

    required  this.whyHere,

    required  this.readMinutes,

    required  this.refs,

    required  this.quiz,

    required  this.reading,

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



      /// Plain text; paragraphs are separated by blank lines
  @JsonKey(
    
    name: r'explanation',
    required: true,
    includeIfNull: false,
  )


  final String explanation;



      /// Why this change needed it
  @JsonKey(
    
    name: r'whyHere',
    required: true,
    includeIfNull: false,
  )


  final String whyHere;



      /// Estimated minutes to read the lesson and take its quiz
  @JsonKey(
    
    name: r'readMinutes',
    required: true,
    includeIfNull: false,
  )


  final int readMinutes;



  @JsonKey(
    
    name: r'refs',
    required: true,
    includeIfNull: false,
  )


  final List<LessonRef> refs;



  @JsonKey(
    
    name: r'quiz',
    required: true,
    includeIfNull: false,
  )


  final List<QuizQuestion> quiz;



  @JsonKey(
    
    name: r'reading',
    required: true,
    includeIfNull: false,
  )


  final List<Link> reading;



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
    bool operator ==(Object other) => identical(this, other) || other is Lesson &&
      other.id == id &&
      other.repoId == repoId &&
      other.repoName == repoName &&
      other.ticketKey == ticketKey &&
      other.slug == slug &&
      other.title == title &&
      other.category == category &&
      other.level == level &&
      other.summary == summary &&
      other.explanation == explanation &&
      other.whyHere == whyHere &&
      other.readMinutes == readMinutes &&
      other.refs == refs &&
      other.quiz == quiz &&
      other.reading == reading &&
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
        explanation.hashCode +
        whyHere.hashCode +
        readMinutes.hashCode +
        refs.hashCode +
        quiz.hashCode +
        reading.hashCode +
        learnedAt.hashCode +
        createdAt.hashCode;

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);

  Map<String, dynamic> toJson() => _$LessonToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

