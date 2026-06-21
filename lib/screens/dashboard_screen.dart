import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/business_provider.dart';
import '../widgets/summary_card.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/transaction_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadBusinesses();
  }

  void _loadBusinesses() {
    final auth = context.read<AppAuthProvider>();
    final bp = context.read<BusinessProvider>();
    if (auth.firebaseUser != null && bp.businesses.isEmpty) {
      bp.loadBusinesses(auth.firebaseUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final bp = context.watch<BusinessProvider>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, auth, bp),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryCardsSection(),
                    SizedBox(height: 24),
                    _QuickActionsSection(),
                    SizedBox(height: 24),
                    _RecentTransactionsSection(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildAppBar(BuildContext context, AppAuthProvider auth, BusinessProvider bp) {
    final businessName = bp.currentBusiness?.name ?? auth.userProfile?.businessName ?? 'Zuraiz Traders';
    final greeting = auth.userProfile?.fullName != null
        ? 'Welcome, ${auth.userProfile!.fullName.split(' ').first}'
        : 'Assalam o Alaikum';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.book_rounded,
              color: Color(0xFF1565C0),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showBusinessSwitcher(context, bp),
                  child: Row(
                    children: [
                      Text(
                        businessName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (bp.businesses.length > 1)
                        Icon(Icons.arrow_drop_down, color: Colors.grey.shade600, size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) async {
              if (value == 'staff') {
                Navigator.pushNamed(context, '/staff');
              } else if (value == 'add-business') {
                Navigator.pushNamed(context, '/business-setup');
              } else if (value == 'logout') {
                await context.read<AppAuthProvider>().signOut();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'staff', child: Text('Staff')),
              const PopupMenuItem(value: 'add-business', child: Text('Add Business')),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBusinessSwitcher(BuildContext context, BusinessProvider bp) {
    if (bp.businesses.length <= 1) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Switch Business',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...bp.businesses.map(
                (b) => ListTile(
                  leading: const Icon(Icons.store_outlined),
                  title: Text(b.name),
                  trailing: b.id == bp.currentBusiness?.id
                      ? const Icon(Icons.check, color: Color(0xFF1565C0))
                      : null,
                  onTap: () {
                    bp.switchBusiness(b.id);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1565C0),
        unselectedItemColor: Colors.grey.shade400,
        currentIndex: 0,
            onTap: (index) {
              if (index == 1) Navigator.pushNamed(context, '/customers');
              if (index == 2) Navigator.pushNamed(context, '/suppliers');
            },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: 'Customers'),
          BottomNavigationBarItem(icon: Icon(Icons.business_rounded), label: 'Suppliers'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}

class _SummaryCardsSection extends StatelessWidget {
  const _SummaryCardsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Total Receivable',
                amount: 'Rs. 125,000',
                icon: Icons.trending_up,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryCard(
                title: 'Total Payable',
                amount: 'Rs. 48,500',
                icon: Icons.trending_down,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Today Cash In',
                amount: 'Rs. 22,000',
                icon: Icons.arrow_downward,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryCard(
                title: 'Today Cash Out',
                amount: 'Rs. 9,500',
                icon: Icons.arrow_upward,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            QuickActionCard(
              label: 'Add Customer',
              icon: Icons.person_add_alt_1,
              color: Colors.blue,
              onTap: () => Navigator.pushNamed(context, '/customers'),
            ),
            QuickActionCard(
              label: 'Add Supplier',
              icon: Icons.business,
              color: Colors.purple,
              onTap: () => Navigator.pushNamed(context, '/suppliers'),
            ),
            QuickActionCard(
              label: 'Cash In',
              icon: Icons.payments,
              color: Colors.green,
              onTap: () => Navigator.pushNamed(context, '/add-udhaar'),
            ),
            QuickActionCard(
              label: 'Cash Out',
              icon: Icons.money_off,
              color: Colors.red,
              onTap: () => Navigator.pushNamed(context, '/add-udhaar'),
            ),
            QuickActionCard(
              label: 'Add Udhaar',
              icon: Icons.receipt_long,
              color: Colors.orange,
              onTap: () => Navigator.pushNamed(context, '/add-udhaar'),
            ),
            QuickActionCard(
              label: 'Reports',
              icon: Icons.bar_chart,
              color: Colors.teal,
            ),
          ],
        ),
      ],
    );
  }
}

class _RecentTransactionsSection extends StatelessWidget {
  const _RecentTransactionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View All',
                style: TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: const [
                TransactionTile(
                  name: 'Ali Khan',
                  type: 'You Got',
                  amount: '+ Rs. 5,000',
                  isPositive: true,
                ),
                Divider(height: 1),
                TransactionTile(
                  name: 'Ahmed Store',
                  type: 'You Gave',
                  amount: '- Rs. 2,500',
                  isPositive: false,
                ),
                Divider(height: 1),
                TransactionTile(
                  name: 'Cash Sale',
                  type: 'Cash In',
                  amount: '+ Rs. 8,000',
                  isPositive: true,
                ),
                Divider(height: 1),
                TransactionTile(
                  name: 'Rent Paid',
                  type: 'Cash Out',
                  amount: '- Rs. 12,000',
                  isPositive: false,
                ),
                Divider(height: 1),
                TransactionTile(
                  name: 'Hassan Traders',
                  type: 'You Got',
                  amount: '+ Rs. 3,500',
                  isPositive: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
