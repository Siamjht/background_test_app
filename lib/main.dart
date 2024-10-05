import 'package:background_test_app/custom_stop_watch.dart';
import 'package:background_test_app/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 850),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Background Stopwatch',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: CustomStopWatch(),
        );
      },
    );
  }
}

class TestClass extends StatelessWidget {
  const TestClass({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Text("This is test class")),
    );
  }
}


