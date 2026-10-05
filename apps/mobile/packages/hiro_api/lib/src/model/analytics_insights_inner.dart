//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analytics_insights_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnalyticsInsightsInner {
  /// Returns a new [AnalyticsInsightsInner] instance.
  AnalyticsInsightsInner({

    required  this.kind,

    required  this.values,
  });

  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final AnalyticsInsightsInnerKindEnum kind;



  @JsonKey(
    
    name: r'values',
    required: true,
    includeIfNull: false,
  )


  final Map<String, String> values;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AnalyticsInsightsInner &&
      other.kind == kind &&
      other.values == values;

    @override
    int get hashCode =>
        kind.hashCode +
        values.hashCode;

  factory AnalyticsInsightsInner.fromJson(Map<String, dynamic> json) => _$AnalyticsInsightsInnerFromJson(json);

  Map<String, dynamic> toJson() => _$AnalyticsInsightsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum AnalyticsInsightsInnerKindEnum {
@JsonValue(r'claudeMd')
claudeMd(r'claudeMd'),
@JsonValue(r'waiting')
waiting(r'waiting'),
@JsonValue(r'stopsTests')
stopsTests(r'stopsTests'),
@JsonValue(r'stopsLimit')
stopsLimit(r'stopsLimit'),
@JsonValue(r'night')
night(r'night');

const AnalyticsInsightsInnerKindEnum(this.value);

final String value;

@override
String toString() => value;
}


