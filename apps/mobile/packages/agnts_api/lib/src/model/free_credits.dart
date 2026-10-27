//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'free_credits.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FreeCredits {
  /// Returns a new [FreeCredits] instance.
  FreeCredits({

    required  this.limit,

    required  this.used,

    required  this.remaining,

     this.setAt,
  });

  @JsonKey(
    
    name: r'limit',
    required: true,
    includeIfNull: false,
  )


  final int limit;



  @JsonKey(
    
    name: r'used',
    required: true,
    includeIfNull: false,
  )


  final int used;



  @JsonKey(
    
    name: r'remaining',
    required: true,
    includeIfNull: false,
  )


  final int remaining;



  @JsonKey(
    
    name: r'setAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? setAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is FreeCredits &&
      other.limit == limit &&
      other.used == used &&
      other.remaining == remaining &&
      other.setAt == setAt;

    @override
    int get hashCode =>
        limit.hashCode +
        used.hashCode +
        remaining.hashCode +
        setAt.hashCode;

  factory FreeCredits.fromJson(Map<String, dynamic> json) => _$FreeCreditsFromJson(json);

  Map<String, dynamic> toJson() => _$FreeCreditsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

