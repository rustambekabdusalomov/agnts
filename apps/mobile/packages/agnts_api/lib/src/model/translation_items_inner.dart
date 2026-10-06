//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'translation_items_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TranslationItemsInner {
  /// Returns a new [TranslationItemsInner] instance.
  TranslationItemsInner({

    required  this.source_,

    required  this.text,
  });

  @JsonKey(
    
    name: r'source',
    required: true,
    includeIfNull: false,
  )


  final String source_;



  @JsonKey(
    
    name: r'text',
    required: true,
    includeIfNull: false,
  )


  final String text;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TranslationItemsInner &&
      other.source_ == source_ &&
      other.text == text;

    @override
    int get hashCode =>
        source_.hashCode +
        text.hashCode;

  factory TranslationItemsInner.fromJson(Map<String, dynamic> json) => _$TranslationItemsInnerFromJson(json);

  Map<String, dynamic> toJson() => _$TranslationItemsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

