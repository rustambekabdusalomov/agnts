//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'remote_repository.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RemoteRepository {
  /// Returns a new [RemoteRepository] instance.
  RemoteRepository({

    required  this.fullName,

    required  this.cloneUrl,

    required  this.defaultBranch,

    required  this.private,

     this.description,

     this.updatedAt,

    required  this.added,
  });

      /// owner/name, or group/sub/project on GitLab
  @JsonKey(
    
    name: r'fullName',
    required: true,
    includeIfNull: false,
  )


  final String fullName;



  @JsonKey(
    
    name: r'cloneUrl',
    required: true,
    includeIfNull: false,
  )


  final String cloneUrl;



  @JsonKey(
    
    name: r'defaultBranch',
    required: true,
    includeIfNull: false,
  )


  final String defaultBranch;



  @JsonKey(
    
    name: r'private',
    required: true,
    includeIfNull: false,
  )


  final bool private;



  @JsonKey(
    
    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;



  @JsonKey(
    
    name: r'updatedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? updatedAt;



      /// Already added to agnts
  @JsonKey(
    
    name: r'added',
    required: true,
    includeIfNull: false,
  )


  final bool added;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RemoteRepository &&
      other.fullName == fullName &&
      other.cloneUrl == cloneUrl &&
      other.defaultBranch == defaultBranch &&
      other.private == private &&
      other.description == description &&
      other.updatedAt == updatedAt &&
      other.added == added;

    @override
    int get hashCode =>
        fullName.hashCode +
        cloneUrl.hashCode +
        defaultBranch.hashCode +
        private.hashCode +
        description.hashCode +
        updatedAt.hashCode +
        added.hashCode;

  factory RemoteRepository.fromJson(Map<String, dynamic> json) => _$RemoteRepositoryFromJson(json);

  Map<String, dynamic> toJson() => _$RemoteRepositoryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

