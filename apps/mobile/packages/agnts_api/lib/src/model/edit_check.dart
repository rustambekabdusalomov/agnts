//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'edit_check.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EditCheck {
  /// Returns a new [EditCheck] instance.
  EditCheck({

    required  this.name,

    required  this.globs,

    required  this.cmd,

     this.every,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'globs',
    required: true,
    includeIfNull: false,
  )


  final List<String> globs;



      /// {file} is the edited file, {dir} its directory, both relative to the repository
  @JsonKey(
    
    name: r'cmd',
    required: true,
    includeIfNull: false,
  )


  final String cmd;



      /// Seconds between runs; 0 runs it after every edit
          // minimum: 0
          // maximum: 3600
  @JsonKey(
    
    name: r'every',
    required: false,
    includeIfNull: false,
  )


  final int? every;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EditCheck &&
      other.name == name &&
      other.globs == globs &&
      other.cmd == cmd &&
      other.every == every;

    @override
    int get hashCode =>
        name.hashCode +
        globs.hashCode +
        cmd.hashCode +
        every.hashCode;

  factory EditCheck.fromJson(Map<String, dynamic> json) => _$EditCheckFromJson(json);

  Map<String, dynamic> toJson() => _$EditCheckToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

