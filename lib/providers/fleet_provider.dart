import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bus.dart';
import '../models/driver.dart';
import '../models/trip.dart';
import '../models/attendance.dart';
import '../models/payroll.dart';

class FleetProvider with ChangeNotifier {
  List<Bus> _buses = [];
  List<Driver> _drivers = [];
  List<Trip> _trips = [];
  List<Attendance> _attendance = [];
  List<Payroll> _payrolls = [];

  bool _isLoading = true;
  final String _institutionName = 'مؤسسة سويقات أبو طالب';
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  WorkShiftPattern _defaultShiftPattern = WorkShiftPattern.dayWorkDayRest;

  FleetProvider() {
    _loadData();
  }

  // Getters
  bool get isLoading => _isLoading;
  String get institutionName => _institutionName;
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;
  WorkShiftPattern get defaultShiftPattern => _defaultShiftPattern;

  String get selectedMonthName {
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
    if (_selectedMonth >= 1 && _selectedMonth <= 12) {
      return months[_selectedMonth - 1];
    }
    return 'شهر $_selectedMonth';
  }

  void previousMonth() {
    if (_selectedMonth == 1) {
      _selectedMonth = 12;
      _selectedYear--;
    } else {
      _selectedMonth--;
    }
    notifyListeners();
  }

  void nextMonth() {
    if (_selectedMonth == 12) {
      _selectedMonth = 1;
      _selectedYear++;
    } else {
      _selectedMonth++;
    }
    notifyListeners();
  }

  void setSelectedMonthYear(int month, int year) {
    _selectedMonth = month;
    _selectedYear = year;
    notifyListeners();
  }

  void setDefaultShiftPattern(WorkShiftPattern pattern, {bool autoFillCalendar = true}) {
    _defaultShiftPattern = pattern;
    _drivers = _drivers.map((d) => d.copyWith(shiftPattern: pattern)).toList();
    if (autoFillCalendar) {
      autoFillAttendanceForMonth(month: _selectedMonth, year: _selectedYear, pattern: pattern);
    }
    notifyListeners();
    _saveData();
  }

  // الملء التلقائي لطريقة العمل لكافة السائقين للشهر المحدد
  Future<void> autoFillAttendanceForMonth({
    required int month,
    required int year,
    WorkShiftPattern? pattern,
    String? specificDriverId,
  }) async {
    final activePattern = pattern ?? _defaultShiftPattern;
    final driversToFill = specificDriverId != null
        ? _drivers.where((d) => d.id == specificDriverId).toList()
        : _drivers;

    final daysInMonth = DateTime(year, month + 1, 0).day;

    for (int driverIndex = 0; driverIndex < driversToFill.length; driverIndex++) {
      final driver = driversToFill[driverIndex];
      // Offset per driver so buses are covered alternately
      final driverOffset = driverIndex % 3;

      for (int day = 1; day <= daysInMonth; day++) {
        final date = DateTime(year, month, day);
        final isFriday = (date.weekday == DateTime.friday);

        AttendanceStatus status;
        if (isFriday) {
          status = AttendanceStatus.rest; // عطلة الجمعة الأسبوعية
        } else {
          final isWork = isWorkDayForPattern(date, activePattern, driverOffset);
          status = isWork ? AttendanceStatus.present : AttendanceStatus.rest;
        }

        final existingIndex = _attendance.indexWhere((a) =>
            a.driverId == driver.id &&
            a.date.year == year &&
            a.date.month == month &&
            a.date.day == day);

        final record = Attendance(
          id: existingIndex != -1
              ? _attendance[existingIndex].id
              : 'att_${driver.id}_${year}_${month}_$day',
          driverId: driver.id,
          date: date,
          status: status,
          checkInTime: status == AttendanceStatus.present ? '07:00' : '',
          checkOutTime: status == AttendanceStatus.present ? '16:00' : '',
          workingHours: status == AttendanceStatus.present ? 8.0 : 0.0,
          overtimeHours: (status == AttendanceStatus.present && day % 4 == 0) ? 1.5 : 0.0,
          notes: status == AttendanceStatus.rest ? 'راحة مناوبة (${activePattern.shortTitle})' : 'يوم عمل مجدول',
        );

        if (existingIndex != -1) {
          _attendance[existingIndex] = record;
        } else {
          _attendance.add(record);
        }
      }
    }

    notifyListeners();
    await _saveData();
  }

