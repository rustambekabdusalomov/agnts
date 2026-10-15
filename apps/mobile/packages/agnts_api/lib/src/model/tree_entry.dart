//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tree_entry.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TreeEntry {
  /// Returns a new [TreeEntry] instance.
  TreeEntry({

    required  this.name,

    required  this.path,

    required  this.type,

     this.size,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



      /// From the repository root
  @JsonKey(
    
    name: r'path',
    required: true,
    includeIfNull: false,
  )


  final String path;



  @JsonKey(
    
    name: r'type',
    required: true,
    includeIfNull: false,
  )


  final TreeEntryTypeEnum type;



      /// Files only, when the git host gives it (GitLab does not)
  @JsonKey(
    
    name: r'size',
    required: false,
    includeIfNull: false,
  )


  final int? size;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TreeEntry &&
      other.name == name &&
      other.path == path &&
      other.type == type &&
      other.size == size;

    @override
    int get hashCode =>
        name.hashCode +
        path.hashCode +
        type.hashCode +
        size.hashCode;

  factory TreeEntry.fromJson(Map<String, dynamic> json) => _$TreeEntryFromJson(json);

  Map<String, dynamic> toJson() => _$TreeEntryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum TreeEntryTypeEnum {
@JsonValue(r'dir')
dir(r'dir'),
@JsonValue(r'file')
file(r'file'),
@JsonValue(r'symlink')
symlink(r'symlink'),
@JsonValue(r'submodule')
submodule(r'submodule');

const TreeEntryTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


