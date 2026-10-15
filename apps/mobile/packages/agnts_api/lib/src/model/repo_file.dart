//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'repo_file.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RepoFile {
  /// Returns a new [RepoFile] instance.
  RepoFile({

    required  this.ref,

    required  this.path,

    required  this.size,

     this.content,

    required  this.binary,

    required  this.tooLarge,

    required  this.url,
  });

  @JsonKey(
    
    name: r'ref',
    required: true,
    includeIfNull: false,
  )


  final String ref;



  @JsonKey(
    
    name: r'path',
    required: true,
    includeIfNull: false,
  )


  final String path;



  @JsonKey(
    
    name: r'size',
    required: true,
    includeIfNull: false,
  )


  final int size;



      /// Left out for binary files and files over 1 MB
  @JsonKey(
    
    name: r'content',
    required: false,
    includeIfNull: false,
  )


  final String? content;



  @JsonKey(
    
    name: r'binary',
    required: true,
    includeIfNull: false,
  )


  final bool binary;



  @JsonKey(
    
    name: r'tooLarge',
    required: true,
    includeIfNull: false,
  )


  final bool tooLarge;



      /// The file on the git host
  @JsonKey(
    
    name: r'url',
    required: true,
    includeIfNull: false,
  )


  final String url;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RepoFile &&
      other.ref == ref &&
      other.path == path &&
      other.size == size &&
      other.content == content &&
      other.binary == binary &&
      other.tooLarge == tooLarge &&
      other.url == url;

    @override
    int get hashCode =>
        ref.hashCode +
        path.hashCode +
        size.hashCode +
        content.hashCode +
        binary.hashCode +
        tooLarge.hashCode +
        url.hashCode;

  factory RepoFile.fromJson(Map<String, dynamic> json) => _$RepoFileFromJson(json);

  Map<String, dynamic> toJson() => _$RepoFileToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