  bool isWorkDayForPattern(DateTime date, WorkShiftPattern pattern, [int offset = 0]) {
    if (date.weekday == DateTime.friday) return false;
    final dayNumber = date.day + offset;
    switch (pattern) {
      case WorkShiftPattern.dayWorkDayRest:
        return dayNumber % 2 == 1; // يوم عمل ثم يوم راحة
      case WorkShiftPattern.dayWorkTwoDaysRest:
        return dayNumber % 3 == 1; // يوم عمل ثم يومان راحة
      case WorkShiftPattern.monthContinuous:
        return true; // طوال الشهر
      case WorkShiftPattern.twoDaysWorkDayRest:
        return (dayNumber % 3 == 1 || dayNumber % 3 == 2); // يومان عمل ثم يوم راحة
    }
  }

  List<Bus> get buses => List.unmodifiable(_buses);
  List<Driver> get drivers => List.unmodifiable(_drivers);
  List<Trip> get trips => List.unmodifiable(_trips);
  List<Attendance> get attendance => List.unmodifiable(_attendance);
  List<Payroll> get payrolls => List.unmodifiable(_payrolls);

  // Filtered lists
  List<Bus> get bigBuses => _buses.where((b) => b.isBigBus).toList();
  List<Driver> get activeDrivers => _drivers.where((d) => d.isActive).toList();

  // Dashboard KPI Computations (تم حذف الوقود والتركيز على الإيرادات والأداء)
  int get totalTripsMonth {
    return _trips.where((t) => t.date.year == _selectedYear && t.date.month == _selectedMonth).length;
  }

  int get activeDriversCount => activeDrivers.length;

  double get totalRevenueMonth {
    return _trips
        .where((t) => t.date.year == _selectedYear && t.date.month == _selectedMonth)
        .fold(0.0, (sum, t) => sum + t.revenueDzd);
  }

  double get averageRevenuePerTrip {
    if (totalTripsMonth == 0) return 0.0;
    return totalRevenueMonth / totalTripsMonth;
  }

  // 50-Seat Big Buses KPI Computations
  int get bigBusesCount => bigBuses.length;

  List<Trip> get bigBusTrips {
    final bigBusIds = bigBuses.map((b) => b.id).toSet();
    return _trips.where((t) =>
        bigBusIds.contains(t.busId) &&
        t.date.year == _selectedYear &&
        t.date.month == _selectedMonth).toList();
  }

  int get bigBusTripsCount => bigBusTrips.length;

  int get bigBusPassengersCount =>
      bigBusTrips.fold(0, (sum, t) => sum + t.passengerCount);

  double get bigBusOccupancyRate {
    if (bigBusTrips.isEmpty) return 0.0;
    int totalSeatsAvailable = 0;
    int totalPassengers = 0;

    for (final trip in bigBusTrips) {
      final bus = getBusById(trip.busId);
      final cap = bus?.capacity ?? 50;
      totalSeatsAvailable += cap;
      totalPassengers += trip.passengerCount;
    }

    if (totalSeatsAvailable == 0) return 0.0;
    return (totalPassengers / totalSeatsAvailable) * 100.0;
  }

  double get bigBusAveragePassengersPerTrip {
    if (bigBusTrips.isEmpty) return 0.0;
    return bigBusPassengersCount / bigBusTrips.length;
  }

