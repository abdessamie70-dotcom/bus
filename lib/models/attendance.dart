import 'dart:convert';

enum AttendanceStatus {
  present, // حاضر (يوم عمل)
  rest,    // راحة دورية (يوم راحة بموجب طريقة العمل)
  absent,  // غائب
  leave,   // إجازة رسمية
}

class Attendance {
  final String id;
  final String driverId;
  final DateTime date;
  final AttendanceStatus status;
  final String checkInTime; // وقت الحضور "07:00"
  final String checkOutTime; // وقت الانصراف "16:30"
  final double workingHours; // ساعات العمل الفعلية
  final double overtimeHours; // ساعات إضافية
  final String notes;

  Attendance({
    required this.id,
    required this.driverId,
    required this.date,
    required this.status,
    this.checkInTime = '',
    this.checkOutTime = '',
    this.workingHours = 8.0,
    this.overtimeHours = 0.0,
    this.notes = '',
  });

  String get statusText {
    switch (status) {
      case AttendanceStatus.present:
        return 'عمل (حاضر)';
      case AttendanceStatus.rest:
        return 'راحة دورية';
      case AttendanceStatus.absent:
        return 'غائب';
      case AttendanceStatus.leave:
        return 'إجازة رسمية';
    }
  }

  bool get isWorkDay => status == AttendanceStatus.present;
  bool get isRestDay => status == AttendanceStatus.rest;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'driverId': driverId,
      'date': date.toIso8601String(),
      'status': status.index,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'workingHours': workingHours,
      'overtimeHours': overtimeHours,
      'notes': notes,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'] ?? '',
      driverId: map['driverId'] ?? '',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      status: AttendanceStatus.values[map['status'] ?? 0],
      checkInTime: map['checkInTime'] ?? '',
      checkOutTime: map['checkOutTime'] ?? '',
      workingHours: (map['workingHours'] ?? 8.0).toDouble(),
      overtimeHours: (map['overtimeHours'] ?? 0.0).toDouble(),
      notes: map['notes'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Attendance.fromJson(String source) => Attendance.fromMap(json.decode(source));

  Attendance copyWith({
    String? id,
    String? driverId,
    DateTime? date,
    AttendanceStatus? status,
    String? checkInTime,
    String? checkOutTime,
    double? workingHours,
    double? overtimeHours,
    String? notes,
  }) {
    return Attendance(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      date: date ?? this.date,
      status: status ?? this.status,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      workingHours: workingHours ?? this.workingHours,
      overtimeHours: overtimeHours ?? this.overtimeHours,
      notes: notes ?? this.notes,
    );
  }
}
