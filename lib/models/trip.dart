import 'dart:convert';

enum TripStatus {
  completed, // مكتملة
  inProgress, // جارية حالياً
  scheduled, // مجدولة
  cancelled, // ملغاة
}

class Trip {
  final String id;
  final String tripCode;
  final String busId;
  final String driverId;
  final String routeName; // اسم المسار / خط السير
  final DateTime date;
  final String departureTime; // وقت الانطلاق (e.g. "07:30")
  final String arrivalTime; // وقت الوصول (e.g. "09:45")
  final int passengerCount; // عدد الركاب
  final double revenueDzd; // إجمالي الإيرادات (دج)
  final double overtimePayDzd; // أجر إضافي للرحلة (دج)
  final double startMileage; // عداد الانطلاق
  final double endMileage; // عداد الوصول
  final TripStatus status;
  final String notes;

  Trip({
    required this.id,
    required this.tripCode,
    required this.busId,
    required this.driverId,
    required this.routeName,
    required this.date,
    required this.departureTime,
    required this.arrivalTime,
    required this.passengerCount,
    required this.revenueDzd,
    this.overtimePayDzd = 0.0,
    this.startMileage = 0.0,
    this.endMileage = 0.0,
    this.status = TripStatus.completed,
    this.notes = '',
  });

  double get distanceKm => (endMileage > startMileage) ? (endMileage - startMileage) : 0.0;

  double getOccupancyRate(int busCapacity) {
    if (busCapacity <= 0) return 0.0;
    return (passengerCount / busCapacity) * 100.0;
  }

  String get statusText {
    switch (status) {
      case TripStatus.completed:
        return 'مكتملة';
      case TripStatus.inProgress:
        return 'جارية حالياً';
      case TripStatus.scheduled:
        return 'مجدولة';
      case TripStatus.cancelled:
        return 'ملغاة';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripCode': tripCode,
      'busId': busId,
      'driverId': driverId,
      'routeName': routeName,
      'date': date.toIso8601String(),
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'passengerCount': passengerCount,
      'revenueDzd': revenueDzd,
      'overtimePayDzd': overtimePayDzd,
      'startMileage': startMileage,
      'endMileage': endMileage,
      'status': status.index,
      'notes': notes,
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'] ?? '',
      tripCode: map['tripCode'] ?? '',
      busId: map['busId'] ?? '',
      driverId: map['driverId'] ?? '',
      routeName: map['routeName'] ?? '',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      departureTime: map['departureTime'] ?? '',
      arrivalTime: map['arrivalTime'] ?? '',
      passengerCount: map['passengerCount']?.toInt() ?? 0,
      revenueDzd: (map['revenueDzd'] ?? 0.0).toDouble(),
      overtimePayDzd: (map['overtimePayDzd'] ?? map['overtimePay'] ?? 0.0).toDouble(),
      startMileage: (map['startMileage'] ?? 0.0).toDouble(),
      endMileage: (map['endMileage'] ?? 0.0).toDouble(),
      status: TripStatus.values[map['status'] ?? 0],
      notes: map['notes'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Trip.fromJson(String source) => Trip.fromMap(json.decode(source));

  Trip copyWith({
    String? id,
    String? tripCode,
    String? busId,
    String? driverId,
    String? routeName,
    DateTime? date,
    String? departureTime,
    String? arrivalTime,
    int? passengerCount,
    double? revenueDzd,
    double? overtimePayDzd,
    double? startMileage,
    double? endMileage,
    TripStatus? status,
    String? notes,
  }) {
    return Trip(
      id: id ?? this.id,
      tripCode: tripCode ?? this.tripCode,
      busId: busId ?? this.busId,
      driverId: driverId ?? this.driverId,
      routeName: routeName ?? this.routeName,
      date: date ?? this.date,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      passengerCount: passengerCount ?? this.passengerCount,
      revenueDzd: revenueDzd ?? this.revenueDzd,
      overtimePayDzd: overtimePayDzd ?? this.overtimePayDzd,
      startMileage: startMileage ?? this.startMileage,
      endMileage: endMileage ?? this.endMileage,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}
