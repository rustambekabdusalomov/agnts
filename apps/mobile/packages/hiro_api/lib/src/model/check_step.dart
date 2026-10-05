//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'check_step.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CheckStep {
  /// Returns a new [CheckStep] instance.
  CheckStep({

    required  this.name,

    required  this.command,

    required  this.exitCode,

    required  this.durationMs,

     this.timedOut,

     this.output,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'command',
    required: true,
    includeIfNull: false,
  )


  final String command;



  @JsonKey(
    
    name: r'exitCode',
    required: true,
    includeIfNull: false,
  )


  final int exitCode;



  @JsonKey(
    
    name: r'durationMs',
    required: true,
    includeIfNull: false,
  )


  final int durationMs;



  @JsonKey(
    
    name: r'timedOut',
    required: false,
    includeIfNull: false,
  )


  final bool? timedOut;



  @JsonKey(
    
    name: r'output',
    required: false,
    includeIfNull: false,
  )


  final String? output;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CheckStep &&
      other.name == name &&
      other.command == command &&
      other.exitCode == exitCode &&
      other.durationMs == durationMs &&
      other.timedOut == timedOut &&
      other.output == output;

    @override
    int get hashCode =>
        name.hashCode +
        command.hashCode +
        exitCode.hashCode +
        durationMs.hashCode +
        timedOut.hashCode +
        output.hashCode;

  factory CheckStep.fromJson(Map<String, dynamic> json) => _$CheckStepFromJson(json);

  Map<String, dynamic> toJson() => _$CheckStepToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

