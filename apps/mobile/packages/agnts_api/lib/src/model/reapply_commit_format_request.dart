//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reapply_commit_format_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReapplyCommitFormatRequest {
  /// Returns a new [ReapplyCommitFormatRequest] instance.
  ReapplyCommitFormatRequest({

     this.number,

     this.dryRun,

     this.only,
  });

      /// Sets the ticket's number ({number}) first, like AMANAT-2677
  @JsonKey(
    
    name: r'number',
    required: false,
    includeIfNull: false,
  )


  final String? number;



      /// Only list the changes
  @JsonKey(
    
    name: r'dryRun',
    required: false,
    includeIfNull: false,
  )


  final bool? dryRun;



      /// Make only these of the preview's changes (commit shas); absent makes them all
  @JsonKey(
    
    name: r'only',
    required: false,
    includeIfNull: false,
  )


  final List<String>? only;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ReapplyCommitFormatRequest &&
      other.number == number &&
      other.dryRun == dryRun &&
      other.only == only;

    @override
    int get hashCode =>
        number.hashCode +
        dryRun.hashCode +
        only.hashCode;

  factory ReapplyCommitFormatRequest.fromJson(Map<String, dynamic> json) => _$ReapplyCommitFormatRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ReapplyCommitFormatRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

