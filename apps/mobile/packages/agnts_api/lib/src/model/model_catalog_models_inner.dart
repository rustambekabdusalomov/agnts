//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'model_catalog_models_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ModelCatalogModelsInner {
  /// Returns a new [ModelCatalogModelsInner] instance.
  ModelCatalogModelsInner({

    required  this.id,

    required  this.label,

    required  this.provider,

    required  this.strong,

     this.inputPerMillionUSD,

     this.outputPerMillionUSD,
  });

      /// muse:<model> for Muse Code (muse:spark, muse:wonder), a Claude model (haiku, sonnet, opus), or codex:<model> for Codex CLI. listModels says which this server offers.
  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'label',
    required: true,
    includeIfNull: false,
  )


  final String label;



  @JsonKey(
    
    name: r'provider',
    required: true,
    includeIfNull: false,
  )


  final ModelCatalogModelsInnerProviderEnum provider;



      /// The stronger, dearer tier
  @JsonKey(
    
    name: r'strong',
    required: true,
    includeIfNull: false,
  )


  final bool strong;



  @JsonKey(
    
    name: r'inputPerMillionUSD',
    required: false,
    includeIfNull: false,
  )


  final num? inputPerMillionUSD;



  @JsonKey(
    
    name: r'outputPerMillionUSD',
    required: false,
    includeIfNull: false,
  )


  final num? outputPerMillionUSD;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ModelCatalogModelsInner &&
      other.id == id &&
      other.label == label &&
      other.provider == provider &&
      other.strong == strong &&
      other.inputPerMillionUSD == inputPerMillionUSD &&
      other.outputPerMillionUSD == outputPerMillionUSD;

    @override
    int get hashCode =>
        id.hashCode +
        label.hashCode +
        provider.hashCode +
        strong.hashCode +
        inputPerMillionUSD.hashCode +
        outputPerMillionUSD.hashCode;

  factory ModelCatalogModelsInner.fromJson(Map<String, dynamic> json) => _$ModelCatalogModelsInnerFromJson(json);

  Map<String, dynamic> toJson() => _$ModelCatalogModelsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum ModelCatalogModelsInnerProviderEnum {
@JsonValue(r'muse')
muse(r'muse'),
@JsonValue(r'claude')
claude(r'claude'),
@JsonValue(r'codex')
codex(r'codex');

const ModelCatalogModelsInnerProviderEnum(this.value);

final String value;

@override
String toString() => value;
}


