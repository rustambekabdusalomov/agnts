//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/proof_run.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'proof_test.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ProofTest {
  /// Returns a new [ProofTest] instance.
  ProofTest({

    required  this.file,

    required  this.name,

    required  this.command,

    required  this.status,

    required  this.before,

    required  this.after,
  });

  @JsonKey(
    
    name: r'file',
    required: true,
    includeIfNull: false,
  )


  final String file;



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
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final String status;



  @JsonKey(
    
    name: r'before',
    required: true,
    includeIfNull: false,
  )


  final ProofRun before;



  @JsonKey(
    
    name: r'after',
    required: true,
    includeIfNull: false,
  )


  final ProofRun after;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ProofTest &&
      other.file == file &&
      other.name == name &&
      other.command == command &&
      other.status == status &&
      other.before == before &&
      other.after == after;

    @override
    int get hashCode =>
        file.hashCode +
        name.hashCode +
        command.hashCode +
        status.hashCode +
        before.hashCode +
        after.hashCode;

  factory ProofTest.fromJson(Map<String, dynamic> json) => _$ProofTestFromJson(json);

  Map<String, dynamic> toJson() => _$ProofTestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

