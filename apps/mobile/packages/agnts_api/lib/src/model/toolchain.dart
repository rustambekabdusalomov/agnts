//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'toolchain.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Toolchain {
  /// Returns a new [Toolchain] instance.
  Toolchain({

    required  this.tool,

    required  this.version,

     this.source_,

     this.dir,
  });

      /// mise tool name: go, node, python, rust, java, dotnet, ruby, ...
  @JsonKey(
    
    name: r'tool',
    required: true,
    includeIfNull: false,
  )


  final String tool;



      /// Exact, a prefix (20, 3.12), latest, lts or system
  @JsonKey(
    
    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final String version;



      /// Where it was found: go.mod, .nvmrc, default, manual
  @JsonKey(
    
    name: r'source',
    required: false,
    includeIfNull: false,
  )


  final String? source_;



      /// Subdirectory it was found in
  @JsonKey(
    
    name: r'dir',
    required: false,
    includeIfNull: false,
  )


  final String? dir;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Toolchain &&
      other.tool == tool &&
      other.version == version &&
      other.source_ == source_ &&
      other.dir == dir;

    @override
    int get hashCode =>
        tool.hashCode +
        version.hashCode +
        source_.hashCode +
        dir.hashCode;

  factory Toolchain.fromJson(Map<String, dynamic> json) => _$ToolchainFromJson(json);

  Map<String, dynamic> toJson() => _$ToolchainToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

