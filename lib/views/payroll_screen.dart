import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/bus.dart';
import '../providers/fleet_provider.dart';
import '../widgets/payslip_dialog.dart';

class PayrollScreen extends StatelessWidget {
  const PayrollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FleetProvider>(context);
    final currencyFormatter = NumberFormat('#,###', 'ar');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded, size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'دورة أجور شهر: ${provider.selectedMonthName} ${provider.selectedYear}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'مسير الرواتب ومستحقات السائقين',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  Text(
                    'احتساب الراتب الأساسي + حوافز الرحلات وبدلات الإضافي مع إمكانية طباعة كشف كل سائق',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Total Payroll Summary Card (Blue and White)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  title: 'إجمالي الأجور المستحقة',
                  value: '${currencyFormatter.format(provider.payrolls.fold(0.0, (sum, p) => sum + p.netSalary))} دج',
                  color: Colors.white,
                ),
                Container(width: 1, height: 40, color: Colors.white24),
                _buildSummaryItem(
                  title: 'إجمالي مكافآت الرحلات',
                  value: '${currencyFormatter.format(provider.payrolls.fold(0.0, (sum, p) => sum + p.tripBonuses))} دج',
                  color: const Color(0xFF38BDF8),
                ),
                Container(width: 1, height: 40, color: Colors.white24),
                _buildSummaryItem(
                  title: 'سائقين بانتظار الصرف',
                  value: '${provider.payrolls.where((p) => !p.isPaid).length} سائقين',
                  color: const Color(0xFFFBBF24),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Drivers Payroll Cards
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.drivers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final driver = provider.drivers[index];
              final payroll = provider.payrolls.firstWhere(
                (p) => p.driverId == driver.id,
                orElse: () => provider.payrolls.isNotEmpty ? provider.payrolls.first : throw 'Empty',
              );

              final bus = provider.buses.firstWhere(
                (b) => b.assignedDriverId == driver.id,
                orElse: () => Bus(id: '', busNumber: 'حافلة الأسطول', plateNumber: '', capacity: 50, model: ''),
              );

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E3A8A).withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    // Action Buttons (Print & Status Toggle)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => PayslipDialog(driver: driver, payroll: payroll, bus: bus),
                            );
                          },
                          icon: const Icon(Icons.print_rounded, size: 16),
                          label: const Text('طباعة التقرير الشهري'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () => provider.togglePayrollPaid(payroll.id),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: payroll.isPaid
                                  ? const Color(0xFFECFDF5)
                                  : const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: payroll.isPaid ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  payroll.isPaid ? Icons.check_circle : Icons.hourglass_top_rounded,
                                  size: 14,
                                  color: payroll.isPaid ? const Color(0xFF059669) : const Color(0xFFD97706),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  payroll.isPaid ? 'تم الصرف والتسديد' : 'جاهز للصرف',
                                  style: TextStyle(
                                    color: payroll.isPaid ? const Color(0xFF059669) : const Color(0xFFD97706),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 20),

                    // Net Salary Highlight
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('الصافي المستحق للدفع', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(
                          '${currencyFormatter.format(payroll.netSalary)} دج',
                          style: const TextStyle(
                            color: Color(0xFF1D4ED8),
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Details breakdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          driver.name,
                          style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'الأساسي: ${currencyFormatter.format(payroll.baseSalary)} دج',
                              style: const TextStyle(color: Color(0xFF475569), fontSize: 12),
                            ),
                            const Text(' • ', style: TextStyle(color: Color(0xFFCBD5E1))),
                            Text(
                              'علاوة الرحلات: +${currencyFormatter.format(payroll.tripBonuses)} دج',
                              style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            if (payroll.overtimePay > 0) ...[
                              const Text(' • ', style: TextStyle(color: Color(0xFFCBD5E1))),
                              Text(
                                'إضافي: +${currencyFormatter.format(payroll.overtimePay)} دج',
                                style: const TextStyle(color: Color(0xFF2563EB), fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(width: 14),

                    // Avatar Circle
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFEFF6FF),
                      child: Text(
                        driver.name.isNotEmpty ? driver.name.substring(0, 1) : 'س',
                        style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
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

  Widget _buildSummaryItem({
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
