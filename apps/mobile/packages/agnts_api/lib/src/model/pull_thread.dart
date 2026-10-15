//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/pull_comment.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pull_thread.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PullThread {
  /// Returns a new [PullThread] instance.
  PullThread({

    required  this.id,

    required  this.kind,

     this.path,

     this.line,

     this.oldLine,

     this.startLine,

     this.diffHunk,

     this.commitSha,

    required  this.outdated,

    required  this.resolvable,

    required  this.resolved,

     this.reviewState,

     this.sent,

     this.replied,

    required  this.comments,
  });

      /// Opaque: pass it back to reply or resolve
  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final PullThreadKindEnum kind;



  @JsonKey(
    
    name: r'path',
    required: false,
    includeIfNull: false,
  )


  final String? path;



      /// Line in the new file
  @JsonKey(
    
    name: r'line',
    required: false,
    includeIfNull: false,
  )


  final int? line;



      /// Line in the old file, for a removed line
  @JsonKey(
    
    name: r'oldLine',
    required: false,
    includeIfNull: false,
  )


  final int? oldLine;



      /// First line of a range
  @JsonKey(
    
    name: r'startLine',
    required: false,
    includeIfNull: false,
  )


  final int? startLine;



  @JsonKey(
    
    name: r'diffHunk',
    required: false,
    includeIfNull: false,
  )


  final String? diffHunk;



  @JsonKey(
    
    name: r'commitSha',
    required: false,
    includeIfNull: false,
  )


  final String? commitSha;



      /// The line changed since the thread started
  @JsonKey(
    
    name: r'outdated',
    required: true,
    includeIfNull: false,
  )


  final bool outdated;



  @JsonKey(
    
    name: r'resolvable',
    required: true,
    includeIfNull: false,
  )


  final bool resolvable;



  @JsonKey(
    
    name: r'resolved',
    required: true,
    includeIfNull: false,
  )


  final bool resolved;



      /// A review's verdict: APPROVED, CHANGES_REQUESTED or COMMENTED
  @JsonKey(
    
    name: r'reviewState',
    required: false,
    includeIfNull: false,
  )


  final String? reviewState;



      /// On agnts's own pull request: sent back to the ticket as feedback, with no newer comment since
  @JsonKey(
    
    name: r'sent',
    required: false,
    includeIfNull: false,
  )


  final bool? sent;



      /// agnts answered it after pushing the fix
  @JsonKey(
    
    name: r'replied',
    required: false,
    includeIfNull: false,
  )


  final bool? replied;



  @JsonKey(
    
    name: r'comments',
    required: true,
    includeIfNull: false,
  )


  final List<PullComment> comments;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PullThread &&
      other.id == id &&
      other.kind == kind &&
      other.path == path &&
      other.line == line &&
      other.oldLine == oldLine &&
      other.startLine == startLine &&
      other.diffHunk == diffHunk &&
      other.commitSha == commitSha &&
      other.outdated == outdated &&
      other.resolvable == resolvable &&
      other.resolved == resolved &&
      other.reviewState == reviewState &&
      other.sent == sent &&
      other.replied == replied &&
      other.comments == comments;

    @override
    int get hashCode =>
        id.hashCode +
        kind.hashCode +
        path.hashCode +
        line.hashCode +
        oldLine.hashCode +
        startLine.hashCode +
        diffHunk.hashCode +
        commitSha.hashCode +
        outdated.hashCode +
        resolvable.hashCode +
        resolved.hashCode +
        reviewState.hashCode +
        sent.hashCode +
        replied.hashCode +
        comments.hashCode;

  factory PullThread.fromJson(Map<String, dynamic> json) => _$PullThreadFromJson(json);

  Map<String, dynamic> toJson() => _$PullThreadToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum PullThreadKindEnum {
@JsonValue(r'general')
general(r'general'),
@JsonValue(r'inline')
inline(r'inline'),
@JsonValue(r'review')
review(r'review');

const PullThreadKindEnum(this.value);

final String value;

@override
String toString() => value;
}


