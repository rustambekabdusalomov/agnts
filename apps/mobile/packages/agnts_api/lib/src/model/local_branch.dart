//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'local_branch.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LocalBranch {
  /// Returns a new [LocalBranch] instance.
  LocalBranch({

    required  this.name,

    required  this.sha,

    required  this.message,

    required  this.author,

     this.date,

    required  this.ahead,

    required  this.behind,

    required  this.status,

    required  this.unpushed,

     this.ticketKey,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



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



      /// Commits not on the default branch
  @JsonKey(
    
    name: r'ahead',
    required: true,
    includeIfNull: false,
  )


  final int ahead;



      /// Default branch commits the branch lacks
  @JsonKey(
    
    name: r'behind',
    required: true,
    includeIfNull: false,
  )


  final int behind;



      /// local: not on origin; pushed: origin has the same commit; unpushed: origin is behind; differs: origin has commits the local branch lacks
  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final LocalBranchStatusEnum status;



      /// Commits origin lacks (status unpushed)
  @JsonKey(
    
    name: r'unpushed',
    required: true,
    includeIfNull: false,
  )


  final int unpushed;



  @JsonKey(
    
    name: r'ticketKey',
    required: false,
    includeIfNull: false,
  )


  final String? ticketKey;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LocalBranch &&
      other.name == name &&
      other.sha == sha &&
      other.message == message &&
      other.author == author &&
      other.date == date &&
      other.ahead == ahead &&
      other.behind == behind &&
      other.status == status &&
      other.unpushed == unpushed &&
      other.ticketKey == ticketKey;

    @override
    int get hashCode =>
        name.hashCode +
        sha.hashCode +
        message.hashCode +
        author.hashCode +
        date.hashCode +
        ahead.hashCode +
        behind.hashCode +
        status.hashCode +
        unpushed.hashCode +
        ticketKey.hashCode;

  factory LocalBranch.fromJson(Map<String, dynamic> json) => _$LocalBranchFromJson(json);

  Map<String, dynamic> toJson() => _$LocalBranchToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// local: not on origin; pushed: origin has the same commit; unpushed: origin is behind; differs: origin has commits the local branch lacks
enum LocalBranchStatusEnum {
@JsonValue(r'local')
local(r'local'),
@JsonValue(r'pushed')
pushed(r'pushed'),
@JsonValue(r'unpushed')
unpushed(r'unpushed'),
@JsonValue(r'differs')
differs(r'differs');

const LocalBranchStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


