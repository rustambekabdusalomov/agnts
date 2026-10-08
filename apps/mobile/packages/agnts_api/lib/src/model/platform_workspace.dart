//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'platform_workspace.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PlatformWorkspace {
  /// Returns a new [PlatformWorkspace] instance.
  PlatformWorkspace({

    required  this.id,

    required  this.slug,

    required  this.name,

     this.owner,

    required  this.plan,

    required  this.slots,

    required  this.memberLimit,

    required  this.members,

    required  this.creditsBalance,

    required  this.running,

     this.suspended,

     this.deletedAt,

    required  this.createdAt,
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
    
    name: r'owner',
    required: false,
    includeIfNull: false,
  )


  final String? owner;



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
    
    name: r'memberLimit',
    required: true,
    includeIfNull: false,
  )


  final int memberLimit;



  @JsonKey(
    
    name: r'members',
    required: true,
    includeIfNull: false,
  )


  final int members;



  @JsonKey(
    
    name: r'creditsBalance',
    required: true,
    includeIfNull: false,
  )


  final int creditsBalance;



  @JsonKey(
    
    name: r'running',
    required: true,
    includeIfNull: false,
  )


  final int running;



  @JsonKey(
    
    name: r'suspended',
    required: false,
    includeIfNull: false,
  )


  final bool? suspended;



  @JsonKey(
    
    name: r'deletedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? deletedAt;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PlatformWorkspace &&
      other.id == id &&
      other.slug == slug &&
      other.name == name &&
      other.owner == owner &&
      other.plan == plan &&
      other.slots == slots &&
      other.memberLimit == memberLimit &&
      other.members == members &&
      other.creditsBalance == creditsBalance &&
      other.running == running &&
      other.suspended == suspended &&
      other.deletedAt == deletedAt &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        slug.hashCode +
        name.hashCode +
        owner.hashCode +
        plan.hashCode +
        slots.hashCode +
        memberLimit.hashCode +
        members.hashCode +
        creditsBalance.hashCode +
        running.hashCode +
        suspended.hashCode +
        deletedAt.hashCode +
        createdAt.hashCode;

  factory PlatformWorkspace.fromJson(Map<String, dynamic> json) => _$PlatformWorkspaceFromJson(json);

  Map<String, dynamic> toJson() => _$PlatformWorkspaceToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

