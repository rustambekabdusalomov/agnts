//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/usage.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'claude_connection_state.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClaudeConnectionState {
  /// Returns a new [ClaudeConnectionState] instance.
  ClaudeConnectionState({

    required  this.connected,

     this.kind,

     this.tokenHint,

     this.account,

     this.lastError,

     this.pausedUntil,

     this.usage,

     this.checkedAt,
  });

  @JsonKey(
    
    name: r'connected',
    required: true,
    includeIfNull: false,
  )


  final bool connected;



  @JsonKey(
    
    name: r'kind',
    required: false,
    includeIfNull: false,
  )


  final ClaudeConnectionStateKindEnum? kind;



      /// The token's last four characters
  @JsonKey(
    
    name: r'tokenHint',
    required: false,
    includeIfNull: false,
  )


  final String? tokenHint;



  @JsonKey(
    
    name: r'account',
    required: false,
    includeIfNull: false,
  )


  final String? account;



  @JsonKey(
    
    name: r'lastError',
    required: false,
    includeIfNull: false,
  )


  final String? lastError;



      /// At its usage limit until then
  @JsonKey(
    
    name: r'pausedUntil',
    required: false,
    includeIfNull: false,
  )


  final DateTime? pausedUntil;



  @JsonKey(
    
    name: r'usage',
    required: false,
    includeIfNull: false,
  )


  final Usage? usage;



  @JsonKey(
    
    name: r'checkedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? checkedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ClaudeConnectionState &&
      other.connected == connected &&
      other.kind == kind &&
      other.tokenHint == tokenHint &&
      other.account == account &&
      other.lastError == lastError &&
      other.pausedUntil == pausedUntil &&
      other.usage == usage &&
      other.checkedAt == checkedAt;

    @override
    int get hashCode =>
        connected.hashCode +
        kind.hashCode +
        tokenHint.hashCode +
        account.hashCode +
        lastError.hashCode +
        pausedUntil.hashCode +
        usage.hashCode +
        checkedAt.hashCode;

  factory ClaudeConnectionState.fromJson(Map<String, dynamic> json) => _$ClaudeConnectionStateFromJson(json);

  Map<String, dynamic> toJson() => _$ClaudeConnectionStateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum ClaudeConnectionStateKindEnum {
@JsonValue(r'subscription')
subscription(r'subscription'),
@JsonValue(r'api_key')
apiKey(r'api_key');

const ClaudeConnectionStateKindEnum(this.value);

final String value;

@override
String toString() => value;
}


