import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../providers/fleet_provider.dart';

class RecordTripDialog extends StatefulWidget {
  const RecordTripDialog({super.key});

  @override
  State<RecordTripDialog> createState() => _RecordTripDialogState();
}

class _RecordTripDialogState extends State<RecordTripDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedBusId;
  String? _selectedDriverId;
  final _routeNameController = TextEditingController(text: 'الجزائر العاصمة ⟵ وهران');
  final _passengerCountController = TextEditingController(text: '48');
  final _revenueController = TextEditingController(text: '72000');
  final _overtimePayController = TextEditingController(text: '1500');
  final _startMileageController = TextEditingController();
  final _endMileageController = TextEditingController();
  final _notesController = TextEditingController();

  final DateTime _selectedDate = DateTime.now();
  final TimeOfDay _departureTime = const TimeOfDay(hour: 7, minute: 0);
  final TimeOfDay _arrivalTime = const TimeOfDay(hour: 12, minute: 30);
  TripStatus _status = TripStatus.completed;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<FleetProvider>(context, listen: false);
    if (provider.buses.isNotEmpty) {
      _selectedBusId = provider.buses.first.id;
      final bus = provider.buses.first;
      _startMileageController.text = bus.currentMileage.toInt().toString();
      _endMileageController.text = (bus.currentMileage + 420).toInt().toString();
      if (bus.assignedDriverId != null) {
        _selectedDriverId = bus.assignedDriverId;
      }
    }
    if (_selectedDriverId == null && provider.drivers.isNotEmpty) {
      _selectedDriverId = provider.drivers.first.id;
    }
  }

  @override
  void dispose() {
    _routeNameController.dispose();
    _passengerCountController.dispose();
    _revenueController.dispose();
    _overtimePayController.dispose();
    _startMileageController.dispose();
    _endMileageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onBusChanged(String? busId) {
    if (busId == null) return;
    final provider = Provider.of<FleetProvider>(context, listen: false);
    final bus = provider.getBusById(busId);
    setState(() {
      _selectedBusId = busId;
      if (bus != null) {
        _startMileageController.text = bus.currentMileage.toInt().toString();
        _endMileageController.text = (bus.currentMileage + 350).toInt().toString();
        if (bus.assignedDriverId != null) {
          _selectedDriverId = bus.assignedDriverId;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FleetProvider>(context);
    final bus = _selectedBusId != null ? provider.getBusById(_selectedBusId!) : null;
    final capacity = bus?.capacity ?? 50;
    final passengers = int.tryParse(_passengerCountController.text) ?? 0;
    final occupancy = capacity > 0 ? (passengers / capacity) * 100 : 0.0;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header (Blue and White Theme)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Row(
                      children: [
                        Text(
                          'تسجيل رحلة جديدة بالأسطول',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.alt_route_rounded, color: Color(0xFF2563EB)),
                      ],
                    ),
                  ],
                ),
                const Divider(color: Color(0xFFE2E8F0), height: 24),

                // Bus and Driver selection
                Row(
                  children: [
                    // Bus
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('الحافلة المخصصة',
                              style: TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedBusId,
                            dropdownColor: Colors.white,
                            style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
                            decoration: _inputDecoration(),
                            items: provider.buses.map((b) {
                              return DropdownMenuItem(
                                value: b.id,
                                child: Text('${b.busNumber} (${b.capacity} راكب)'),
                              );
                            }).toList(),
                            onChanged: _onBusChanged,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Driver
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('السائق المسؤول',
                              style: TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedDriverId,
                            dropdownColor: Colors.white,
                            style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
                            decoration: _inputDecoration(),
                            items: provider.drivers.map((d) {
                              return DropdownMenuItem(
                                value: d.id,
                                child: Text(d.name),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedDriverId = val),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Route name
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('خط السير / المسار',
                        style: TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _routeNameController,
                      style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
                      decoration: _inputDecoration(
                        hintText: 'مثال: الجزائر العاصمة ⟵ وهران (محطة الخروبة)',
                        prefixIcon: const Icon(Icons.route, color: Color(0xFF2563EB), size: 18),
                      ),
                      validator: (val) =>
                          (val == null || val.isEmpty) ? 'يرجى إدخال اسم المسار' : null,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Passengers & Occupancy Preview
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('عدد الركاب (السعة: $capacity راكب)',
                              style: const TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passengerCountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
                            decoration: _inputDecoration(
                              prefixIcon:
                                  const Icon(Icons.people_alt, color: Color(0xFF2563EB), size: 18),
                            ),
                            onChanged: (_) => setState(() {}),
                            validator: (val) =>
                                (val == null || val.isEmpty) ? 'أدخل عدد الركاب' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Occupancy Badge
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (occupancy >= 80
                                  ? const Color(0xFFECFDF5)
                                  : const Color(0xFFFFFBEB)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: occupancy >= 80
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF59E0B),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text('نسبة الامتلاء والإشغال',
                                style: TextStyle(color: Color(0xFF475569), fontSize: 11)),
                            const SizedBox(height: 4),
                            Text(
                              '${occupancy.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: occupancy >= 80
                                    ? const Color(0xFF059669)
                                    : const Color(0xFFD97706),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Financials: Revenue & Overtime Pay (تم حذف الوقود واستبداله بأجر إضافي)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('إجمالي إيراد التذاكر (دج)',
                              style: TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _revenueController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold),
                            decoration: _inputDecoration(
                              prefixIcon: const Icon(Icons.monetization_on_rounded,
                                  color: Color(0xFF059669), size: 18),
                            ),
                            validator: (val) =>
                                (val == null || val.isEmpty) ? 'أدخل الإيراد' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('أجر إضافي للسائق (دج)',
                              style: TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _overtimePayController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                            decoration: _inputDecoration(
                              prefixIcon: const Icon(Icons.more_time_rounded,
                                  color: Color(0xFF2563EB), size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Odometer (Start / End)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('عداد الانطلاق (كم)',
                              style: TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _startMileageController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Color(0xFF0F172A)),
                            decoration: _inputDecoration(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('عداد الوصول (كم)',
                              style: TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _endMileageController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Color(0xFF0F172A)),
                            decoration: _inputDecoration(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('حالة الرحلة',
                        style: TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<TripStatus>(
                      initialValue: _status,
                      dropdownColor: Colors.white,
                      style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
                      decoration: _inputDecoration(),
                      items: TripStatus.values.map((s) {
                        String label = 'مكتملة';
                        if (s == TripStatus.inProgress) label = 'جارية حالياً';
                        if (s == TripStatus.scheduled) label = 'مجدولة';
                        if (s == TripStatus.cancelled) label = 'ملغاة';
                        return DropdownMenuItem(value: s, child: Text(label));
                      }).toList(),
                      onChanged: (val) => setState(() => _status = val ?? _status),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _submit(provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('حفظ وتأكيد تسجيل الرحلة'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText, Widget? prefixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.8),
      ),
    );
  }

  void _submit(FleetProvider provider) {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBusId == null || _selectedDriverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تحديد الحافلة والسائق')),
      );
      return;
    }

    final newTrip = Trip(
      id: 'trp_${DateTime.now().millisecondsSinceEpoch}',
      tripCode: 'TRP-${(provider.trips.length + 101)}',
      busId: _selectedBusId!,
      driverId: _selectedDriverId!,
      routeName: _routeNameController.text.trim(),
      date: _selectedDate,
      departureTime: '${_departureTime.hour.toString().padLeft(2, '0')}:${_departureTime.minute.toString().padLeft(2, '0')}',
      arrivalTime: '${_arrivalTime.hour.toString().padLeft(2, '0')}:${_arrivalTime.minute.toString().padLeft(2, '0')}',
      passengerCount: int.tryParse(_passengerCountController.text) ?? 0,
      revenueDzd: double.tryParse(_revenueController.text) ?? 0.0,
      overtimePayDzd: double.tryParse(_overtimePayController.text) ?? 0.0,
      startMileage: double.tryParse(_startMileageController.text) ?? 0.0,
      endMileage: double.tryParse(_endMileageController.text) ?? 0.0,
      status: _status,
      notes: _notesController.text.trim(),
    );

    provider.addTrip(newTrip);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تسجيل الرحلة (${newTrip.tripCode}) بنجاح!'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }
}
