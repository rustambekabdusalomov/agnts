//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_audit_entry.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminAuditEntry {
  /// Returns a new [AdminAuditEntry] instance.
  AdminAuditEntry({

    required  this.id,

     this.adminId,

    required  this.adminName,

    required  this.action,

    required  this.target,

     this.workspaceId,

     this.workspace,

     this.ip,

    required  this.createdAt,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



      /// Absent once the Admin account is deleted
  @JsonKey(
    
    name: r'adminId',
    required: false,
    includeIfNull: false,
  )


  final int? adminId;



  @JsonKey(
    
    name: r'adminName',
    required: true,
    includeIfNull: false,
  )


  final String adminName;



      /// transcript.view, transcript.prompt, transcript.download, run_history.settings
  @JsonKey(
    
    name: r'action',
    required: true,
    includeIfNull: false,
  )


  final String action;



  @JsonKey(
    
    name: r'target',
    required: true,
    includeIfNull: false,
  )


  final String target;



  @JsonKey(
    
    name: r'workspaceId',
    required: false,
    includeIfNull: false,
  )


  final int? workspaceId;



  @JsonKey(
    
    name: r'workspace',
    required: false,
    includeIfNull: false,
  )


  final String? workspace;



  @JsonKey(
    
    name: r'ip',
    required: false,
    includeIfNull: false,
  )


  final String? ip;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AdminAuditEntry &&
      other.id == id &&
      other.adminId == adminId &&
      other.adminName == adminName &&
      other.action == action &&
      other.target == target &&
      other.workspaceId == workspaceId &&
      other.workspace == workspace &&
      other.ip == ip &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        adminId.hashCode +
        adminName.hashCode +
        action.hashCode +
        target.hashCode +
        workspaceId.hashCode +
        workspace.hashCode +
        ip.hashCode +
        createdAt.hashCode;

  factory AdminAuditEntry.fromJson(Map<String, dynamic> json) => _$AdminAuditEntryFromJson(json);

  Map<String, dynamic> toJson() => _$AdminAuditEntryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

