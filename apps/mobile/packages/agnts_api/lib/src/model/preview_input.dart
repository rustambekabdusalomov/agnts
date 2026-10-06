//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'preview_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PreviewInput {
  /// Returns a new [PreviewInput] instance.
  PreviewInput({

     this.compare,
  });

      /// Also capture the default branch; kept for later previews of the ticket
  @JsonKey(
    
    name: r'compare',
    required: false,
    includeIfNull: false,
  )


  final bool? compare;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PreviewInput &&
      other.compare == compare;

    @override
    int get hashCode =>
        compare.hashCode;

  factory PreviewInput.fromJson(Map<String, dynamic> json) => _$PreviewInputFromJson(json);

  Map<String, dynamic> toJson() => _$PreviewInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

