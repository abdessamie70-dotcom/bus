import 'dart:convert';

class Payroll {
  final String id;
  final String driverId;
  final int month;
  final int year;
  final double baseSalary; // الراتب الأساسي (دج)
  final int completedTripsCount; // عدد الرحلات المنجزة
  final double tripBonuses; // علاوة الرحلات
  final double overtimeHours; // ساعات إضافية
  final double overtimePay; // أجر الإضافي
  final double incentives; // حوافز ومكافآت
  final double deductions; // خصومات (غياب/مخالفات)
  final bool isPaid; // تم الصرف
  final DateTime? paymentDate;
  final String notes;

  Payroll({
    required this.id,
    required this.driverId,
    required this.month,
    required this.year,
    required this.baseSalary,
    this.completedTripsCount = 0,
    this.tripBonuses = 0.0,
    this.overtimeHours = 0.0,
    this.overtimePay = 0.0,
    this.incentives = 0.0,
    this.deductions = 0.0,
    this.isPaid = false,
    this.paymentDate,
    this.notes = '',
  });

  double get grossSalary => baseSalary + tripBonuses + overtimePay + incentives;
  double get netSalary => grossSalary - deductions;

  String get monthName {
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
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return 'شهر $month';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'driverId': driverId,
      'month': month,
      'year': year,
      'baseSalary': baseSalary,
      'completedTripsCount': completedTripsCount,
      'tripBonuses': tripBonuses,
      'overtimeHours': overtimeHours,
      'overtimePay': overtimePay,
      'incentives': incentives,
      'deductions': deductions,
      'isPaid': isPaid,
      'paymentDate': paymentDate?.toIso8601String(),
      'notes': notes,
    };
  }

  factory Payroll.fromMap(Map<String, dynamic> map) {
    return Payroll(
      id: map['id'] ?? '',
      driverId: map['driverId'] ?? '',
      month: map['month']?.toInt() ?? DateTime.now().month,
      year: map['year']?.toInt() ?? DateTime.now().year,
      baseSalary: (map['baseSalary'] ?? 45000.0).toDouble(),
      completedTripsCount: map['completedTripsCount']?.toInt() ?? 0,
      tripBonuses: (map['tripBonuses'] ?? 0.0).toDouble(),
      overtimeHours: (map['overtimeHours'] ?? 0.0).toDouble(),
      overtimePay: (map['overtimePay'] ?? 0.0).toDouble(),
      incentives: (map['incentives'] ?? 0.0).toDouble(),
      deductions: (map['deductions'] ?? 0.0).toDouble(),
      isPaid: map['isPaid'] ?? false,
      paymentDate: map['paymentDate'] != null ? DateTime.tryParse(map['paymentDate']) : null,
      notes: map['notes'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Payroll.fromJson(String source) => Payroll.fromMap(json.decode(source));

  Payroll copyWith({
    String? id,
    String? driverId,
    int? month,
    int? year,
    double? baseSalary,
    int? completedTripsCount,
    double? tripBonuses,
    double? overtimeHours,
    double? overtimePay,
    double? incentives,
    double? deductions,
    bool? isPaid,
    DateTime? paymentDate,
    String? notes,
  }) {
    return Payroll(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      month: month ?? this.month,
      year: year ?? this.year,
      baseSalary: baseSalary ?? this.baseSalary,
      completedTripsCount: completedTripsCount ?? this.completedTripsCount,
      tripBonuses: tripBonuses ?? this.tripBonuses,
      overtimeHours: overtimeHours ?? this.overtimeHours,
      overtimePay: overtimePay ?? this.overtimePay,
      incentives: incentives ?? this.incentives,
      deductions: deductions ?? this.deductions,
      isPaid: isPaid ?? this.isPaid,
      paymentDate: paymentDate ?? this.paymentDate,
      notes: notes ?? this.notes,
    );
  }
}
