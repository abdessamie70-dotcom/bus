import 'dart:convert';

class Booking {
  final String id;
  final String bookingCode; // e.g. "BOK-2026-001"
  final String busId;
  final String busName;
  final String route;
  final DateTime travelDate;
  final int seatsCount;
  final String passengerName;
  final String passengerPhone;
  final String notes;
  final double ticketPrice;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.bookingCode,
    required this.busId,
    required this.busName,
    required this.route,
    required this.travelDate,
    required this.seatsCount,
    required this.passengerName,
    required this.passengerPhone,
    this.notes = '',
    this.ticketPrice = 1500.0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get totalPrice => seatsCount * ticketPrice;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookingCode': bookingCode,
      'busId': busId,
      'busName': busName,
      'route': route,
      'travelDate': travelDate.toIso8601String(),
      'seatsCount': seatsCount,
      'passengerName': passengerName,
      'passengerPhone': passengerPhone,
      'notes': notes,
      'ticketPrice': ticketPrice,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] ?? '',
      bookingCode: map['bookingCode'] ?? '',
      busId: map['busId'] ?? '',
      busName: map['busName'] ?? '',
      route: map['route'] ?? '',
      travelDate: DateTime.tryParse(map['travelDate'] ?? '') ?? DateTime.now(),
      seatsCount: map['seatsCount']?.toInt() ?? 1,
      passengerName: map['passengerName'] ?? '',
      passengerPhone: map['passengerPhone'] ?? '',
      notes: map['notes'] ?? '',
      ticketPrice: (map['ticketPrice'] ?? 1500.0).toDouble(),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Booking.fromJson(String source) => Booking.fromMap(json.decode(source));
}
