//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'approach.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Approach {
  /// Returns a new [Approach] instance.
  Approach({

    required  this.title,

    required  this.sketch,

    required  this.pros,

    required  this.cons,

     this.fit,

    required  this.chosen,

     this.why,
  });

  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(
    
    name: r'sketch',
    required: true,
    includeIfNull: false,
  )


  final String sketch;



  @JsonKey(
    
    name: r'pros',
    required: true,
    includeIfNull: false,
  )


  final List<String> pros;



  @JsonKey(
    
    name: r'cons',
    required: true,
    includeIfNull: false,
  )


  final List<String> cons;



      /// How it fits the repository brief and the team rules, or what it bends
  @JsonKey(
    
    name: r'fit',
    required: false,
    includeIfNull: false,
  )


  final String? fit;



  @JsonKey(
    
    name: r'chosen',
    required: true,
    includeIfNull: false,
  )


  final bool chosen;



      /// For the chosen approach, why it beats the others; for the others, why not
  @JsonKey(
    
    name: r'why',
    required: false,
    includeIfNull: false,
  )


  final String? why;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Approach &&
      other.title == title &&
      other.sketch == sketch &&
      other.pros == pros &&
      other.cons == cons &&
      other.fit == fit &&
      other.chosen == chosen &&
      other.why == why;

    @override
    int get hashCode =>
        title.hashCode +
        sketch.hashCode +
        pros.hashCode +
        cons.hashCode +
        fit.hashCode +
        chosen.hashCode +
        why.hashCode;

  factory Approach.fromJson(Map<String, dynamic> json) => _$ApproachFromJson(json);

  Map<String, dynamic> toJson() => _$ApproachToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

