//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'device_registration.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DeviceRegistration {
  /// Returns a new [DeviceRegistration] instance.
  DeviceRegistration({

    required  this.platform,

    required  this.fcmToken,

     this.appVersion,
  });

  @JsonKey(
    
    name: r'platform',
    required: true,
    includeIfNull: false,
  )


  final DeviceRegistrationPlatformEnum platform;



  @JsonKey(
    
    name: r'fcmToken',
    required: true,
    includeIfNull: false,
  )


  final String fcmToken;



  @JsonKey(
    
    name: r'appVersion',
    required: false,
    includeIfNull: false,
  )


  final String? appVersion;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DeviceRegistration &&
      other.platform == platform &&
      other.fcmToken == fcmToken &&
      other.appVersion == appVersion;

    @override
    int get hashCode =>
        platform.hashCode +
        fcmToken.hashCode +
        appVersion.hashCode;

  factory DeviceRegistration.fromJson(Map<String, dynamic> json) => _$DeviceRegistrationFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceRegistrationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum DeviceRegistrationPlatformEnum {
@JsonValue(r'ios')
ios(r'ios'),
@JsonValue(r'android')
android(r'android');

const DeviceRegistrationPlatformEnum(this.value);

final String value;

@override
String toString() => value;
}


