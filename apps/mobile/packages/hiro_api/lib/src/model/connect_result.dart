//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:hiro_api/src/model/integration.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'connect_result.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ConnectResult {
  /// Returns a new [ConnectResult] instance.
  ConnectResult({

    required  this.integration,

     this.webhookSecret,
  });

  @JsonKey(
    
    name: r'integration',
    required: true,
    includeIfNull: false,
  )


  final Integration integration;



      /// Shown once; paste it into the provider's webhook settings
  @JsonKey(
    
    name: r'webhookSecret',
    required: false,
    includeIfNull: false,
  )


  final String? webhookSecret;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ConnectResult &&
      other.integration == integration &&
      other.webhookSecret == webhookSecret;

    @override
    int get hashCode =>
        integration.hashCode +
        webhookSecret.hashCode;

  factory ConnectResult.fromJson(Map<String, dynamic> json) => _$ConnectResultFromJson(json);

  Map<String, dynamic> toJson() => _$ConnectResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

