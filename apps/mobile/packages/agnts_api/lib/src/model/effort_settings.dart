//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'effort_settings.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EffortSettings {
  /// Returns a new [EffortSettings] instance.
  EffortSettings({

    required  this.analyze,

    required  this.coding,

    required  this.review,

    required  this.complex,
  });

  @JsonKey(
    
    name: r'analyze',
    required: true,
    includeIfNull: false,
  )


  final EffortSettingsAnalyzeEnum analyze;



  @JsonKey(
    
    name: r'coding',
    required: true,
    includeIfNull: false,
  )


  final EffortSettingsCodingEnum coding;



  @JsonKey(
    
    name: r'review',
    required: true,
    includeIfNull: false,
  )


  final EffortSettingsReviewEnum review;



      /// For the coding and review of complex tickets, and the re-check of their analysis; empty keeps the stage effort
  @JsonKey(
    
    name: r'complex',
    required: true,
    includeIfNull: false,
  )


  final EffortSettingsComplexEnum complex;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EffortSettings &&
      other.analyze == analyze &&
      other.coding == coding &&
      other.review == review &&
      other.complex == complex;

    @override
    int get hashCode =>
        analyze.hashCode +
        coding.hashCode +
        review.hashCode +
        complex.hashCode;

  factory EffortSettings.fromJson(Map<String, dynamic> json) => _$EffortSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$EffortSettingsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum EffortSettingsAnalyzeEnum {
@JsonValue(r'')
empty(r''),
@JsonValue(r'low')
low(r'low'),
@JsonValue(r'medium')
medium(r'medium'),
@JsonValue(r'high')
high(r'high');

const EffortSettingsAnalyzeEnum(this.value);

final String value;

@override
String toString() => value;
}


enum EffortSettingsCodingEnum {
@JsonValue(r'')
empty(r''),
@JsonValue(r'low')
low(r'low'),
@JsonValue(r'medium')
medium(r'medium'),
@JsonValue(r'high')
high(r'high');

const EffortSettingsCodingEnum(this.value);

final String value;

@override
String toString() => value;
}


enum EffortSettingsReviewEnum {
@JsonValue(r'')
empty(r''),
@JsonValue(r'low')
low(r'low'),
@JsonValue(r'medium')
medium(r'medium'),
@JsonValue(r'high')
high(r'high');

const EffortSettingsReviewEnum(this.value);

final String value;

@override
String toString() => value;
}


/// For the coding and review of complex tickets, and the re-check of their analysis; empty keeps the stage effort
enum EffortSettingsComplexEnum {
@JsonValue(r'')
empty(r''),
@JsonValue(r'low')
low(r'low'),
@JsonValue(r'medium')
medium(r'medium'),
@JsonValue(r'high')
high(r'high');

const EffortSettingsComplexEnum(this.value);

final String value;

@override
String toString() => value;
}


