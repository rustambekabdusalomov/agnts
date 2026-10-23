//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'document_comment_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DocumentCommentInput {
  /// Returns a new [DocumentCommentInput] instance.
  DocumentCommentInput({

    required  this.body,

     this.parentId,

     this.quote,

     this.prefix,

     this.suffix,

     this.slide,
  });

  @JsonKey(
    
    name: r'body',
    required: true,
    includeIfNull: false,
  )


  final String body;



      /// The thread this replies to
  @JsonKey(
    
    name: r'parentId',
    required: false,
    includeIfNull: false,
  )


  final int? parentId;



      /// The selected text; required for a thread
  @JsonKey(
    
    name: r'quote',
    required: false,
    includeIfNull: false,
  )


  final String? quote;



  @JsonKey(
    
    name: r'prefix',
    required: false,
    includeIfNull: false,
  )


  final String? prefix;



  @JsonKey(
    
    name: r'suffix',
    required: false,
    includeIfNull: false,
  )


  final String? suffix;



          // minimum: 0
  @JsonKey(
    
    name: r'slide',
    required: false,
    includeIfNull: false,
  )


  final int? slide;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DocumentCommentInput &&
      other.body == body &&
      other.parentId == parentId &&
      other.quote == quote &&
      other.prefix == prefix &&
      other.suffix == suffix &&
      other.slide == slide;

    @override
    int get hashCode =>
        body.hashCode +
        parentId.hashCode +
        quote.hashCode +
        prefix.hashCode +
        suffix.hashCode +
        slide.hashCode;

  factory DocumentCommentInput.fromJson(Map<String, dynamic> json) => _$DocumentCommentInputFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentCommentInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

