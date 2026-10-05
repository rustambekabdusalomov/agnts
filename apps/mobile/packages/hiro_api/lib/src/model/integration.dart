//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'integration.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Integration {
  /// Returns a new [Integration] instance.
  Integration({

    required  this.provider,

    required  this.connected,

     this.checkedAt,

     this.account,

     this.tokenHint,

     this.lastError,

    required  this.settings,

     this.webhookUrl,

     this.webhookSecret,
  });

  @JsonKey(
    
    name: r'provider',
    required: true,
    includeIfNull: false,
  )


  final String provider;



  @JsonKey(
    
    name: r'connected',
    required: true,
    includeIfNull: false,
  )


  final bool connected;



  @JsonKey(
    
    name: r'checkedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? checkedAt;



  @JsonKey(
    
    name: r'account',
    required: false,
    includeIfNull: false,
  )


  final String? account;



      /// Last four characters
  @JsonKey(
    
    name: r'tokenHint',
    required: false,
    includeIfNull: false,
  )


  final String? tokenHint;



  @JsonKey(
    
    name: r'lastError',
    required: false,
    includeIfNull: false,
  )


  final String? lastError;



  @JsonKey(
    
    name: r'settings',
    required: true,
    includeIfNull: false,
  )


  final Map<String, String> settings;



  @JsonKey(
    
    name: r'webhookUrl',
    required: false,
    includeIfNull: false,
  )


  final String? webhookUrl;



      /// GitHub and GitLab: secret to enter in the webhook settings
  @JsonKey(
    
    name: r'webhookSecret',
    required: false,
    includeIfNull: false,
  )


  final String? webhookSecret;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Integration &&
      other.provider == provider &&
      other.connected == connected &&
      other.checkedAt == checkedAt &&
      other.account == account &&
      other.tokenHint == tokenHint &&
      other.lastError == lastError &&
      other.settings == settings &&
      other.webhookUrl == webhookUrl &&
      other.webhookSecret == webhookSecret;

    @override
    int get hashCode =>
        provider.hashCode +
        connected.hashCode +
        checkedAt.hashCode +
        account.hashCode +
        tokenHint.hashCode +
        lastError.hashCode +
        settings.hashCode +
        webhookUrl.hashCode +
        webhookSecret.hashCode;

  factory Integration.fromJson(Map<String, dynamic> json) => _$IntegrationFromJson(json);

  Map<String, dynamic> toJson() => _$IntegrationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

