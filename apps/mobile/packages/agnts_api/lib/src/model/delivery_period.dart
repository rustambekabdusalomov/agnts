//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/spread.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'delivery_period.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DeliveryPeriod {
  /// Returns a new [DeliveryPeriod] instance.
  DeliveryPeriod({

    required  this.opened,

    required  this.merged,

    required  this.closed,

    required  this.mergeMin,

    required  this.pushed,

    required  this.pushedMin,

    required  this.mergedTickets,

    required  this.mergedMin,

    required  this.questions,

    required  this.askedTickets,

    required  this.analyzedTickets,

    required  this.answerMin,
  });

      /// Pull requests opened in the period
  @JsonKey(
    
    name: r'opened',
    required: true,
    includeIfNull: false,
  )


  final int opened;



      /// Of those, merged so far
  @JsonKey(
    
    name: r'merged',
    required: true,
    includeIfNull: false,
  )


  final int merged;



      /// Of those, closed without a merge so far
  @JsonKey(
    
    name: r'closed',
    required: true,
    includeIfNull: false,
  )


  final int closed;



  @JsonKey(
    
    name: r'mergeMin',
    required: true,
    includeIfNull: false,
  )


  final Spread mergeMin;



      /// Tickets that first reached done in the period
  @JsonKey(
    
    name: r'pushed',
    required: true,
    includeIfNull: false,
  )


  final int pushed;



  @JsonKey(
    
    name: r'pushedMin',
    required: true,
    includeIfNull: false,
  )


  final Spread pushedMin;



      /// Tickets merged in the period
  @JsonKey(
    
    name: r'mergedTickets',
    required: true,
    includeIfNull: false,
  )


  final int mergedTickets;



  @JsonKey(
    
    name: r'mergedMin',
    required: true,
    includeIfNull: false,
  )


  final Spread mergedMin;



  @JsonKey(
    
    name: r'questions',
    required: true,
    includeIfNull: false,
  )


  final int questions;



      /// Tickets that asked the questions
  @JsonKey(
    
    name: r'askedTickets',
    required: true,
    includeIfNull: false,
  )


  final int askedTickets;



      /// Tickets analysed in the period
  @JsonKey(
    
    name: r'analyzedTickets',
    required: true,
    includeIfNull: false,
  )


  final int analyzedTickets;



  @JsonKey(
    
    name: r'answerMin',
    required: true,
    includeIfNull: false,
  )


  final Spread answerMin;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DeliveryPeriod &&
      other.opened == opened &&
      other.merged == merged &&
      other.closed == closed &&
      other.mergeMin == mergeMin &&
      other.pushed == pushed &&
      other.pushedMin == pushedMin &&
      other.mergedTickets == mergedTickets &&
      other.mergedMin == mergedMin &&
      other.questions == questions &&
      other.askedTickets == askedTickets &&
      other.analyzedTickets == analyzedTickets &&
      other.answerMin == answerMin;

    @override
    int get hashCode =>
        opened.hashCode +
        merged.hashCode +
        closed.hashCode +
        mergeMin.hashCode +
        pushed.hashCode +
        pushedMin.hashCode +
        mergedTickets.hashCode +
        mergedMin.hashCode +
        questions.hashCode +
        askedTickets.hashCode +
        analyzedTickets.hashCode +
        answerMin.hashCode;

  factory DeliveryPeriod.fromJson(Map<String, dynamic> json) => _$DeliveryPeriodFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveryPeriodToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

