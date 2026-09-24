import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/attendance.dart';
import '../models/driver.dart';
import '../providers/fleet_provider.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String? _selectedDriverId;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FleetProvider>(context);

    if (provider.drivers.isNotEmpty && _selectedDriverId == null) {
      _selectedDriverId = provider.drivers.first.id;
    }

    final driver = _selectedDriverId != null ? provider.getDriverById(_selectedDriverId!) : null;
    final driverAttendance = _selectedDriverId != null ? provider.getAttendanceForDriver(_selectedDriverId!) : [];

    // Calculate month stats (حضور، راحة دورية، غياب، ساعات إضافية)
    int presentCount = 0;
    int restCount = 0;
    int absentCount = 0;
    double totalOvertime = 0.0;

    for (final att in driverAttendance) {
      if (att.date.year == _focusedDay.year && att.date.month == _focusedDay.month) {
        if (att.status == AttendanceStatus.present) presentCount++;
        if (att.status == AttendanceStatus.rest) restCount++;
        if (att.status == AttendanceStatus.absent) absentCount++;
        totalOvertime += att.overtimeHours;
      }
    }

    final selectedRecord = (_selectedDay != null && _selectedDriverId != null)
        ? provider.getAttendanceForDriverDate(_selectedDriverId!, _selectedDay!)
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Action buttons
              Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // زر الملء التلقائي لطريقة العمل
                  ElevatedButton.icon(
                    onPressed: () {
                      provider.autoFillAttendanceForMonth(
                        month: _focusedDay.month,
                        year: _focusedDay.year,
                        specificDriverId: _selectedDriverId,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('تم الملء التلقائي للتقويم وفق نظام (${provider.defaultShiftPattern.title}) بنجاح!'),
                          backgroundColor: const Color(0xFF2563EB),
                        ),
                      );
                    },
                    icon: const Icon(Icons.auto_awesome, size: 16),
                    label: const Text('الملء التلقائي لطريقة العمل'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),

              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'تقويم حضور ومناوبات السائقين',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  Text(
                    'متابعة أيام العمل وجدول الراحة بموجب طريقة العمل المعتمدة',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // قائمة السائقين للاختيار السريع في خيار التقويم
          _buildDriversListSelector(provider),

          const SizedBox(height: 16),

          // Monthly Stats Cards (حضور، راحة دورية، غياب، إضافي - تم حذف التأخيرات)
          Row(
            children: [
              Expanded(
                child: _buildAttendanceStatCard(
                  title: 'أيام العمل (حضور)',
                  value: '$presentCount يوم',
                  color: const Color(0xFF059669),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildAttendanceStatCard(
                  title: 'أيام الراحة الدورية',
                  value: '$restCount يوم',
                  color: const Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildAttendanceStatCard(
                  title: 'أيام الغياب',
                  value: '$absentCount يوم',
                  color: const Color(0xFFEF4444),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildAttendanceStatCard(
                  title: 'ساعات إضافية',
                  value: '${totalOvertime.toStringAsFixed(1)} س',
                  color: const Color(0xFF2563EB),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Calendar & Day Detail Container
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 750;

              final calendarWidget = Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E3A8A).withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: TableCalendar(
                  firstDay: DateTime.utc(2025, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  startingDayOfWeek: StartingDayOfWeek.saturday,
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
                    weekendTextStyle: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600),
                    outsideTextStyle: const TextStyle(color: Color(0xFFCBD5E1)),
                    todayDecoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF2563EB)),
                    ),
                    todayTextStyle: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                    selectedDecoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold),
                    leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF2563EB)),
                    rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF2563EB)),
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      if (_selectedDriverId == null) return null;
                      final record = provider.getAttendanceForDriverDate(_selectedDriverId!, day);
                      if (record == null) return null;

                      Color dotColor = const Color(0xFF10B981); // عمل
                      if (record.status == AttendanceStatus.rest) dotColor = const Color(0xFF818CF8); // راحة
                      if (record.status == AttendanceStatus.absent) dotColor = const Color(0xFFEF4444); // غياب
                      if (record.status == AttendanceStatus.leave) dotColor = const Color(0xFF2563EB); // إجازة

                      return Positioned(
                        bottom: 4,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                        ),
                      );
                    },
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                ),
              );

              final dayDetailWidget = Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E3A8A).withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'سجل يوم: ${_selectedDay != null ? DateFormat('yyyy/MM/dd').format(_selectedDay!) : ""}',
                      style: const TextStyle(color: Color(0xFF0F172A), fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'السائق: ${driver?.name ?? "اختر سائق"}',
                      style: const TextStyle(color: Color(0xFF2563EB), fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const Divider(color: Color(0xFFE2E8F0), height: 24),

                    if (selectedRecord != null) ...[
                      _buildDetailRow('الحالة المسجلة', selectedRecord.statusText),
                      if (selectedRecord.status == AttendanceStatus.present) ...[
                        _buildDetailRow('وقت الحضور', selectedRecord.checkInTime.isNotEmpty ? selectedRecord.checkInTime : '07:00'),
                        _buildDetailRow('وقت الانصراف', selectedRecord.checkOutTime.isNotEmpty ? selectedRecord.checkOutTime : '16:00'),
                        _buildDetailRow('ساعات العمل', '${selectedRecord.workingHours} ساعة'),
                        _buildDetailRow('ساعات إضافية', '${selectedRecord.overtimeHours} ساعة'),
                      ],
                      if (selectedRecord.notes.isNotEmpty)
                        _buildDetailRow('ملاحظات المناوبة', selectedRecord.notes),
                    ] else ...[
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'لم يتم تحديد حالة لهذا اليوم. يمكنك استخدام زر الملء التلقائي.',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showMarkAttendanceDialog(context, provider),
                      icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                      label: Text(selectedRecord != null ? 'تعديل حالة اليوم' : 'تسجيل حالة اليوم'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: calendarWidget),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: dayDetailWidget),
                  ],
                );
              } else {
                return Column(
                  children: [
                    calendarWidget,
                    const SizedBox(height: 16),
                    dayDetailWidget,
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStatCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13)),
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
        ],
      ),
    );
  }

  void _showMarkAttendanceDialog(BuildContext context, FleetProvider provider) {
    if (_selectedDriverId == null || _selectedDay == null) return;

    AttendanceStatus status = AttendanceStatus.present;
    final inTimeCtrl = TextEditingController(text: '07:00');
    final outTimeCtrl = TextEditingController(text: '16:00');
    final overtimeCtrl = TextEditingController(text: '0.0');

    final existing = provider.getAttendanceForDriverDate(_selectedDriverId!, _selectedDay!);
    if (existing != null) {
      status = existing.status;
      if (existing.checkInTime.isNotEmpty) inTimeCtrl.text = existing.checkInTime;
      if (existing.checkOutTime.isNotEmpty) outTimeCtrl.text = existing.checkOutTime;
      overtimeCtrl.text = existing.overtimeHours.toString();
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('تسجيل حالة السائق', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<AttendanceStatus>(
                initialValue: status,
                dropdownColor: Colors.white,
                style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
                decoration: const InputDecoration(labelText: 'الحالة'),
                items: const [
                  DropdownMenuItem(value: AttendanceStatus.present, child: Text('عمل (حاضر بالخدمة)')),
                  DropdownMenuItem(value: AttendanceStatus.rest, child: Text('راحة دورية (عطلة بموجب المناوبة)')),
                  DropdownMenuItem(value: AttendanceStatus.absent, child: Text('غائب (بدون عذر)')),
                  DropdownMenuItem(value: AttendanceStatus.leave, child: Text('إجازة رسمية / مرضية')),
                ],
                onChanged: (val) => setDialogState(() => status = val ?? status),
              ),
              const SizedBox(height: 10),
              if (status == AttendanceStatus.present) ...[
                TextField(
                  controller: inTimeCtrl,
                  style: const TextStyle(color: Color(0xFF0F172A)),
                  decoration: const InputDecoration(labelText: 'وقت الحضور'),
                ),
                TextField(
                  controller: outTimeCtrl,
                  style: const TextStyle(color: Color(0xFF0F172A)),
                  decoration: const InputDecoration(labelText: 'وقت الانصراف'),
                ),
                TextField(
                  controller: overtimeCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Color(0xFF0F172A)),
                  decoration: const InputDecoration(labelText: 'ساعات العمل الإضافية (س)'),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: Color(0xFF64748B)))),
            ElevatedButton(
              onPressed: () {
                provider.markAttendance(
                  driverId: _selectedDriverId!,
                  date: _selectedDay!,
                  status: status,
                  checkInTime: inTimeCtrl.text.trim(),
                  checkOutTime: outTimeCtrl.text.trim(),
                  overtimeHours: double.tryParse(overtimeCtrl.text) ?? 0.0,
                  notes: status == AttendanceStatus.rest ? 'راحة دورية' : '',
                );
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriversListSelector(FleetProvider provider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Text(
                  '${provider.drivers.length} سائقين مسجلين',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ),
              const Row(
                children: [
                  Text(
                    'اختر السائق لعرض وتعديل تقويمه:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.badge_outlined, size: 18, color: Color(0xFF2563EB)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: provider.drivers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final d = provider.drivers[index];
                final isSelected = d.id == _selectedDriverId;
                final assignedBus = provider.buses.where((b) => b.assignedDriverId == d.id).firstOrNull;

                return InkWell(
                  onTap: () => setState(() => _selectedDriverId = d.id),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF1D4ED8) : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: isSelected ? Colors.white : const Color(0xFFEFF6FF),
                          child: Icon(
                            Icons.person,
                            size: 20,
                            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF1D4ED8),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              d.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              assignedBus != null ? assignedBus.name : d.licenseNumber,
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected ? const Color(0xFFDBEAFE) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.check_circle, size: 16, color: Colors.white),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
