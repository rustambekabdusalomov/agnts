//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'file_change.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FileChange {
  /// Returns a new [FileChange] instance.
  FileChange({

     this.repo,

     this.repoId,

    required  this.path,

    required  this.add,

    required  this.del,

    required  this.diff,
  });

      /// The repository's folder, for a ticket in several; path is relative to the repository
  @JsonKey(
    
    name: r'repo',
    required: false,
    includeIfNull: false,
  )


  final String? repo;



  @JsonKey(
    
    name: r'repoId',
    required: false,
    includeIfNull: false,
  )


  final int? repoId;



  @JsonKey(
    
    name: r'path',
    required: true,
    includeIfNull: false,
  )


  final String path;



  @JsonKey(
    
    name: r'add',
    required: true,
    includeIfNull: false,
  )


  final int add;



  @JsonKey(
    
    name: r'del',
    required: true,
    includeIfNull: false,
  )


  final int del;



  @JsonKey(
    
    name: r'diff',
    required: true,
    includeIfNull: false,
  )


  final String diff;





    @override
    bool operator ==(Object other) => identical(this, other) || other is FileChange &&
      other.repo == repo &&
      other.repoId == repoId &&
      other.path == path &&
      other.add == add &&
      other.del == del &&
      other.diff == diff;

    @override
    int get hashCode =>
        repo.hashCode +
        repoId.hashCode +
        path.hashCode +
        add.hashCode +
        del.hashCode +
        diff.hashCode;

  factory FileChange.fromJson(Map<String, dynamic> json) => _$FileChangeFromJson(json);

  Map<String, dynamic> toJson() => _$FileChangeToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

