//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'run_history_settings.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RunHistorySettings {
  /// Returns a new [RunHistorySettings] instance.
  RunHistorySettings({

    required  this.retentionDays,

    required  this.toolOutputKB,

    required  this.textKB,

    required  this.transcriptMB,
  });

      /// Transcripts older than this are deleted daily; 0 keeps them
          // minimum: 0
          // maximum: 3650
  @JsonKey(
    
    name: r'retentionDays',
    required: true,
    includeIfNull: false,
  )


  final int retentionDays;



      /// Cap of one tool output; its start and end are kept
          // minimum: 1
          // maximum: 1024
  @JsonKey(
    
    name: r'toolOutputKB',
    required: true,
    includeIfNull: false,
  )


  final int toolOutputKB;



      /// Cap of one text block or tool input
          // minimum: 1
          // maximum: 1024
  @JsonKey(
    
    name: r'textKB',
    required: true,
    includeIfNull: false,
  )


  final int textKB;



      /// Cap of one transcript; past it only tool calls and the result are kept
          // minimum: 1
          // maximum: 64
  @JsonKey(
    
    name: r'transcriptMB',
    required: true,
    includeIfNull: false,
  )


  final int transcriptMB;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RunHistorySettings &&
      other.retentionDays == retentionDays &&
      other.toolOutputKB == toolOutputKB &&
      other.textKB == textKB &&
      other.transcriptMB == transcriptMB;

    @override
    int get hashCode =>
        retentionDays.hashCode +
        toolOutputKB.hashCode +
        textKB.hashCode +
        transcriptMB.hashCode;

  factory RunHistorySettings.fromJson(Map<String, dynamic> json) => _$RunHistorySettingsFromJson(json);

  Map<String, dynamic> toJson() => _$RunHistorySettingsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

