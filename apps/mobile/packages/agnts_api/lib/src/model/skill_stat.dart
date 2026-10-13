//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'skill_stat.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SkillStat {
  /// Returns a new [SkillStat] instance.
  SkillStat({

    required  this.skill,

    required  this.tickets,

    required  this.loaded,

    required  this.done,

    required  this.firstTry,

    required  this.loadedDone,

    required  this.loadedFirstTry,

    required  this.findings,

    required  this.tokens,
  });

      /// A method skill (agnts-method-…); empty for the tickets whose coding runs had no method skills
  @JsonKey(
    
    name: r'skill',
    required: true,
    includeIfNull: false,
  )


  final String skill;



      /// Tickets with a coding run that had the skill
  @JsonKey(
    
    name: r'tickets',
    required: true,
    includeIfNull: false,
  )


  final int tickets;



      /// Of those, tickets where Claude loaded it
  @JsonKey(
    
    name: r'loaded',
    required: true,
    includeIfNull: false,
  )


  final int loaded;



  @JsonKey(
    
    name: r'done',
    required: true,
    includeIfNull: false,
  )


  final int done;



      /// Done without a person asking for changes
  @JsonKey(
    
    name: r'firstTry',
    required: true,
    includeIfNull: false,
  )


  final int firstTry;



      /// Done, of the tickets where Claude loaded it
  @JsonKey(
    
    name: r'loadedDone',
    required: true,
    includeIfNull: false,
  )


  final int loadedDone;



      /// Done first try, of the tickets where Claude loaded it
  @JsonKey(
    
    name: r'loadedFirstTry',
    required: true,
    includeIfNull: false,
  )


  final int loadedFirstTry;



      /// Review findings the method skills target: architecture and maintainability, or any on a migration file
  @JsonKey(
    
    name: r'findings',
    required: true,
    includeIfNull: false,
  )


  final int findings;



      /// Average tokens of a done ticket, all stages
  @JsonKey(
    
    name: r'tokens',
    required: true,
    includeIfNull: false,
  )


  final num tokens;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SkillStat &&
      other.skill == skill &&
      other.tickets == tickets &&
      other.loaded == loaded &&
      other.done == done &&
      other.firstTry == firstTry &&
      other.loadedDone == loadedDone &&
      other.loadedFirstTry == loadedFirstTry &&
      other.findings == findings &&
      other.tokens == tokens;

    @override
    int get hashCode =>
        skill.hashCode +
        tickets.hashCode +
        loaded.hashCode +
        done.hashCode +
        firstTry.hashCode +
        loadedDone.hashCode +
        loadedFirstTry.hashCode +
        findings.hashCode +
        tokens.hashCode;

  factory SkillStat.fromJson(Map<String, dynamic> json) => _$SkillStatFromJson(json);

  Map<String, dynamic> toJson() => _$SkillStatToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

