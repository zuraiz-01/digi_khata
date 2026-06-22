import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/business_provider.dart';
import 'dashboard_screen.dart';
import 'customer_screen.dart';
import 'supplier_screen.dart';
import 'report_screen.dart';
import 'more_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initLoad());
  }

  Future<void> _initLoad() async {
    final auth = context.read<AppAuthProvider>();
    final bp = context.read<BusinessProvider>();
    if (auth.isLoggedIn && !bp.hasLoaded) {
      await bp.loadBusinesses(auth.firebaseUser!.uid);
    }
    if (mounted) setState(() => _initialLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_initialLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final tabs = <Widget>[
      const DashboardScreen(),
      const CustomerScreen(),
      const SupplierScreen(),
      const ReportScreen(),
      const MoreScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -3)),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: const Color(0xFF1565C0),
              unselectedItemColor: Colors.grey.shade400,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
                BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: 'Customers'),
                BottomNavigationBarItem(icon: Icon(Icons.business_rounded), label: 'Suppliers'),
                BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Reports'),
                BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'More'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