  // Lookup helpers
  Bus? getBusById(String id) {
    try {
      return _buses.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  Driver? getDriverById(String id) {
    try {
      return _drivers.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Attendance> getAttendanceForDriver(String driverId) {
    return _attendance.where((a) => a.driverId == driverId).toList();
  }

  Attendance? getAttendanceForDriverDate(String driverId, DateTime date) {
    try {
      return _attendance.firstWhere((a) =>
          a.driverId == driverId &&
          a.date.year == date.year &&
          a.date.month == date.month &&
          a.date.day == date.day);
    } catch (_) {
      return null;
    }
  }

  // Actions
  Future<void> addTrip(Trip trip) async {
    _trips.insert(0, trip);

    final bus = getBusById(trip.busId);
    if (bus != null && trip.endMileage > bus.currentMileage) {
      final updatedBus = bus.copyWith(currentMileage: trip.endMileage);
      final index = _buses.indexWhere((b) => b.id == bus.id);
      if (index != -1) {
        _buses[index] = updatedBus;
      }
    }

    notifyListeners();
    await _saveData();
  }

  Future<void> deleteTrip(String tripId) async {
    _trips.removeWhere((t) => t.id == tripId);
    notifyListeners();
    await _saveData();
  }

  Future<void> addBus(Bus bus) async {
    _buses.add(bus);
    notifyListeners();
    await _saveData();
  }

  Future<void> updateBus(Bus updatedBus) async {
    final index = _buses.indexWhere((b) => b.id == updatedBus.id);
    if (index != -1) {
      _buses[index] = updatedBus;
      notifyListeners();
      await _saveData();
    }
  }

  Future<void> deleteBus(String busId) async {
    _buses.removeWhere((b) => b.id == busId);
    notifyListeners();
    await _saveData();
  }

  Future<void> addDriver(Driver driver) async {
    _drivers.add(driver);
    notifyListeners();
    await _saveData();
  }

  Future<void> updateDriver(Driver updatedDriver) async {
    final index = _drivers.indexWhere((d) => d.id == updatedDriver.id);
    if (index != -1) {
      _drivers[index] = updatedDriver;
      notifyListeners();
      await _saveData();
    }
  }

  Future<void> deleteDriver(String driverId) async {
    _drivers.removeWhere((d) => d.id == driverId);
    notifyListeners();
    await _saveData();
  }

  Future<void> markAttendance({
    required String driverId,
    required DateTime date,
    required AttendanceStatus status,
    String checkInTime = '07:00',
    String checkOutTime = '16:00',
    double workingHours = 8.0,
    double overtimeHours = 0.0,
    String notes = '',
  }) async {
    final existingIndex = _attendance.indexWhere((a) =>
        a.driverId == driverId &&
        a.date.year == date.year &&
        a.date.month == date.month &&
        a.date.day == date.day);

    final record = Attendance(
      id: existingIndex != -1
          ? _attendance[existingIndex].id
          : 'att_${DateTime.now().millisecondsSinceEpoch}',
      driverId: driverId,
      date: DateTime(date.year, date.month, date.day),
      status: status,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      workingHours: workingHours,
      overtimeHours: overtimeHours,
      notes: notes,
    );

    if (existingIndex != -1) {
      _attendance[existingIndex] = record;
    } else {
      _attendance.add(record);
    }

    notifyListeners();
    await _saveData();
  }

  Future<void> generateOrUpdatePayroll({
    required String driverId,
    required int month,
    required int year,
    double? customIncentives,
    double? customDeductions,
    String notes = '',
  }) async {
    final driver = getDriverById(driverId);
    if (driver == null) return;

    final driverTrips = _trips.where((t) =>
        t.driverId == driverId &&
        t.date.year == year &&
        t.date.month == month &&
        t.status == TripStatus.completed).toList();

    final tripBonuses = driverTrips.length * driver.tripBonusRate;

    final driverAtt = _attendance.where((a) =>
        a.driverId == driverId &&
        a.date.year == year &&
        a.date.month == month).toList();

    double totalOvertimeHours = 0.0;
    int absentDays = 0;

    for (final att in driverAtt) {
      if (att.status == AttendanceStatus.absent) absentDays++;
      totalOvertimeHours += att.overtimeHours;
    }

    final overtimePay = totalOvertimeHours * 500.0;
    final dailyRate = driver.baseSalary / 26.0;
    final calculatedDeductions = (absentDays * dailyRate) + (customDeductions ?? 0.0);

    final existingIndex = _payrolls.indexWhere((p) =>
        p.driverId == driverId && p.month == month && p.year == year);

    final payroll = Payroll(
      id: existingIndex != -1
          ? _payrolls[existingIndex].id
          : 'pay_${driverId}_${year}_$month',
      driverId: driverId,
      month: month,
      year: year,
      baseSalary: driver.baseSalary,
      completedTripsCount: driverTrips.length,
      tripBonuses: tripBonuses,
      overtimeHours: totalOvertimeHours,
      overtimePay: overtimePay,
      incentives: customIncentives ?? 0.0,
      deductions: calculatedDeductions,
      isPaid: existingIndex != -1 ? _payrolls[existingIndex].isPaid : false,
      paymentDate: existingIndex != -1 ? _payrolls[existingIndex].paymentDate : null,
      notes: notes,
    );

    if (existingIndex != -1) {
      _payrolls[existingIndex] = payroll;
    } else {
      _payrolls.add(payroll);
    }

    notifyListeners();
    await _saveData();
  }

  Future<void> togglePayrollPaid(String payrollId) async {
    final index = _payrolls.indexWhere((p) => p.id == payrollId);
    if (index != -1) {
      final current = _payrolls[index];
      final newStatus = !current.isPaid;
      _payrolls[index] = current.copyWith(
        isPaid: newStatus,
        paymentDate: newStatus ? DateTime.now() : null,
      );
      notifyListeners();
      await _saveData();
    }
  }

  // Persistence & Initial Mock Data
  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final busesJson = prefs.getString('fleet_buses');
      final driversJson = prefs.getString('fleet_drivers');
      final tripsJson = prefs.getString('fleet_trips');
      final attJson = prefs.getString('fleet_attendance');
      final payJson = prefs.getString('fleet_payrolls');

      if (busesJson != null && driversJson != null && tripsJson != null) {
        _buses = (json.decode(busesJson) as List)
            .map((item) => Bus.fromMap(item))
            .toList();
        _drivers = (json.decode(driversJson) as List)
            .map((item) => Driver.fromMap(item))
            .toList();
        _trips = (json.decode(tripsJson) as List)
            .map((item) => Trip.fromMap(item))
            .toList();
        if (attJson != null) {
          _attendance = (json.decode(attJson) as List)
              .map((item) => Attendance.fromMap(item))
              .toList();
        }
        if (payJson != null) {
          _payrolls = (json.decode(payJson) as List)
              .map((item) => Payroll.fromMap(item))
              .toList();
        }
      } else {
        _seedInitialData();
      }
    } catch (e) {
      _seedInitialData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'fleet_buses', json.encode(_buses.map((b) => b.toMap()).toList()));
      await prefs.setString(
          'fleet_drivers', json.encode(_drivers.map((d) => d.toMap()).toList()));
      await prefs.setString(
          'fleet_trips', json.encode(_trips.map((t) => t.toMap()).toList()));
      await prefs.setString(
          'fleet_attendance', json.encode(_attendance.map((a) => a.toMap()).toList()));
      await prefs.setString(
          'fleet_payrolls', json.encode(_payrolls.map((p) => p.toMap()).toList()));
    } catch (_) {}
  }

  void _seedInitialData() {
    _drivers = [
      Driver(
        id: 'd1',
        name: 'عبد القادر بن حمودة',
        phone: '0550 12 34 56',
        licenseNumber: 'DZ-16/094832',
        licenseExpiry: DateTime.now().add(const Duration(days: 420)),
        baseSalary: 55000.0,
        tripBonusRate: 1500.0,
        rating: 4.9,
        isActive: true,
        shiftPattern: WorkShiftPattern.dayWorkDayRest,
      ),
      Driver(
        id: 'd2',
        name: 'مولود ياحي',
        phone: '0661 78 90 12',
        licenseNumber: 'DZ-09/441203',
        licenseExpiry: DateTime.now().add(const Duration(days: 300)),
        baseSalary: 52000.0,
        tripBonusRate: 1500.0,
        rating: 4.8,
        isActive: true,
        shiftPattern: WorkShiftPattern.dayWorkDayRest,
      ),
      Driver(
        id: 'd3',
        name: 'جمال بوفرة',
        phone: '0772 33 44 55',
        licenseNumber: 'DZ-35/112940',
        licenseExpiry: DateTime.now().add(const Duration(days: 180)),
        baseSalary: 50000.0,
        tripBonusRate: 1400.0,
        rating: 4.7,
        isActive: true,
        shiftPattern: WorkShiftPattern.dayWorkDayRest,
      ),
      Driver(
        id: 'd4',
        name: 'سفيان بن عيسى',
        phone: '0560 99 88 77',
        licenseNumber: 'DZ-16/883019',
        licenseExpiry: DateTime.now().add(const Duration(days: 600)),
        baseSalary: 48000.0,
        tripBonusRate: 1200.0,
        rating: 4.6,
        isActive: true,
        shiftPattern: WorkShiftPattern.dayWorkDayRest,
      ),
    ];

    _buses = [
      Bus(
        id: 'b1',
        busNumber: 'حافلة 101 (سوبر VIP)',
        plateNumber: '00142-120-16',
        capacity: 50,
        model: 'مرسيدس توريزمو (Mercedes Tourismo)',
        assignedDriverId: 'd1',
        status: BusStatus.active,
        currentMileage: 142500,
      ),
      Bus(
        id: 'b2',
        busNumber: 'حافلة 102 (الخط السريع)',
        plateNumber: '01893-118-16',
        capacity: 50,
        model: 'هايجر سياحية (Higer Bus 50S)',
        assignedDriverId: 'd2',
        status: BusStatus.active,
        currentMileage: 98400,
      ),
      Bus(
        id: 'b3',
        busNumber: 'حافلة 103 (الأسطول الماسي)',
        plateNumber: '02541-122-16',
        capacity: 50,
        model: 'فولفو B11R سعة 50 راكب',
        assignedDriverId: 'd3',
        status: BusStatus.onTrip,
        currentMileage: 64120,
      ),
      Bus(
        id: 'b4',
        busNumber: 'حافلة 104 (النقل الجامعي)',
        plateNumber: '00778-119-16',
        capacity: 50,
        model: 'كينغ لونغ (King Long XMQ6127)',
        assignedDriverId: 'd4',
        status: BusStatus.active,
        currentMileage: 185000,
      ),
      Bus(
        id: 'b5',
        busNumber: 'حافلة ميني 201',
        plateNumber: '03412-121-16',
        capacity: 30,
        model: 'تويوتا كوستر (Toyota Coaster)',
        assignedDriverId: null,
        status: BusStatus.maintenance,
        currentMileage: 112000,
      ),
    ];

    final now = DateTime.now();
    _trips = [
      Trip(
        id: 't1',
        tripCode: 'TRP-101',
        busId: 'b1',
        driverId: 'd1',
        routeName: 'الجزائر العاصمة ⟵ وهران',
        date: now.subtract(const Duration(hours: 4)),
        departureTime: '06:30',
        arrivalTime: '11:45',
        passengerCount: 48,
        revenueDzd: 72000.0,
        startMileage: 142050,
        endMileage: 142500,
        status: TripStatus.completed,
      ),
      Trip(
        id: 't2',
        tripCode: 'TRP-102',
        busId: 'b2',
        driverId: 'd2',
        routeName: 'الجزائر العاصمة ⟵ قسنطينة',
        date: now.subtract(const Duration(hours: 8)),
        departureTime: '07:00',
        arrivalTime: '12:30',
        passengerCount: 46,
        revenueDzd: 69000.0,
        startMileage: 98010,
        endMileage: 98400,
        status: TripStatus.completed,
      ),
      Trip(
        id: 't3',
        tripCode: 'TRP-103',
        busId: 'b3',
        driverId: 'd3',
        routeName: 'الجزائر العاصمة ⟵ سطيف',
        date: now,
        departureTime: '09:00',
        arrivalTime: '13:00',
        passengerCount: 49,
        revenueDzd: 58800.0,
        startMileage: 63820,
        endMileage: 64120,
        status: TripStatus.inProgress,
      ),
      Trip(
        id: 't4',
        tripCode: 'TRP-104',
        busId: 'b4',
        driverId: 'd4',
        routeName: 'خط نقل الموظفين (بومرداس - الرويبة)',
        date: now.subtract(const Duration(days: 1)),
        departureTime: '06:45',
        arrivalTime: '08:00',
        passengerCount: 50,
        revenueDzd: 45000.0,
        startMileage: 184930,
        endMileage: 185000,
        status: TripStatus.completed,
      ),
    ];

    // Auto-fill initial attendance using shift pattern
    autoFillAttendanceForMonth(month: now.month, year: now.year);

    _payrolls = [
      Payroll(
        id: 'pay_d1_current',
        driverId: 'd1',
        month: now.month,
        year: now.year,
        baseSalary: 55000.0,
        completedTripsCount: 14,
        tripBonuses: 21000.0,
        overtimeHours: 6.0,
        overtimePay: 3000.0,
        incentives: 5000.0,
        deductions: 0.0,
        isPaid: false,
        notes: 'سائق متميز والتزام تام بالمواعيد',
      ),
      Payroll(
        id: 'pay_d2_current',
        driverId: 'd2',
        month: now.month,
        year: now.year,
        baseSalary: 52000.0,
        completedTripsCount: 12,
        tripBonuses: 18000.0,
        overtimeHours: 4.0,
        overtimePay: 2000.0,
        incentives: 2500.0,
        deductions: 0.0,
        isPaid: false,
      ),
    ];
  }
}
