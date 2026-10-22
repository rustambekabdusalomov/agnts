//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'document_grant.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DocumentGrant {
  /// Returns a new [DocumentGrant] instance.
  DocumentGrant({

    required  this.userId,

     this.username,

    required  this.level,

     this.createdAt,
  });

  @JsonKey(
    
    name: r'userId',
    required: true,
    includeIfNull: false,
  )


  final int userId;



  @JsonKey(
    
    name: r'username',
    required: false,
    includeIfNull: false,
  )


  final String? username;



  @JsonKey(
    
    name: r'level',
    required: true,
    includeIfNull: false,
  )


  final DocumentGrantLevelEnum level;



  @JsonKey(
    
    name: r'createdAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DocumentGrant &&
      other.userId == userId &&
      other.username == username &&
      other.level == level &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        userId.hashCode +
        username.hashCode +
        level.hashCode +
        createdAt.hashCode;

  factory DocumentGrant.fromJson(Map<String, dynamic> json) => _$DocumentGrantFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentGrantToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum DocumentGrantLevelEnum {
@JsonValue(r'view')
view(r'view'),
@JsonValue(r'edit')
edit(r'edit');

const DocumentGrantLevelEnum(this.value);

final String value;

@override
String toString() => value;
}


