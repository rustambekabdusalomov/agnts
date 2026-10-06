//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/translation_language.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'translate_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TranslateInput {
  /// Returns a new [TranslateInput] instance.
  TranslateInput({

    required  this.lang,
  });

  @JsonKey(
    
    name: r'lang',
    required: true,
    includeIfNull: false,
  )


  final TranslationLanguage lang;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TranslateInput &&
      other.lang == lang;

    @override
    int get hashCode =>
        lang.hashCode;

  factory TranslateInput.fromJson(Map<String, dynamic> json) => _$TranslateInputFromJson(json);

  Map<String, dynamic> toJson() => _$TranslateInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

