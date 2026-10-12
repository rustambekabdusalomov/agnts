//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analysis_acceptance_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnalysisAcceptanceInner {
  /// Returns a new [AnalysisAcceptanceInner] instance.
  AnalysisAcceptanceInner({

    required  this.id,

    required  this.criterion,

    required  this.check,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'criterion',
    required: true,
    includeIfNull: false,
  )


  final String criterion;



  @JsonKey(
    
    name: r'check',
    required: true,
    includeIfNull: false,
  )


  final AnalysisAcceptanceInnerCheckEnum check;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AnalysisAcceptanceInner &&
      other.id == id &&
      other.criterion == criterion &&
      other.check == check;

    @override
    int get hashCode =>
        id.hashCode +
        criterion.hashCode +
        check.hashCode;

  factory AnalysisAcceptanceInner.fromJson(Map<String, dynamic> json) => _$AnalysisAcceptanceInnerFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisAcceptanceInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum AnalysisAcceptanceInnerCheckEnum {
@JsonValue(r'ui')
ui(r'ui'),
@JsonValue(r'api')
api(r'api'),
@JsonValue(r'test')
test(r'test'),
@JsonValue(r'manual')
manual(r'manual');

const AnalysisAcceptanceInnerCheckEnum(this.value);

final String value;

@override
String toString() => value;
}


