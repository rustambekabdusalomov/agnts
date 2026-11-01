//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/log_mode.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'log_override.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LogOverride {
  /// Returns a new [LogOverride] instance.
  LogOverride({

     this.repoId,

     this.service,

     this.errors,

     this.security,
  });

  @JsonKey(
    
    name: r'repoId',
    required: false,
    includeIfNull: false,
  )


  final int? repoId;



      /// <source name>/<service name>
  @JsonKey(
    
    name: r'service',
    required: false,
    includeIfNull: false,
  )


  final String? service;



  @JsonKey(
    
    name: r'errors',
    required: false,
    includeIfNull: false,
  )


  final LogMode? errors;



  @JsonKey(
    
    name: r'security',
    required: false,
    includeIfNull: false,
  )


  final LogMode? security;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LogOverride &&
      other.repoId == repoId &&
      other.service == service &&
      other.errors == errors &&
      other.security == security;

    @override
    int get hashCode =>
        repoId.hashCode +
        service.hashCode +
        errors.hashCode +
        security.hashCode;

  factory LogOverride.fromJson(Map<String, dynamic> json) => _$LogOverrideFromJson(json);

  Map<String, dynamic> toJson() => _$LogOverrideToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

