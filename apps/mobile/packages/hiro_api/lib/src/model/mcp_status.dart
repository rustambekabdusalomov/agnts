//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mcp_status.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class McpStatus {
  /// Returns a new [McpStatus] instance.
  McpStatus({

    required  this.url,

    required  this.staticToken,

    required  this.connections,
  });

      /// The connector URL to add in Claude
  @JsonKey(
    
    name: r'url',
    required: true,
    includeIfNull: false,
  )


  final String url;



  @JsonKey(
    
    name: r'staticToken',
    required: true,
    includeIfNull: false,
  )


  final bool staticToken;



      /// Claude connections authorised with OAuth
  @JsonKey(
    
    name: r'connections',
    required: true,
    includeIfNull: false,
  )


  final int connections;





    @override
    bool operator ==(Object other) => identical(this, other) || other is McpStatus &&
      other.url == url &&
      other.staticToken == staticToken &&
      other.connections == connections;

    @override
    int get hashCode =>
        url.hashCode +
        staticToken.hashCode +
        connections.hashCode;

  factory McpStatus.fromJson(Map<String, dynamic> json) => _$McpStatusFromJson(json);

  Map<String, dynamic> toJson() => _$McpStatusToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

