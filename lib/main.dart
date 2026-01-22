import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:vdc_store/app/routes/app_routes.dart';
import 'package:vdc_store/app/shared/utils/app_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'VDC Store',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        fontFamily: AppFonts.kanit,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: AppRoutes.spalsh,
      getPages: AppRoutes.routes,
    );
  }
}
