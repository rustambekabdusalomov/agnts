//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'grant_credits_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GrantCreditsRequest {
  /// Returns a new [GrantCreditsRequest] instance.
  GrantCreditsRequest({

    required  this.amount,

     this.note,
  });

  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final int amount;



  @JsonKey(
    
    name: r'note',
    required: false,
    includeIfNull: false,
  )


  final String? note;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GrantCreditsRequest &&
      other.amount == amount &&
      other.note == note;

    @override
    int get hashCode =>
        amount.hashCode +
        note.hashCode;

  factory GrantCreditsRequest.fromJson(Map<String, dynamic> json) => _$GrantCreditsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GrantCreditsRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

