//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/chat_ai.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_ref.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ChatRef {
  /// Returns a new [ChatRef] instance.
  ChatRef({

    required  this.type,

    required  this.id,

    required  this.source_,

    required  this.confidence,

     this.reason,

     this.label,

     this.url,

     this.ai,
  });

  @JsonKey(
    
    name: r'type',
    required: true,
    includeIfNull: false,
  )


  final ChatRefTypeEnum type;



      /// A ticket key, \"<repo>#<number>\", a repository name or a finding id
  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'source',
    required: true,
    includeIfNull: false,
  )


  final ChatRefSource_Enum source_;



  @JsonKey(
    
    name: r'confidence',
    required: true,
    includeIfNull: false,
  )


  final num confidence;



  @JsonKey(
    
    name: r'reason',
    required: false,
    includeIfNull: false,
  )


  final String? reason;



  @JsonKey(
    
    name: r'label',
    required: false,
    includeIfNull: false,
  )


  final String? label;



  @JsonKey(
    
    name: r'url',
    required: false,
    includeIfNull: false,
  )


  final String? url;



  @JsonKey(
    
    name: r'ai',
    required: false,
    includeIfNull: false,
  )


  final ChatAI? ai;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ChatRef &&
      other.type == type &&
      other.id == id &&
      other.source_ == source_ &&
      other.confidence == confidence &&
      other.reason == reason &&
      other.label == label &&
      other.url == url &&
      other.ai == ai;

    @override
    int get hashCode =>
        type.hashCode +
        id.hashCode +
        source_.hashCode +
        confidence.hashCode +
        reason.hashCode +
        label.hashCode +
        url.hashCode +
        ai.hashCode;

  factory ChatRef.fromJson(Map<String, dynamic> json) => _$ChatRefFromJson(json);

  Map<String, dynamic> toJson() => _$ChatRefToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum ChatRefTypeEnum {
@JsonValue(r'ticket')
ticket(r'ticket'),
@JsonValue(r'pr')
pr(r'pr'),
@JsonValue(r'repo')
repo(r'repo'),
@JsonValue(r'finding')
finding(r'finding');

const ChatRefTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


enum ChatRefSource_Enum {
@JsonValue(r'explicit')
explicit(r'explicit'),
@JsonValue(r'model')
model(r'model'),
@JsonValue(r'card')
card(r'card');

const ChatRefSource_Enum(this.value);

final String value;

@override
String toString() => value;
}


