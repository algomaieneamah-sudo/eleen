import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}
class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isArabic = true;
  bool isLoading = false;
  Future<void> _signUp() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;
    setState(() => isLoading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'age': _ageController.text.trim(),
        'phone': _phoneController.text.trim(),
        'language': isArabic ? 'ar' : 'en',
        'createdAt': DateTime.now(),
      });
      if (!mounted) return;
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String msg = isArabic ? 'حدث خطأ ما' : 'Error occurred';
      if (e.code == 'email-already-in-use') msg = isArabic ? 'البريد مستخدم بالفعل' : 'Email already in use';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    } finally {
      setState(() => isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(width: double.infinity, decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFF0F9FF), Color(0xFFE0F2F1)])),
            child: Stack(children: [
              Center(child: SingleChildScrollView(padding: const EdgeInsets.symmetric(vertical: 40), child: Container(margin: const EdgeInsets.symmetric(horizontal: 25), padding: const EdgeInsets.all(25), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 8))]),
                  child: Column(children: [
                    const Icon(Icons.person_add_rounded, size: 50, color: Color(0xFF00796B)),
                    Text(isArabic ? 'إنشاء حساب جديد' : 'Create New Account', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF004D40))),
                    const SizedBox(height: 25),
                    _buildSignUpField(hint: isArabic ? 'الاسم الكامل' : 'Full Name', icon: Icons.person_outline, controller: _nameController),
                    _buildSignUpField(hint: isArabic ? 'البريد الإلكتروني' : 'Email Address', icon: Icons.email_outlined, controller: _emailController, keyboardType: TextInputType.emailAddress),
                    _buildSignUpField(hint: isArabic ? 'العمر' : 'Age', icon: Icons.calendar_today_outlined, controller: _ageController, keyboardType: TextInputType.number),
                    _buildSignUpField(hint: isArabic ? 'رقم الهاتف' : 'Phone Number', icon: Icons.phone_android_outlined, controller: _phoneController, keyboardType: TextInputType.phone),
                    _buildSignUpField(hint: isArabic ? 'كلمة المرور' : 'Password', icon: Icons.lock_outline, controller: _passwordController, isPassword: true),
                    const SizedBox(height: 20),
                    isLoading ? const CircularProgressIndicator() : SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: _signUp, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00796B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))), child: Text(isArabic ? 'إنشاء الحساب' : 'Create Account', style: const TextStyle(fontSize: 18, color: Colors.white)))),
                    TextButton(onPressed: () => Navigator.pop(context), child: Text(isArabic ? 'لديك حساب بالفعل؟ سجل دخولك' : 'Already have an account? Login', style: const TextStyle(color: Colors.blueGrey))),
                  ])))),
              Positioned(top: 50, right: isArabic ? 20 : null, left: isArabic ? null : 20, child: _buildLanguageMenu()),
            ])));
  }
  Widget _buildLanguageMenu() {
    return PopupMenuButton<String>(icon: const Icon(Icons.language, color: Color(0xFF00796B), size: 30), onSelected: (val) => setState(() => isArabic = (val == 'ar')), itemBuilder: (context) => [const PopupMenuItem(value: 'ar', child: Text("العربية 🇾🇪")), const PopupMenuItem(value: 'en', child: Text("English 🇺🇸"))]);
  }
  Widget _buildSignUpField({required String hint, required IconData icon, required TextEditingController controller, bool isPassword = false, TextInputType keyboardType = TextInputType.text}) {
    return Padding(padding: const EdgeInsets.only(bottom: 15), child: Directionality(textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr, child: TextField(controller: controller, obscureText: isPassword, keyboardType: keyboardType, decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: const Color(0xFF00796B)), filled: true, fillColor: Colors.grey[50], border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)))));
  }
}