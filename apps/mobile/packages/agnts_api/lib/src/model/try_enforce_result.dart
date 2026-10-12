//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/try_enforce_result_hits_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'try_enforce_result.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TryEnforceResult {
  /// Returns a new [TryEnforceResult] instance.
  TryEnforceResult({

    required  this.checked,

    required  this.tickets,

    required  this.hits,

     this.note,
  });

      /// Changes looked at
  @JsonKey(
    
    name: r'checked',
    required: true,
    includeIfNull: false,
  )


  final int checked;



  @JsonKey(
    
    name: r'tickets',
    required: true,
    includeIfNull: false,
  )


  final List<String> tickets;



  @JsonKey(
    
    name: r'hits',
    required: true,
    includeIfNull: false,
  )


  final List<TryEnforceResultHitsInner> hits;



  @JsonKey(
    
    name: r'note',
    required: false,
    includeIfNull: false,
  )


  final String? note;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TryEnforceResult &&
      other.checked == checked &&
      other.tickets == tickets &&
      other.hits == hits &&
      other.note == note;

    @override
    int get hashCode =>
        checked.hashCode +
        tickets.hashCode +
        hits.hashCode +
        note.hashCode;

  factory TryEnforceResult.fromJson(Map<String, dynamic> json) => _$TryEnforceResultFromJson(json);

  Map<String, dynamic> toJson() => _$TryEnforceResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

