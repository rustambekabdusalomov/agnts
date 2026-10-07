//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'repo_detect_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RepoDetectInput {
  /// Returns a new [RepoDetectInput] instance.
  RepoDetectInput({

     this.id,

     this.cloneUrl,

     this.defaultBranch,

     this.deep,
  });

      /// A saved repository; the other fields are then optional
  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final int? id;



  @JsonKey(
    
    name: r'cloneUrl',
    required: false,
    includeIfNull: false,
  )


  final String? cloneUrl;



  @JsonKey(
    
    name: r'defaultBranch',
    required: false,
    includeIfNull: false,
  )


  final String? defaultBranch;



      /// Ask Claude when the file scan finds no commands
  @JsonKey(
    
    name: r'deep',
    required: false,
    includeIfNull: false,
  )


  final bool? deep;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RepoDetectInput &&
      other.id == id &&
      other.cloneUrl == cloneUrl &&
      other.defaultBranch == defaultBranch &&
      other.deep == deep;

    @override
    int get hashCode =>
        id.hashCode +
        cloneUrl.hashCode +
        defaultBranch.hashCode +
        deep.hashCode;

  factory RepoDetectInput.fromJson(Map<String, dynamic> json) => _$RepoDetectInputFromJson(json);

  Map<String, dynamic> toJson() => _$RepoDetectInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

