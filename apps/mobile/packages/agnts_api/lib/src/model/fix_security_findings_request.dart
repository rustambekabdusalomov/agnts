//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'fix_security_findings_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FixSecurityFindingsRequest {
  /// Returns a new [FixSecurityFindingsRequest] instance.
  FixSecurityFindingsRequest({

    required  this.findingIds,

     this.hold,
  });

  @JsonKey(
    
    name: r'findingIds',
    required: true,
    includeIfNull: false,
  )


  final List<int> findingIds;



      /// Create the ticket without starting it
  @JsonKey(
    
    name: r'hold',
    required: false,
    includeIfNull: false,
  )


  final bool? hold;





    @override
    bool operator ==(Object other) => identical(this, other) || other is FixSecurityFindingsRequest &&
      other.findingIds == findingIds &&
      other.hold == hold;

    @override
    int get hashCode =>
        findingIds.hashCode +
        hold.hashCode;

  factory FixSecurityFindingsRequest.fromJson(Map<String, dynamic> json) => _$FixSecurityFindingsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$FixSecurityFindingsRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

