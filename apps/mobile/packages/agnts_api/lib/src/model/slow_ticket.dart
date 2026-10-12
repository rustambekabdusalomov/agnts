//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'slow_ticket.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SlowTicket {
  /// Returns a new [SlowTicket] instance.
  SlowTicket({

    required  this.key,

    required  this.title,

    required  this.cycleMin,

    required  this.agntsMin,

    required  this.answersMin,

    required  this.reviewMin,

    required  this.queueMin,

    required  this.merged,
  });

  @JsonKey(
    
    name: r'key',
    required: true,
    includeIfNull: false,
  )


  final String key;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



      /// Minutes picked → pushed
  @JsonKey(
    
    name: r'cycleMin',
    required: true,
    includeIfNull: false,
  )


  final num cycleMin;



  @JsonKey(
    
    name: r'agntsMin',
    required: true,
    includeIfNull: false,
  )


  final num agntsMin;



  @JsonKey(
    
    name: r'answersMin',
    required: true,
    includeIfNull: false,
  )


  final num answersMin;



  @JsonKey(
    
    name: r'reviewMin',
    required: true,
    includeIfNull: false,
  )


  final num reviewMin;



      /// The rest: queued, paused or retried
  @JsonKey(
    
    name: r'queueMin',
    required: true,
    includeIfNull: false,
  )


  final num queueMin;



  @JsonKey(
    
    name: r'merged',
    required: true,
    includeIfNull: false,
  )


  final bool merged;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SlowTicket &&
      other.key == key &&
      other.title == title &&
      other.cycleMin == cycleMin &&
      other.agntsMin == agntsMin &&
      other.answersMin == answersMin &&
      other.reviewMin == reviewMin &&
      other.queueMin == queueMin &&
      other.merged == merged;

    @override
    int get hashCode =>
        key.hashCode +
        title.hashCode +
        cycleMin.hashCode +
        agntsMin.hashCode +
        answersMin.hashCode +
        reviewMin.hashCode +
        queueMin.hashCode +
        merged.hashCode;

  factory SlowTicket.fromJson(Map<String, dynamic> json) => _$SlowTicketFromJson(json);

  Map<String, dynamic> toJson() => _$SlowTicketToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

