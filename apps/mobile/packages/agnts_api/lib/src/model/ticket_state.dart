//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum TicketState {
      @JsonValue(r'new')
      new_(r'new'),
      @JsonValue(r'analyzing')
      analyzing(r'analyzing'),
      @JsonValue(r'waiting_for_answers')
      waitingForAnswers(r'waiting_for_answers'),
      @JsonValue(r'coding')
      coding(r'coding'),
      @JsonValue(r'testing')
      testing(r'testing'),
      @JsonValue(r'waiting_for_review')
      waitingForReview(r'waiting_for_review'),
      @JsonValue(r'pushing')
      pushing(r'pushing'),
      @JsonValue(r'done')
      done(r'done'),
      @JsonValue(r'rejected')
      rejected(r'rejected'),
      @JsonValue(r'failed')
      failed(r'failed'),
      @JsonValue(r'rate_limited')
      rateLimited(r'rate_limited');

  const TicketState(this.value);

  final String value;

  @override
  String toString() => value;
}
