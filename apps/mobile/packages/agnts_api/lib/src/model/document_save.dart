//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'document_save.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DocumentSave {
  /// Returns a new [DocumentSave] instance.
  DocumentSave({

    required  this.title,

    required  this.body,

    required  this.baseVersion,
  });

  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(
    
    name: r'body',
    required: true,
    includeIfNull: false,
  )


  final String body;



      /// The version the edit started from
          // minimum: 0
  @JsonKey(
    
    name: r'baseVersion',
    required: true,
    includeIfNull: false,
  )


  final int baseVersion;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DocumentSave &&
      other.title == title &&
      other.body == body &&
      other.baseVersion == baseVersion;

    @override
    int get hashCode =>
        title.hashCode +
        body.hashCode +
        baseVersion.hashCode;

  factory DocumentSave.fromJson(Map<String, dynamic> json) => _$DocumentSaveFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentSaveToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

