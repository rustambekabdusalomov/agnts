//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'linked_commit.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LinkedCommit {
  /// Returns a new [LinkedCommit] instance.
  LinkedCommit({

    required  this.sha,

    required  this.shortSha,

    required  this.subject,

    required  this.author,

     this.authorLogin,

    required  this.branch,

    required  this.repoId,

    required  this.repo,

    required  this.url,

    required  this.committedAt,

    required  this.matchedOn,
  });

  @JsonKey(
    
    name: r'sha',
    required: true,
    includeIfNull: false,
  )


  final String sha;



  @JsonKey(
    
    name: r'shortSha',
    required: true,
    includeIfNull: false,
  )


  final String shortSha;



      /// The message's first line
  @JsonKey(
    
    name: r'subject',
    required: true,
    includeIfNull: false,
  )


  final String subject;



  @JsonKey(
    
    name: r'author',
    required: true,
    includeIfNull: false,
  )


  final String author;



      /// The git host account, when known
  @JsonKey(
    
    name: r'authorLogin',
    required: false,
    includeIfNull: false,
  )


  final String? authorLogin;



      /// The branch it was first seen on
  @JsonKey(
    
    name: r'branch',
    required: true,
    includeIfNull: false,
  )


  final String branch;



  @JsonKey(
    
    name: r'repoId',
    required: true,
    includeIfNull: false,
  )


  final int repoId;



  @JsonKey(
    
    name: r'repo',
    required: true,
    includeIfNull: false,
  )


  final String repo;



      /// The commit on the git host
  @JsonKey(
    
    name: r'url',
    required: true,
    includeIfNull: false,
  )


  final String url;



  @JsonKey(
    
    name: r'committedAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime committedAt;



      /// Where the ticket's number was found
  @JsonKey(
    
    name: r'matchedOn',
    required: true,
    includeIfNull: false,
  )


  final List<LinkedCommitMatchedOnEnum> matchedOn;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LinkedCommit &&
      other.sha == sha &&
      other.shortSha == shortSha &&
      other.subject == subject &&
      other.author == author &&
      other.authorLogin == authorLogin &&
      other.branch == branch &&
      other.repoId == repoId &&
      other.repo == repo &&
      other.url == url &&
      other.committedAt == committedAt &&
      other.matchedOn == matchedOn;

    @override
    int get hashCode =>
        sha.hashCode +
        shortSha.hashCode +
        subject.hashCode +
        author.hashCode +
        authorLogin.hashCode +
        branch.hashCode +
        repoId.hashCode +
        repo.hashCode +
        url.hashCode +
        committedAt.hashCode +
        matchedOn.hashCode;

  factory LinkedCommit.fromJson(Map<String, dynamic> json) => _$LinkedCommitFromJson(json);

  Map<String, dynamic> toJson() => _$LinkedCommitToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum LinkedCommitMatchedOnEnum {
@JsonValue(r'branch')
branch(r'branch'),
@JsonValue(r'message')
message(r'message');

const LinkedCommitMatchedOnEnum(this.value);

final String value;

@override
String toString() => value;
}


