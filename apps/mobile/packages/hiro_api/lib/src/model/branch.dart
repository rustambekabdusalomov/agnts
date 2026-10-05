//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:hiro_api/src/model/ci.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'branch.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Branch {
  /// Returns a new [Branch] instance.
  Branch({

    required  this.name,

    required  this.default_,

    required  this.sha,

    required  this.message,

    required  this.author,

     this.date,

    required  this.ahead,

    required  this.behind,

    required  this.ci,

     this.ticketKey,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'default',
    required: true,
    includeIfNull: false,
  )


  final bool default_;



  @JsonKey(
    
    name: r'sha',
    required: true,
    includeIfNull: false,
  )


  final String sha;



  @JsonKey(
    
    name: r'message',
    required: true,
    includeIfNull: false,
  )


  final String message;



  @JsonKey(
    
    name: r'author',
    required: true,
    includeIfNull: false,
  )


  final String author;



  @JsonKey(
    
    name: r'date',
    required: false,
    includeIfNull: false,
  )


  final DateTime? date;



  @JsonKey(
    
    name: r'ahead',
    required: true,
    includeIfNull: false,
  )


  final int ahead;



  @JsonKey(
    
    name: r'behind',
    required: true,
    includeIfNull: false,
  )


  final int behind;



  @JsonKey(
    
    name: r'ci',
    required: true,
    includeIfNull: false,
  )


  final CI ci;



  @JsonKey(
    
    name: r'ticketKey',
    required: false,
    includeIfNull: false,
  )


  final String? ticketKey;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Branch &&
      other.name == name &&
      other.default_ == default_ &&
      other.sha == sha &&
      other.message == message &&
      other.author == author &&
      other.date == date &&
      other.ahead == ahead &&
      other.behind == behind &&
      other.ci == ci &&
      other.ticketKey == ticketKey;

    @override
    int get hashCode =>
        name.hashCode +
        default_.hashCode +
        sha.hashCode +
        message.hashCode +
        author.hashCode +
        date.hashCode +
        ahead.hashCode +
        behind.hashCode +
        ci.hashCode +
        ticketKey.hashCode;

  factory Branch.fromJson(Map<String, dynamic> json) => _$BranchFromJson(json);

  Map<String, dynamic> toJson() => _$BranchToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

