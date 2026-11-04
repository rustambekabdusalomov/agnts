//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sec_rejected_hit.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SecRejectedHit {
  /// Returns a new [SecRejectedHit] instance.
  SecRejectedHit({

    required  this.hit,

     this.tool,

     this.rule,

     this.file,

     this.line,

    required  this.reason,
  });

  @JsonKey(
    
    name: r'hit',
    required: true,
    includeIfNull: false,
  )


  final String hit;



  @JsonKey(
    
    name: r'tool',
    required: false,
    includeIfNull: false,
  )


  final String? tool;



  @JsonKey(
    
    name: r'rule',
    required: false,
    includeIfNull: false,
  )


  final String? rule;



  @JsonKey(
    
    name: r'file',
    required: false,
    includeIfNull: false,
  )


  final String? file;



  @JsonKey(
    
    name: r'line',
    required: false,
    includeIfNull: false,
  )


  final int? line;



  @JsonKey(
    
    name: r'reason',
    required: true,
    includeIfNull: false,
  )


  final String reason;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SecRejectedHit &&
      other.hit == hit &&
      other.tool == tool &&
      other.rule == rule &&
      other.file == file &&
      other.line == line &&
      other.reason == reason;

    @override
    int get hashCode =>
        hit.hashCode +
        tool.hashCode +
        rule.hashCode +
        file.hashCode +
        line.hashCode +
        reason.hashCode;

  factory SecRejectedHit.fromJson(Map<String, dynamic> json) => _$SecRejectedHitFromJson(json);

  Map<String, dynamic> toJson() => _$SecRejectedHitToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

