import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../providers/fleet_provider.dart';
import '../widgets/record_trip_dialog.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  String _searchQuery = '';
  TripStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FleetProvider>(context);
    final currencyFormatter = NumberFormat('#,###', 'ar');

    final filteredTrips = provider.trips.where((t) {
      final bus = provider.getBusById(t.busId);
      final driver = provider.getDriverById(t.driverId);
      final matchQuery = _searchQuery.isEmpty ||
          t.tripCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.routeName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (bus != null && bus.busNumber.toLowerCase().contains(_searchQuery.toLowerCase())) ||
          (driver != null && driver.name.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchStatus = _statusFilter == null || t.status == _statusFilter;
      return matchQuery && matchStatus;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const RecordTripDialog(),
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('تسجيل رحلة جديدة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'سجل الرحلات اليومية والمسارات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'توثيق الرحلات ومتابعة الإيرادات والأجور الإضافية لكل حافلة',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Filters Row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'ابحث برقم الرحلة، الحافلة، السائق أو خط السير...',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF2563EB), size: 18),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<TripStatus?>(
                  value: _statusFilter,
                  dropdownColor: Colors.white,
                  style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13),
                  underline: const SizedBox(),
                  hint: const Text('كافة الحالات', style: TextStyle(color: Color(0xFF64748B))),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('كافة الحالات', style: TextStyle(color: Color(0xFF0F172A)))),
                    DropdownMenuItem(value: TripStatus.completed, child: Text('مكتملة', style: TextStyle(color: Color(0xFF0F172A)))),
                    DropdownMenuItem(value: TripStatus.inProgress, child: Text('جارية حالياً', style: TextStyle(color: Color(0xFF0F172A)))),
                    DropdownMenuItem(value: TripStatus.scheduled, child: Text('مجدولة', style: TextStyle(color: Color(0xFF0F172A)))),
                    DropdownMenuItem(value: TripStatus.cancelled, child: Text('ملغاة', style: TextStyle(color: Color(0xFF0F172A)))),
                  ],
                  onChanged: (val) => setState(() => _statusFilter = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // List of Trips
          if (filteredTrips.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Center(
                child: Text('لا توجد رحلات مطابقة لمعايير البحث.',
                    style: TextStyle(color: Color(0xFF64748B))),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredTrips.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final trip = filteredTrips[index];
                final bus = provider.getBusById(trip.busId);
                final driver = provider.getDriverById(trip.driverId);
                final cap = bus?.capacity ?? 50;
                final occupancy = trip.getOccupancyRate(cap);

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E3A8A).withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Delete Action
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                        tooltip: 'حذف الرحلة',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: Colors.white,
                              title: const Text('تأكيد الحذف', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
                              content: Text('هل أنت متأكد من حذف رحلة (${trip.tripCode})؟',
                                  style: const TextStyle(color: Color(0xFF64748B))),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('إلغاء', style: TextStyle(color: Color(0xFF64748B))),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    provider.deleteTrip(trip.id);
                                    Navigator.pop(ctx);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEF4444),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('حذف'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // Financial summary
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '+${currencyFormatter.format(trip.revenueDzd)} دج',
                            style: const TextStyle(
                              color: Color(0xFF059669),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const Text(
                            'إيراد التذاكر',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Trip details (Route, Bus, Driver)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: const Color(0xFFBFDBFE)),
                                ),
                                child: Text(
                                  '${trip.passengerCount}/$cap راكب (${occupancy.toStringAsFixed(0)}%)',
                                  style: const TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                trip.routeName,
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${DateFormat('yyyy/MM/dd').format(trip.date)} • الانطلاق: ${trip.departureTime}',
                                style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'السائق: ${driver?.name ?? "غير محدد"}',
                                style: const TextStyle(color: Color(0xFF334155), fontSize: 12),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                bus?.busNumber ?? 'حافلة',
                                style: const TextStyle(
                                  color: Color(0xFFD97706),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Code Badge
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          trip.tripCode,
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
