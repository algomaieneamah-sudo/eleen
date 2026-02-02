import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'viwe/home.dart';

class ConfirmPage extends StatefulWidget {
  final Map<String, String> bookingData;
  final bool isArabicInitial;

  const ConfirmPage({super.key, required this.bookingData, this.isArabicInitial = true});

  @override
  State<ConfirmPage> createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage> {
  late bool isArabic;

  // توحيد الألوان مع الصفحة الرئيسية وصفحة الحجز
  final Color primaryColor = const Color(0xFF00796B);
  final Color accentColor = const Color(0xFF004D40);

  @override
  void initState() {
    super.initState();
    isArabic = widget.isArabicInitial;
  }

  // دالة إرسال البيانات النهائية للفايربيز
  Future<void> _saveFinalBooking() async {
    // إظهار مؤشر تحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator(color: primaryColor)),
    );

    try {
      await FirebaseFirestore.instance.collection('bookings').add({
        ...widget.bookingData,
        'status': 'confirmed',
        'timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context); // إغلاق التحميل

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? 'تم حفظ الحجز بنجاح!' : 'Booking saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // العودة للرئيسية بعد الحفظ
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
              (route) => false,
        );
      });
    } catch (e) {
      Navigator.pop(context); // إغلاق التحميل
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isArabic ? 'خطأ في الحفظ' : 'Save Error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? 'تأكيد الحجز' : 'Confirm Booking',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Colors.white),
            onSelected: (val) => setState(() => isArabic = (val == 'ar')),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'ar', child: Text("العربية 🇾🇪")),
              const PopupMenuItem(value: 'en', child: Text("English 🇺🇸"))
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0F9FF), Color(0xFFE0F2F1)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.fact_check_rounded, size: 80, color: primaryColor),
              const SizedBox(height: 15),
              Text(
                isArabic ? 'الرجاء مراجعة بياناتك' : 'Please review your details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accentColor),
              ),
              const SizedBox(height: 20),

              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Directionality(
                    textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                    child: Column(
                      children: [
                        _buildInfoRow(isArabic ? 'اسم الطبيب' : 'Doctor', widget.bookingData['doctor']!),
                        _buildInfoRow(isArabic ? 'اسم المريض' : 'Patient', widget.bookingData['patientName']!),
                        _buildInfoRow(isArabic ? 'رقم الهاتف' : 'Phone', widget.bookingData['phone']!),
                        _buildInfoRow(isArabic ? 'التاريخ' : 'Date', widget.bookingData['date']!),
                        _buildInfoRow(isArabic ? 'الوقت' : 'Time', widget.bookingData['time']!),
                        const Divider(height: 30),
                        _buildInfoRow(isArabic ? 'الوصف' : 'Notes', widget.bookingData['description']!),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // أزرار العمليات
              _buildButton(
                text: isArabic ? 'تأكيد وحفظ في القاعدة' : 'Confirm & Save to DB',
                icon: Icons.cloud_done,
                color: primaryColor,
                onPressed: _saveFinalBooking,
              ),
              const SizedBox(height: 12),

              _buildButton(
                text: isArabic ? 'تعديل البيانات' : 'Edit Info',
                icon: Icons.edit_note,
                color: Colors.orange.shade800,
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 12),

              _buildButton(
                text: isArabic ? 'إلغاء والعودة للرئيسية' : 'Cancel & Go Home',
                icon: Icons.cancel_outlined,
                color: Colors.red.shade700,
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                        (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text("$label: ", style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 15)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 15, color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _buildButton({required String text, required IconData icon, required Color color, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}