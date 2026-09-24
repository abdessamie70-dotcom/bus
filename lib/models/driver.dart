import 'dart:convert';

enum WorkShiftPattern {
  dayWorkDayRest, // يوم عمل يوم راحة
  dayWorkTwoDaysRest, // يوم عمل يومان راحة
  monthContinuous, // شهر عمل
  twoDaysWorkDayRest, // يومان عمل يوم راحة
}

extension WorkShiftPatternExtension on WorkShiftPattern {
  String get title {
    switch (this) {
      case WorkShiftPattern.dayWorkDayRest:
        return 'يوم عمل / يوم راحة';
      case WorkShiftPattern.dayWorkTwoDaysRest:
        return 'يوم عمل / يومان راحة';
      case WorkShiftPattern.monthContinuous:
        return 'شهر عمل مستمر';
      case WorkShiftPattern.twoDaysWorkDayRest:
        return 'يومان عمل / يوم راحة';
    }
  }

  String get shortTitle {
    switch (this) {
      case WorkShiftPattern.dayWorkDayRest:
        return '1 عمل : 1 راحة';
      case WorkShiftPattern.dayWorkTwoDaysRest:
        return '1 عمل : 2 راحة';
      case WorkShiftPattern.monthContinuous:
        return 'شهر عمل';
      case WorkShiftPattern.twoDaysWorkDayRest:
        return '2 عمل : 1 راحة';
    }
  }

  String get description {
    switch (this) {
      case WorkShiftPattern.dayWorkDayRest:
        return 'مناوبة متناوبة: يعمل السائق يوماً ويستريح اليوم الموالي بالتناوب.';
      case WorkShiftPattern.dayWorkTwoDaysRest:
        return 'مناوبة مريحة: يعمل السائق يوماً واحداً ويعقبه يومان استراحة.';
      case WorkShiftPattern.monthContinuous:
        return 'نظام العمل المستمر طوال الشهر مع العطل الأسبوعية الرسمية.';
      case WorkShiftPattern.twoDaysWorkDayRest:
        return 'مناوبة مكثفة: يعمل السائق يومين متتاليين ثم يوم راحة.';
    }
  }
}

class Driver {
  final String id;
  final String name;
  final String phone;
  final String licenseNumber;
  final DateTime licenseExpiry;
  final String? assignedBusId;
  final double baseSalary; // الراتب الأساسي (دج)
  final double tripBonusRate; // مكافأة كل رحلة (دج)
  final double rating; // تقييم السائق
  final bool isActive; // نشط في جدول الخدمة
  final WorkShiftPattern shiftPattern; // طريقة ونظام العمل
  final DateTime hireDate;
  final String notes;

  Driver({
    required this.id,
    required this.name,
    required this.phone,
    required this.licenseNumber,
    required this.licenseExpiry,
    this.assignedBusId,
    this.baseSalary = 45000.0,
    this.tripBonusRate = 1200.0,
    this.rating = 4.8,
    this.isActive = true,
    this.shiftPattern = WorkShiftPattern.dayWorkDayRest,
    DateTime? hireDate,
    this.notes = '',
  }) : hireDate = hireDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'licenseNumber': licenseNumber,
      'licenseExpiry': licenseExpiry.toIso8601String(),
      'assignedBusId': assignedBusId,
      'baseSalary': baseSalary,
      'tripBonusRate': tripBonusRate,
      'rating': rating,
      'isActive': isActive,
      'shiftPattern': shiftPattern.index,
      'hireDate': hireDate.toIso8601String(),
      'notes': notes,
    };
  }

  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      licenseNumber: map['licenseNumber'] ?? '',
      licenseExpiry: DateTime.tryParse(map['licenseExpiry'] ?? '') ??
          DateTime.now().add(const Duration(days: 365)),
      assignedBusId: map['assignedBusId'],
      baseSalary: (map['baseSalary'] ?? 45000.0).toDouble(),
      tripBonusRate: (map['tripBonusRate'] ?? 1200.0).toDouble(),
      rating: (map['rating'] ?? 5.0).toDouble(),
      isActive: map['isActive'] ?? true,
      shiftPattern: WorkShiftPattern.values[map['shiftPattern'] ?? 0],
      hireDate: DateTime.tryParse(map['hireDate'] ?? '') ?? DateTime.now(),
      notes: map['notes'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Driver.fromJson(String source) => Driver.fromMap(json.decode(source));

  Driver copyWith({
    String? id,
    String? name,
    String? phone,
    String? licenseNumber,
    DateTime? licenseExpiry,
    String? assignedBusId,
    double? baseSalary,
    double? tripBonusRate,
    double? rating,
    bool? isActive,
    WorkShiftPattern? shiftPattern,
    DateTime? hireDate,
    String? notes,
  }) {
    return Driver(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiry: licenseExpiry ?? this.licenseExpiry,
      assignedBusId: assignedBusId ?? this.assignedBusId,
      baseSalary: baseSalary ?? this.baseSalary,
      tripBonusRate: tripBonusRate ?? this.tripBonusRate,
      rating: rating ?? this.rating,
      isActive: isActive ?? this.isActive,
      shiftPattern: shiftPattern ?? this.shiftPattern,
      hireDate: hireDate ?? this.hireDate,
      notes: notes ?? this.notes,
    );
  }
}
