import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/fleet_provider.dart';
import 'views/dashboard_screen.dart';
import 'views/trips_screen.dart';
import 'views/fleet_screen.dart';
import 'views/attendance_screen.dart';
import 'views/payroll_screen.dart';
import 'views/drivers_screen.dart';
import 'widgets/app_header.dart';
import 'widgets/record_trip_dialog.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FleetProvider()),
      ],
      child: const BusFleetApp(),
    ),
  );
}

class BusFleetApp extends StatelessWidget {
  const BusFleetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'إدارة أسطول الحافلات - مؤسسة سويقات أبو طالب',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox(),
        );
      },
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        primaryColor: const Color(0xFF2563EB),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2563EB),
          secondary: Color(0xFF0284C7),
          surface: Colors.white,
        ),
        cardColor: Colors.white,
        textTheme: GoogleFonts.cairoTextTheme(ThemeData.light().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentTabIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(
        onNavigateToTrips: () => _onTabSelected(1),
        onNavigateToFleet: () => _onTabSelected(2),
      ),
      const TripsScreen(),
      const FleetScreen(),
      const AttendanceScreen(),
      const PayrollScreen(),
      const DriversScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top App Header matching the image
            AppHeader(
              selectedTabIndex: _currentTabIndex,
              onTabSelected: _onTabSelected,
              onOpenDrivers: () => _onTabSelected(5),
              onRecordTrip: () {
                showDialog(
                  context: context,
                  builder: (_) => const RecordTripDialog(),
                );
              },
            ),

            // Active Tab View
            Expanded(
              child: IndexedStack(
                index: _currentTabIndex,
                children: screens,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const RecordTripDialog(),
          );
        },
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          'تسجيل رحلة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
