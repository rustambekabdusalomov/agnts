//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'footprint.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Footprint {
  /// Returns a new [Footprint] instance.
  Footprint({

    required  this.files,

     this.modules,

     this.provides,

     this.consumes,

     this.migrations,
  });

  @JsonKey(
    
    name: r'files',
    required: true,
    includeIfNull: false,
  )


  final List<String> files;



  @JsonKey(
    
    name: r'modules',
    required: false,
    includeIfNull: false,
  )


  final List<String>? modules;



      /// What the change adds that other work could use
  @JsonKey(
    
    name: r'provides',
    required: false,
    includeIfNull: false,
  )


  final List<String>? provides;



      /// What the change needs that may not exist yet
  @JsonKey(
    
    name: r'consumes',
    required: false,
    includeIfNull: false,
  )


  final List<String>? consumes;



  @JsonKey(
    
    name: r'migrations',
    required: false,
    includeIfNull: false,
  )


  final bool? migrations;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Footprint &&
      other.files == files &&
      other.modules == modules &&
      other.provides == provides &&
      other.consumes == consumes &&
      other.migrations == migrations;

    @override
    int get hashCode =>
        files.hashCode +
        modules.hashCode +
        provides.hashCode +
        consumes.hashCode +
        migrations.hashCode;

  factory Footprint.fromJson(Map<String, dynamic> json) => _$FootprintFromJson(json);

  Map<String, dynamic> toJson() => _$FootprintToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

