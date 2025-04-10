import 'package:flutter/material.dart';
// import 'package:frontend/login.dart';
// import 'package:frontend/dir_main/main_login.dart';
// import 'package:sludhealtech/login.dart';

void main() => (Widget app) {
      final WidgetsBinding binding = WidgetsFlutterBinding.ensureInitialized();
      assert(binding.debugCheckZone('runApp'));
      binding
        // ignore: invalid_use_of_protected_member
        ..scheduleAttachRootWidget(binding.wrapWithDefaultView(app))
        ..scheduleWarmUpFrame();
    }(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // home: Login(),
    );
  }
}
