//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/tree_entry.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'repo_tree.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RepoTree {
  /// Returns a new [RepoTree] instance.
  RepoTree({

    required  this.ref,

    required  this.path,

    required  this.entries,

     this.capped,
  });

  @JsonKey(
    
    name: r'ref',
    required: true,
    includeIfNull: false,
  )


  final String ref;



      /// \"\" for the root
  @JsonKey(
    
    name: r'path',
    required: true,
    includeIfNull: false,
  )


  final String path;



  @JsonKey(
    
    name: r'entries',
    required: true,
    includeIfNull: false,
  )


  final List<TreeEntry> entries;



      /// The directory has more entries than are listed
  @JsonKey(
    
    name: r'capped',
    required: false,
    includeIfNull: false,
  )


  final bool? capped;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RepoTree &&
      other.ref == ref &&
      other.path == path &&
      other.entries == entries &&
      other.capped == capped;

    @override
    int get hashCode =>
        ref.hashCode +
        path.hashCode +
        entries.hashCode +
        capped.hashCode;

  factory RepoTree.fromJson(Map<String, dynamic> json) => _$RepoTreeFromJson(json);

  Map<String, dynamic> toJson() => _$RepoTreeToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

