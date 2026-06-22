import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/business_provider.dart';
import 'providers/staff_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/supplier_provider.dart';
import 'providers/ledger_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/invoice_provider.dart';
import 'providers/report_provider.dart';
import 'providers/security_provider.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/business_setup_screen.dart';
import 'screens/staff_screen.dart';
import 'screens/customer_screen.dart';
import 'screens/supplier_screen.dart';
import 'screens/add_udhaar_screen.dart';
import 'screens/cash_transaction_screen.dart';
import 'screens/whatsapp_reminder_screen.dart';
import 'screens/invoice_screen.dart';
import 'screens/create_invoice_screen.dart';
import 'screens/report_screen.dart';
import 'screens/export_screen.dart';
import 'screens/backup_screen.dart';
import 'screens/pin_lock_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/main_shell.dart';
import 'screens/more_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
        ChangeNotifierProvider(create: (_) => BusinessProvider()),
        ChangeNotifierProvider(create: (_) => StaffProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => SupplierProvider()),
        ChangeNotifierProvider(create: (_) => LedgerProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => SecurityProvider()),
      ],
      child: const DigiKhataApp(),
    ),
  );
}

class DigiKhataApp extends StatelessWidget {
  const DigiKhataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digi Khata',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shadowColor: Colors.black.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Color(0xFF1565C0),
          unselectedItemColor: Colors.grey,
        ),
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/business-setup': (context) => const BusinessSetupScreen(),
        '/staff': (context) => const StaffScreen(),
        '/customers': (context) => const CustomerScreen(),
        '/suppliers': (context) => const SupplierScreen(),
        '/add-udhaar': (context) => const AddUdhaarScreen(),
        '/cash-in': (context) => const CashTransactionScreen(isCashIn: true),
        '/cash-out': (context) => const CashTransactionScreen(isCashIn: false),
        '/invoices': (context) => const InvoiceScreen(),
        '/whatsapp-reminder': (context) => const WhatsAppReminderScreen(),
        '/create-invoice': (context) => const CreateInvoiceScreen(),
        '/reports': (context) => const ReportScreen(),
        '/export': (context) => const ExportScreen(),
        '/backup': (context) => const BackupScreen(),
        '/security': (context) => const PinLockScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/more': (context) => const MoreScreen(),
      },
      home: Consumer<AppAuthProvider>(
        builder: (context, auth, _) {
          if (auth.isLoggedIn) {
            return const MainShell();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
