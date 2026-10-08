//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/workspace_role.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workspace_detail.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WorkspaceDetail {
  /// Returns a new [WorkspaceDetail] instance.
  WorkspaceDetail({

    required  this.id,

    required  this.slug,

    required  this.name,

    required  this.role,

    required  this.ownerId,

    required  this.plan,

    required  this.slots,

    required  this.memberLimit,

    required  this.members,

    required  this.claudeMode,

    required  this.claudeFallback,

     this.defaultMemberId,

    required  this.creditsBalance,

     this.trialEndsAt,

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
    
    name: r'role',
    required: true,
    includeIfNull: false,
  )


  final WorkspaceRole role;



  @JsonKey(
    
    name: r'ownerId',
    required: true,
    includeIfNull: false,
  )


  final int ownerId;



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



      /// 0 means no limit
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
    
    name: r'claudeMode',
    required: true,
    includeIfNull: false,
  )


  final WorkspaceDetailClaudeModeEnum claudeMode;



  @JsonKey(
    
    name: r'claudeFallback',
    required: true,
    includeIfNull: false,
  )


  final bool claudeFallback;



  @JsonKey(
    
    name: r'defaultMemberId',
    required: false,
    includeIfNull: false,
  )


  final int? defaultMemberId;



  @JsonKey(
    
    name: r'creditsBalance',
    required: true,
    includeIfNull: false,
  )


  final int creditsBalance;



  @JsonKey(
    
    name: r'trialEndsAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? trialEndsAt;



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
    bool operator ==(Object other) => identical(this, other) || other is WorkspaceDetail &&
      other.id == id &&
      other.slug == slug &&
      other.name == name &&
      other.role == role &&
      other.ownerId == ownerId &&
      other.plan == plan &&
      other.slots == slots &&
      other.memberLimit == memberLimit &&
      other.members == members &&
      other.claudeMode == claudeMode &&
      other.claudeFallback == claudeFallback &&
      other.defaultMemberId == defaultMemberId &&
      other.creditsBalance == creditsBalance &&
      other.trialEndsAt == trialEndsAt &&
      other.suspended == suspended &&
      other.deletedAt == deletedAt &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        slug.hashCode +
        name.hashCode +
        role.hashCode +
        ownerId.hashCode +
        plan.hashCode +
        slots.hashCode +
        memberLimit.hashCode +
        members.hashCode +
        claudeMode.hashCode +
        claudeFallback.hashCode +
        defaultMemberId.hashCode +
        creditsBalance.hashCode +
        trialEndsAt.hashCode +
        suspended.hashCode +
        deletedAt.hashCode +
        createdAt.hashCode;

  factory WorkspaceDetail.fromJson(Map<String, dynamic> json) => _$WorkspaceDetailFromJson(json);

  Map<String, dynamic> toJson() => _$WorkspaceDetailToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum WorkspaceDetailClaudeModeEnum {
@JsonValue(r'shared')
shared(r'shared'),
@JsonValue(r'member')
member(r'member');

const WorkspaceDetailClaudeModeEnum(this.value);

final String value;

@override
String toString() => value;
}


