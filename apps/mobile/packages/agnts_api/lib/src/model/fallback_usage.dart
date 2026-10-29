//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'fallback_usage.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FallbackUsage {
  /// Returns a new [FallbackUsage] instance.
  FallbackUsage({

    required  this.provider,

    required  this.monthLimit,

    required  this.monthUsed,

    required  this.isDefault,

     this.setAt,
  });

      /// e.g. baseten
  @JsonKey(
    
    name: r'provider',
    required: true,
    includeIfNull: false,
  )


  final String provider;



      /// Credits per calendar month (UTC); 0 is no limit
  @JsonKey(
    
    name: r'monthLimit',
    required: true,
    includeIfNull: false,
  )


  final int monthLimit;



  @JsonKey(
    
    name: r'monthUsed',
    required: true,
    includeIfNull: false,
  )


  final int monthUsed;



      /// The server's default limit applies; an Admin has not set one
  @JsonKey(
    
    name: r'isDefault',
    required: true,
    includeIfNull: false,
  )


  final bool isDefault;



  @JsonKey(
    
    name: r'setAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? setAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is FallbackUsage &&
      other.provider == provider &&
      other.monthLimit == monthLimit &&
      other.monthUsed == monthUsed &&
      other.isDefault == isDefault &&
      other.setAt == setAt;

    @override
    int get hashCode =>
        provider.hashCode +
        monthLimit.hashCode +
        monthUsed.hashCode +
        isDefault.hashCode +
        setAt.hashCode;

  factory FallbackUsage.fromJson(Map<String, dynamic> json) => _$FallbackUsageFromJson(json);

  Map<String, dynamic> toJson() => _$FallbackUsageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

