//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/model_catalog_models_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'model_catalog.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ModelCatalog {
  /// Returns a new [ModelCatalog] instance.
  ModelCatalog({

    required  this.providers,

    required  this.primary,

    required  this.models,
  });

      /// The coding modules you may use (an Admin chooses them); empty when none
  @JsonKey(
    
    name: r'providers',
    required: true,
    includeIfNull: false,
  )


  final List<ModelCatalogProvidersEnum> providers;



      /// Your default module; settings naming a module you may not use run on its models
  @JsonKey(
    
    name: r'primary',
    required: true,
    includeIfNull: false,
  )


  final ModelCatalogPrimaryEnum primary;



  @JsonKey(
    
    name: r'models',
    required: true,
    includeIfNull: false,
  )


  final List<ModelCatalogModelsInner> models;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ModelCatalog &&
      other.providers == providers &&
      other.primary == primary &&
      other.models == models;

    @override
    int get hashCode =>
        providers.hashCode +
        primary.hashCode +
        models.hashCode;

  factory ModelCatalog.fromJson(Map<String, dynamic> json) => _$ModelCatalogFromJson(json);

  Map<String, dynamic> toJson() => _$ModelCatalogToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum ModelCatalogProvidersEnum {
@JsonValue(r'muse')
muse(r'muse'),
@JsonValue(r'claude')
claude(r'claude'),
@JsonValue(r'codex')
codex(r'codex');

const ModelCatalogProvidersEnum(this.value);

final String value;

@override
String toString() => value;
}


/// Your default module; settings naming a module you may not use run on its models
enum ModelCatalogPrimaryEnum {
@JsonValue(r'muse')
muse(r'muse'),
@JsonValue(r'claude')
claude(r'claude'),
@JsonValue(r'codex')
codex(r'codex');

const ModelCatalogPrimaryEnum(this.value);

final String value;

@override
String toString() => value;
}


