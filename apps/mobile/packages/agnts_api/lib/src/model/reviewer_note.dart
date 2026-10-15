//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reviewer_note.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReviewerNote {
  /// Returns a new [ReviewerNote] instance.
  ReviewerNote({

    required  this.id,

    required  this.login,

     this.username,

     this.repoName,

     this.ticketKey,

     this.pullTitle,

    required  this.kind,

    required  this.note,

    required  this.createdAt,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



      /// The git host user the review was for
  @JsonKey(
    
    name: r'login',
    required: true,
    includeIfNull: false,
  )


  final String login;



      /// Who wrote it in agnts
  @JsonKey(
    
    name: r'username',
    required: false,
    includeIfNull: false,
  )


  final String? username;



  @JsonKey(
    
    name: r'repoName',
    required: false,
    includeIfNull: false,
  )


  final String? repoName;



  @JsonKey(
    
    name: r'ticketKey',
    required: false,
    includeIfNull: false,
  )


  final String? ticketKey;



  @JsonKey(
    
    name: r'pullTitle',
    required: false,
    includeIfNull: false,
  )


  final String? pullTitle;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final ReviewerNoteKindEnum kind;



  @JsonKey(
    
    name: r'note',
    required: true,
    includeIfNull: false,
  )


  final String note;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ReviewerNote &&
      other.id == id &&
      other.login == login &&
      other.username == username &&
      other.repoName == repoName &&
      other.ticketKey == ticketKey &&
      other.pullTitle == pullTitle &&
      other.kind == kind &&
      other.note == note &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        login.hashCode +
        username.hashCode +
        repoName.hashCode +
        ticketKey.hashCode +
        pullTitle.hashCode +
        kind.hashCode +
        note.hashCode +
        createdAt.hashCode;

  factory ReviewerNote.fromJson(Map<String, dynamic> json) => _$ReviewerNoteFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewerNoteToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum ReviewerNoteKindEnum {
@JsonValue(r'rereview')
rereview(r'rereview'),
@JsonValue(r'dismissed')
dismissed(r'dismissed'),
@JsonValue(r'manual')
manual(r'manual'),
@JsonValue(r'host_comment')
hostComment(r'host_comment');

const ReviewerNoteKindEnum(this.value);

final String value;

@override
String toString() => value;
}


