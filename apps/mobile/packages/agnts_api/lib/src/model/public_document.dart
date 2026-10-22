//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'public_document.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PublicDocument {
  /// Returns a new [PublicDocument] instance.
  PublicDocument({

    required  this.title,

    required  this.body,

    required  this.version,

    required  this.updatedAt,
  });

  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



      /// Markdown
  @JsonKey(
    
    name: r'body',
    required: true,
    includeIfNull: false,
  )


  final String body;



  @JsonKey(
    
    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final int version;



  @JsonKey(
    
    name: r'updatedAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime updatedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PublicDocument &&
      other.title == title &&
      other.body == body &&
      other.version == version &&
      other.updatedAt == updatedAt;

    @override
    int get hashCode =>
        title.hashCode +
        body.hashCode +
        version.hashCode +
        updatedAt.hashCode;

  factory PublicDocument.fromJson(Map<String, dynamic> json) => _$PublicDocumentFromJson(json);

  Map<String, dynamic> toJson() => _$PublicDocumentToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

