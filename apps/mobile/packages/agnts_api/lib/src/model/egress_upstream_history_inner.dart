//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'egress_upstream_history_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EgressUpstreamHistoryInner {
  /// Returns a new [EgressUpstreamHistoryInner] instance.
  EgressUpstreamHistoryInner({

    required  this.at,

    required  this.ok,

    required  this.ms,
  });

  @JsonKey(
    
    name: r'at',
    required: true,
    includeIfNull: false,
  )


  final DateTime at;



  @JsonKey(
    
    name: r'ok',
    required: true,
    includeIfNull: false,
  )


  final bool ok;



  @JsonKey(
    
    name: r'ms',
    required: true,
    includeIfNull: false,
  )


  final int ms;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EgressUpstreamHistoryInner &&
      other.at == at &&
      other.ok == ok &&
      other.ms == ms;

    @override
    int get hashCode =>
        at.hashCode +
        ok.hashCode +
        ms.hashCode;

  factory EgressUpstreamHistoryInner.fromJson(Map<String, dynamic> json) => _$EgressUpstreamHistoryInnerFromJson(json);

  Map<String, dynamic> toJson() => _$EgressUpstreamHistoryInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

