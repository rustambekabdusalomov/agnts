//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/slow_ticket.dart';
import 'package:agnts_api/src/model/stale_pr.dart';
import 'package:agnts_api/src/model/delivery_day.dart';
import 'package:agnts_api/src/model/delivery_period.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analytics_delivery.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnalyticsDelivery {
  /// Returns a new [AnalyticsDelivery] instance.
  AnalyticsDelivery({

    required  this.days,

    required  this.current,

    required  this.previous,

    required  this.perDay,

    required  this.slowest,

    required  this.stale,

    required  this.unanswered,
  });

  @JsonKey(
    
    name: r'days',
    required: true,
    includeIfNull: false,
  )


  final int days;



  @JsonKey(
    
    name: r'current',
    required: true,
    includeIfNull: false,
  )


  final DeliveryPeriod current;



  @JsonKey(
    
    name: r'previous',
    required: true,
    includeIfNull: false,
  )


  final DeliveryPeriod previous;



  @JsonKey(
    
    name: r'perDay',
    required: true,
    includeIfNull: false,
  )


  final List<DeliveryDay> perDay;



      /// The slowest tickets pushed in the period, and where their time went
  @JsonKey(
    
    name: r'slowest',
    required: true,
    includeIfNull: false,
  )


  final List<SlowTicket> slowest;



      /// Pull requests still open after a week, oldest first
  @JsonKey(
    
    name: r'stale',
    required: true,
    includeIfNull: false,
  )


  final List<StalePR> stale;



      /// Questions waiting for an answer now
  @JsonKey(
    
    name: r'unanswered',
    required: true,
    includeIfNull: false,
  )


  final int unanswered;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AnalyticsDelivery &&
      other.days == days &&
      other.current == current &&
      other.previous == previous &&
      other.perDay == perDay &&
      other.slowest == slowest &&
      other.stale == stale &&
      other.unanswered == unanswered;

    @override
    int get hashCode =>
        days.hashCode +
        current.hashCode +
        previous.hashCode +
        perDay.hashCode +
        slowest.hashCode +
        stale.hashCode +
        unanswered.hashCode;

  factory AnalyticsDelivery.fromJson(Map<String, dynamic> json) => _$AnalyticsDeliveryFromJson(json);

  Map<String, dynamic> toJson() => _$AnalyticsDeliveryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

