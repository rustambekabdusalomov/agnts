//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'delivery_day.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DeliveryDay {
  /// Returns a new [DeliveryDay] instance.
  DeliveryDay({

    required  this.date,

    required  this.merged,

    required  this.closed,

     this.pushedMin,

     this.mergedMin,
  });

  @JsonKey(
    
    name: r'date',
    required: true,
    includeIfNull: false,
  )


  final DateTime date;



  @JsonKey(
    
    name: r'merged',
    required: true,
    includeIfNull: false,
  )


  final int merged;



  @JsonKey(
    
    name: r'closed',
    required: true,
    includeIfNull: false,
  )


  final int closed;



      /// Median minutes picked → pushed of the tickets pushed that day
  @JsonKey(
    
    name: r'pushedMin',
    required: false,
    includeIfNull: false,
  )


  final num? pushedMin;



      /// Median minutes picked → merged of the tickets merged that day
  @JsonKey(
    
    name: r'mergedMin',
    required: false,
    includeIfNull: false,
  )


  final num? mergedMin;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DeliveryDay &&
      other.date == date &&
      other.merged == merged &&
      other.closed == closed &&
      other.pushedMin == pushedMin &&
      other.mergedMin == mergedMin;

    @override
    int get hashCode =>
        date.hashCode +
        merged.hashCode +
        closed.hashCode +
        pushedMin.hashCode +
        mergedMin.hashCode;

  factory DeliveryDay.fromJson(Map<String, dynamic> json) => _$DeliveryDayFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveryDayToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

