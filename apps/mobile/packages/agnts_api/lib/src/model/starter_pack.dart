//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'starter_pack.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class StarterPack {
  /// Returns a new [StarterPack] instance.
  StarterPack({

    required  this.pack,

    required  this.name,

    required  this.rules,

    required  this.offered,
  });

  @JsonKey(
    
    name: r'pack',
    required: true,
    includeIfNull: false,
  )


  final String pack;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'rules',
    required: true,
    includeIfNull: false,
  )


  final int rules;



      /// Its rules are already among the repository's rules or suggestions
  @JsonKey(
    
    name: r'offered',
    required: true,
    includeIfNull: false,
  )


  final bool offered;





    @override
    bool operator ==(Object other) => identical(this, other) || other is StarterPack &&
      other.pack == pack &&
      other.name == name &&
      other.rules == rules &&
      other.offered == offered;

    @override
    int get hashCode =>
        pack.hashCode +
        name.hashCode +
        rules.hashCode +
        offered.hashCode;

  factory StarterPack.fromJson(Map<String, dynamic> json) => _$StarterPackFromJson(json);

  Map<String, dynamic> toJson() => _$StarterPackToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

