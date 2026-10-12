//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ci_watch.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CIWatch {
  /// Returns a new [CIWatch] instance.
  CIWatch({

    required  this.enabled,

    required  this.branches,

    required  this.ignore,

    required  this.prs,

     this.autoFix,

     this.problem,
  });

  @JsonKey(
    
    name: r'enabled',
    required: true,
    includeIfNull: false,
  )


  final bool enabled;



      /// Globs of extra watched branches; the default branch is always watched
  @JsonKey(
    
    name: r'branches',
    required: true,
    includeIfNull: false,
  )


  final List<String> branches;



      /// Globs of workflow or job names never watched
  @JsonKey(
    
    name: r'ignore',
    required: true,
    includeIfNull: false,
  )


  final List<String> ignore;



      /// Failures on other people's pull requests: off (ignore) or comment (post one diagnosis comment)
  @JsonKey(
    
    name: r'prs',
    required: true,
    includeIfNull: false,
  )


  final String prs;



      /// Overrides the workspace setting for this repository; null follows it
  @JsonKey(
    
    name: r'autoFix',
    required: false,
    includeIfNull: false,
  )


  final bool? autoFix;



      /// Why agnts cannot read this repository's CI with the current token, or empty
  @JsonKey(
    
    name: r'problem',
    required: false,
    includeIfNull: false,
  )


  final String? problem;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CIWatch &&
      other.enabled == enabled &&
      other.branches == branches &&
      other.ignore == ignore &&
      other.prs == prs &&
      other.autoFix == autoFix &&
      other.problem == problem;

    @override
    int get hashCode =>
        enabled.hashCode +
        branches.hashCode +
        ignore.hashCode +
        prs.hashCode +
        (autoFix == null ? 0 : autoFix.hashCode) +
        problem.hashCode;

  factory CIWatch.fromJson(Map<String, dynamic> json) => _$CIWatchFromJson(json);

  Map<String, dynamic> toJson() => _$CIWatchToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

