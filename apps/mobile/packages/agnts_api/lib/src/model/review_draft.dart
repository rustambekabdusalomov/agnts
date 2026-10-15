//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review_draft.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReviewDraft {
  /// Returns a new [ReviewDraft] instance.
  ReviewDraft({

    required  this.id,

    required  this.kind,

    required  this.key,

     this.severity,

     this.category,

     this.title,

     this.confidence,

     this.pass,

     this.path,

     this.line,

    required  this.headSha,

    required  this.body,

    required  this.edited,

    required  this.state,

     this.dismissReason,

     this.error,

     this.author,

     this.decidedBy,

     this.decidedAt,

    required  this.createdAt,

    required  this.updatedAt,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final ReviewDraftKindEnum kind;



      /// Which finding it is across re-reviews (file and title)
  @JsonKey(
    
    name: r'key',
    required: true,
    includeIfNull: false,
  )


  final String key;



      /// A finding's severity; for the summary, the verdict
  @JsonKey(
    
    name: r'severity',
    required: false,
    includeIfNull: false,
  )


  final String? severity;



  @JsonKey(
    
    name: r'category',
    required: false,
    includeIfNull: false,
  )


  final String? category;



  @JsonKey(
    
    name: r'title',
    required: false,
    includeIfNull: false,
  )


  final String? title;



  @JsonKey(
    
    name: r'confidence',
    required: false,
    includeIfNull: false,
  )


  final num? confidence;



  @JsonKey(
    
    name: r'pass',
    required: false,
    includeIfNull: false,
  )


  final String? pass;



  @JsonKey(
    
    name: r'path',
    required: false,
    includeIfNull: false,
  )


  final String? path;



      /// Line in the new file; it may be outside the diff
  @JsonKey(
    
    name: r'line',
    required: false,
    includeIfNull: false,
  )


  final int? line;



      /// The commit it is about
  @JsonKey(
    
    name: r'headSha',
    required: true,
    includeIfNull: false,
  )


  final String headSha;



      /// Markdown: what is published
  @JsonKey(
    
    name: r'body',
    required: true,
    includeIfNull: false,
  )


  final String body;



      /// A person rewrote it; re-reviews keep their text
  @JsonKey(
    
    name: r'edited',
    required: true,
    includeIfNull: false,
  )


  final bool edited;



  @JsonKey(
    
    name: r'state',
    required: true,
    includeIfNull: false,
  )


  final ReviewDraftStateEnum state;



  @JsonKey(
    
    name: r'dismissReason',
    required: false,
    includeIfNull: false,
  )


  final String? dismissReason;



      /// Why its last publish failed
  @JsonKey(
    
    name: r'error',
    required: false,
    includeIfNull: false,
  )


  final String? error;



      /// Who wrote it (comment)
  @JsonKey(
    
    name: r'author',
    required: false,
    includeIfNull: false,
  )


  final String? author;



  @JsonKey(
    
    name: r'decidedBy',
    required: false,
    includeIfNull: false,
  )


  final String? decidedBy;



  @JsonKey(
    
    name: r'decidedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? decidedAt;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;



  @JsonKey(
    
    name: r'updatedAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime updatedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ReviewDraft &&
      other.id == id &&
      other.kind == kind &&
      other.key == key &&
      other.severity == severity &&
      other.category == category &&
      other.title == title &&
      other.confidence == confidence &&
      other.pass == pass &&
      other.path == path &&
      other.line == line &&
      other.headSha == headSha &&
      other.body == body &&
      other.edited == edited &&
      other.state == state &&
      other.dismissReason == dismissReason &&
      other.error == error &&
      other.author == author &&
      other.decidedBy == decidedBy &&
      other.decidedAt == decidedAt &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

    @override
    int get hashCode =>
        id.hashCode +
        kind.hashCode +
        key.hashCode +
        severity.hashCode +
        category.hashCode +
        title.hashCode +
        confidence.hashCode +
        pass.hashCode +
        path.hashCode +
        line.hashCode +
        headSha.hashCode +
        body.hashCode +
        edited.hashCode +
        state.hashCode +
        dismissReason.hashCode +
        error.hashCode +
        author.hashCode +
        decidedBy.hashCode +
        decidedAt.hashCode +
        createdAt.hashCode +
        updatedAt.hashCode;

  factory ReviewDraft.fromJson(Map<String, dynamic> json) => _$ReviewDraftFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewDraftToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum ReviewDraftKindEnum {
@JsonValue(r'summary')
summary(r'summary'),
@JsonValue(r'finding')
finding(r'finding'),
@JsonValue(r'comment')
comment(r'comment');

const ReviewDraftKindEnum(this.value);

final String value;

@override
String toString() => value;
}


enum ReviewDraftStateEnum {
@JsonValue(r'draft')
draft(r'draft'),
@JsonValue(r'accepted')
accepted(r'accepted'),
@JsonValue(r'publishing')
publishing(r'publishing'),
@JsonValue(r'dismissed')
dismissed(r'dismissed'),
@JsonValue(r'published')
published(r'published'),
@JsonValue(r'outdated')
outdated(r'outdated');

const ReviewDraftStateEnum(this.value);

final String value;

@override
String toString() => value;
}


