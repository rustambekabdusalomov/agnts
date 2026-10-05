//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:hiro_api/src/model/repository.dart';
import 'package:hiro_api/src/model/ticket.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'repo_activity.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RepoActivity {
  /// Returns a new [RepoActivity] instance.
  RepoActivity({

    required  this.repo,

    required  this.open,

     this.latest,
  });

  @JsonKey(
    
    name: r'repo',
    required: true,
    includeIfNull: false,
  )


  final Repository repo;



  @JsonKey(
    
    name: r'open',
    required: true,
    includeIfNull: false,
  )


  final int open;



  @JsonKey(
    
    name: r'latest',
    required: false,
    includeIfNull: false,
  )


  final Ticket? latest;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RepoActivity &&
      other.repo == repo &&
      other.open == open &&
      other.latest == latest;

    @override
    int get hashCode =>
        repo.hashCode +
        open.hashCode +
        latest.hashCode;

  factory RepoActivity.fromJson(Map<String, dynamic> json) => _$RepoActivityFromJson(json);

  Map<String, dynamic> toJson() => _$RepoActivityToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

