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

// Employee Screens
class EmployeeTasksListScreen extends StatelessWidget {
  const EmployeeTasksListScreen({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderScreen(title: 'My Tasks');
}

class EmployeeTaskDetailScreen extends StatelessWidget {
  final int orderId;
  const EmployeeTaskDetailScreen({super.key, required this.orderId});
  @override
  Widget build(BuildContext context) => PlaceholderScreen(title: 'Task Detail #$orderId');
}

class EmployeeDocumentationsListScreen extends StatelessWidget {
  const EmployeeDocumentationsListScreen({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderScreen(title: 'Documentations');
}

class OrderDocumentationsScreen extends StatelessWidget {
  final int orderId;
  const OrderDocumentationsScreen({super.key, required this.orderId});
  @override
  Widget build(BuildContext context) => PlaceholderScreen(title: 'Order Docs #$orderId');
}

class AddDocumentationScreen extends StatelessWidget {
  final int orderId;
  const AddDocumentationScreen({super.key, required this.orderId});
  @override
  Widget build(BuildContext context) => PlaceholderScreen(title: 'Add Documentation');
}

class EmployeeChatRoomsScreen extends StatelessWidget {
  const EmployeeChatRoomsScreen({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderScreen(title: 'Chat Rooms');
}

class EmployeeChatScreen extends StatelessWidget {
  final int roomId;
  const EmployeeChatScreen({super.key, required this.roomId});
  @override
  Widget build(BuildContext context) => PlaceholderScreen(title: 'Chat Room #$roomId');
}

class EmployeeNotificationsScreen extends StatelessWidget {
  const EmployeeNotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderScreen(title: 'Notifications');
}

class EmployeeProfileScreen extends StatelessWidget {
  const EmployeeProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderScreen(title: 'Profile');
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