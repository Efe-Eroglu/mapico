import 'package:get/get.dart';
import 'flight_details_controller.dart';

class FlightDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FlightDetailsController>(() => FlightDetailsController());
  }
} 