//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_stats.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ChatStats {
  /// Returns a new [ChatStats] instance.
  ChatStats({

    required  this.links,

    required  this.answers,

    required  this.drafts,

    required  this.medianMs,
  });

  @JsonKey(
    
    name: r'links',
    required: true,
    includeIfNull: false,
  )


  final int links;



  @JsonKey(
    
    name: r'answers',
    required: true,
    includeIfNull: false,
  )


  final int answers;



  @JsonKey(
    
    name: r'drafts',
    required: true,
    includeIfNull: false,
  )


  final int drafts;



  @JsonKey(
    
    name: r'medianMs',
    required: true,
    includeIfNull: false,
  )


  final int medianMs;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ChatStats &&
      other.links == links &&
      other.answers == answers &&
      other.drafts == drafts &&
      other.medianMs == medianMs;

    @override
    int get hashCode =>
        links.hashCode +
        answers.hashCode +
        drafts.hashCode +
        medianMs.hashCode;

  factory ChatStats.fromJson(Map<String, dynamic> json) => _$ChatStatsFromJson(json);

  Map<String, dynamic> toJson() => _$ChatStatsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

