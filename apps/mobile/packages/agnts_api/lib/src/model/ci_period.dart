//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/spread.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ci_period.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CIPeriod {
  /// Returns a new [CIPeriod] instance.
  CIPeriod({

    required  this.seen,

    required  this.new_,

    required  this.fixed,

    required  this.autoFixed,

    required  this.flaky,

    required  this.fixMin,

    required  this.ownFixes,
  });

      /// Failure groups that failed in the period
  @JsonKey(
    
    name: r'seen',
    required: true,
    includeIfNull: false,
  )


  final int seen;



      /// First seen in the period
  @JsonKey(
    
    name: r'new',
    required: true,
    includeIfNull: false,
  )


  final int new_;



  @JsonKey(
    
    name: r'fixed',
    required: true,
    includeIfNull: false,
  )


  final int fixed;



      /// Fixed by an agnts ticket
  @JsonKey(
    
    name: r'autoFixed',
    required: true,
    includeIfNull: false,
  )


  final int autoFixed;



  @JsonKey(
    
    name: r'flaky',
    required: true,
    includeIfNull: false,
  )


  final int flaky;



  @JsonKey(
    
    name: r'fixMin',
    required: true,
    includeIfNull: false,
  )


  final Spread fixMin;



      /// Times red CI sent agnts's own pull request back to coding
  @JsonKey(
    
    name: r'ownFixes',
    required: true,
    includeIfNull: false,
  )


  final int ownFixes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CIPeriod &&
      other.seen == seen &&
      other.new_ == new_ &&
      other.fixed == fixed &&
      other.autoFixed == autoFixed &&
      other.flaky == flaky &&
      other.fixMin == fixMin &&
      other.ownFixes == ownFixes;

    @override
    int get hashCode =>
        seen.hashCode +
        new_.hashCode +
        fixed.hashCode +
        autoFixed.hashCode +
        flaky.hashCode +
        fixMin.hashCode +
        ownFixes.hashCode;

  factory CIPeriod.fromJson(Map<String, dynamic> json) => _$CIPeriodFromJson(json);

  Map<String, dynamic> toJson() => _$CIPeriodToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

