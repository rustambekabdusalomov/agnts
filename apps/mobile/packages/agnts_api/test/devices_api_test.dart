import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for DevicesApi
void main() {
  final instance = AgntsApi().getDevicesApi();

  group(DevicesApi, () {
    // Register this phone for push notifications (call again when the token changes)
    //
    //Future registerDevice(DeviceRegistration deviceRegistration) async
    test('test registerDevice', () async {
      // TODO
    });

    // Stop push notifications to this phone (on sign-out)
    //
    //Future unregisterDevice(UnregisterDeviceRequest unregisterDeviceRequest) async
    test('test unregisterDevice', () async {
      // TODO
    });

  });
}
