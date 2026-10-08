//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/workspace_role.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workspace_summary.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WorkspaceSummary {
  /// Returns a new [WorkspaceSummary] instance.
  WorkspaceSummary({

    required  this.id,

    required  this.slug,

    required  this.name,

    required  this.role,

    required  this.members,

    required  this.plan,

    required  this.slots,

     this.suspended,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'slug',
    required: true,
    includeIfNull: false,
  )


  final String slug;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'role',
    required: true,
    includeIfNull: false,
  )


  final WorkspaceRole role;



  @JsonKey(
    
    name: r'members',
    required: true,
    includeIfNull: false,
  )


  final int members;



  @JsonKey(
    
    name: r'plan',
    required: true,
    includeIfNull: false,
  )


  final String plan;



  @JsonKey(
    
    name: r'slots',
    required: true,
    includeIfNull: false,
  )


  final int slots;



  @JsonKey(
    
    name: r'suspended',
    required: false,
    includeIfNull: false,
  )


  final bool? suspended;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WorkspaceSummary &&
      other.id == id &&
      other.slug == slug &&
      other.name == name &&
      other.role == role &&
      other.members == members &&
      other.plan == plan &&
      other.slots == slots &&
      other.suspended == suspended;

    @override
    int get hashCode =>
        id.hashCode +
        slug.hashCode +
        name.hashCode +
        role.hashCode +
        members.hashCode +
        plan.hashCode +
        slots.hashCode +
        suspended.hashCode;

  factory WorkspaceSummary.fromJson(Map<String, dynamic> json) => _$WorkspaceSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$WorkspaceSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

