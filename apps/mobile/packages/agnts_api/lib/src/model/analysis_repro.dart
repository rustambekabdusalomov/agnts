//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analysis_repro.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnalysisRepro {
  /// Returns a new [AnalysisRepro] instance.
  AnalysisRepro({

    required  this.reproduced,

     this.command,

     this.output,

     this.why,
  });

  @JsonKey(
    
    name: r'reproduced',
    required: true,
    includeIfNull: false,
  )


  final bool reproduced;



  @JsonKey(
    
    name: r'command',
    required: false,
    includeIfNull: false,
  )


  final String? command;



  @JsonKey(
    
    name: r'output',
    required: false,
    includeIfNull: false,
  )


  final String? output;



  @JsonKey(
    
    name: r'why',
    required: false,
    includeIfNull: false,
  )


  final String? why;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AnalysisRepro &&
      other.reproduced == reproduced &&
      other.command == command &&
      other.output == output &&
      other.why == why;

    @override
    int get hashCode =>
        reproduced.hashCode +
        command.hashCode +
        output.hashCode +
        why.hashCode;

  factory AnalysisRepro.fromJson(Map<String, dynamic> json) => _$AnalysisReproFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisReproToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

