//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'decide_code_approval_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DecideCodeApprovalRequest {
  /// Returns a new [DecideCodeApprovalRequest] instance.
  DecideCodeApprovalRequest({

    required  this.allow,
  });

  @JsonKey(
    
    name: r'allow',
    required: true,
    includeIfNull: false,
  )


  final bool allow;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DecideCodeApprovalRequest &&
      other.allow == allow;

    @override
    int get hashCode =>
        allow.hashCode;

  factory DecideCodeApprovalRequest.fromJson(Map<String, dynamic> json) => _$DecideCodeApprovalRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DecideCodeApprovalRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

