//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'document_all_of_derived_from.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DocumentAllOfDerivedFrom {
  /// Returns a new [DocumentAllOfDerivedFrom] instance.
  DocumentAllOfDerivedFrom({

    required  this.id,

    required  this.title,

    required  this.version,

    required  this.currentVersion,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



      /// The version the current slides were made from; 0 while the first are being made
  @JsonKey(
    
    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final int version;



      /// The page's version now
  @JsonKey(
    
    name: r'currentVersion',
    required: true,
    includeIfNull: false,
  )


  final int currentVersion;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DocumentAllOfDerivedFrom &&
      other.id == id &&
      other.title == title &&
      other.version == version &&
      other.currentVersion == currentVersion;

    @override
    int get hashCode =>
        id.hashCode +
        title.hashCode +
        version.hashCode +
        currentVersion.hashCode;

  factory DocumentAllOfDerivedFrom.fromJson(Map<String, dynamic> json) => _$DocumentAllOfDerivedFromFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentAllOfDerivedFromToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

