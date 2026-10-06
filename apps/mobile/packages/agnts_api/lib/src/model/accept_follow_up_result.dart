//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/ticket.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'accept_follow_up_result.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AcceptFollowUpResult {
  /// Returns a new [AcceptFollowUpResult] instance.
  AcceptFollowUpResult({

    required  this.id,

     this.ticket,

     this.error,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'ticket',
    required: false,
    includeIfNull: false,
  )


  final Ticket? ticket;



      /// Why no ticket was made from this suggestion
  @JsonKey(
    
    name: r'error',
    required: false,
    includeIfNull: false,
  )


  final String? error;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AcceptFollowUpResult &&
      other.id == id &&
      other.ticket == ticket &&
      other.error == error;

    @override
    int get hashCode =>
        id.hashCode +
        ticket.hashCode +
        error.hashCode;

  factory AcceptFollowUpResult.fromJson(Map<String, dynamic> json) => _$AcceptFollowUpResultFromJson(json);

  Map<String, dynamic> toJson() => _$AcceptFollowUpResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

