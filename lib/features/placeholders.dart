// This file provides temporary placeholder screens for all routes
// Will be replaced with actual screens in later phases

import 'package:flutter/material.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Coming Soon - Phase 1.x',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// Super Admin Screens
class SuperAdminDashboardScreen extends StatelessWidget {
  const SuperAdminDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderScreen(title: 'Super Admin Dashboard');
}

class SuperAdminDivisionsListScreen extends StatelessWidget {
  const SuperAdminDivisionsListScreen({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderScreen(title: 'Divisions');
}

class SuperAdminDivisionDetailScreen extends StatelessWidget {
  final int divisionId;
  const SuperAdminDivisionDetailScreen({super.key, required this.divisionId});
  @override
  Widget build(BuildContext context) => PlaceholderScreen(title: 'Division Detail #$divisionId');
}

class SuperAdminUserDetailScreen extends StatelessWidget {
  final int userId;
  const SuperAdminUserDetailScreen({super.key, required this.userId});
  @override
  Widget build(BuildContext context) => PlaceholderScreen(title: 'User Detail #$userId');
}

class SuperAdminOrdersListScreen extends StatelessWidget {
  const SuperAdminOrdersListScreen({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderScreen(title: 'All Orders');
}

class SuperAdminOrderDetailScreen extends StatelessWidget {
  final int orderId;
  const SuperAdminOrderDetailScreen({super.key, required this.orderId});
  @override
  Widget build(BuildContext context) => PlaceholderScreen(title: 'Order Detail #$orderId');
}

class SuperAdminReportsScreen extends StatelessWidget {
  const SuperAdminReportsScreen({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderScreen(title: 'Global Reports');
}

class SuperAdminNotificationsScreen extends StatelessWidget {
  const SuperAdminNotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderScreen(title: 'Notifications');
}

class SuperAdminProfileScreen extends StatelessWidget {
  const SuperAdminProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderScreen(title: 'Profile');
}