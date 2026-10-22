//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/document_grant.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'document_sharing.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DocumentSharing {
  /// Returns a new [DocumentSharing] instance.
  DocumentSharing({

    required  this.type,

     this.publicUrl,

    required  this.workspaceAccess,

    required  this.ownerId,

    required  this.grants,

    required  this.publicAllowed,
  });

  @JsonKey(
    
    name: r'type',
    required: true,
    includeIfNull: false,
  )


  final DocumentSharingTypeEnum type;



  @JsonKey(
    
    name: r'publicUrl',
    required: false,
    includeIfNull: false,
  )


  final String? publicUrl;



  @JsonKey(
    
    name: r'workspaceAccess',
    required: true,
    includeIfNull: false,
  )


  final DocumentSharingWorkspaceAccessEnum workspaceAccess;



  @JsonKey(
    
    name: r'ownerId',
    required: true,
    includeIfNull: false,
  )


  final int ownerId;



  @JsonKey(
    
    name: r'grants',
    required: true,
    includeIfNull: false,
  )


  final List<DocumentGrant> grants;



      /// Whether the workspace allows public documents
  @JsonKey(
    
    name: r'publicAllowed',
    required: true,
    includeIfNull: false,
  )


  final bool publicAllowed;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DocumentSharing &&
      other.type == type &&
      other.publicUrl == publicUrl &&
      other.workspaceAccess == workspaceAccess &&
      other.ownerId == ownerId &&
      other.grants == grants &&
      other.publicAllowed == publicAllowed;

    @override
    int get hashCode =>
        type.hashCode +
        publicUrl.hashCode +
        workspaceAccess.hashCode +
        ownerId.hashCode +
        grants.hashCode +
        publicAllowed.hashCode;

  factory DocumentSharing.fromJson(Map<String, dynamic> json) => _$DocumentSharingFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentSharingToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum DocumentSharingTypeEnum {
@JsonValue(r'private')
private(r'private'),
@JsonValue(r'public')
public(r'public');

const DocumentSharingTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


enum DocumentSharingWorkspaceAccessEnum {
@JsonValue(r'none')
none(r'none'),
@JsonValue(r'view')
view(r'view'),
@JsonValue(r'edit')
edit(r'edit');

const DocumentSharingWorkspaceAccessEnum(this.value);

final String value;

@override
String toString() => value;
}


