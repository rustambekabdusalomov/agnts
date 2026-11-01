//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'model_catalog_tiers_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ModelCatalogTiersInner {
  /// Returns a new [ModelCatalogTiersInner] instance.
  ModelCatalogTiersInner({

    required  this.id,

    required  this.label,

    required  this.strong,
  });

      /// muse:<model> for Muse Code (muse:spark, muse:wonder), a Claude model (haiku, sonnet, opus), codex:<model> for Codex CLI, or a tier (tier:light, tier:strong): the light or strong model of the module the run lands on. listModels says which this server offers.
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
    
    name: r'strong',
    required: true,
    includeIfNull: false,
  )


  final bool strong;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ModelCatalogTiersInner &&
      other.id == id &&
      other.label == label &&
      other.strong == strong;

    @override
    int get hashCode =>
        id.hashCode +
        label.hashCode +
        strong.hashCode;

  factory ModelCatalogTiersInner.fromJson(Map<String, dynamic> json) => _$ModelCatalogTiersInnerFromJson(json);

  Map<String, dynamic> toJson() => _$ModelCatalogTiersInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

