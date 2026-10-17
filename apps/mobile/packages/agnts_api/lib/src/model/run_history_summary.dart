//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'run_history_summary.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RunHistorySummary {
  /// Returns a new [RunHistorySummary] instance.
  RunHistorySummary({

    required  this.count,

    required  this.errors,

    required  this.stalled,

    required  this.costUsd,

    required  this.backgroundCostUsd,

    required  this.inputTokens,

    required  this.outputTokens,

    required  this.p50Ms,

    required  this.p95Ms,
  });

  @JsonKey(
    
    name: r'count',
    required: true,
    includeIfNull: false,
  )


  final int count;



      /// Ended in error, timeout or out of memory
  @JsonKey(
    
    name: r'errors',
    required: true,
    includeIfNull: false,
  )


  final int errors;



      /// Had at least one stall
  @JsonKey(
    
    name: r'stalled',
    required: true,
    includeIfNull: false,
  )


  final int stalled;



  @JsonKey(
    
    name: r'costUsd',
    required: true,
    includeIfNull: false,
  )


  final num costUsd;



      /// The part of costUsd spent outside a ticket's stages
  @JsonKey(
    
    name: r'backgroundCostUsd',
    required: true,
    includeIfNull: false,
  )


  final num backgroundCostUsd;



  @JsonKey(
    
    name: r'inputTokens',
    required: true,
    includeIfNull: false,
  )


  final int inputTokens;



  @JsonKey(
    
    name: r'outputTokens',
    required: true,
    includeIfNull: false,
  )


  final int outputTokens;



      /// Median duration of finished invocations
  @JsonKey(
    
    name: r'p50Ms',
    required: true,
    includeIfNull: false,
  )


  final int p50Ms;



  @JsonKey(
    
    name: r'p95Ms',
    required: true,
    includeIfNull: false,
  )


  final int p95Ms;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RunHistorySummary &&
      other.count == count &&
      other.errors == errors &&
      other.stalled == stalled &&
      other.costUsd == costUsd &&
      other.backgroundCostUsd == backgroundCostUsd &&
      other.inputTokens == inputTokens &&
      other.outputTokens == outputTokens &&
      other.p50Ms == p50Ms &&
      other.p95Ms == p95Ms;

    @override
    int get hashCode =>
        count.hashCode +
        errors.hashCode +
        stalled.hashCode +
        costUsd.hashCode +
        backgroundCostUsd.hashCode +
        inputTokens.hashCode +
        outputTokens.hashCode +
        p50Ms.hashCode +
        p95Ms.hashCode;

  factory RunHistorySummary.fromJson(Map<String, dynamic> json) => _$RunHistorySummaryFromJson(json);

  Map<String, dynamic> toJson() => _$RunHistorySummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

