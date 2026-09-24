import 'dart:convert';

enum BusStatus {
  active, // نشطة في الخدمة
  onTrip, // في رحلة حالياً
  maintenance, // في الصيانة
  inactive, // متوقفة
}

class Bus {
  final String id;
  final String busNumber; // رقم الحافلة مثل "حافلة 101"
  final String plateNumber; // رقم اللوحة مثل "16-10243-01"
  final int capacity; // سعة المقاعد (مثل 50 أو 30 راكب)
  final String model; // نوع وموديل الحافلة
  final String? assignedDriverId; // السائق المكلف
  final BusStatus status;
  final double currentMileage; // عداد الكيلومترات
  final String notes;

  Bus({
    required this.id,
    required this.busNumber,
    required this.plateNumber,
    required this.capacity,
    required this.model,
    this.assignedDriverId,
    this.status = BusStatus.active,
    this.currentMileage = 0.0,
    this.notes = '',
  });

  bool get isBigBus => capacity >= 50;

  String get statusText {
    switch (status) {
      case BusStatus.active:
        return 'جاهزة للخدمة';
      case BusStatus.onTrip:
        return 'في رحلة حالياً';
      case BusStatus.maintenance:
        return 'في الصيانة';
      case BusStatus.inactive:
        return 'متوقفة';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'busNumber': busNumber,
      'plateNumber': plateNumber,
      'capacity': capacity,
      'model': model,
      'assignedDriverId': assignedDriverId,
      'status': status.index,
      'currentMileage': currentMileage,
      'notes': notes,
    };
  }

  factory Bus.fromMap(Map<String, dynamic> map) {
    return Bus(
      id: map['id'] ?? '',
      busNumber: map['busNumber'] ?? '',
      plateNumber: map['plateNumber'] ?? '',
      capacity: map['capacity']?.toInt() ?? 50,
      model: map['model'] ?? '',
      assignedDriverId: map['assignedDriverId'],
      status: BusStatus.values[map['status'] ?? 0],
      currentMileage: (map['currentMileage'] ?? 0.0).toDouble(),
      notes: map['notes'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Bus.fromJson(String source) => Bus.fromMap(json.decode(source));

  Bus copyWith({
    String? id,
    String? busNumber,
    String? plateNumber,
    int? capacity,
    String? model,
    String? assignedDriverId,
    BusStatus? status,
    double? currentMileage,
    String? notes,
  }) {
    return Bus(
      id: id ?? this.id,
      busNumber: busNumber ?? this.busNumber,
      plateNumber: plateNumber ?? this.plateNumber,
      capacity: capacity ?? this.capacity,
      model: model ?? this.model,
      assignedDriverId: assignedDriverId ?? this.assignedDriverId,
      status: status ?? this.status,
      currentMileage: currentMileage ?? this.currentMileage,
      notes: notes ?? this.notes,
    );
  }
}
