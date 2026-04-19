import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';

class CustomerScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final FloatingActionButton? floatingActionButton;

  const CustomerScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
  });

  static const List<BottomNavItem> _navItems = [
    BottomNavItem(icon: Icons.home_outlined,       activeIcon: Icons.home,        label: 'Beranda'),
    BottomNavItem(icon: Icons.assignment_outlined, activeIcon: Icons.assignment,  label: 'Pesanan'),
    BottomNavItem(icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble, label: 'Chat'),
    BottomNavItem(icon: Icons.person_outline,      activeIcon: Icons.person,      label: 'Profil'),
  ];

  static const List<String> _routes = [
    RouteNames.customerHome,
    RouteNames.customerOrders,
    RouteNames.customerChatRooms,
    RouteNames.customerProfile,
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _routes.indexOf(location);
    return index < 0 ? 0 : index;
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
    );
  }
}