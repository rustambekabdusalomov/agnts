//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'try_enforce_result_hits_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TryEnforceResultHitsInner {
  /// Returns a new [TryEnforceResultHitsInner] instance.
  TryEnforceResultHitsInner({

    required  this.ticket,

    required  this.path,

     this.line,

    required  this.text,
  });

  @JsonKey(
    
    name: r'ticket',
    required: true,
    includeIfNull: false,
  )


  final String ticket;



  @JsonKey(
    
    name: r'path',
    required: true,
    includeIfNull: false,
  )


  final String path;



  @JsonKey(
    
    name: r'line',
    required: false,
    includeIfNull: false,
  )


  final int? line;



  @JsonKey(
    
    name: r'text',
    required: true,
    includeIfNull: false,
  )


  final String text;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TryEnforceResultHitsInner &&
      other.ticket == ticket &&
      other.path == path &&
      other.line == line &&
      other.text == text;

    @override
    int get hashCode =>
        ticket.hashCode +
        path.hashCode +
        line.hashCode +
        text.hashCode;

  factory TryEnforceResultHitsInner.fromJson(Map<String, dynamic> json) => _$TryEnforceResultHitsInnerFromJson(json);

  Map<String, dynamic> toJson() => _$TryEnforceResultHitsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

