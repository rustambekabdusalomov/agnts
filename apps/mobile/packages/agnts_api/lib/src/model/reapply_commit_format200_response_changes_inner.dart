//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reapply_commit_format200_response_changes_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReapplyCommitFormat200ResponseChangesInner {
  /// Returns a new [ReapplyCommitFormat200ResponseChangesInner] instance.
  ReapplyCommitFormat200ResponseChangesInner({

    required  this.repoId,

    required  this.repoName,

    required  this.sha,

    required  this.from,

    required  this.to,

    required  this.suggested,
  });

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
    
    name: r'sha',
    required: true,
    includeIfNull: false,
  )


  final String sha;



  @JsonKey(
    
    name: r'from',
    required: true,
    includeIfNull: false,
  )


  final String from;



  @JsonKey(
    
    name: r'to',
    required: true,
    includeIfNull: false,
  )


  final String to;



      /// Worth making unasked: the run that made the commit described it, or the commit has agnts's own message. Off, it may undo a message a person wrote
  @JsonKey(
    
    name: r'suggested',
    required: true,
    includeIfNull: false,
  )


  final bool suggested;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ReapplyCommitFormat200ResponseChangesInner &&
      other.repoId == repoId &&
      other.repoName == repoName &&
      other.sha == sha &&
      other.from == from &&
      other.to == to &&
      other.suggested == suggested;

    @override
    int get hashCode =>
        repoId.hashCode +
        repoName.hashCode +
        sha.hashCode +
        from.hashCode +
        to.hashCode +
        suggested.hashCode;

  factory ReapplyCommitFormat200ResponseChangesInner.fromJson(Map<String, dynamic> json) => _$ReapplyCommitFormat200ResponseChangesInnerFromJson(json);

  Map<String, dynamic> toJson() => _$ReapplyCommitFormat200ResponseChangesInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

