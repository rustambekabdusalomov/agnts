//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/sec_severity.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'security_settings.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SecuritySettings {
  /// Returns a new [SecuritySettings] instance.
  SecuritySettings({

    required  this.schedule,

    required  this.exclude,

    required  this.minNotify,

     this.nextAt,
  });

      /// Scan on its own at a quiet hour (03:00 UTC)
  @JsonKey(
    
    name: r'schedule',
    required: true,
    includeIfNull: false,
  )


  final SecuritySettingsScheduleEnum schedule;



      /// Path patterns no tool reports on, besides vendor, node_modules, dist, build and *.min.js
  @JsonKey(
    
    name: r'exclude',
    required: true,
    includeIfNull: false,
  )


  final List<String> exclude;



  @JsonKey(
    
    name: r'minNotify',
    required: true,
    includeIfNull: false,
  )


  final SecSeverity minNotify;



      /// When the next scheduled scan is due
  @JsonKey(
    
    name: r'nextAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? nextAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SecuritySettings &&
      other.schedule == schedule &&
      other.exclude == exclude &&
      other.minNotify == minNotify &&
      other.nextAt == nextAt;

    @override
    int get hashCode =>
        schedule.hashCode +
        exclude.hashCode +
        minNotify.hashCode +
        nextAt.hashCode;

  factory SecuritySettings.fromJson(Map<String, dynamic> json) => _$SecuritySettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SecuritySettingsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// Scan on its own at a quiet hour (03:00 UTC)
enum SecuritySettingsScheduleEnum {
@JsonValue(r'off')
off(r'off'),
@JsonValue(r'daily')
daily(r'daily'),
@JsonValue(r'weekly')
weekly(r'weekly');

const SecuritySettingsScheduleEnum(this.value);

final String value;

@override
String toString() => value;
}


