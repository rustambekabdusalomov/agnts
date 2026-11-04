//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dismiss_security_findings_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DismissSecurityFindingsRequest {
  /// Returns a new [DismissSecurityFindingsRequest] instance.
  DismissSecurityFindingsRequest({

    required  this.findingIds,

    required  this.reason,

     this.note,
  });

  @JsonKey(
    
    name: r'findingIds',
    required: true,
    includeIfNull: false,
  )


  final List<int> findingIds;



  @JsonKey(
    
    name: r'reason',
    required: true,
    includeIfNull: false,
  )


  final DismissSecurityFindingsRequestReasonEnum reason;



  @JsonKey(
    
    name: r'note',
    required: false,
    includeIfNull: false,
  )


  final String? note;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DismissSecurityFindingsRequest &&
      other.findingIds == findingIds &&
      other.reason == reason &&
      other.note == note;

    @override
    int get hashCode =>
        findingIds.hashCode +
        reason.hashCode +
        note.hashCode;

  factory DismissSecurityFindingsRequest.fromJson(Map<String, dynamic> json) => _$DismissSecurityFindingsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DismissSecurityFindingsRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum DismissSecurityFindingsRequestReasonEnum {
@JsonValue(r'false_positive')
falsePositive(r'false_positive'),
@JsonValue(r'accepted_risk')
acceptedRisk(r'accepted_risk'),
@JsonValue(r'wont_fix')
wontFix(r'wont_fix');

const DismissSecurityFindingsRequestReasonEnum(this.value);

final String value;

@override
String toString() => value;
}


