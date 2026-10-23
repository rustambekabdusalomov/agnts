//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'guest_join.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GuestJoin {
  /// Returns a new [GuestJoin] instance.
  GuestJoin({

     this.name,

     this.googleCredential,
  });

  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'googleCredential',
    required: false,
    includeIfNull: false,
  )


  final String? googleCredential;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GuestJoin &&
      other.name == name &&
      other.googleCredential == googleCredential;

    @override
    int get hashCode =>
        name.hashCode +
        googleCredential.hashCode;

  factory GuestJoin.fromJson(Map<String, dynamic> json) => _$GuestJoinFromJson(json);

  Map<String, dynamic> toJson() => _$GuestJoinToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

