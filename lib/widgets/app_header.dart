import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/driver.dart';
import '../providers/fleet_provider.dart';

class AppHeader extends StatelessWidget {
  final int selectedTabIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback? onOpenDrivers;
  final VoidCallback? onOpenBooking;
  final VoidCallback? onRecordTrip;

  const AppHeader({
    super.key,
    required this.selectedTabIndex,
    required this.onTabSelected,
    this.onOpenDrivers,
    this.onOpenBooking,
    this.onRecordTrip,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final provider = Provider.of<FleetProvider>(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E3A8A), // Deep navy blue
            Color(0xFF1D4ED8), // Royal blue
            Color(0xFF2563EB), // Vibrant blue
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x331E3A8A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          // Top Row: Brand, Institution Badge, and Quick Action Buttons
          Row(
            children: [
              // Left action buttons: Work Shift Pattern Selector + Gregorian Calendar Month & Year Picker + Booking Portal Button
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // 1. طريقة العمل (بديل إدارة السائقين)
                  _buildWorkShiftPatternSelector(context, provider),

                  // 2. التقويم الميلادي شهر وسنة (بديل بوابة الحجز)
                  _buildGregorianMonthYearPicker(context, provider),

                  // 3. زر بوابة الحجز المباشر (مثل الصورة)
                  ElevatedButton.icon(
                    onPressed: onOpenBooking ?? () => onTabSelected(6),
                    icon: const Icon(Icons.confirmation_number_outlined, size: 15),
                    label: const Text('بوابة الحجز'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedTabIndex == 6 ? Colors.white : const Color(0xFFF59E0B),
                      foregroundColor: selectedTabIndex == 6 ? const Color(0xFF1E3A8A) : Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Right: Institution & System Title
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'سائقي الحافلات',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Text(
                          'مؤسسة سويقات أبو طالب',
                          style: TextStyle(
                            color: Color(0xFF1E3A8A),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'مؤسسة سويقات أبو طالب • إدارة الرحلات اليومية والأسطول وحضور السائقين',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: isDesktop ? 12 : 10,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 8),

          // Bottom Row: Navigation Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildNavTab(
                  index: 0,
                  label: 'لوحة التحكم',
                  icon: Icons.dashboard_rounded,
                ),
                _buildNavTab(
                  index: 1,
                  label: 'سجل الرحلات',
                  icon: Icons.alt_route_rounded,
                ),
                _buildNavTab(
                  index: 2,
                  label: 'الأسطول والحافلات',
                  icon: Icons.directions_bus_rounded,
                ),
                _buildNavTab(
                  index: 3,
                  label: 'تقويم الحضور',
                  icon: Icons.calendar_month_rounded,
                ),
                _buildNavTab(
                  index: 4,
                  label: 'الأجور والمستحقات',
                  icon: Icons.payments_rounded,
                ),
                _buildNavTab(
                  index: 5,
                  label: 'دليل السائقين',
                  icon: Icons.badge_rounded,
                ),
                _buildNavTab(
                  index: 6,
                  label: 'بوابة الحجز',
                  icon: Icons.confirmation_number_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1. زر واختيار طريقة ونظام العمل للسائقين (بديل إدارة السائقين)
  Widget _buildWorkShiftPatternSelector(BuildContext context, FleetProvider provider) {
    final pattern = provider.defaultShiftPattern;

    return InkWell(
      onTap: () => _showShiftPatternDialog(context, provider),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFDBEAFE),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.published_with_changes_rounded,
              size: 18,
              color: Color(0xFF2563EB),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'طريقة العمل:',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  pattern.title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: Color(0xFF2563EB),
            ),
          ],
        ),
      ),
    );
  }

  void _showShiftPatternDialog(BuildContext context, FleetProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.published_with_changes_rounded, color: Color(0xFF2563EB)),
            Text(
              'تحديد طريقة ونظام عمل السائقين',
              style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'اختر نمط المناوبة المعمول به بالأسطول لحساب جدول الحضور والراحة:',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
              const SizedBox(height: 14),

              // الخيارات الأربعة المطلوبة
              _buildPatternOption(
                ctx,
                provider,
                pattern: WorkShiftPattern.dayWorkDayRest,
                title: 'يوم عمل / يوم راحة',
                badge: '1 : 1',
                desc: 'مناوبة متناوبة: يعمل السائق يوماً ويستريح اليوم الموالي.',
              ),
              const SizedBox(height: 8),
              _buildPatternOption(
                ctx,
                provider,
                pattern: WorkShiftPattern.dayWorkTwoDaysRest,
                title: 'يوم عمل / يومان راحة',
                badge: '1 : 2',
                desc: 'مناوبة مريحة: يوم عمل واحد يعقبه يومان استراحة كاملة.',
              ),
              const SizedBox(height: 8),
              _buildPatternOption(
                ctx,
                provider,
                pattern: WorkShiftPattern.monthContinuous,
                title: 'شهر عمل',
                badge: 'شهر كامل',
                desc: 'عمل مستمر طوال الشهر مع العطل الأسبوعية الرسمية (الجمعة).',
              ),
              const SizedBox(height: 8),
              _buildPatternOption(
                ctx,
                provider,
                pattern: WorkShiftPattern.twoDaysWorkDayRest,
                title: 'يومان عمل / يوم راحة',
                badge: '2 : 1',
                desc: 'مناوبة مكثفة: يعمل السائق يومين متتاليين ثم يوم راحة.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق', style: TextStyle(color: Color(0xFF64748B))),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternOption(
    BuildContext ctx,
    FleetProvider provider, {
    required WorkShiftPattern pattern,
    required String title,
    required String badge,
    required String desc,
  }) {
    final isSelected = provider.defaultShiftPattern == pattern;

    return InkWell(
      onTap: () {
        provider.setDefaultShiftPattern(pattern);
        Navigator.pop(ctx);
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text('تم ضبط طريقة العمل: ($title)'),
            backgroundColor: const Color(0xFF2563EB),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF1D4ED8) : const Color(0xFF0F172A),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Color(0xFF2563EB), size: 18),
          ],
        ),
      ),
    );
  }

  // 2. التقويم الميلادي شهر وسنة (بديل بوابة الحجز)
  Widget _buildGregorianMonthYearPicker(BuildContext context, FleetProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFDBEAFE),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Next Month Button
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF2563EB)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
            tooltip: 'الشهر التالي',
            onPressed: provider.nextMonth,
          ),

          // Month and Year Display Clickable Button
          InkWell(
            onTap: () => _showMonthYearDialog(context, provider),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    size: 16,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'التقويم الميلادي',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${provider.selectedMonthName} ${provider.selectedYear}',
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Previous Month Button
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, size: 20, color: Color(0xFF2563EB)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
            tooltip: 'الشهر السابق',
            onPressed: provider.previousMonth,
          ),
        ],
      ),
    );
  }

  void _showMonthYearDialog(BuildContext context, FleetProvider provider) {
    int selectedM = provider.selectedMonth;
    int selectedY = provider.selectedYear;

    const months = [
      'جانفي (يناير)',
      'فيفري (فبراير)',
      'مارس',
      'أفريل (أبريل)',
      'ماي (مايو)',
      'جوان (يونيو)',
      'جويلية (يوليو)',
      'أوت (أغسطس)',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
          ),
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.calendar_month, color: Color(0xFF2563EB)),
              Text(
                'اختر الشهر والسنة الميلادية',
                style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Year selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_left, color: Color(0xFF2563EB)),
                    onPressed: () => setModalState(() => selectedY--),
                  ),
                  Text(
                    '$selectedY',
                    style: const TextStyle(
                      color: Color(0xFF1D4ED8),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_right, color: Color(0xFF2563EB)),
                    onPressed: () => setModalState(() => selectedY++),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Months Grid
              SizedBox(
                width: 320,
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: List.generate(12, (index) {
                    final m = index + 1;
                    final isSel = m == selectedM;
                    return InkWell(
                      onTap: () => setModalState(() => selectedM = m),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 98,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFF2563EB) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSel ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          months[index],
                          style: TextStyle(
                            color: isSel ? Colors.white : const Color(0xFF1E293B),
                            fontSize: 10,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              onPressed: () {
                provider.setSelectedMonthYear(selectedM, selectedY);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),
              child: const Text('تطبيق', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTab({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = selectedTabIndex == index;

    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: InkWell(
        onTap: () => onTabSelected(index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? const Color(0xFF1E3A8A) : Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF1E3A8A) : Colors.white,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
