//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/linked_commit.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'linked_commits.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LinkedCommits {
  /// Returns a new [LinkedCommits] instance.
  LinkedCommits({

    required  this.commits,

    required  this.total,
  });

  @JsonKey(
    
    name: r'commits',
    required: true,
    includeIfNull: false,
  )


  final List<LinkedCommit> commits;



      /// How many commits are linked in all
  @JsonKey(
    
    name: r'total',
    required: true,
    includeIfNull: false,
  )


  final int total;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LinkedCommits &&
      other.commits == commits &&
      other.total == total;

    @override
    int get hashCode =>
        commits.hashCode +
        total.hashCode;

  factory LinkedCommits.fromJson(Map<String, dynamic> json) => _$LinkedCommitsFromJson(json);

  Map<String, dynamic> toJson() => _$LinkedCommitsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

