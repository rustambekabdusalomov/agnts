//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attached_file.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AttachedFile {
  /// Returns a new [AttachedFile] instance.
  AttachedFile({

    required  this.id,

    required  this.name,

    required  this.contentType,

    required  this.size,

    required  this.image,

    required  this.url,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'contentType',
    required: true,
    includeIfNull: false,
  )


  final String contentType;



      /// Bytes
  @JsonKey(
    
    name: r'size',
    required: true,
    includeIfNull: false,
  )


  final int size;



      /// A picture clients can show in place
  @JsonKey(
    
    name: r'image',
    required: true,
    includeIfNull: false,
  )


  final bool image;



      /// Where to load the file, relative to the API base
  @JsonKey(
    
    name: r'url',
    required: true,
    includeIfNull: false,
  )


  final String url;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AttachedFile &&
      other.id == id &&
      other.name == name &&
      other.contentType == contentType &&
      other.size == size &&
      other.image == image &&
      other.url == url;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        contentType.hashCode +
        size.hashCode +
        image.hashCode +
        url.hashCode;

  factory AttachedFile.fromJson(Map<String, dynamic> json) => _$AttachedFileFromJson(json);

  Map<String, dynamic> toJson() => _$AttachedFileToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

