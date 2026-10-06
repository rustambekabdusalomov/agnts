//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/follow_ups_mode.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'follow_ups_setting.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FollowUpsSetting {
  /// Returns a new [FollowUpsSetting] instance.
  FollowUpsSetting({

    required  this.mode,
  });

  @JsonKey(
    
    name: r'mode',
    required: true,
    includeIfNull: false,
  )


  final FollowUpsMode mode;





    @override
    bool operator ==(Object other) => identical(this, other) || other is FollowUpsSetting &&
      other.mode == mode;

    @override
    int get hashCode =>
        mode.hashCode;

  factory FollowUpsSetting.fromJson(Map<String, dynamic> json) => _$FollowUpsSettingFromJson(json);

  Map<String, dynamic> toJson() => _$FollowUpsSettingToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

