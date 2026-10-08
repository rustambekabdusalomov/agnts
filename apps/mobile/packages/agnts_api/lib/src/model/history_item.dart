//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/ticket_state.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'history_item.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HistoryItem {
  /// Returns a new [HistoryItem] instance.
  HistoryItem({

    required  this.at,

    required  this.state,

    required  this.message,

    required  this.origin,

     this.user,
  });

  @JsonKey(
    
    name: r'at',
    required: true,
    includeIfNull: false,
  )


  final DateTime at;



  @JsonKey(
    
    name: r'state',
    required: true,
    includeIfNull: false,
  )


  final TicketState state;



  @JsonKey(
    
    name: r'message',
    required: true,
    includeIfNull: false,
  )


  final String message;



  @JsonKey(
    
    name: r'origin',
    required: true,
    includeIfNull: false,
  )


  final String origin;



      /// The person behind it; absent for agnts
  @JsonKey(
    
    name: r'user',
    required: false,
    includeIfNull: false,
  )


  final String? user;





    @override
    bool operator ==(Object other) => identical(this, other) || other is HistoryItem &&
      other.at == at &&
      other.state == state &&
      other.message == message &&
      other.origin == origin &&
      other.user == user;

    @override
    int get hashCode =>
        at.hashCode +
        state.hashCode +
        message.hashCode +
        origin.hashCode +
        user.hashCode;

  factory HistoryItem.fromJson(Map<String, dynamic> json) => _$HistoryItemFromJson(json);

  Map<String, dynamic> toJson() => _$HistoryItemToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

