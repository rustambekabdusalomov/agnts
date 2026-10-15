//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pull_comment.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PullComment {
  /// Returns a new [PullComment] instance.
  PullComment({

    required  this.id,

    required  this.author,

     this.avatarUrl,

    required  this.body,

    required  this.createdAt,

    required  this.updatedAt,

     this.url,

    required  this.mine,

    required  this.system,

    required  this.agnts,
  });

      /// Opaque: pass it back to edit or delete
  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'author',
    required: true,
    includeIfNull: false,
  )


  final String author;



  @JsonKey(
    
    name: r'avatarUrl',
    required: false,
    includeIfNull: false,
  )


  final String? avatarUrl;



      /// Markdown, as the git host stores it
  @JsonKey(
    
    name: r'body',
    required: true,
    includeIfNull: false,
  )


  final String body;



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



  @JsonKey(
    
    name: r'url',
    required: false,
    includeIfNull: false,
  )


  final String? url;



      /// Written by the git host token's user, who may edit and delete it
  @JsonKey(
    
    name: r'mine',
    required: true,
    includeIfNull: false,
  )


  final bool mine;



      /// A note the git host wrote (\"added 2 commits\")
  @JsonKey(
    
    name: r'system',
    required: true,
    includeIfNull: false,
  )


  final bool system;



      /// agnts posted it
  @JsonKey(
    
    name: r'agnts',
    required: true,
    includeIfNull: false,
  )


  final bool agnts;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PullComment &&
      other.id == id &&
      other.author == author &&
      other.avatarUrl == avatarUrl &&
      other.body == body &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.url == url &&
      other.mine == mine &&
      other.system == system &&
      other.agnts == agnts;

    @override
    int get hashCode =>
        id.hashCode +
        author.hashCode +
        avatarUrl.hashCode +
        body.hashCode +
        createdAt.hashCode +
        updatedAt.hashCode +
        url.hashCode +
        mine.hashCode +
        system.hashCode +
        agnts.hashCode;

  factory PullComment.fromJson(Map<String, dynamic> json) => _$PullCommentFromJson(json);

  Map<String, dynamic> toJson() => _$PullCommentToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

