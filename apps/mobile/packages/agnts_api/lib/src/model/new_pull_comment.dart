//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'new_pull_comment.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NewPullComment {
  /// Returns a new [NewPullComment] instance.
  NewPullComment({

    required  this.body,

     this.path,

     this.line,

     this.oldLine,

     this.startLine,

     this.headSha,
  });

  @JsonKey(
    
    name: r'body',
    required: true,
    includeIfNull: false,
  )


  final String body;



      /// The file, for a comment on a line
  @JsonKey(
    
    name: r'path',
    required: false,
    includeIfNull: false,
  )


  final String? path;



      /// Line in the new file (an added or unchanged line)
          // minimum: 0
  @JsonKey(
    
    name: r'line',
    required: false,
    includeIfNull: false,
  )


  final int? line;



      /// Line in the old file: a removed line, or with line an unchanged one
          // minimum: 0
  @JsonKey(
    
    name: r'oldLine',
    required: false,
    includeIfNull: false,
  )


  final int? oldLine;



      /// First line of a range (GitHub)
          // minimum: 0
  @JsonKey(
    
    name: r'startLine',
    required: false,
    includeIfNull: false,
  )


  final int? startLine;



      /// The commit the line is in; the newest when empty
  @JsonKey(
    
    name: r'headSha',
    required: false,
    includeIfNull: false,
  )


  final String? headSha;





    @override
    bool operator ==(Object other) => identical(this, other) || other is NewPullComment &&
      other.body == body &&
      other.path == path &&
      other.line == line &&
      other.oldLine == oldLine &&
      other.startLine == startLine &&
      other.headSha == headSha;

    @override
    int get hashCode =>
        body.hashCode +
        path.hashCode +
        line.hashCode +
        oldLine.hashCode +
        startLine.hashCode +
        headSha.hashCode;

  factory NewPullComment.fromJson(Map<String, dynamic> json) => _$NewPullCommentFromJson(json);

  Map<String, dynamic> toJson() => _$NewPullCommentToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

