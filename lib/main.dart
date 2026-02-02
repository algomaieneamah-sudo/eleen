
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // مكتبة الفايربيس
import 'firebase_options.dart'; // ملف الإعدادات الذي أنشأناه
import 'viwe/login.dart';
import 'viwe/splash_screen.dart';

void main() async { // 1. إضافة كلمة async هنا
  // 2. هذا السطر إلزامي عند استخدام Firebase قبل runApp
  WidgetsFlutterBinding.ensureInitialized();

  // 3. إضافة كلمة await لانتظار التهيئة
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // لإخفاء شريط الديباج المزعج
      title: 'Booking App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // هنا حددنا أن أول واجهة تظهر هي صفحة تسجيل الدخول
      home: const SplashScreen(),
    );
  }
}