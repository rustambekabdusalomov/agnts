//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'secret_findings_findings_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SecretFindingsFindingsInner {
  /// Returns a new [SecretFindingsFindingsInner] instance.
  SecretFindingsFindingsInner({

    required  this.line,

    required  this.excerpt,
  });

      /// 1-based line of the text
  @JsonKey(
    
    name: r'line',
    required: true,
    includeIfNull: false,
  )


  final int line;



      /// The line with the secret masked
  @JsonKey(
    
    name: r'excerpt',
    required: true,
    includeIfNull: false,
  )


  final String excerpt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SecretFindingsFindingsInner &&
      other.line == line &&
      other.excerpt == excerpt;

    @override
    int get hashCode =>
        line.hashCode +
        excerpt.hashCode;

  factory SecretFindingsFindingsInner.fromJson(Map<String, dynamic> json) => _$SecretFindingsFindingsInnerFromJson(json);

  Map<String, dynamic> toJson() => _$SecretFindingsFindingsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

