//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'capacity.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Capacity {
  /// Returns a new [Capacity] instance.
  Capacity({

    required  this.budgetMb,

    required  this.reservedMb,

    required  this.runs,

     this.diskFreeMb,

    required  this.full,
  });

      /// Memory the server lends to runs; 0 when it is not limited
  @JsonKey(
    
    name: r'budgetMb',
    required: true,
    includeIfNull: false,
  )


  final int budgetMb;



  @JsonKey(
    
    name: r'reservedMb',
    required: true,
    includeIfNull: false,
  )


  final int reservedMb;



  @JsonKey(
    
    name: r'runs',
    required: true,
    includeIfNull: false,
  )


  final int runs;



  @JsonKey(
    
    name: r'diskFreeMb',
    required: false,
    includeIfNull: false,
  )


  final int? diskFreeMb;



  @JsonKey(
    
    name: r'full',
    required: true,
    includeIfNull: false,
  )


  final bool full;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Capacity &&
      other.budgetMb == budgetMb &&
      other.reservedMb == reservedMb &&
      other.runs == runs &&
      other.diskFreeMb == diskFreeMb &&
      other.full == full;

    @override
    int get hashCode =>
        budgetMb.hashCode +
        reservedMb.hashCode +
        runs.hashCode +
        diskFreeMb.hashCode +
        full.hashCode;

  factory Capacity.fromJson(Map<String, dynamic> json) => _$CapacityFromJson(json);

  Map<String, dynamic> toJson() => _$CapacityToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

