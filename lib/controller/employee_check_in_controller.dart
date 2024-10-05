import 'dart:convert';

import 'package:get/get.dart';


class EmployeeCheckInController extends GetxController{

  ///===============Check in handle================<>
  RxBool checkInLoading = false.obs;

  RxString checkInTime = "N/A".obs;
  RxString lunchBreakOut = "N/A".obs;
  RxString lunchBreakIN = "N/A".obs;
  RxString checkOutTime = "N/A".obs;

  checkInSystem({String status =  '', int step = 0}) async {
    checkInLoading(true);
    var body =
      {
        "checkIn":"${status}"
      };
  }

}