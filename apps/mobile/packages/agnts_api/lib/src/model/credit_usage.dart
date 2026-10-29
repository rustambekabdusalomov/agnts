//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/fallback_usage.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'credit_usage.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreditUsage {
  /// Returns a new [CreditUsage] instance.
  CreditUsage({

    required  this.monthLimit,

    required  this.monthUsed,

    required  this.totalUsed,

     this.setAt,

     this.fallback,
  });

      /// Credits per calendar month (UTC); 0 is no limit
  @JsonKey(
    
    name: r'monthLimit',
    required: true,
    includeIfNull: false,
  )


  final int monthLimit;



      /// Credits spent this calendar month
  @JsonKey(
    
    name: r'monthUsed',
    required: true,
    includeIfNull: false,
  )


  final int monthUsed;



      /// Credits spent ever
  @JsonKey(
    
    name: r'totalUsed',
    required: true,
    includeIfNull: false,
  )


  final int totalUsed;



  @JsonKey(
    
    name: r'setAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? setAt;



  @JsonKey(
    
    name: r'fallback',
    required: false,
    includeIfNull: false,
  )


  final FallbackUsage? fallback;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreditUsage &&
      other.monthLimit == monthLimit &&
      other.monthUsed == monthUsed &&
      other.totalUsed == totalUsed &&
      other.setAt == setAt &&
      other.fallback == fallback;

    @override
    int get hashCode =>
        monthLimit.hashCode +
        monthUsed.hashCode +
        totalUsed.hashCode +
        setAt.hashCode +
        fallback.hashCode;

  factory CreditUsage.fromJson(Map<String, dynamic> json) => _$CreditUsageFromJson(json);

  Map<String, dynamic> toJson() => _$CreditUsageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

