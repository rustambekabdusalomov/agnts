//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_platform_user_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdatePlatformUserRequest {
  /// Returns a new [UpdatePlatformUserRequest] instance.
  UpdatePlatformUserRequest({

    required  this.isAdmin,
  });

  @JsonKey(
    
    name: r'isAdmin',
    required: true,
    includeIfNull: false,
  )


  final bool isAdmin;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpdatePlatformUserRequest &&
      other.isAdmin == isAdmin;

    @override
    int get hashCode =>
        isAdmin.hashCode;

  factory UpdatePlatformUserRequest.fromJson(Map<String, dynamic> json) => _$UpdatePlatformUserRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdatePlatformUserRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

