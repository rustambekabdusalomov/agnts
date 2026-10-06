//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/usage_window.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'usage.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Usage {
  /// Returns a new [Usage] instance.
  Usage({

    required  this.fiveHour,

    required  this.sevenDay,

    required  this.status,

     this.updatedAt,

    required  this.paused,

     this.pausedUntil,

    required  this.pauseAbove,

    required  this.refreshing,
  });

  @JsonKey(
    
    name: r'fiveHour',
    required: true,
    includeIfNull: false,
  )


  final UsageWindow fiveHour;



  @JsonKey(
    
    name: r'sevenDay',
    required: true,
    includeIfNull: false,
  )


  final UsageWindow sevenDay;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final UsageStatusEnum status;



  @JsonKey(
    
    name: r'updatedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? updatedAt;



      /// New runs are held back
  @JsonKey(
    
    name: r'paused',
    required: true,
    includeIfNull: false,
  )


  final bool paused;



  @JsonKey(
    
    name: r'pausedUntil',
    required: false,
    includeIfNull: false,
  )


  final DateTime? pausedUntil;



  @JsonKey(
    
    name: r'pauseAbove',
    required: true,
    includeIfNull: false,
  )


  final int pauseAbove;



  @JsonKey(
    
    name: r'refreshing',
    required: true,
    includeIfNull: false,
  )


  final bool refreshing;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Usage &&
      other.fiveHour == fiveHour &&
      other.sevenDay == sevenDay &&
      other.status == status &&
      other.updatedAt == updatedAt &&
      other.paused == paused &&
      other.pausedUntil == pausedUntil &&
      other.pauseAbove == pauseAbove &&
      other.refreshing == refreshing;

    @override
    int get hashCode =>
        fiveHour.hashCode +
        sevenDay.hashCode +
        status.hashCode +
        updatedAt.hashCode +
        paused.hashCode +
        pausedUntil.hashCode +
        pauseAbove.hashCode +
        refreshing.hashCode;

  factory Usage.fromJson(Map<String, dynamic> json) => _$UsageFromJson(json);

  Map<String, dynamic> toJson() => _$UsageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum UsageStatusEnum {
@JsonValue(r'allowed')
allowed(r'allowed'),
@JsonValue(r'allowed_warning')
allowedWarning(r'allowed_warning'),
@JsonValue(r'rejected')
rejected(r'rejected'),
@JsonValue(r'unknown')
unknown(r'unknown');

const UsageStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


