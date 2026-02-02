import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../confirmation.dart';

class BookingPage extends StatefulWidget {
  final Map<String, String> doctorData;
  final bool isArabic;

  const BookingPage({super.key, required this.doctorData, required this.isArabic});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late bool isAr;
  DateTime selectedDate = DateTime.now();
  String? selectedTime;
  String? visitType; // هذا المتغير هو الذي سيحمل القيمة المختارة

  final Color primaryColor = const Color(0xFF00796B);
  final Color accentColor = const Color(0xFF004D40);

  final List<String> timeSlotsAr = ['09:00 صباحاً', '10:30 صباحاً', '04:00 مساءً', '06:30 مساءً'];
  final List<String> timeSlotsEn = ['09:00 AM', '10:30 AM', '04:00 PM', '06:30 PM'];

  final List<String> visitTypesAr = ['كشف جديد', 'مراجعة', 'استشارة'];
  final List<String> visitTypesEn = ['New Visit', 'Follow-up', 'Consultation'];

  @override
  void initState() {
    super.initState();
    isAr = widget.isArabic;
  }

  void _clearData() {
    setState(() {
      _nameController.clear();
      _phoneController.clear();
      _ageController.clear();
      _descriptionController.clear();
      selectedTime = null;
      visitType = null;
      selectedDate = DateTime.now();
    });
  }

  Future<void> _saveToFirebase() async {
    await FirebaseFirestore.instance.collection('bookings').add({
      'doctor_name': widget.doctorData['name'],
      'patient_name': _nameController.text,
      'phone': _phoneController.text,
      'age': _ageController.text,
      'date': "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}",
      'time': selectedTime,
      'visit_type': visitType, // التأكد من إرسال المتغير المحدث
      'description': _descriptionController.text.isEmpty ? "No description" : _descriptionController.text,
      'created_at': FieldValue.serverTimestamp(),
      'status': 'pending'
    });
  }

  void _confirmBooking() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty || _ageController.text.isEmpty || selectedTime == null || visitType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAr ? 'الرجاء إكمال كافة البيانات!' : 'Please complete all fields!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator(color: primaryColor)),
    );

    try {
      await _saveToFirebase();
      if (!mounted) return;
      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmPage(
            isArabicInitial: isAr,
            bookingData: {
              'doctor': widget.doctorData['name']!,
              'patientName': _nameController.text,
              'phone': _phoneController.text,
              'age': _ageController.text,
              'date': "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}",
              'time': selectedTime!,
              'visitType': visitType!,
              'description': _descriptionController.text,
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'إدخال بيانات الحجز' : 'Booking Entry', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildDoctorCard(),
              const SizedBox(height: 25),
              _buildSectionTitle(isAr ? 'معلومات المريض' : 'Patient Information'),
              _buildInputContainer(
                child: Column(
                  children: [
                    _buildTextField(hint: isAr ? 'اسم المريض' : 'Patient Name', icon: Icons.person_outline, controller: _nameController),
                    _buildTextField(hint: isAr ? 'رقم الهاتف' : 'Phone Number', icon: Icons.phone_android, type: TextInputType.phone, controller: _phoneController),
                    _buildTextField(hint: isAr ? 'العمر' : 'Age', icon: Icons.calendar_month, type: TextInputType.number, controller: _ageController),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              _buildSectionTitle(isAr ? 'تفاصيل الموعد' : 'Appointment Details'),
              _buildInputContainer(
                child: Column(
                  children: [
                    ListTile(
                      title: Text("${isAr ? 'تاريخ الحجز' : 'Date'}: ${selectedDate.year}-${selectedDate.month}-${selectedDate.day}"),
                      trailing: Icon(Icons.event_available, color: primaryColor),
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2027),
                        );
                        if (picked != null) setState(() => selectedDate = picked);
                      },
                    ),
                    const Divider(height: 1),
                    // هنا تم تصحيح ربط القيمة المباشرة لضمان التحديث
                    _buildDropdown(
                        hint: isAr ? 'الوقت المتاح' : 'Available Time',
                        items: isAr ? timeSlotsAr : timeSlotsEn,
                        value: selectedTime,
                        onChanged: (newValue) {
                          setState(() {
                            selectedTime = newValue;
                          });
                        }
                    ),
                    const Divider(height: 1),
                    // تم التأكد من أن visitType يحصل على القيمة الصحيحة هنا
                    _buildDropdown(
                        hint: isAr ? 'نوع الزيارة' : 'Visit Type',
                        items: isAr ? visitTypesAr : visitTypesEn,
                        value: visitType,
                        onChanged: (newValue) {
                          setState(() {
                            visitType = newValue;
                          });
                        }
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 35),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  // أزرار الحفظ والمسح
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _clearData,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(isAr ? 'مسح' : 'Clear', style: const TextStyle(color: Colors.red)),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _confirmBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(isAr ? 'تأكيد الحجز' : 'Confirm', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // ويدجت مساعدة (بدون تغيير)
  Widget _buildDoctorCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(backgroundColor: primaryColor, child: const Icon(Icons.local_hospital, color: Colors.white)),
        title: Text(widget.doctorData['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${widget.doctorData['specialty']} - ${widget.doctorData['location']}"),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
        child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: accentColor)),
      ),
    );
  }

  Widget _buildInputContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: child,
    );
  }

  Widget _buildTextField({required String hint, required IconData icon, TextInputType type = TextInputType.text, required TextEditingController controller}) {
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: primaryColor), border: InputBorder.none, contentPadding: const EdgeInsets.all(15)),
      ),
    );
  }

  Widget _buildDropdown({required String hint, required List<String> items, String? value, required ValueChanged<String?> onChanged}) {
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Padding(padding: const EdgeInsets.symmetric(horizontal: 15), child: Text(hint)),
          value: value,
          icon: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Icon(Icons.arrow_drop_down, color: primaryColor)),
          items: items.map((String item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}