//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pattern.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Pattern {
  /// Returns a new [Pattern] instance.
  Pattern({

    required  this.file,

    required  this.kind,

    required  this.like,

     this.layer,

     this.why,

     this.place,

     this.precedent,
  });

  @JsonKey(
    
    name: r'file',
    required: true,
    includeIfNull: false,
  )


  final String file;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final PatternKindEnum kind;



      /// The existing file to follow; for a new pattern, the one to take conventions from (may be empty)
  @JsonKey(
    
    name: r'like',
    required: true,
    includeIfNull: false,
  )


  final String like;



  @JsonKey(
    
    name: r'layer',
    required: false,
    includeIfNull: false,
  )


  final String? layer;



  @JsonKey(
    
    name: r'why',
    required: false,
    includeIfNull: false,
  )


  final String? why;



  @JsonKey(
    
    name: r'place',
    required: false,
    includeIfNull: false,
  )


  final String? place;



      /// A new pattern other code will copy; the author is asked about it
  @JsonKey(
    
    name: r'precedent',
    required: false,
    includeIfNull: false,
  )


  final bool? precedent;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Pattern &&
      other.file == file &&
      other.kind == kind &&
      other.like == like &&
      other.layer == layer &&
      other.why == why &&
      other.place == place &&
      other.precedent == precedent;

    @override
    int get hashCode =>
        file.hashCode +
        kind.hashCode +
        like.hashCode +
        layer.hashCode +
        why.hashCode +
        place.hashCode +
        precedent.hashCode;

  factory Pattern.fromJson(Map<String, dynamic> json) => _$PatternFromJson(json);

  Map<String, dynamic> toJson() => _$PatternToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum PatternKindEnum {
@JsonValue(r'copy')
copy(r'copy'),
@JsonValue(r'adapt')
adapt(r'adapt'),
@JsonValue(r'new')
new_(r'new');

const PatternKindEnum(this.value);

final String value;

@override
String toString() => value;
}


