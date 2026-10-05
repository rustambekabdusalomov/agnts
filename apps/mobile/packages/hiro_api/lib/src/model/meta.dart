//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meta.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Meta {
  /// Returns a new [Meta] instance.
  Meta({

    required  this.version,

    required  this.commit,
  });

  @JsonKey(
    
    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final String version;



  @JsonKey(
    
    name: r'commit',
    required: true,
    includeIfNull: false,
  )


  final String commit;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Meta &&
      other.version == version &&
      other.commit == commit;

    @override
    int get hashCode =>
        version.hashCode +
        commit.hashCode;

  factory Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);

  Map<String, dynamic> toJson() => _$MetaToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

