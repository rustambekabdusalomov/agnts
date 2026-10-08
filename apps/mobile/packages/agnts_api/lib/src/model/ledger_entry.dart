//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ledger_entry.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LedgerEntry {
  /// Returns a new [LedgerEntry] instance.
  LedgerEntry({

    required  this.id,

    required  this.amount,

    required  this.reason,

     this.ticketKey,

     this.note,

    required  this.createdAt,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



      /// Credits; negative for spend
  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final int amount;



  @JsonKey(
    
    name: r'reason',
    required: true,
    includeIfNull: false,
  )


  final LedgerEntryReasonEnum reason;



  @JsonKey(
    
    name: r'ticketKey',
    required: false,
    includeIfNull: false,
  )


  final String? ticketKey;



  @JsonKey(
    
    name: r'note',
    required: false,
    includeIfNull: false,
  )


  final String? note;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LedgerEntry &&
      other.id == id &&
      other.amount == amount &&
      other.reason == reason &&
      other.ticketKey == ticketKey &&
      other.note == note &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        amount.hashCode +
        reason.hashCode +
        ticketKey.hashCode +
        note.hashCode +
        createdAt.hashCode;

  factory LedgerEntry.fromJson(Map<String, dynamic> json) => _$LedgerEntryFromJson(json);

  Map<String, dynamic> toJson() => _$LedgerEntryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum LedgerEntryReasonEnum {
@JsonValue(r'purchase')
purchase(r'purchase'),
@JsonValue(r'run')
run(r'run'),
@JsonValue(r'refund')
refund(r'refund'),
@JsonValue(r'grant')
grant(r'grant');

const LedgerEntryReasonEnum(this.value);

final String value;

@override
String toString() => value;
}


