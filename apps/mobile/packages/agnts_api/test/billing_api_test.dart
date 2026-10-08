import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for BillingApi
void main() {
  final instance = AgntsApi().getBillingApi();

  group(BillingApi, () {
    // Start buying credits; returns the payment page to open
    //
    //Future<CheckoutCredits200Response> checkoutCredits(CheckoutCreditsRequest checkoutCreditsRequest) async
    test('test checkoutCredits', () async {
      // TODO
    });

    // The workspace's plan, slots, members and credits
    //
    //Future<Billing> getBilling() async
    test('test getBilling', () async {
      // TODO
    });

    // Change how many runs the workspace may have at once
    //
    //Future<Billing> setSlots(SetSlotsRequest setSlotsRequest) async
    test('test setSlots', () async {
      // TODO
    });

  });
}
