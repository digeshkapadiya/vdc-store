import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vdc_store/app/routes/app_routes.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _checkSubscription();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'VDC Store',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  void _checkSubscription() async {
    await Future.delayed(Duration(seconds: 2));
    if (!mounted || _navigated) return;

    final prefs = await SharedPreferences.getInstance();
    final isSubscribed = prefs.getBool('is_subscribed') ?? false;
    if (!mounted || _navigated) return;

    _navigated = true;

    if (isSubscribed) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.home);
    }
  }
}
