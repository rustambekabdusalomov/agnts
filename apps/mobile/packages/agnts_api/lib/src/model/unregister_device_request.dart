//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'unregister_device_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UnregisterDeviceRequest {
  /// Returns a new [UnregisterDeviceRequest] instance.
  UnregisterDeviceRequest({

    required  this.fcmToken,
  });

  @JsonKey(
    
    name: r'fcmToken',
    required: true,
    includeIfNull: false,
  )


  final String fcmToken;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UnregisterDeviceRequest &&
      other.fcmToken == fcmToken;

    @override
    int get hashCode =>
        fcmToken.hashCode;

  factory UnregisterDeviceRequest.fromJson(Map<String, dynamic> json) => _$UnregisterDeviceRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UnregisterDeviceRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

