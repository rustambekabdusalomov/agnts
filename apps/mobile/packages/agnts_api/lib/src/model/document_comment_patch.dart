//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'document_comment_patch.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DocumentCommentPatch {
  /// Returns a new [DocumentCommentPatch] instance.
  DocumentCommentPatch({

     this.body,

     this.resolved,
  });

  @JsonKey(
    
    name: r'body',
    required: false,
    includeIfNull: false,
  )


  final String? body;



  @JsonKey(
    
    name: r'resolved',
    required: false,
    includeIfNull: false,
  )


  final bool? resolved;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DocumentCommentPatch &&
      other.body == body &&
      other.resolved == resolved;

    @override
    int get hashCode =>
        body.hashCode +
        resolved.hashCode;

  factory DocumentCommentPatch.fromJson(Map<String, dynamic> json) => _$DocumentCommentPatchFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentCommentPatchToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

