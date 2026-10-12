//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'spread.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Spread {
  /// Returns a new [Spread] instance.
  Spread({

     this.p50,

     this.p90,
  });

  @JsonKey(
    
    name: r'p50',
    required: false,
    includeIfNull: false,
  )


  final num? p50;



  @JsonKey(
    
    name: r'p90',
    required: false,
    includeIfNull: false,
  )


  final num? p90;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Spread &&
      other.p50 == p50 &&
      other.p90 == p90;

    @override
    int get hashCode =>
        p50.hashCode +
        p90.hashCode;

  factory Spread.fromJson(Map<String, dynamic> json) => _$SpreadFromJson(json);

  Map<String, dynamic> toJson() => _$SpreadToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

