//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/acceptance_criteria_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'acceptance.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Acceptance {
  /// Returns a new [Acceptance] instance.
  Acceptance({

    required  this.status,

    required  this.summary,

    required  this.criteria,
  });

  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final AcceptanceStatusEnum status;



  @JsonKey(
    
    name: r'summary',
    required: true,
    includeIfNull: false,
  )


  final String summary;



  @JsonKey(
    
    name: r'criteria',
    required: true,
    includeIfNull: false,
  )


  final List<AcceptanceCriteriaInner> criteria;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Acceptance &&
      other.status == status &&
      other.summary == summary &&
      other.criteria == criteria;

    @override
    int get hashCode =>
        status.hashCode +
        summary.hashCode +
        criteria.hashCode;

  factory Acceptance.fromJson(Map<String, dynamic> json) => _$AcceptanceFromJson(json);

  Map<String, dynamic> toJson() => _$AcceptanceToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum AcceptanceStatusEnum {
@JsonValue(r'ok')
ok(r'ok'),
@JsonValue(r'partial')
partial(r'partial'),
@JsonValue(r'failed')
failed(r'failed');

const AcceptanceStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


