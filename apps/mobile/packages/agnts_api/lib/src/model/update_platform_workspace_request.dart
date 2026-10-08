//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_platform_workspace_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdatePlatformWorkspaceRequest {
  /// Returns a new [UpdatePlatformWorkspaceRequest] instance.
  UpdatePlatformWorkspaceRequest({

     this.plan,

     this.slots,

     this.memberLimit,

     this.suspended,
  });

  @JsonKey(
    
    name: r'plan',
    required: false,
    includeIfNull: false,
  )


  final String? plan;



          // minimum: 1
          // maximum: 50
  @JsonKey(
    
    name: r'slots',
    required: false,
    includeIfNull: false,
  )


  final int? slots;



          // minimum: 0
          // maximum: 10000
  @JsonKey(
    
    name: r'memberLimit',
    required: false,
    includeIfNull: false,
  )


  final int? memberLimit;



  @JsonKey(
    
    name: r'suspended',
    required: false,
    includeIfNull: false,
  )


  final bool? suspended;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpdatePlatformWorkspaceRequest &&
      other.plan == plan &&
      other.slots == slots &&
      other.memberLimit == memberLimit &&
      other.suspended == suspended;

    @override
    int get hashCode =>
        plan.hashCode +
        slots.hashCode +
        memberLimit.hashCode +
        suspended.hashCode;

  factory UpdatePlatformWorkspaceRequest.fromJson(Map<String, dynamic> json) => _$UpdatePlatformWorkspaceRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdatePlatformWorkspaceRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

