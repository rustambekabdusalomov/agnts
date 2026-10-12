//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stale_pr.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class StalePR {
  /// Returns a new [StalePR] instance.
  StalePR({

    required  this.key,

    required  this.title,

    required  this.repo,

    required  this.url,

    required  this.openedAt,
  });

  @JsonKey(
    
    name: r'key',
    required: true,
    includeIfNull: false,
  )


  final String key;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(
    
    name: r'repo',
    required: true,
    includeIfNull: false,
  )


  final String repo;



  @JsonKey(
    
    name: r'url',
    required: true,
    includeIfNull: false,
  )


  final String url;



  @JsonKey(
    
    name: r'openedAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime openedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is StalePR &&
      other.key == key &&
      other.title == title &&
      other.repo == repo &&
      other.url == url &&
      other.openedAt == openedAt;

    @override
    int get hashCode =>
        key.hashCode +
        title.hashCode +
        repo.hashCode +
        url.hashCode +
        openedAt.hashCode;

  factory StalePR.fromJson(Map<String, dynamic> json) => _$StalePRFromJson(json);

  Map<String, dynamic> toJson() => _$StalePRToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

