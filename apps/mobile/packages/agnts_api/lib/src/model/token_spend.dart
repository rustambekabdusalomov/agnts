//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'token_spend.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TokenSpend {
  /// Returns a new [TokenSpend] instance.
  TokenSpend({

    required  this.input,

    required  this.output,

    required  this.cacheRead,

    required  this.cacheWrite,

    required  this.total,

    required  this.costUsd,
  });

  @JsonKey(
    
    name: r'input',
    required: true,
    includeIfNull: false,
  )


  final int input;



  @JsonKey(
    
    name: r'output',
    required: true,
    includeIfNull: false,
  )


  final int output;



  @JsonKey(
    
    name: r'cacheRead',
    required: true,
    includeIfNull: false,
  )


  final int cacheRead;



  @JsonKey(
    
    name: r'cacheWrite',
    required: true,
    includeIfNull: false,
  )


  final int cacheWrite;



      /// All four counts added
  @JsonKey(
    
    name: r'total',
    required: true,
    includeIfNull: false,
  )


  final int total;



  @JsonKey(
    
    name: r'costUsd',
    required: true,
    includeIfNull: false,
  )


  final double costUsd;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TokenSpend &&
      other.input == input &&
      other.output == output &&
      other.cacheRead == cacheRead &&
      other.cacheWrite == cacheWrite &&
      other.total == total &&
      other.costUsd == costUsd;

    @override
    int get hashCode =>
        input.hashCode +
        output.hashCode +
        cacheRead.hashCode +
        cacheWrite.hashCode +
        total.hashCode +
        costUsd.hashCode;

  factory TokenSpend.fromJson(Map<String, dynamic> json) => _$TokenSpendFromJson(json);

  Map<String, dynamic> toJson() => _$TokenSpendToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

