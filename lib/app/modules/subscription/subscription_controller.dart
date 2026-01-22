import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/utils.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vdc_store/app/routes/app_routes.dart';

class SubscriptionController extends GetxController {
  late Razorpay _razorpay;

  @override
  void onInit() {
    super.onInit();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  void startPayment() {
    var options = {
      'key': 'RAZORPAY_KEY',
      'amount': 4000, // amount in paisa
      'name': 'VDC Store subscription',
      'description': 'Monthly Subscription',
      'prefill': {'contact': '', 'email': ''},
    };
    _razorpay.open(options);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Save Subscription status
    Get.offAllNamed(AppRoutes.home);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Get.snackbar('Payment Failed', 'Please try again');
  }
}
