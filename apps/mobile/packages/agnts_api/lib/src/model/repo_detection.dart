//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/toolchain.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'repo_detection.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RepoDetection {
  /// Returns a new [RepoDetection] instance.
  RepoDetection({

    required  this.toolchains,

    required  this.buildCmd,

    required  this.lintCmd,

    required  this.testCmd,

    required  this.notes,

    required  this.stack,

    required  this.source_,
  });

  @JsonKey(
    
    name: r'toolchains',
    required: true,
    includeIfNull: false,
  )


  final List<Toolchain> toolchains;



  @JsonKey(
    
    name: r'buildCmd',
    required: true,
    includeIfNull: false,
  )


  final String buildCmd;



  @JsonKey(
    
    name: r'lintCmd',
    required: true,
    includeIfNull: false,
  )


  final String lintCmd;



  @JsonKey(
    
    name: r'testCmd',
    required: true,
    includeIfNull: false,
  )


  final String testCmd;



  @JsonKey(
    
    name: r'notes',
    required: true,
    includeIfNull: false,
  )


  final List<String> notes;



  @JsonKey(
    
    name: r'stack',
    required: true,
    includeIfNull: false,
  )


  final String stack;



      /// Whether Claude filled in what the file scan could not
  @JsonKey(
    
    name: r'source',
    required: true,
    includeIfNull: false,
  )


  final RepoDetectionSource_Enum source_;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RepoDetection &&
      other.toolchains == toolchains &&
      other.buildCmd == buildCmd &&
      other.lintCmd == lintCmd &&
      other.testCmd == testCmd &&
      other.notes == notes &&
      other.stack == stack &&
      other.source_ == source_;

    @override
    int get hashCode =>
        toolchains.hashCode +
        buildCmd.hashCode +
        lintCmd.hashCode +
        testCmd.hashCode +
        notes.hashCode +
        stack.hashCode +
        source_.hashCode;

  factory RepoDetection.fromJson(Map<String, dynamic> json) => _$RepoDetectionFromJson(json);

  Map<String, dynamic> toJson() => _$RepoDetectionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// Whether Claude filled in what the file scan could not
enum RepoDetectionSource_Enum {
@JsonValue(r'files')
files(r'files'),
@JsonValue(r'claude')
claude(r'claude');

const RepoDetectionSource_Enum(this.value);

final String value;

@override
String toString() => value;
}


