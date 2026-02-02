import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../creata_account.dart'; // تأكد أن هذا هو اسم ملف إنشاء الحساب لديك
import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isArabic = true;
  bool isLoading = false;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isArabic ? "يرجى ملء جميع الحقول" : "Please fill all fields")));
      return;
    }
    setState(() => isLoading = true);
    try {
      UserCredential user = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (user.user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.user!.uid)
            .get();
        if (userDoc.exists) {
          String lang = userDoc.get('language') ?? 'ar';
          setState(() => isArabic = (lang == 'ar'));
        }
        if (!mounted) return;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const HomePage()));
      }
    } on FirebaseAuthException catch (e) {
      String msg = isArabic ? 'فشل الدخول: تأكد من البيانات' : 'Login failed: check your info';
      if (e.code == 'user-not-found') {
        msg = isArabic ? 'المستخدم غير موجود' : 'No user found';
      } else if (e.code == 'wrong-password') {
        msg = isArabic ? 'كلمة المرور خاطئة' : 'Wrong password';
      }
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
          Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFF0F9FF), Color(0xFFE0F2F1)])),
              child: Center(
                  child: SingleChildScrollView(
                      child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 30),
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 20,
                                    offset: Offset(0, 10))
                              ]),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.local_hospital_rounded,
                                size: 60, color: Color(0xFF00796B)),
                            Text(isArabic ? 'تطبيق شِفاء' : 'Shefa\'a App',
                                style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF004D40),
                                    letterSpacing: 1.2)),
                            Text(isArabic ? 'لحجز المواعيد الطبية' : 'Medical Appointments',
                                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                            const SizedBox(height: 40),
                            _buildTextField(
                                hint: isArabic ? 'البريد الإلكتروني' : 'Email',
                                controller: _emailController,
                                icon: Icons.email_outlined),
                            const SizedBox(height: 15),
                            _buildTextField(
                                hint: isArabic ? 'كلمة المرور' : 'Password',
                                isPassword: true,
                                controller: _passwordController,
                                icon: Icons.lock_outline),
                            const SizedBox(height: 25),
                            isLoading
                                ? const CircularProgressIndicator(color: Color(0xFF00796B))
                                : _buildButton(
                                text: isArabic ? 'دخول' : 'Login',
                                color: const Color(0xFF00796B),
                                onPressed: _login),
                            const SizedBox(height: 20),
                            _buildFooterLinks(), // هذا القسم تم تعديله
                          ]))))),
          Positioned(top: 50, right: 20, child: _buildLanguageMenu()),
        ]));
  }

  // الجزء المعدل لحذف زر "نسيت كلمة المرور"
  Widget _buildFooterLinks() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(
        isArabic ? 'ليس لديك حساب؟ ' : 'Don\'t have an account? ',
        style: TextStyle(color: Colors.grey[600], fontSize: 14),
      ),
      TextButton(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => const SignUpPage())),
          child: Text(isArabic ? 'إنشاء حساب' : 'Sign Up',
              style: const TextStyle(
                  color: Colors.teal, fontWeight: FontWeight.bold))),
    ]);
  }

  Widget _buildTextField(
      {required String hint,
        bool isPassword = false,
        required TextEditingController controller,
        required IconData icon}) {
    return Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: TextField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
                prefixIcon: Icon(icon, color: const Color(0xFF00796B)),
                hintText: hint,
                filled: true,
                fillColor: Colors.grey[50],
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.teal.shade50)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Color(0xFF00796B))))));
  }

  Widget _buildButton(
      {required String text,
        required Color color,
        required VoidCallback onPressed}) {
    return SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            child: Text(text,
                style: const TextStyle(fontSize: 18, color: Colors.white))));
  }

  Widget _buildLanguageMenu() {
    return PopupMenuButton<String>(
        icon: const Icon(Icons.language, color: Color(0xFF00796B), size: 30),
        onSelected: (val) => setState(() => isArabic = (val == 'ar')),
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'ar', child: Text("العربية 🇾🇪")),
          const PopupMenuItem(value: 'en', child: Text("English 🇺🇸"))
        ]);
  }
}