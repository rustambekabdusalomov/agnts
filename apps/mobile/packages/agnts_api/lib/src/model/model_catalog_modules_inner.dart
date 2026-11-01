//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'model_catalog_modules_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ModelCatalogModulesInner {
  /// Returns a new [ModelCatalogModulesInner] instance.
  ModelCatalogModulesInner({

    required  this.id,

    required  this.label,

     this.light,

     this.strong,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final ModelCatalogModulesInnerIdEnum id;



  @JsonKey(
    
    name: r'label',
    required: true,
    includeIfNull: false,
  )


  final String label;



      /// muse:<model> for Muse Code (muse:spark, muse:wonder), a Claude model (haiku, sonnet, opus), codex:<model> for Codex CLI, or a tier (tier:light, tier:strong): the light or strong model of the module the run lands on. listModels says which this server offers.
  @JsonKey(
    
    name: r'light',
    required: false,
    includeIfNull: false,
  )


  final String? light;



      /// muse:<model> for Muse Code (muse:spark, muse:wonder), a Claude model (haiku, sonnet, opus), codex:<model> for Codex CLI, or a tier (tier:light, tier:strong): the light or strong model of the module the run lands on. listModels says which this server offers.
  @JsonKey(
    
    name: r'strong',
    required: false,
    includeIfNull: false,
  )


  final String? strong;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ModelCatalogModulesInner &&
      other.id == id &&
      other.label == label &&
      other.light == light &&
      other.strong == strong;

    @override
    int get hashCode =>
        id.hashCode +
        label.hashCode +
        light.hashCode +
        strong.hashCode;

  factory ModelCatalogModulesInner.fromJson(Map<String, dynamic> json) => _$ModelCatalogModulesInnerFromJson(json);

  Map<String, dynamic> toJson() => _$ModelCatalogModulesInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum ModelCatalogModulesInnerIdEnum {
@JsonValue(r'muse')
muse(r'muse'),
@JsonValue(r'claude')
claude(r'claude'),
@JsonValue(r'codex')
codex(r'codex');

const ModelCatalogModulesInnerIdEnum(this.value);

final String value;

@override
String toString() => value;
}


