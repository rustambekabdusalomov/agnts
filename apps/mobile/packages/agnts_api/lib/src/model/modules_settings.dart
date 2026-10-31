//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/module.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'modules_settings.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ModulesSettings {
  /// Returns a new [ModulesSettings] instance.
  ModulesSettings({

    required  this.available,

    required  this.enabled,

    required  this.default_,
  });

      /// What this server can run (AGNTS_PROVIDERS); enabled stays within it
  @JsonKey(
    
    name: r'available',
    required: true,
    includeIfNull: false,
  )


  final List<Module> available;



  @JsonKey(
    
    name: r'enabled',
    required: true,
    includeIfNull: false,
  )


  final List<Module> enabled;



      /// What a person gets unless an Admin set theirs, the default module first; codex cannot be first
  @JsonKey(
    
    name: r'default',
    required: true,
    includeIfNull: false,
  )


  final List<Module> default_;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ModulesSettings &&
      other.available == available &&
      other.enabled == enabled &&
      other.default_ == default_;

    @override
    int get hashCode =>
        available.hashCode +
        enabled.hashCode +
        default_.hashCode;

  factory ModulesSettings.fromJson(Map<String, dynamic> json) => _$ModulesSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$ModulesSettingsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

