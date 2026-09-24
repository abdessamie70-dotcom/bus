import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/bus.dart';
import '../providers/fleet_provider.dart';

class FleetScreen extends StatefulWidget {
  const FleetScreen({super.key});

  @override
  State<FleetScreen> createState() => _FleetScreenState();
}

class _FleetScreenState extends State<FleetScreen> {
  bool _onlyBigBuses = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FleetProvider>(context);
    final numberFormatter = NumberFormat('#,###', 'ar');

    final busesList = _onlyBigBuses ? provider.bigBuses : provider.buses;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showAddBusDialog(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('إضافة حافلة جديدة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'إدارة ومتابعة أسطول الحافلات',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  Text(
                    'مؤسسة سويقات أبو طالب • إجمالي الحافلات: ${provider.buses.length}',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Filter bar
          Row(
            children: [
              FilterChip(
                label: const Text('كافة الحافلات'),
                selected: !_onlyBigBuses,
                onSelected: (val) => setState(() => _onlyBigBuses = false),
                selectedColor: const Color(0xFFEFF6FF),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: !_onlyBigBuses ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                  ),
                ),
                labelStyle: TextStyle(
                  color: !_onlyBigBuses ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('حافلات 50 مقعد فقط ★'),
                selected: _onlyBigBuses,
                onSelected: (val) => setState(() => _onlyBigBuses = true),
                selectedColor: const Color(0xFFFFFBEB),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: _onlyBigBuses ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0),
                  ),
                ),
                labelStyle: TextStyle(
                  color: _onlyBigBuses ? const Color(0xFFD97706) : const Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Buses Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: busesList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.25,
                ),
                itemBuilder: (context, index) {
                  final bus = busesList[index];
                  final driver = provider.getDriverById(bus.assignedDriverId ?? '');

                  Color statusBg = const Color(0xFFECFDF5);
                  Color statusBorder = const Color(0xFF10B981);
                  Color statusText = const Color(0xFF059669);

                  if (bus.status == BusStatus.onTrip) {
                    statusBg = const Color(0xFFEFF6FF);
                    statusBorder = const Color(0xFF2563EB);
                    statusText = const Color(0xFF2563EB);
                  } else if (bus.status == BusStatus.maintenance) {
                    statusBg = const Color(0xFFFEF2F2);
                    statusBorder = const Color(0xFFEF4444);
                    statusText = const Color(0xFFDC2626);
                  } else if (bus.status == BusStatus.inactive) {
                    statusBg = const Color(0xFFF1F5F9);
                    statusBorder = const Color(0xFFCBD5E1);
                    statusText = const Color(0xFF64748B);
                  }

                  return Container(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top row: Plate + Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: statusBorder),
                              ),
                              child: Text(
                                bus.statusText,
                                style: TextStyle(
                                  color: statusText,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFFDE68A)),
                              ),
                              child: Text(
                                bus.plateNumber,
                                style: const TextStyle(
                                  color: Color(0xFFB45309),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Bus Number & Model
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bus.busNumber,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              bus.model,
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                            ),
                          ],
                        ),

                        // Stats box (Capacity + Mileage)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text('سعة المقاعد',
                                      style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${bus.capacity} راكب ${bus.isBigBus ? "★" : ""}',
                                    style: const TextStyle(
                                      color: Color(0xFF2563EB),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Container(width: 1, height: 24, color: const Color(0xFFE2E8F0)),
                              Column(
                                children: [
                                  const Text('عداد المسافة',
                                      style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${numberFormatter.format(bus.currentMileage)} كم',
                                    style: const TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Assigned Driver
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            PopupMenuButton<BusStatus>(
                              icon: const Icon(Icons.more_vert, color: Color(0xFF64748B), size: 18),
                              color: Colors.white,
                              onSelected: (newStatus) {
                                provider.updateBus(bus.copyWith(status: newStatus));
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: BusStatus.active, child: Text('جاهزة للخدمة', style: TextStyle(color: Color(0xFF0F172A)))),
                                const PopupMenuItem(value: BusStatus.onTrip, child: Text('في رحلة حالياً', style: TextStyle(color: Color(0xFF0F172A)))),
                                const PopupMenuItem(value: BusStatus.maintenance, child: Text('صيانة دورية', style: TextStyle(color: Color(0xFF0F172A)))),
                                const PopupMenuItem(value: BusStatus.inactive, child: Text('متوقفة', style: TextStyle(color: Color(0xFF0F172A)))),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  driver != null ? driver.name : 'غير محدد',
                                  style: const TextStyle(color: Color(0xFF0F172A), fontSize: 12),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.person, color: Color(0xFF2563EB), size: 16),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddBusDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final numberCtrl = TextEditingController(text: 'حافلة جديدة');
    final plateCtrl = TextEditingController(text: '00551-124-16');
    final modelCtrl = TextEditingController(text: 'مرسيدس بينز 50 راكب');
    final capCtrl = TextEditingController(text: '50');
    final mileageCtrl = TextEditingController(text: '50000');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('إضافة حافلة جديدة للأسطول',
            style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: numberCtrl,
                style: const TextStyle(color: Color(0xFF0F172A)),
                decoration: const InputDecoration(labelText: 'اسم / رقم الحافلة'),
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              TextFormField(
                controller: plateCtrl,
                style: const TextStyle(color: Color(0xFF0F172A)),
                decoration: const InputDecoration(labelText: 'رقم اللوحة الترقيمية'),
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              TextFormField(
                controller: modelCtrl,
                style: const TextStyle(color: Color(0xFF0F172A)),
                decoration: const InputDecoration(labelText: 'النوع والموديل'),
              ),
              TextFormField(
                controller: capCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Color(0xFF0F172A)),
                decoration: const InputDecoration(labelText: 'سعة المقاعد (مثل 50)'),
              ),
              TextFormField(
                controller: mileageCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Color(0xFF0F172A)),
                decoration: const InputDecoration(labelText: 'عداد الكيلومتر الحالي'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: Color(0xFF64748B)))),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final provider = Provider.of<FleetProvider>(context, listen: false);
                provider.addBus(Bus(
                  id: 'bus_${DateTime.now().millisecondsSinceEpoch}',
                  busNumber: numberCtrl.text.trim(),
                  plateNumber: plateCtrl.text.trim(),
                  capacity: int.tryParse(capCtrl.text) ?? 50,
                  model: modelCtrl.text.trim(),
                  currentMileage: double.tryParse(mileageCtrl.text) ?? 0.0,
                  status: BusStatus.active,
                ));
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
