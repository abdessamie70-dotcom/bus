import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/driver.dart';
import '../providers/fleet_provider.dart';
import '../widgets/kpi_card.dart';
import '../widgets/record_trip_dialog.dart';
import '../models/trip.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback onNavigateToTrips;
  final VoidCallback onNavigateToFleet;

  const DashboardScreen({
    super.key,
    required this.onNavigateToTrips,
    required this.onNavigateToFleet,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FleetProvider>(context);
    final currencyFormatter = NumberFormat('#,###', 'ar');

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
    }

    final isWide = MediaQuery.of(context).size.width >= 900;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. TOP KPI CARDS (تم حذف الوقود والتركيز على الإيرادات والأداء وطريقة العمل)
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return Row(
                  children: [
                    Expanded(
                      child: KpiCard(
                        title: 'إجمالي الرحلات',
                        subtitle: 'الشهر الحالي (${provider.selectedMonthName})',
                        value: '${provider.totalTripsMonth}',
                        icon: Icons.directions_bus_rounded,
                        iconColor: const Color(0xFF38BDF8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: KpiCard(
                        title: 'السائقون النشطون',
                        subtitle: 'في جدول الخدمة',
                        value: '${provider.activeDriversCount}',
                        icon: Icons.people_alt_rounded,
                        iconColor: const Color(0xFF06B6D4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: KpiCard(
                        title: 'إجمالي الإيرادات',
                        subtitle: 'مداخيل التذاكر',
                        value: '${currencyFormatter.format(provider.totalRevenueMonth)} دج',
                        icon: Icons.savings_rounded,
                        iconColor: const Color(0xFF10B981),
                        isHighlighted: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: KpiCard(
                        title: 'طريقة العمل المعتمدة',
                        subtitle: 'نظام مناوبة الأسطول',
                        value: provider.defaultShiftPattern.shortTitle,
                        icon: Icons.published_with_changes_rounded,
                        iconColor: const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                );
              } else {
                return GridView.count(
                  crossAxisCount: constraints.maxWidth > 500 ? 2 : 1,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.6,
                  children: [
                    KpiCard(
                      title: 'إجمالي الرحلات',
                      subtitle: 'الشهر الحالي (${provider.selectedMonthName})',
                      value: '${provider.totalTripsMonth}',
                      icon: Icons.directions_bus_rounded,
                      iconColor: const Color(0xFF38BDF8),
                    ),
                    KpiCard(
                      title: 'السائقون النشطون',
                      subtitle: 'في جدول الخدمة',
                      value: '${provider.activeDriversCount}',
                      icon: Icons.people_alt_rounded,
                      iconColor: const Color(0xFF06B6D4),
                    ),
                    KpiCard(
                      title: 'إجمالي الإيرادات',
                      subtitle: 'مداخيل التذاكر',
                      value: '${currencyFormatter.format(provider.totalRevenueMonth)} دج',
                      icon: Icons.savings_rounded,
                      iconColor: const Color(0xFF10B981),
                      isHighlighted: true,
                    ),
                    KpiCard(
                      title: 'طريقة العمل المعتمدة',
                      subtitle: 'نظام مناوبة الأسطول',
                      value: provider.defaultShiftPattern.title,
                      icon: Icons.published_with_changes_rounded,
                      iconColor: const Color(0xFFF59E0B),
                    ),
                  ],
                );
              }
            },
          ),

          const SizedBox(height: 24),

          // 2. BIG BUS STATISTICS SECTION (50-SEAT BUSES)
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Section Header with Action Button
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const RecordTripDialog(),
                        );
                      },
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('تسجيل رحلة جديدة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1E3A8A),
                        elevation: 3,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'إحصائيات حافلات النقل الكبيرة (سعة 50 راكب)',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 20),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'تحليل كفاءة الإشغال ونسب الامتلاء للحافلات الكبيرة ومردودية المقاعد',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: isWide ? 12 : 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 5 Sub-metric Cards for 50-Seat Buses
                LayoutBuilder(
                  builder: (context, constraints) {
                    final occupancy = provider.bigBusOccupancyRate;
                    final subCards = [
                      _buildSubKpi(
                        title: 'عدد حافلات 50 مقعد',
                        value: '${provider.bigBusesCount}',
                      ),
                      _buildSubKpi(
                        title: 'رحلات حافلات 50 مقعد',
                        value: '${provider.bigBusTripsCount}',
                      ),
                      _buildSubKpi(
                        title: 'ركاب الحافلات الكبيرة',
                        value: '${provider.bigBusPassengersCount}',
                        highlightColor: Colors.white,
                      ),
                      _buildSubKpi(
                        title: 'معدل الإشغال للحافلات الكبيرة',
                        value: '${occupancy.toStringAsFixed(1)}%',
                        highlightColor: occupancy >= 80 ? const Color(0xFF6EE7B7) : const Color(0xFFFDE68A),
                      ),
                      _buildSubKpi(
                        title: 'متوسط الركاب/رحلة',
                        value: provider.bigBusAveragePassengersPerTrip.toStringAsFixed(1),
                      ),
                    ];

                    if (constraints.maxWidth > 800) {
                      return Row(
                        children: subCards.map((w) => Expanded(child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: w,
                        ))).toList(),
                      );
                    } else {
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: subCards.map((w) => SizedBox(
                          width: (constraints.maxWidth - 20) / 2,
                          child: w,
                        )).toList(),
                      );
                    }
                  },
                ),

                const SizedBox(height: 20),

                // Progress Bar: مقياس استغلال المقاعد (الهدف >= 80%)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الهدف: ≥ 80% امتلاء (المحقق: ${provider.bigBusOccupancyRate.toStringAsFixed(1)}%)',
                          style: TextStyle(
                            color: provider.bigBusOccupancyRate >= 80
                                ? const Color(0xFF6EE7B7)
                                : const Color(0xFFFDE68A),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'مقياس استغلال المقاعد للحافلات الكبيرة (سعة 50 راكب)',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (provider.bigBusOccupancyRate / 100.0).clamp(0.0, 1.0),
                        minHeight: 10,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          provider.bigBusOccupancyRate >= 80
                              ? const Color(0xFF10B981)
                              : const Color(0xFFFBBF24),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. RECENT LOGGED TRIPS TABLE (تم حذف عمود الوقود)
          Container(
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
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: onNavigateToTrips,
                      icon: const Icon(Icons.arrow_back_rounded, size: 16),
                      label: const Text('عرض كافة الرحلات'),
                    ),
                    const Row(
                      children: [
                        Text(
                          'آخر الرحلات المسجلة بالأسطول',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.alt_route_rounded, color: Color(0xFF2563EB), size: 18),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (provider.trips.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(
                      child: Text(
                        'لا توجد رحلات مسجلة بعد. استخدم زر "تسجيل رحلة جديدة" للبدء.',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    ),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingTextStyle: const TextStyle(
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      dataTextStyle: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 13,
                      ),
                      columns: const [
                        DataColumn(label: Text('كود الرحلة')),
                        DataColumn(label: Text('الحافلة')),
                        DataColumn(label: Text('السائق')),
                        DataColumn(label: Text('المسار')),
                        DataColumn(label: Text('الركاب')),
                        DataColumn(label: Text('الإيراد')),
                        DataColumn(label: Text('الحالة')),
                      ],
                      rows: provider.trips.take(5).map((trip) {
                        final bus = provider.getBusById(trip.busId);
                        final driver = provider.getDriverById(trip.driverId);
                        final cap = bus?.capacity ?? 50;

                        return DataRow(cells: [
                          DataCell(Text(trip.tripCode,
                              style: const TextStyle(
                                  color: Color(0xFF2563EB), fontWeight: FontWeight.bold))),
                          DataCell(Text(bus?.busNumber ?? 'حافلة')),
                          DataCell(Text(driver?.name ?? 'سائق')),
                          DataCell(Text(trip.routeName)),
                          DataCell(Text('${trip.passengerCount} / $cap')),
                          DataCell(Text('${currencyFormatter.format(trip.revenueDzd)} دج',
                              style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: trip.status == TripStatus.completed
                                    ? const Color(0xFFECFDF5)
                                    : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: trip.status == TripStatus.completed
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF2563EB),
                                ),
                              ),
                              child: Text(
                                trip.statusText,
                                style: TextStyle(
                                  color: trip.status == TripStatus.completed
                                      ? const Color(0xFF059669)
                                      : const Color(0xFF2563EB),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubKpi({
    required String title,
    required String value,
    Color? highlightColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: highlightColor ?? Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
