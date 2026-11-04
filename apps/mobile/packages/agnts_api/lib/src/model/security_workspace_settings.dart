//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'security_workspace_settings.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SecurityWorkspaceSettings {
  /// Returns a new [SecurityWorkspaceSettings] instance.
  SecurityWorkspaceSettings({

    required  this.autoCheck,

    required  this.dailyBudget,
  });

      /// Check agnts's own changes for security issues while they wait for review (advice, never a gate)
  @JsonKey(
    
    name: r'autoCheck',
    required: true,
    includeIfNull: false,
  )


  final bool autoCheck;



      /// Scheduled scans a day that may run the agent; later ones run the scanners only (0: no limit)
          // minimum: 0
          // maximum: 200
  @JsonKey(
    
    name: r'dailyBudget',
    required: true,
    includeIfNull: false,
  )


  final int dailyBudget;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SecurityWorkspaceSettings &&
      other.autoCheck == autoCheck &&
      other.dailyBudget == dailyBudget;

    @override
    int get hashCode =>
        autoCheck.hashCode +
        dailyBudget.hashCode;

  factory SecurityWorkspaceSettings.fromJson(Map<String, dynamic> json) => _$SecurityWorkspaceSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SecurityWorkspaceSettingsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

