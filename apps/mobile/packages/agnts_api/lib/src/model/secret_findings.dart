//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/secret_findings_findings_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'secret_findings.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SecretFindings {
  /// Returns a new [SecretFindings] instance.
  SecretFindings({

    required  this.code,

    required  this.message,

    required  this.findings,
  });

  @JsonKey(
    
    name: r'code',
    required: true,
    includeIfNull: false,
  )


  final String code;



  @JsonKey(
    
    name: r'message',
    required: true,
    includeIfNull: false,
  )


  final String message;



  @JsonKey(
    
    name: r'findings',
    required: true,
    includeIfNull: false,
  )


  final List<SecretFindingsFindingsInner> findings;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SecretFindings &&
      other.code == code &&
      other.message == message &&
      other.findings == findings;

    @override
    int get hashCode =>
        code.hashCode +
        message.hashCode +
        findings.hashCode;

  factory SecretFindings.fromJson(Map<String, dynamic> json) => _$SecretFindingsFromJson(json);

  Map<String, dynamic> toJson() => _$SecretFindingsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

