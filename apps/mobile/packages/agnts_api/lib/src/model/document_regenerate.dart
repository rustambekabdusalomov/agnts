//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/document_source_input.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'document_regenerate.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DocumentRegenerate {
  /// Returns a new [DocumentRegenerate] instance.
  DocumentRegenerate({

     this.source_,
  });

  @JsonKey(
    
    name: r'source',
    required: false,
    includeIfNull: false,
  )


  final DocumentSourceInput? source_;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DocumentRegenerate &&
      other.source_ == source_;

    @override
    int get hashCode =>
        source_.hashCode;

  factory DocumentRegenerate.fromJson(Map<String, dynamic> json) => _$DocumentRegenerateFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentRegenerateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

