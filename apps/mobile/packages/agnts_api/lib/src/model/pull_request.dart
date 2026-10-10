//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pull_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PullRequest {
  /// Returns a new [PullRequest] instance.
  PullRequest({

    required  this.number,

    required  this.url,

    required  this.title,

    required  this.author,

    required  this.headRef,

    required  this.headSha,

    required  this.baseRef,

    required  this.draft,

    required  this.state,

    required  this.login,

    required  this.why,

     this.additions,

     this.deletions,

     this.updatedAt,

     this.postedSha,

     this.postedAt,
  });

      /// The pull request number (GitLab: the IID)
  @JsonKey(
    
    name: r'number',
    required: true,
    includeIfNull: false,
  )


  final int number;



  @JsonKey(
    
    name: r'url',
    required: true,
    includeIfNull: false,
  )


  final String url;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



      /// Git host username of the author
  @JsonKey(
    
    name: r'author',
    required: true,
    includeIfNull: false,
  )


  final String author;



      /// The branch it comes from
  @JsonKey(
    
    name: r'headRef',
    required: true,
    includeIfNull: false,
  )


  final String headRef;



      /// Its newest commit on the git host
  @JsonKey(
    
    name: r'headSha',
    required: true,
    includeIfNull: false,
  )


  final String headSha;



      /// The branch it goes into
  @JsonKey(
    
    name: r'baseRef',
    required: true,
    includeIfNull: false,
  )


  final String baseRef;



  @JsonKey(
    
    name: r'draft',
    required: true,
    includeIfNull: false,
  )


  final bool draft;



  @JsonKey(
    
    name: r'state',
    required: true,
    includeIfNull: false,
  )


  final PullRequestStateEnum state;



      /// The git host user it waits for; their reviewer profile shapes its reviews
  @JsonKey(
    
    name: r'login',
    required: true,
    includeIfNull: false,
  )


  final String login;



  @JsonKey(
    
    name: r'why',
    required: true,
    includeIfNull: false,
  )


  final PullRequestWhyEnum why;



  @JsonKey(
    
    name: r'additions',
    required: false,
    includeIfNull: false,
  )


  final int? additions;



  @JsonKey(
    
    name: r'deletions',
    required: false,
    includeIfNull: false,
  )


  final int? deletions;



  @JsonKey(
    
    name: r'updatedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? updatedAt;



      /// The reviewed commit whose review agnts last posted on the pull request
  @JsonKey(
    
    name: r'postedSha',
    required: false,
    includeIfNull: false,
  )


  final String? postedSha;



      /// When agnts last posted its review on the pull request
  @JsonKey(
    
    name: r'postedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? postedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PullRequest &&
      other.number == number &&
      other.url == url &&
      other.title == title &&
      other.author == author &&
      other.headRef == headRef &&
      other.headSha == headSha &&
      other.baseRef == baseRef &&
      other.draft == draft &&
      other.state == state &&
      other.login == login &&
      other.why == why &&
      other.additions == additions &&
      other.deletions == deletions &&
      other.updatedAt == updatedAt &&
      other.postedSha == postedSha &&
      other.postedAt == postedAt;

    @override
    int get hashCode =>
        number.hashCode +
        url.hashCode +
        title.hashCode +
        author.hashCode +
        headRef.hashCode +
        headSha.hashCode +
        baseRef.hashCode +
        draft.hashCode +
        state.hashCode +
        login.hashCode +
        why.hashCode +
        additions.hashCode +
        deletions.hashCode +
        updatedAt.hashCode +
        postedSha.hashCode +
        postedAt.hashCode;

  factory PullRequest.fromJson(Map<String, dynamic> json) => _$PullRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PullRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum PullRequestStateEnum {
@JsonValue(r'open')
open(r'open'),
@JsonValue(r'closed')
closed(r'closed'),
@JsonValue(r'merged')
merged(r'merged');

const PullRequestStateEnum(this.value);

final String value;

@override
String toString() => value;
}


enum PullRequestWhyEnum {
@JsonValue(r'assigned')
assigned(r'assigned'),
@JsonValue(r'review_requested')
reviewRequested(r'review_requested');

const PullRequestWhyEnum(this.value);

final String value;

@override
String toString() => value;
}


