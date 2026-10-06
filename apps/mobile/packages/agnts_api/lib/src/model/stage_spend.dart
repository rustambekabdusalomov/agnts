//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/token_spend.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stage_spend.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class StageSpend {
  /// Returns a new [StageSpend] instance.
  StageSpend({

    required  this.stage,

    required  this.model,

    required  this.calls,

    required  this.turns,

    required  this.partial,

    required  this.spend,
  });

      /// retry is fix attempts after failed checks and requested changes
  @JsonKey(
    
    name: r'stage',
    required: true,
    includeIfNull: false,
  )


  final StageSpendStageEnum stage;



  @JsonKey(
    
    name: r'model',
    required: true,
    includeIfNull: false,
  )


  final String model;



      /// Claude invocations
  @JsonKey(
    
    name: r'calls',
    required: true,
    includeIfNull: false,
  )


  final int calls;



  @JsonKey(
    
    name: r'turns',
    required: true,
    includeIfNull: false,
  )


  final int turns;



      /// A run was cut off, so its tokens are counted from the messages seen and its cost is unknown
  @JsonKey(
    
    name: r'partial',
    required: true,
    includeIfNull: false,
  )


  final bool partial;



  @JsonKey(
    
    name: r'spend',
    required: true,
    includeIfNull: false,
  )


  final TokenSpend spend;





    @override
    bool operator ==(Object other) => identical(this, other) || other is StageSpend &&
      other.stage == stage &&
      other.model == model &&
      other.calls == calls &&
      other.turns == turns &&
      other.partial == partial &&
      other.spend == spend;

    @override
    int get hashCode =>
        stage.hashCode +
        model.hashCode +
        calls.hashCode +
        turns.hashCode +
        partial.hashCode +
        spend.hashCode;

  factory StageSpend.fromJson(Map<String, dynamic> json) => _$StageSpendFromJson(json);

  Map<String, dynamic> toJson() => _$StageSpendToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// retry is fix attempts after failed checks and requested changes
enum StageSpendStageEnum {
@JsonValue(r'analyze')
analyze(r'analyze'),
@JsonValue(r'coding')
coding(r'coding'),
@JsonValue(r'retry')
retry(r'retry'),
@JsonValue(r'helper')
helper(r'helper'),
@JsonValue(r'learn')
learn(r'learn'),
@JsonValue(r'review')
review(r'review'),
@JsonValue(r'preview')
preview(r'preview');

const StageSpendStageEnum(this.value);

final String value;

@override
String toString() => value;
}


