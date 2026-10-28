//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'code_handoff.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CodeHandoff {
  /// Returns a new [CodeHandoff] instance.
  CodeHandoff({

    required  this.request,

    required  this.repoIds,

    required  this.repos,
  });

  @JsonKey(
    
    name: r'request',
    required: true,
    includeIfNull: false,
  )


  final String request;



  @JsonKey(
    
    name: r'repoIds',
    required: true,
    includeIfNull: false,
  )


  final List<int> repoIds;



  @JsonKey(
    
    name: r'repos',
    required: true,
    includeIfNull: false,
  )


  final List<String> repos;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CodeHandoff &&
      other.request == request &&
      other.repoIds == repoIds &&
      other.repos == repos;

    @override
    int get hashCode =>
        request.hashCode +
        repoIds.hashCode +
        repos.hashCode;

  factory CodeHandoff.fromJson(Map<String, dynamic> json) => _$CodeHandoffFromJson(json);

  Map<String, dynamic> toJson() => _$CodeHandoffToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

