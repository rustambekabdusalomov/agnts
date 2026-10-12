//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ci_settings.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CISettings {
  /// Returns a new [CISettings] instance.
  CISettings({

    required  this.autoFix,

    required  this.maxAutoPerDay,

    required  this.retryFlaky,

    required  this.feedbackRounds,

    required  this.infraPatterns,
  });

      /// Open a ticket for every confirmed failure on a watched branch; off, failures wait for Fix it
  @JsonKey(
    
    name: r'autoFix',
    required: true,
    includeIfNull: false,
  )


  final bool autoFix;



      /// Automatic CI tickets a day at most
          // minimum: 0
          // maximum: 50
  @JsonKey(
    
    name: r'maxAutoPerDay',
    required: true,
    includeIfNull: false,
  )


  final int maxAutoPerDay;



      /// Re-run the failed jobs of a new failure once before believing it
  @JsonKey(
    
    name: r'retryFlaky',
    required: true,
    includeIfNull: false,
  )


  final bool retryFlaky;



      /// How many times a red check sends one of agnts's pull requests back to coding; 0 turns it off
          // minimum: 0
          // maximum: 5
  @JsonKey(
    
    name: r'feedbackRounds',
    required: true,
    includeIfNull: false,
  )


  final int feedbackRounds;



      /// Extra regular expressions that mark a failure as infra (not the code)
  @JsonKey(
    
    name: r'infraPatterns',
    required: true,
    includeIfNull: false,
  )


  final List<String> infraPatterns;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CISettings &&
      other.autoFix == autoFix &&
      other.maxAutoPerDay == maxAutoPerDay &&
      other.retryFlaky == retryFlaky &&
      other.feedbackRounds == feedbackRounds &&
      other.infraPatterns == infraPatterns;

    @override
    int get hashCode =>
        autoFix.hashCode +
        maxAutoPerDay.hashCode +
        retryFlaky.hashCode +
        feedbackRounds.hashCode +
        infraPatterns.hashCode;

  factory CISettings.fromJson(Map<String, dynamic> json) => _$CISettingsFromJson(json);

  Map<String, dynamic> toJson() => _$CISettingsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

