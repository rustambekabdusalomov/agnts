//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:hiro_api/src/model/ticket_state.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'step_duration.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class StepDuration {
  /// Returns a new [StepDuration] instance.
  StepDuration({

    required  this.state,

     this.avgMs,

    required  this.count,
  });

  @JsonKey(
    
    name: r'state',
    required: true,
    includeIfNull: false,
  )


  final TicketState state;



  @JsonKey(
    
    name: r'avgMs',
    required: false,
    includeIfNull: false,
  )


  final int? avgMs;



  @JsonKey(
    
    name: r'count',
    required: true,
    includeIfNull: false,
  )


  final int count;





    @override
    bool operator ==(Object other) => identical(this, other) || other is StepDuration &&
      other.state == state &&
      other.avgMs == avgMs &&
      other.count == count;

    @override
    int get hashCode =>
        state.hashCode +
        avgMs.hashCode +
        count.hashCode;

  factory StepDuration.fromJson(Map<String, dynamic> json) => _$StepDurationFromJson(json);

  Map<String, dynamic> toJson() => _$StepDurationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

