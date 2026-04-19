import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/widgets/app_bottom_nav_bar.dart';

class SuperAdminScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final FloatingActionButton? floatingActionButton;
  final Widget? bottomSheet;

  const SuperAdminScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomSheet,
  });

  static const List<BottomNavItem> _navItems = [
    BottomNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
    ),
    BottomNavItem(
      icon: Icons.business_outlined,
      activeIcon: Icons.business,
      label: 'Divisi',
    ),
    BottomNavItem(
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment,
      label: 'Pesanan',
    ),
    BottomNavItem(
      icon: Icons.bar_chart,
      activeIcon: Icons.bar_chart,
      label: 'Laporan',
    ),
    BottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profil',
    ),
  ];

  static const List<String> _routes = [
    RouteNames.superAdminDashboard,
    RouteNames.superAdminDivisions,
    RouteNames.superAdminOrders,
    RouteNames.superAdminReports,
    RouteNames.superAdminProfile,
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    
    final exactIndex = _routes.indexOf(location);
    if (exactIndex >= 0) return exactIndex;
    
    for (int i = 0; i < _routes.length; i++) {
      if (location.startsWith(_routes[i])) {
        return i;
      }
    }
    
    return 0;
  }

  void _onNavTap(BuildContext context, int index) {
    if (index == _currentIndex(context)) return;
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex(context),
        items: _navItems,
        onTap: (index) => _onNavTap(context, index),
      ),
      bottomSheet: bottomSheet,
    );
  }
}