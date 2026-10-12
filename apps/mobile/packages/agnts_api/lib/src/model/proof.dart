//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/proof_test.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'proof.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Proof {
  /// Returns a new [Proof] instance.
  Proof({

    required  this.status,

     this.base_,

     this.why,

    required  this.tests,
  });

  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final ProofStatusEnum status;



      /// The commit the change started from
  @JsonKey(
    
    name: r'base',
    required: false,
    includeIfNull: false,
  )


  final String? base_;



  @JsonKey(
    
    name: r'why',
    required: false,
    includeIfNull: false,
  )


  final String? why;



  @JsonKey(
    
    name: r'tests',
    required: true,
    includeIfNull: false,
  )


  final List<ProofTest> tests;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Proof &&
      other.status == status &&
      other.base_ == base_ &&
      other.why == why &&
      other.tests == tests;

    @override
    int get hashCode =>
        status.hashCode +
        base_.hashCode +
        why.hashCode +
        tests.hashCode;

  factory Proof.fromJson(Map<String, dynamic> json) => _$ProofFromJson(json);

  Map<String, dynamic> toJson() => _$ProofToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum ProofStatusEnum {
@JsonValue(r'proven')
proven(r'proven'),
@JsonValue(r'not_reproduced')
notReproduced(r'not_reproduced'),
@JsonValue(r'still_failing')
stillFailing(r'still_failing'),
@JsonValue(r'inconclusive')
inconclusive(r'inconclusive'),
@JsonValue(r'no_test')
noTest(r'no_test'),
@JsonValue(r'error')
error(r'error');

const ProofStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


