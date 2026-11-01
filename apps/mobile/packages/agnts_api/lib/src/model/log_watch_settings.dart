//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/log_override.dart';
import 'package:agnts_api/src/model/log_pattern.dart';
import 'package:agnts_api/src/model/log_severity.dart';
import 'package:agnts_api/src/model/log_mode.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'log_watch_settings.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LogWatchSettings {
  /// Returns a new [LogWatchSettings] instance.
  LogWatchSettings({

    required  this.errors,

    required  this.security,

    required  this.alwaysNotifyLeaks,

    required  this.minSeverity,

    required  this.threshold,

    required  this.maxAutoPerDay,

    required  this.attackTicketAfter,

    required  this.resolveAfterDays,

    required  this.digest,

    required  this.triagePerDay,

    required  this.patterns,

    required  this.overrides,
  });

  @JsonKey(
    
    name: r'errors',
    required: true,
    includeIfNull: false,
  )


  final LogMode errors;



  @JsonKey(
    
    name: r'security',
    required: true,
    includeIfNull: false,
  )


  final LogMode security;



      /// Notify a high-severity secret leak even when Security is off
  @JsonKey(
    
    name: r'alwaysNotifyLeaks',
    required: true,
    includeIfNull: false,
  )


  final bool alwaysNotifyLeaks;



  @JsonKey(
    
    name: r'minSeverity',
    required: true,
    includeIfNull: false,
  )


  final LogSeverity minSeverity;



      /// Occurrences within the hour before a plain error acts
          // minimum: 1
          // maximum: 1000
  @JsonKey(
    
    name: r'threshold',
    required: true,
    includeIfNull: false,
  )


  final int threshold;



      /// Automatic log tickets a day at most
          // minimum: 0
          // maximum: 50
  @JsonKey(
    
    name: r'maxAutoPerDay',
    required: true,
    includeIfNull: false,
  )


  final int maxAutoPerDay;



      /// Bursts of the same attack within 7 days before a hardening ticket; 0 never
          // minimum: 0
          // maximum: 50
  @JsonKey(
    
    name: r'attackTicketAfter',
    required: true,
    includeIfNull: false,
  )


  final int attackTicketAfter;



          // minimum: 1
          // maximum: 30
  @JsonKey(
    
    name: r'resolveAfterDays',
    required: true,
    includeIfNull: false,
  )


  final int resolveAfterDays;



      /// One daily summary instead of a message per finding
  @JsonKey(
    
    name: r'digest',
    required: true,
    includeIfNull: false,
  )


  final bool digest;



      /// Model triage calls a day for new findings; 0 off
          // minimum: 0
          // maximum: 500
  @JsonKey(
    
    name: r'triagePerDay',
    required: true,
    includeIfNull: false,
  )


  final int triagePerDay;



  @JsonKey(
    
    name: r'patterns',
    required: true,
    includeIfNull: false,
  )


  final List<LogPattern> patterns;



  @JsonKey(
    
    name: r'overrides',
    required: true,
    includeIfNull: false,
  )


  final List<LogOverride> overrides;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LogWatchSettings &&
      other.errors == errors &&
      other.security == security &&
      other.alwaysNotifyLeaks == alwaysNotifyLeaks &&
      other.minSeverity == minSeverity &&
      other.threshold == threshold &&
      other.maxAutoPerDay == maxAutoPerDay &&
      other.attackTicketAfter == attackTicketAfter &&
      other.resolveAfterDays == resolveAfterDays &&
      other.digest == digest &&
      other.triagePerDay == triagePerDay &&
      other.patterns == patterns &&
      other.overrides == overrides;

    @override
    int get hashCode =>
        errors.hashCode +
        security.hashCode +
        alwaysNotifyLeaks.hashCode +
        minSeverity.hashCode +
        threshold.hashCode +
        maxAutoPerDay.hashCode +
        attackTicketAfter.hashCode +
        resolveAfterDays.hashCode +
        digest.hashCode +
        triagePerDay.hashCode +
        patterns.hashCode +
        overrides.hashCode;

  factory LogWatchSettings.fromJson(Map<String, dynamic> json) => _$LogWatchSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$LogWatchSettingsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

