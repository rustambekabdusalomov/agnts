//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'muse_provider_fallback.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MuseProviderFallback {
  /// Returns a new [MuseProviderFallback] instance.
  MuseProviderFallback({

    required  this.name,

    required  this.model,
  });

      /// The host, e.g. baseten
  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



      /// The model runs use there
  @JsonKey(
    
    name: r'model',
    required: true,
    includeIfNull: false,
  )


  final String model;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MuseProviderFallback &&
      other.name == name &&
      other.model == model;

    @override
    int get hashCode =>
        name.hashCode +
        model.hashCode;

  factory MuseProviderFallback.fromJson(Map<String, dynamic> json) => _$MuseProviderFallbackFromJson(json);

  Map<String, dynamic> toJson() => _$MuseProviderFallbackToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

