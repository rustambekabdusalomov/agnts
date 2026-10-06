//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/ticket_spend_row.dart';
import 'package:agnts_api/src/model/token_spend.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ticket_spend_list.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TicketSpendList {
  /// Returns a new [TicketSpendList] instance.
  TicketSpendList({

    required  this.days,

    required  this.total,

    required  this.tickets,
  });

  @JsonKey(
    
    name: r'days',
    required: true,
    includeIfNull: false,
  )


  final int days;



  @JsonKey(
    
    name: r'total',
    required: true,
    includeIfNull: false,
  )


  final TokenSpend total;



      /// Costliest first; partial runs have no cost, so ties fall back to tokens
  @JsonKey(
    
    name: r'tickets',
    required: true,
    includeIfNull: false,
  )


  final List<TicketSpendRow> tickets;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TicketSpendList &&
      other.days == days &&
      other.total == total &&
      other.tickets == tickets;

    @override
    int get hashCode =>
        days.hashCode +
        total.hashCode +
        tickets.hashCode;

  factory TicketSpendList.fromJson(Map<String, dynamic> json) => _$TicketSpendListFromJson(json);

  Map<String, dynamic> toJson() => _$TicketSpendListToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

