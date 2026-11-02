//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'log_service.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LogService {
  /// Returns a new [LogService] instance.
  LogService({

     this.id,

    required  this.name,

    required  this.selector,

    required  this.repoIds,

     this.groupId,

    required  this.enabled,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final int? id;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



      /// Loki: a matcher like {app=\"api\"}; Elasticsearch: the service field's value; Graylog: a stream id
  @JsonKey(
    
    name: r'selector',
    required: true,
    includeIfNull: false,
  )


  final String selector;



      /// The repositories the service runs on; none means its findings are only reported
  @JsonKey(
    
    name: r'repoIds',
    required: true,
    includeIfNull: false,
  )


  final List<int> repoIds;



  @JsonKey(
    
    name: r'groupId',
    required: false,
    includeIfNull: false,
  )


  final int? groupId;



  @JsonKey(
    
    name: r'enabled',
    required: true,
    includeIfNull: false,
  )


  final bool enabled;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LogService &&
      other.id == id &&
      other.name == name &&
      other.selector == selector &&
      other.repoIds == repoIds &&
      other.groupId == groupId &&
      other.enabled == enabled;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        selector.hashCode +
        repoIds.hashCode +
        (groupId == null ? 0 : groupId.hashCode) +
        enabled.hashCode;

  factory LogService.fromJson(Map<String, dynamic> json) => _$LogServiceFromJson(json);

  Map<String, dynamic> toJson() => _$LogServiceToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

