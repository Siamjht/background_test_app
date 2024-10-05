import 'package:background_test_app/utils/app_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import '../../../../../utils/app_colors.dart';
import 'backgroud_services/background_services.dart';
import 'controller/employee_check_in_controller.dart';
import 'custom_text.dart';
import 'helpers/time_format.dart';


class CustomStopWatch extends StatefulWidget {
  @override
  _CustomStopWatchState createState() => _CustomStopWatchState();
}

class _CustomStopWatchState extends State<CustomStopWatch> {
  final EmployeeCheckInController employeeCheckInController = Get.put(EmployeeCheckInController());
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
  );

  RxInt step = 1.obs;
  RxString lunchBreakOut = 'Lunch Break Out'.obs;
  bool isStopwatchRunning = false;

  @override
  void initState() {
    super.initState();
    initService();
    // Restore previous state from preferences
    restoreDataFromPrefs();
  }

  // Restore data from shared preferences
  Future<void> restoreDataFromPrefs() async {
    // Restore step value and lunch break state
    step.value = await PrefsHelper.getIntThis(AppConstants.stopWatchStep) ?? 1;
    lunchBreakOut.value = await PrefsHelper.getStringThis(AppConstants.lunchBackStatus) ?? 'Lunch Break Out';

    // Restore stopwatch time and running state
    final savedTime = await PrefsHelper.getIntThis(AppConstants.stopWatchTime);
    final savedRunningState = await PrefsHelper.getBoolThis(AppConstants.stopWatchRunningState);
    final lastSavedTimestamp = await PrefsHelper.getIntThis(AppConstants.lastSavedTimestamp);

    if (savedTime != null) {
      // If the stopwatch was running, calculate the time difference and add it to the saved time
      if (savedRunningState != null && savedRunningState && lastSavedTimestamp != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final timeDifference = now - lastSavedTimestamp;
        final totalElapsedTime = savedTime + timeDifference; // Add the elapsed time to the saved time
        _stopWatchTimer.setPresetSecondTime(totalElapsedTime ~/ 1000); // Set stopwatch to the total time
        _stopWatchTimer.onStartTimer(); // Start the stopwatch if it was running
        isStopwatchRunning = true;
      } else {
        _stopWatchTimer.setPresetSecondTime(savedTime ~/ 1000); // Set stopwatch to the saved time
      }
    }

    setState(() {}); // Update the UI with restored values
  }

  // Save data to shared preferences
  Future<void> saveDataToPrefs() async {
    await PrefsHelper.setIntThis(AppConstants.stopWatchStep, step.value);
    await PrefsHelper.setStringThis(AppConstants.lunchBackStatus, lunchBreakOut.value);
    await PrefsHelper.setIntThis(AppConstants.stopWatchTime, _stopWatchTimer.rawTime.value);
    await PrefsHelper.setBoolThis(AppConstants.stopWatchRunningState, isStopwatchRunning); // Save running state
    await PrefsHelper.setIntThis(AppConstants.lastSavedTimestamp, DateTime.now().millisecondsSinceEpoch); // Save the current time
  }

  @override
  void dispose() async {
    // Save state when disposing (e.g. on screen exit)
    if (step.value == 3) {
      _stopWatchTimer.dispose();
      await PrefsHelper.setIntThis(AppConstants.stopWatchStep, 1);
      await PrefsHelper.setStringThis(AppConstants.lunchBackStatus, 'Lunch Break Out');
    }else{
      await saveDataToPrefs(); // Always save the stopwatch state
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.r),
                border: Border.all(color: AppColors.primaryColor)),
            child: Padding(
              padding: EdgeInsets.all(30.r),
              child: StreamBuilder<int>(
                stream: _stopWatchTimer.rawTime,
                initialData: _stopWatchTimer.rawTime.value,
                builder: (context, snapshot) {
                  final value = snapshot.data!;
                  final displayTime = StopWatchTimer.getDisplayTime(value, hours: true, milliSecond: false);
                  return Text(
                    displayTime,
                    style: const TextStyle(
                      fontSize: 30,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Obx(
                () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                step.value == 1
                    ? SizedBox(
                    width: 120.w,
                    child: ButtonClockIn(
                        onpress: () {
                          employeeCheckInController.checkInSystem(status: "checkIn", step: 2);
                          step.value = 2;
                          _stopWatchTimer.onStartTimer();
                          isStopwatchRunning = true;
                          saveDataToPrefs(); // Save state after Check-In
                        },
                        title: "Check In"))
                    : const SizedBox(),
                step.value == 2 && lunchBreakOut.value != 'Lunch Break Done'
                    ? SizedBox(
                    width: 150.w,
                    child: ButtonClockIn(
                        onpress: () {
                          if (lunchBreakOut.value == 'Lunch Break Out') {
                            employeeCheckInController.checkInSystem(status: "BreakTimeOut", step: 3);
                            _stopWatchTimer.onStopTimer();
                            lunchBreakOut.value = 'Lunch Break In';
                            isStopwatchRunning = false;
                            saveDataToPrefs(); // Save state after Break Out
                          } else if (lunchBreakOut.value == 'Lunch Break In') {
                            employeeCheckInController.checkInSystem(status: "BreakTimeIn", step: 4);
                            _stopWatchTimer.onStartTimer();
                            lunchBreakOut.value = 'Lunch Break Done';
                            isStopwatchRunning = true;
                            saveDataToPrefs(); // Save state after Break In
                          }
                        },
                        title: "$lunchBreakOut"))
                    : const SizedBox(),
                step.value == 2
                    ? SizedBox(
                    width: 150.w,
                    child: ButtonClockIn(
                        onpress: () {
                          employeeCheckInController.checkInSystem(status: "checkOut", step: 5);
                          _stopWatchTimer.onStopTimer();
                          step.value = 3;
                          isStopwatchRunning = false;
                          saveDataToPrefs(); // Save state after Check-Out
                        },
                        title: "Clock Out",
                        color: Colors.red))
                    : const SizedBox(),
                step.value == 3
                    ? SizedBox(
                    width: 150.w,
                    child: ButtonClockIn(
                        onpress: () {
                          // Show total work hours (no state change)
                          step.value = 3;
                          saveDataToPrefs();
                        },
                        title: "Total Work Hours",
                        color: Colors.white,
                        titlecolor: AppColors.primaryColor))
                    : const SizedBox(),
              ],
            ),
          ),
          SizedBox(height: 40.h),


          Obx((){
            return Column(
              children: [


                _twoText('Check In Time', employeeCheckInController.checkInTime.value == "N/A" ? "N/A"  : '${TimeFormatHelper.timeWithAMPM(DateTime.parse("${employeeCheckInController.checkInTime}"))}'),
                _twoText('Lunch Break Out', employeeCheckInController.lunchBreakOut.value == "N/A" ? "N/A"  : '${TimeFormatHelper.timeWithAMPM(DateTime.parse("${employeeCheckInController.lunchBreakOut}"))}'),
                _twoText('Lunch Break In', employeeCheckInController.lunchBreakIN.value == "N/A" ? "N/A"  : '${TimeFormatHelper.timeWithAMPM(DateTime.parse("${employeeCheckInController.lunchBreakIN}"))}'),
                _twoText('Check Out Time',employeeCheckInController.checkOutTime.value == "N/A" ? "N/A"  : '${TimeFormatHelper.timeWithAMPM(DateTime.parse("${employeeCheckInController.checkOutTime}"))}'),



              ],
            );
          }

          )

        ],
      ),
    );
  }

  _twoText(String leftText, String rightText) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(text: leftText, fontWeight: FontWeight.w600),
          CustomText(text: rightText, fontWeight: FontWeight.w500),
        ],
      ),
    );
  }
}

class ButtonClockIn extends StatelessWidget {
  final VoidCallback onpress;
  final String title;
  final Color? color;
  final Color? titlecolor;
  final double? height;
  final double? width;
  final double? fontSize;
  final bool loading;

  ButtonClockIn({
    required this.title,
    required this.onpress,
    this.color,
    this.height,
    this.width,
    this.fontSize,
    this.titlecolor,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? () {} : onpress,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 3.w),
        width: width ?? 345.w,
        height: height ?? 45.h,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50.r),
            color: color ?? AppColors.primaryColor),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            loading
                ? SizedBox(
              height: 20.h,
              width: 20.h,
              child: const CircularProgressIndicator(
                color: Colors.white,
              ),
            )
                : Flexible(
              child: CustomText(
                text: title,
                fontsize: fontSize ?? 13.h,
                color: titlecolor ?? Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrefsHelper {
  // Save integer value
  static Future<void> setIntThis(String key, int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  // Get integer value
  static Future<int?> getIntThis(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  // Save string value
  static Future<void> setStringThis(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // Get string value
  static Future<String?> getStringThis(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // Save boolean value (for stopwatch state)
  static Future<void> setBoolThis(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // Get boolean value (for stopwatch state)
  static Future<bool?> getBoolThis(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }
}