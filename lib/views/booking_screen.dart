import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/booking.dart';
import '../models/bus.dart';
import '../providers/fleet_provider.dart';

class BookingScreen extends StatefulWidget {
  final VoidCallback? onNavigateToDashboard;

  const BookingScreen({
    super.key,
    this.onNavigateToDashboard,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedBusId;
  DateTime _selectedDate = DateTime(2026, 9, 24);
  int _seatsCount = 1;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2030, 12, 31),
      locale: const Locale('ar'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _handleBookingSubmit(FleetProvider provider, Bus selectedBus, int remainingSeats) {
    if (!_formKey.currentState!.validate()) return;

    if (remainingSeats < _seatsCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('عذراً، عدد المقاعد المطلوبة غير متوفر في هذه الحافلة.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    final newBooking = Booking(
      id: 'bok_${DateTime.now().millisecondsSinceEpoch}',
      bookingCode: 'BOK-2026-${provider.bookings.length + 101}',
      busId: selectedBus.id,
      busName: selectedBus.busNumber,
      route: selectedBus.busNumber,
      travelDate: _selectedDate,
      seatsCount: _seatsCount,
      passengerName: _nameController.text.trim(),
      passengerPhone: _phoneController.text.trim(),
      notes: _notesController.text.trim(),
      ticketPrice: 1500.0,
    );

    provider.addBooking(newBooking);

    // Show Confirmation Ticket Dialog
    _showTicketConfirmationDialog(context, newBooking, selectedBus);
  }

  void _showTicketConfirmationDialog(BuildContext context, Booking booking, Bus bus) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: 440,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Badge
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFBFDBFE), width: 2),
                ),
                child: const Icon(Icons.check_circle, size: 36, color: Color(0xFF2563EB)),
              ),
              const SizedBox(height: 12),
              const Text(
                'تم تأكيد الحجز بنجاح!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const Text(
                'مؤسسة سويقات أبو طالب للنقل والرحلات',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),

              // Ticket Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildTicketRow('رمز التذكرة الإلكترونية', booking.bookingCode, isBold: true, valueColor: const Color(0xFF2563EB)),
                    const Divider(height: 16),
                    _buildTicketRow('اسم المسافر', booking.passengerName),
                    const Divider(height: 16),
                    _buildTicketRow('رقم الهاتف', booking.passengerPhone),
                    const Divider(height: 16),
                    _buildTicketRow('الحافلة المخصصة', bus.busNumber),
                    const Divider(height: 16),
                    _buildTicketRow('تاريخ السفر', DateFormat('yyyy-MM-dd').format(booking.travelDate)),
                    const Divider(height: 16),
                    _buildTicketRow('عدد المقاعد المحجوزة', '${booking.seatsCount} مقعد'),
                    const Divider(height: 16),
                    _buildTicketRow('الإجمالي المستحق', '${booking.totalPrice.toStringAsFixed(0)} دج', isBold: true, valueColor: const Color(0xFF059669)),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('إغلاق'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('جاري إرسال التذكرة وطباعتها...'),
                            backgroundColor: Color(0xFF2563EB),
                          ),
                        );
                      },
                      icon: const Icon(Icons.print, size: 16),
                      label: const Text('طباعة التذكرة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FleetProvider>(context);
    final buses = provider.buses;

    if (buses.isNotEmpty && _selectedBusId == null) {
      _selectedBusId = buses.first.id;
    }

    final selectedBus = _selectedBusId != null
        ? provider.getBusById(_selectedBusId!) ?? (buses.isNotEmpty ? buses.first : null)
        : (buses.isNotEmpty ? buses.first : null);

    final bookedSeats = selectedBus != null
        ? provider.getBookedSeatsForBus(selectedBus.id, _selectedDate)
        : 0;

    final remainingSeats = selectedBus != null
        ? (selectedBus.capacity - bookedSeats).clamp(0, selectedBus.capacity)
        : 50;

    final isAvailable = remainingSeats >= _seatsCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. TOP HEADER (Matching the user photo top navigation)
              _buildTopHeader(context),

              // 2. HERO BLUE BANNER (Matching the user photo hero section)
              _buildHeroBanner(),

              // 3. MAIN BOOKING FORM CARD (بيانات حجز الرحلة)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 860),
                    child: _buildBookingFormCard(provider, selectedBus, remainingSeats, isAvailable),
                  ),
                ),
              ),

              // 4. FOOTER NOTE
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF1E3A8A),
        border: Border(bottom: BorderSide(color: Color(0xFF1D4ED8))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Admin Dashboard Button
          ElevatedButton.icon(
            onPressed: widget.onNavigateToDashboard,
            icon: const Icon(Icons.settings, size: 16),
            label: const Text('لوحة الإدارة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),

          // Center/Right: Brand Name & Subtitle
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'بوابة الحجز المباشر',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'مؤسسة سويقات أبو طالب',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'حجز مقاعد الحافلات وتأكيد التذاكر الإلكترونية',
                    style: TextStyle(color: Color(0xFFBFDBFE), fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.directions_bus, color: Colors.white, size: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: const Text(
              'خدمة النقل المنتظم والرحلات اليومية',
              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'احجز تذكرتك ومقعدك الآن بسهولة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'اختر خط الرحلة وتاريخ السفر، وسيقوم النظام بتأمين مقعدك تلقائياً في الحافلة المتاحة. في حالة امتلاء الحافلة الأولى، يتم تحويل الحجز فورياً للحافلة التالية!',
            style: TextStyle(
              color: Color(0xFFDBEAFE),
              fontSize: 13,
              height: 1.5,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingFormCard(FleetProvider provider, Bus? selectedBus, int remainingSeats, bool isAvailable) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title: بيانات حجز الرحلة
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'بيانات حجز الرحلة',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.description_outlined, size: 20, color: Color(0xFF2563EB)),
              ],
            ),
            const SizedBox(height: 18),

            // Field 1: مسار الرحلة / الخط
            const Text(
              'مسار الرحلة / الخط: *',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedBusId,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF2563EB)),
                  style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13),
                  items: provider.buses.map((b) {
                    return DropdownMenuItem(
                      value: b.id,
                      child: Text(
                        b.busNumber,
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedBusId = val),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Availability Status Card (Matching the green banner in the photo)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isAvailable ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isAvailable ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAvailable ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isAvailable ? const Color(0xFF6EE7B7) : const Color(0xFFFCA5A5),
                      ),
                    ),
                    child: Text(
                      isAvailable ? 'حجز مؤكد' : 'الحافلة ممتلئة',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isAvailable ? const Color(0xFF047857) : const Color(0xFFB91C1C),
                      ),
                    ),
                  ),

                  // Info Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              isAvailable
                                  ? 'مقاعد متوفرة في الحافلة الأساسية (${selectedBus?.busNumber.split(' ').last ?? '12'})'
                                  : 'المقاعد غير متوفرة',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isAvailable ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: isAvailable ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'الحافلة جاهزة - المتبقي: $remainingSeats من أصل ${selectedBus?.capacity ?? 50} مقعد',
                          style: TextStyle(
                            fontSize: 11,
                            color: isAvailable ? const Color(0xFF047857) : const Color(0xFF991B1B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Row: تاريخ الرحلة & عدد المقاعد المطلوبة
            Row(
              children: [
                // تاريخ الرحلة
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'تاريخ الرحلة: *',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () => _selectDate(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(Icons.calendar_today, size: 18, color: Color(0xFF2563EB)),
                              Text(
                                DateFormat('yyyy/MM/dd').format(_selectedDate),
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                // عدد المقاعد المطلوبة
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'عدد المقاعد المطلوبة: *',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _seatsCount,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF2563EB)),
                            style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13),
                            items: const [
                              DropdownMenuItem(value: 1, child: Text('مقعد واحد (1)', textAlign: TextAlign.right)),
                              DropdownMenuItem(value: 2, child: Text('مقعدان (2)', textAlign: TextAlign.right)),
                              DropdownMenuItem(value: 3, child: Text('3 مقاعد (3)', textAlign: TextAlign.right)),
                              DropdownMenuItem(value: 4, child: Text('4 مقاعد (4)', textAlign: TextAlign.right)),
                              DropdownMenuItem(value: 5, child: Text('5 مقاعد (5)', textAlign: TextAlign.right)),
                            ],
                            onChanged: (val) => setState(() => _seatsCount = val ?? 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Row: اسم المسافر الكامل & رقم الهاتف للتواصل
            Row(
              children: [
                // رقم الهاتف
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'رقم الهاتف للتواصل: *',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _phoneController,
                        textAlign: TextAlign.right,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: '0550 12 34 56',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال رقم الهاتف';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                // اسم المسافر الكامل
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'اسم المسافر الكامل: *',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: 'الاسم واللقب',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال اسم المسافر';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Field: ملاحظات إضافية أو مكان الصعود (اختياري)
            const Text(
              'ملاحظات إضافية أو مكان الصعود (اختياري):',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _notesController,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
              decoration: InputDecoration(
                hintText: 'مثال: نقطة الصعود عند مفترق الطرق المركزي',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // CONFIRMATION BUTTON (Matching the big blue button in the user photo)
            ElevatedButton(
              onPressed: isAvailable && selectedBus != null
                  ? () => _handleBookingSubmit(provider, selectedBus, remainingSeats)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF94A3B8),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 3,
                shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'تأكيد الحجز في الحافلة (${selectedBus?.busNumber.split(' ').last ?? '12'})',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.confirmation_number_outlined, size: 20),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Footnote
            const Text(
              '* يتم حجز المقعد فورياً وحفظه في سجل رحلات مؤسسة سويقات أبو طالب',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      child: const Text(
        'نظام الحجز الذكي • مؤسسة سويقات أبو طالب للنقل ، جميع الحقوق محفوظة © 2026',
        style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
      ),
    );
  }
}
