//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/document_share_input_grants_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'document_share_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DocumentShareInput {
  /// Returns a new [DocumentShareInput] instance.
  DocumentShareInput({

    required  this.type,

    required  this.workspaceAccess,

    required  this.grants,
  });

  @JsonKey(
    
    name: r'type',
    required: true,
    includeIfNull: false,
  )


  final DocumentShareInputTypeEnum type;



  @JsonKey(
    
    name: r'workspaceAccess',
    required: true,
    includeIfNull: false,
  )


  final DocumentShareInputWorkspaceAccessEnum workspaceAccess;



  @JsonKey(
    
    name: r'grants',
    required: true,
    includeIfNull: false,
  )


  final List<DocumentShareInputGrantsInner> grants;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DocumentShareInput &&
      other.type == type &&
      other.workspaceAccess == workspaceAccess &&
      other.grants == grants;

    @override
    int get hashCode =>
        type.hashCode +
        workspaceAccess.hashCode +
        grants.hashCode;

  factory DocumentShareInput.fromJson(Map<String, dynamic> json) => _$DocumentShareInputFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentShareInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum DocumentShareInputTypeEnum {
@JsonValue(r'private')
private(r'private'),
@JsonValue(r'public')
public(r'public');

const DocumentShareInputTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


enum DocumentShareInputWorkspaceAccessEnum {
@JsonValue(r'none')
none(r'none'),
@JsonValue(r'view')
view(r'view'),
@JsonValue(r'edit')
edit(r'edit');

const DocumentShareInputWorkspaceAccessEnum(this.value);

final String value;

@override
String toString() => value;
}


