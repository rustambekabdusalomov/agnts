//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/muse_provider_mode.dart';
import 'package:agnts_api/src/model/muse_provider_fallback.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'muse_provider.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MuseProvider {
  /// Returns a new [MuseProvider] instance.
  MuseProvider({

    required  this.mode,

     this.fallback,

     this.primaryOutUntil,

     this.primaryOutReason,

     this.setAt,
  });

  @JsonKey(
    
    name: r'mode',
    required: true,
    includeIfNull: false,
  )


  final MuseProviderMode mode;



  @JsonKey(
    
    name: r'fallback',
    required: false,
    includeIfNull: false,
  )


  final MuseProviderFallback? fallback;



      /// agnts's Meta account ran out; in auto mode runs go to the fallback until then
  @JsonKey(
    
    name: r'primaryOutUntil',
    required: false,
    includeIfNull: false,
  )


  final DateTime? primaryOutUntil;



  @JsonKey(
    
    name: r'primaryOutReason',
    required: false,
    includeIfNull: false,
  )


  final String? primaryOutReason;



      /// When an Admin last chose the mode
  @JsonKey(
    
    name: r'setAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? setAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MuseProvider &&
      other.mode == mode &&
      other.fallback == fallback &&
      other.primaryOutUntil == primaryOutUntil &&
      other.primaryOutReason == primaryOutReason &&
      other.setAt == setAt;

    @override
    int get hashCode =>
        mode.hashCode +
        fallback.hashCode +
        primaryOutUntil.hashCode +
        primaryOutReason.hashCode +
        setAt.hashCode;

  factory MuseProvider.fromJson(Map<String, dynamic> json) => _$MuseProviderFromJson(json);

  Map<String, dynamic> toJson() => _$MuseProviderToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

