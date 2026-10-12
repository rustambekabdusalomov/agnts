//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'coverage_config.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CoverageConfig {
  /// Returns a new [CoverageConfig] instance.
  CoverageConfig({

     this.enabled,

     this.command,

     this.report,

     this.threshold,
  });

  @JsonKey(
    
    name: r'enabled',
    required: false,
    includeIfNull: false,
  )


  final bool? enabled;



      /// Runs the tests with coverage; empty uses the one agnts derives
  @JsonKey(
    
    name: r'command',
    required: false,
    includeIfNull: false,
  )


  final String? command;



      /// The report the command writes (Go profile or lcov), in the repository or under /agnts/out/
  @JsonKey(
    
    name: r'report',
    required: false,
    includeIfNull: false,
  )


  final String? report;



          // minimum: 0
          // maximum: 100
  @JsonKey(
    
    name: r'threshold',
    required: false,
    includeIfNull: false,
  )


  final int? threshold;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CoverageConfig &&
      other.enabled == enabled &&
      other.command == command &&
      other.report == report &&
      other.threshold == threshold;

    @override
    int get hashCode =>
        enabled.hashCode +
        command.hashCode +
        report.hashCode +
        threshold.hashCode;

  factory CoverageConfig.fromJson(Map<String, dynamic> json) => _$CoverageConfigFromJson(json);

  Map<String, dynamic> toJson() => _$CoverageConfigToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

