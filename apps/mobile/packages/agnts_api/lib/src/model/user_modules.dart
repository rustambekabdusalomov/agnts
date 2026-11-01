//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/module.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_modules.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UserModules {
  /// Returns a new [UserModules] instance.
  UserModules({

     this.own,

    required  this.effective,

     this.order,

     this.setAt,
  });

      /// The list an Admin set; absent or null follows the default
  @JsonKey(
    
    name: r'own',
    required: false,
    includeIfNull: false,
  )


  final List<Module>? own;



      /// What the person may use now, in their order, the default module first
  @JsonKey(
    
    name: r'effective',
    required: true,
    includeIfNull: false,
  )


  final List<Module> effective;



      /// The order the person put their modules in themselves; absent or null keeps the Admin's
  @JsonKey(
    
    name: r'order',
    required: false,
    includeIfNull: false,
  )


  final List<Module>? order;



  @JsonKey(
    
    name: r'setAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? setAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UserModules &&
      other.own == own &&
      other.effective == effective &&
      other.order == order &&
      other.setAt == setAt;

    @override
    int get hashCode =>
        (own == null ? 0 : own.hashCode) +
        effective.hashCode +
        (order == null ? 0 : order.hashCode) +
        setAt.hashCode;

  factory UserModules.fromJson(Map<String, dynamic> json) => _$UserModulesFromJson(json);

  Map<String, dynamic> toJson() => _$UserModulesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

