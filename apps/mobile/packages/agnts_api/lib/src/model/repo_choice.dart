//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'repo_choice.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RepoChoice {
  /// Returns a new [RepoChoice] instance.
  RepoChoice({

     this.repoId,

     this.repoIds,

     this.groupId,
  });

  @JsonKey(
    
    name: r'repoId',
    required: false,
    includeIfNull: false,
  )


  final int? repoId;



  @JsonKey(
    
    name: r'repoIds',
    required: false,
    includeIfNull: false,
  )


  final List<int>? repoIds;



  @JsonKey(
    
    name: r'groupId',
    required: false,
    includeIfNull: false,
  )


  final int? groupId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RepoChoice &&
      other.repoId == repoId &&
      other.repoIds == repoIds &&
      other.groupId == groupId;

    @override
    int get hashCode =>
        repoId.hashCode +
        repoIds.hashCode +
        groupId.hashCode;

  factory RepoChoice.fromJson(Map<String, dynamic> json) => _$RepoChoiceFromJson(json);

  Map<String, dynamic> toJson() => _$RepoChoiceToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

