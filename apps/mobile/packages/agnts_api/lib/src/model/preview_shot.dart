//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'preview_shot.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PreviewShot {
  /// Returns a new [PreviewShot] instance.
  PreviewShot({

    required  this.id,

    required  this.name,

    required  this.route,

    required  this.viewport,

    required  this.side,

     this.note,

     this.width,

     this.height,

     this.consoleErrors,

    required  this.url,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'route',
    required: true,
    includeIfNull: false,
  )


  final String route;



  @JsonKey(
    
    name: r'viewport',
    required: true,
    includeIfNull: false,
  )


  final PreviewShotViewportEnum viewport;



  @JsonKey(
    
    name: r'side',
    required: true,
    includeIfNull: false,
  )


  final PreviewShotSideEnum side;



  @JsonKey(
    
    name: r'note',
    required: false,
    includeIfNull: false,
  )


  final String? note;



  @JsonKey(
    
    name: r'width',
    required: false,
    includeIfNull: false,
  )


  final int? width;



  @JsonKey(
    
    name: r'height',
    required: false,
    includeIfNull: false,
  )


  final int? height;



  @JsonKey(
    
    name: r'consoleErrors',
    required: false,
    includeIfNull: false,
  )


  final int? consoleErrors;



      /// Where to load the PNG, relative to the API base
  @JsonKey(
    
    name: r'url',
    required: true,
    includeIfNull: false,
  )


  final String url;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PreviewShot &&
      other.id == id &&
      other.name == name &&
      other.route == route &&
      other.viewport == viewport &&
      other.side == side &&
      other.note == note &&
      other.width == width &&
      other.height == height &&
      other.consoleErrors == consoleErrors &&
      other.url == url;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        route.hashCode +
        viewport.hashCode +
        side.hashCode +
        note.hashCode +
        width.hashCode +
        height.hashCode +
        consoleErrors.hashCode +
        url.hashCode;

  factory PreviewShot.fromJson(Map<String, dynamic> json) => _$PreviewShotFromJson(json);

  Map<String, dynamic> toJson() => _$PreviewShotToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum PreviewShotViewportEnum {
@JsonValue(r'desktop')
desktop(r'desktop'),
@JsonValue(r'phone')
phone(r'phone');

const PreviewShotViewportEnum(this.value);

final String value;

@override
String toString() => value;
}


enum PreviewShotSideEnum {
@JsonValue(r'after')
after(r'after'),
@JsonValue(r'before')
before(r'before');

const PreviewShotSideEnum(this.value);

final String value;

@override
String toString() => value;
}


