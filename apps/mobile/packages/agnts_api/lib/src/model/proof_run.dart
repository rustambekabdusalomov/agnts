//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'proof_run.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ProofRun {
  /// Returns a new [ProofRun] instance.
  ProofRun({

    required  this.exit,

    required  this.output,

    required  this.ms,
  });

  @JsonKey(
    
    name: r'exit',
    required: true,
    includeIfNull: false,
  )


  final int exit;



  @JsonKey(
    
    name: r'output',
    required: true,
    includeIfNull: false,
  )


  final String output;



  @JsonKey(
    
    name: r'ms',
    required: true,
    includeIfNull: false,
  )


  final int ms;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ProofRun &&
      other.exit == exit &&
      other.output == output &&
      other.ms == ms;

    @override
    int get hashCode =>
        exit.hashCode +
        output.hashCode +
        ms.hashCode;

  factory ProofRun.fromJson(Map<String, dynamic> json) => _$ProofRunFromJson(json);

  Map<String, dynamic> toJson() => _$ProofRunToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

