//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/translation_items_inner.dart';
import 'package:agnts_api/src/model/translation_language.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'translation.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Translation {
  /// Returns a new [Translation] instance.
  Translation({

    required  this.lang,

    required  this.items,
  });

  @JsonKey(
    
    name: r'lang',
    required: true,
    includeIfNull: false,
  )


  final TranslationLanguage lang;



      /// Each text as the ticket page shows it, and its translation
  @JsonKey(
    
    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<TranslationItemsInner> items;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Translation &&
      other.lang == lang &&
      other.items == items;

    @override
    int get hashCode =>
        lang.hashCode +
        items.hashCode;

  factory Translation.fromJson(Map<String, dynamic> json) => _$TranslationFromJson(json);

  Map<String, dynamic> toJson() => _$TranslationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

