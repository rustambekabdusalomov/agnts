//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ci_day.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CIDay {
  /// Returns a new [CIDay] instance.
  CIDay({

    required  this.date,

    required  this.new_,

    required  this.fixed,
  });

  @JsonKey(
    
    name: r'date',
    required: true,
    includeIfNull: false,
  )


  final DateTime date;



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





    @override
    bool operator ==(Object other) => identical(this, other) || other is CIDay &&
      other.date == date &&
      other.new_ == new_ &&
      other.fixed == fixed;

    @override
    int get hashCode =>
        date.hashCode +
        new_.hashCode +
        fixed.hashCode;

  factory CIDay.fromJson(Map<String, dynamic> json) => _$CIDayFromJson(json);

  Map<String, dynamic> toJson() => _$CIDayToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

