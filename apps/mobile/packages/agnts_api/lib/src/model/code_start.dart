//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/ticket_kind_choice.dart';
import 'package:agnts_api/src/model/repo_choice.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'code_start.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CodeStart {
  /// Returns a new [CodeStart] instance.
  CodeStart({

     this.text,

     this.attachments,

     this.repos,

     this.kind,

     this.quick,

     this.ticketKey,
  });

      /// What you want done
  @JsonKey(
    
    name: r'text',
    required: false,
    includeIfNull: false,
  )


  final String? text;



  @JsonKey(
    
    name: r'attachments',
    required: false,
    includeIfNull: false,
  )


  final List<int>? attachments;



  @JsonKey(
    
    name: r'repos',
    required: false,
    includeIfNull: false,
  )


  final RepoChoice? repos;



  @JsonKey(
    
    name: r'kind',
    required: false,
    includeIfNull: false,
  )


  final TicketKindChoice? kind;



      /// Tickets skip their checks (build, lint, test)
  @JsonKey(
    
    name: r'quick',
    required: false,
    includeIfNull: false,
  )


  final bool? quick;



      /// Work on this existing ticket instead of starting one
  @JsonKey(
    
    name: r'ticketKey',
    required: false,
    includeIfNull: false,
  )


  final String? ticketKey;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CodeStart &&
      other.text == text &&
      other.attachments == attachments &&
      other.repos == repos &&
      other.kind == kind &&
      other.quick == quick &&
      other.ticketKey == ticketKey;

    @override
    int get hashCode =>
        text.hashCode +
        attachments.hashCode +
        repos.hashCode +
        kind.hashCode +
        quick.hashCode +
        ticketKey.hashCode;

  factory CodeStart.fromJson(Map<String, dynamic> json) => _$CodeStartFromJson(json);

  Map<String, dynamic> toJson() => _$CodeStartToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

