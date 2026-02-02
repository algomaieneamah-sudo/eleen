import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'booking.dart';
import 'notifications_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isArabic = true;

  final Color primaryColor = const Color(0xFF00796B);
  final Color accentColor = const Color(0xFF004D40);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      // هذا السطر يقوم بقلب اتجاه التطبيق كاملاً بناءً على اللغة
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isArabic ? 'أطباء شِفاء' : 'Shefa Doctors',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: primaryColor,
          centerTitle: true,
          actions: [
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_active, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationsPage(isArabic: isArabic),
                      ),
                    );
                  },
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                    constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                  ),
                )
              ],
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.language, color: Colors.white),
              onSelected: (val) => setState(() => isArabic = (val == 'ar')),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'ar', child: Text("العربية 🇾🇪")),
                const PopupMenuItem(value: 'en', child: Text("English 🇺🇸")),
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
          child: StreamBuilder<QuerySnapshot>(
            // ملاحظة: تأكد أن اسم المجموعة 'dectors' مطابق لما في الفايربيس
            stream: FirebaseFirestore.instance.collection('dectors').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text(isArabic ? "خطأ في الاتصال" : "Connection Error"));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: primaryColor));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text(isArabic ? "لا يوجد أطباء مضافين حالياً" : "No doctors found"));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var doc = snapshot.data!.docs[index];
                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

                  // منطق اختيار البيانات بناءً على اللغة المتوفرة في Firebase
                  Map<String, String> doctorData = {
                    'id': doc.id,
                    'name': isArabic
                        ? (data['name']?.toString() ?? '')
                        : (data['name_en']?.toString() ?? data['name']?.toString() ?? ''),
                    'specialty': isArabic
                        ? (data['specialty']?.toString() ?? '')
                        : (data['specialty_en']?.toString() ?? data['specialty']?.toString() ?? ''),
                    'location': isArabic
                        ? (data['location']?.toString() ?? '')
                        : (data['location_en']?.toString() ?? data['location']?.toString() ?? ''),
                    'phone': data['phone']?.toString() ?? '',
                  };

                  return _buildDoctorCard(context, doctorData);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, Map<String, String> doctor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          // التموضع سيتغير تلقائياً بسبب وجود Directionality في الأعلى
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              doctor['name']!,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: accentColor),
            ),
            const SizedBox(height: 5),
            Text(
              doctor['specialty']!,
              style: TextStyle(color: Colors.grey[700], fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Divider(height: 25, thickness: 1),

            Row(
              children: [
                Icon(Icons.phone, size: 18, color: primaryColor),
                const SizedBox(width: 8),
                Text(doctor['phone']!, style: const TextStyle(fontSize: 14, color: Colors.black87)),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Icon(Icons.location_on, size: 18, color: primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    doctor['location']!,
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingPage(doctorData: doctor, isArabic: isArabic),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                child: Text(
                  isArabic ? 'حجز موعد الآن' : 'Book Now',
                  style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}