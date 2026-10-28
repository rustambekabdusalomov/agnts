//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// none; recording (notes are on); queued, transcribing (Muse hears the audio), writing (Muse writes the notes); done; failed
enum MeetingNotesStatus {
      @JsonValue(r'none')
      none(r'none'),
      @JsonValue(r'recording')
      recording(r'recording'),
      @JsonValue(r'queued')
      queued(r'queued'),
      @JsonValue(r'transcribing')
      transcribing(r'transcribing'),
      @JsonValue(r'writing')
      writing(r'writing'),
      @JsonValue(r'done')
      done(r'done'),
      @JsonValue(r'failed')
      failed(r'failed');

  const MeetingNotesStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
