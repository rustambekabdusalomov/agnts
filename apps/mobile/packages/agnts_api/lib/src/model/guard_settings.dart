//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/guard_hook.dart';
import 'package:agnts_api/src/model/guard_profile.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'guard_settings.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GuardSettings {
  /// Returns a new [GuardSettings] instance.
  GuardSettings({

    required  this.profile,

    required  this.disabled,

    required  this.factCheck,
  });

  @JsonKey(
    
    name: r'profile',
    required: true,
    includeIfNull: false,
  )


  final GuardProfile profile;



      /// Guard hooks turned off
  @JsonKey(
    
    name: r'disabled',
    required: true,
    includeIfNull: false,
  )


  final List<GuardHook> disabled;



      /// Percent of strict-profile tickets whose runs must state facts before the first edit of each file (A/B)
          // minimum: 0
          // maximum: 100
  @JsonKey(
    
    name: r'factCheck',
    required: true,
    includeIfNull: false,
  )


  final int factCheck;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GuardSettings &&
      other.profile == profile &&
      other.disabled == disabled &&
      other.factCheck == factCheck;

    @override
    int get hashCode =>
        profile.hashCode +
        disabled.hashCode +
        factCheck.hashCode;

  factory GuardSettings.fromJson(Map<String, dynamic> json) => _$GuardSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$GuardSettingsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

