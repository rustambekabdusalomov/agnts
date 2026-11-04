//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_ai.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ChatAI {
  /// Returns a new [ChatAI] instance.
  ChatAI({

    required  this.provider,

    required  this.model,

    required  this.ms,

    required  this.costUsd,
  });

  @JsonKey(
    
    name: r'provider',
    required: true,
    includeIfNull: false,
  )


  final String provider;



  @JsonKey(
    
    name: r'model',
    required: true,
    includeIfNull: false,
  )


  final String model;



  @JsonKey(
    
    name: r'ms',
    required: true,
    includeIfNull: false,
  )


  final int ms;



  @JsonKey(
    
    name: r'costUsd',
    required: true,
    includeIfNull: false,
  )


  final num costUsd;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ChatAI &&
      other.provider == provider &&
      other.model == model &&
      other.ms == ms &&
      other.costUsd == costUsd;

    @override
    int get hashCode =>
        provider.hashCode +
        model.hashCode +
        ms.hashCode +
        costUsd.hashCode;

  factory ChatAI.fromJson(Map<String, dynamic> json) => _$ChatAIFromJson(json);

  Map<String, dynamic> toJson() => _$ChatAIToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

