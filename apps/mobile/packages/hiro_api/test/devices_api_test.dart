import 'package:test/test.dart';
import 'package:hiro_api/hiro_api.dart';


/// tests for DevicesApi
void main() {
  final instance = HiroApi().getDevicesApi();

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
