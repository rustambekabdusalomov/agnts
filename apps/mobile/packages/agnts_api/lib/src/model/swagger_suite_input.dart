//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'swagger_suite_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SwaggerSuiteInput {
  /// Returns a new [SwaggerSuiteInput] instance.
  SwaggerSuiteInput({

     this.fromTicket,

     this.name,

     this.schedule,

     this.hour,

     this.enabled,

     this.token,
  });

      /// Create: the Swagger test ticket whose test to keep
  @JsonKey(
    
    name: r'fromTicket',
    required: false,
    includeIfNull: false,
  )


  final String? fromTicket;



  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



      /// off runs only by hand or the deploy hook
  @JsonKey(
    
    name: r'schedule',
    required: false,
    includeIfNull: false,
  )


  final SwaggerSuiteInputScheduleEnum? schedule;



      /// UTC hour of daily and weekly runs (weekly: Mondays)
          // minimum: 0
          // maximum: 23
  @JsonKey(
    
    name: r'hour',
    required: false,
    includeIfNull: false,
  )


  final int? hour;



  @JsonKey(
    
    name: r'enabled',
    required: false,
    includeIfNull: false,
  )


  final bool? enabled;



      /// A new token for the suite; left out keeps it (a new suite takes the ticket's)
  @JsonKey(
    
    name: r'token',
    required: false,
    includeIfNull: false,
  )


  final String? token;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SwaggerSuiteInput &&
      other.fromTicket == fromTicket &&
      other.name == name &&
      other.schedule == schedule &&
      other.hour == hour &&
      other.enabled == enabled &&
      other.token == token;

    @override
    int get hashCode =>
        fromTicket.hashCode +
        name.hashCode +
        schedule.hashCode +
        hour.hashCode +
        enabled.hashCode +
        token.hashCode;

  factory SwaggerSuiteInput.fromJson(Map<String, dynamic> json) => _$SwaggerSuiteInputFromJson(json);

  Map<String, dynamic> toJson() => _$SwaggerSuiteInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// off runs only by hand or the deploy hook
enum SwaggerSuiteInputScheduleEnum {
@JsonValue(r'off')
off(r'off'),
@JsonValue(r'hourly')
hourly(r'hourly'),
@JsonValue(r'daily')
daily(r'daily'),
@JsonValue(r'weekly')
weekly(r'weekly');

const SwaggerSuiteInputScheduleEnum(this.value);

final String value;

@override
String toString() => value;
}


