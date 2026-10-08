//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'claude_connection_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClaudeConnectionInput {
  /// Returns a new [ClaudeConnectionInput] instance.
  ClaudeConnectionInput({

    required  this.kind,

    required  this.token,
  });

      /// subscription: a token from `claude setup-token`; api_key: an Anthropic API key
  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final ClaudeConnectionInputKindEnum kind;



  @JsonKey(
    
    name: r'token',
    required: true,
    includeIfNull: false,
  )


  final String token;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ClaudeConnectionInput &&
      other.kind == kind &&
      other.token == token;

    @override
    int get hashCode =>
        kind.hashCode +
        token.hashCode;

  factory ClaudeConnectionInput.fromJson(Map<String, dynamic> json) => _$ClaudeConnectionInputFromJson(json);

  Map<String, dynamic> toJson() => _$ClaudeConnectionInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// subscription: a token from `claude setup-token`; api_key: an Anthropic API key
enum ClaudeConnectionInputKindEnum {
@JsonValue(r'subscription')
subscription(r'subscription'),
@JsonValue(r'api_key')
apiKey(r'api_key');

const ClaudeConnectionInputKindEnum(this.value);

final String value;

@override
String toString() => value;
}


