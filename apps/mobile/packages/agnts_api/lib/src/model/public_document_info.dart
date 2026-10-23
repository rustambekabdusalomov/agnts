//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/document_kind.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'public_document_info.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PublicDocumentInfo {
  /// Returns a new [PublicDocumentInfo] instance.
  PublicDocumentInfo({

    required  this.kind,

    required  this.title,

     this.googleClientId,
  });

  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final DocumentKind kind;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



      /// Shown when \"Continue with Google\" is on
  @JsonKey(
    
    name: r'googleClientId',
    required: false,
    includeIfNull: false,
  )


  final String? googleClientId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PublicDocumentInfo &&
      other.kind == kind &&
      other.title == title &&
      other.googleClientId == googleClientId;

    @override
    int get hashCode =>
        kind.hashCode +
        title.hashCode +
        googleClientId.hashCode;

  factory PublicDocumentInfo.fromJson(Map<String, dynamic> json) => _$PublicDocumentInfoFromJson(json);

  Map<String, dynamic> toJson() => _$PublicDocumentInfoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

