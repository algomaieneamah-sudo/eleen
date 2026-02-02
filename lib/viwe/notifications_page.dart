import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsPage extends StatelessWidget {
  final bool isArabic;
  const NotificationsPage({super.key, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? 'الإشعارات' : 'Notifications',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00796B),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // تأكدي أن اسم الكولكشن في فايربيز هو 'bookings'
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(isArabic ? "حدث خطأ في جلب البيانات" : "Error fetching data"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00796B)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  Text(isArabic ? 'لا توجد إشعارات حالياً' : 'No notifications yet'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;

              // --- معالجة أسماء الحقول لضمان عرض اسم الطبيب ---
              // يبحث الكود عن اسم الطبيب في عدة احتمالات للمسميات
              String doctorName = data['doctorName'] ??
                  data['doctor_name'] ??
                  data['name'] ??
                  (isArabic ? 'طبيب متخصص' : 'Specialist Doctor');

              String bookingType = data['bookingType'] ??
                  data['type'] ??
                  (isArabic ? 'كشف عام' : 'General Checkup');

              String time = data['time'] ?? '--:--';
              String date = data['date'] ?? '';

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.event_available, color: Color(0xFF00796B), size: 30),
                  ),
                  title: Text(
                    isArabic ? 'تأكيد الحجز' : 'Booking Confirmed',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF004D40)),
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic
                              ? 'تم تأكيد موعدك مع د. $doctorName'
                              : 'Confirmed appointment with Dr. $doctorName',
                          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                          textAlign: isArabic ? TextAlign.right : TextAlign.left,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isArabic
                              ? 'نوع الحجز: $bookingType\nالوقت: $time | التاريخ: $date'
                              : 'Type: $bookingType\nTime: $time | Date: $date',
                          style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.4),
                          textAlign: isArabic ? TextAlign.right : TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}