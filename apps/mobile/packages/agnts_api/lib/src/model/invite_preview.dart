//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'invite_preview.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class InvitePreview {
  /// Returns a new [InvitePreview] instance.
  InvitePreview({

    required  this.workspace,

     this.invitedBy,

     this.email,

    required  this.expiresAt,
  });

      /// The workspace's name
  @JsonKey(
    
    name: r'workspace',
    required: true,
    includeIfNull: false,
  )


  final String workspace;



  @JsonKey(
    
    name: r'invitedBy',
    required: false,
    includeIfNull: false,
  )


  final String? invitedBy;



  @JsonKey(
    
    name: r'email',
    required: false,
    includeIfNull: false,
  )


  final String? email;



  @JsonKey(
    
    name: r'expiresAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime expiresAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is InvitePreview &&
      other.workspace == workspace &&
      other.invitedBy == invitedBy &&
      other.email == email &&
      other.expiresAt == expiresAt;

    @override
    int get hashCode =>
        workspace.hashCode +
        invitedBy.hashCode +
        email.hashCode +
        expiresAt.hashCode;

  factory InvitePreview.fromJson(Map<String, dynamic> json) => _$InvitePreviewFromJson(json);

  Map<String, dynamic> toJson() => _$InvitePreviewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

