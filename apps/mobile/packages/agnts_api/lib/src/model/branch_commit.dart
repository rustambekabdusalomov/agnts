//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'branch_commit.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BranchCommit {
  /// Returns a new [BranchCommit] instance.
  BranchCommit({

    required  this.sha,

    required  this.message,
  });

  @JsonKey(
    
    name: r'sha',
    required: true,
    includeIfNull: false,
  )


  final String sha;



      /// The whole message: the subject line, then the body after a blank line
  @JsonKey(
    
    name: r'message',
    required: true,
    includeIfNull: false,
  )


  final String message;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BranchCommit &&
      other.sha == sha &&
      other.message == message;

    @override
    int get hashCode =>
        sha.hashCode +
        message.hashCode;

  factory BranchCommit.fromJson(Map<String, dynamic> json) => _$BranchCommitFromJson(json);

  Map<String, dynamic> toJson() => _$BranchCommitToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

