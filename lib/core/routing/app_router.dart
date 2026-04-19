import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jasafix_app/features/shared/profile/screens/edit_profile_screen.dart';
import '../../providers/app_state.dart';
import '../constants/app_config.dart';
import 'route_names.dart';
import '../../data/models/user_model.dart'; 

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/role_selector_screen.dart';
import '../../features/shared/help/screens/help_center_screen.dart';

import '../../features/customer/home/screens/home_screen.dart';
import '../../features/customer/division/screens/division_detail_screen.dart';
import '../../features/customer/division/screens/service_detail_screen.dart';
import '../../features/customer/orders/screens/orders_list_screen.dart';
import '../../features/customer/orders/screens/order_detail_screen.dart';
import '../../features/customer/orders/screens/create_order_screen.dart';
import '../../features/customer/orders/screens/upload_payment_screen.dart';
import '../../features/customer/chat/screens/chat_rooms_list_screen.dart';
import '../../features/customer/chat/screens/chat_screen.dart';
import '../../features/customer/review/screens/write_review_screen.dart';
import '../../features/customer/notifications/screens/notifications_screen.dart';
import '../../features/customer/profile/screens/profile_screen.dart';
import '../../features/customer/address/screens/saved_addresses_screen.dart';

import '../../features/admin/dashboard/screens/dashboard_screen.dart';
import '../../features/admin/orders/screens/orders_list_screen.dart';
import '../../features/admin/orders/screens/order_detail_screen.dart';
import '../../features/admin/orders/screens/verify_payment_screen.dart';
import '../../features/admin/chat/screens/chat_rooms_list_screen.dart';
import '../../features/admin/chat/screens/chat_screen.dart';
import '../../features/admin/team/screens/team_list_screen.dart';
import '../../features/admin/team/screens/employee_detail_screen.dart';
import '../../features/admin/finance/screens/reports_screen.dart';
import '../../features/admin/notifications/screens/notifications_screen.dart';
import '../../features/admin/profile/screens/profile_screen.dart';

import '../../features/employee/tasks/screens/tasks_list_screen.dart';
import '../../features/employee/settings/screens/settings_screen.dart';
import '../../features/employee/tasks/screens/task_detail_screen.dart';
import '../../features/employee/documentation/screens/documentations_list_screen.dart';
import '../../features/employee/documentation/screens/order_documentations_screen.dart';
import '../../features/employee/documentation/screens/add_documentation_screen.dart';
import '../../features/employee/chat/screens/chat_rooms_list_screen.dart';
import '../../features/employee/chat/screens/chat_screen.dart';
import '../../features/employee/notifications/screens/notifications_screen.dart';
import '../../features/employee/profile/screens/profile_screen.dart';
import '../../features/admin/settings/screens/settings_screen.dart';

import '../../features/super_admin/dashboard/screens/dashboard_screen.dart';
import '../../features/super_admin/divisions/screens/divisions_list_screen.dart';
import '../../features/super_admin/divisions/screens/division_detail_screen.dart';
import '../../features/super_admin/users/screens/user_detail_screen.dart';
import '../../features/super_admin/orders/screens/orders_list_screen.dart';
import '../../features/super_admin/orders/screens/order_detail_screen.dart';
import '../../features/super_admin/finance/screens/reports_screen.dart';
import '../../features/super_admin/notifications/screens/notifications_screen.dart';
import '../../features/super_admin/profile/screens/profile_screen.dart';
import '../../features/super_admin/settings/screens/app_settings_screen.dart';
import '../../features/super_admin/users/screens/user_management_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
  
  static GoRouter createRouter(AppState appState) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: RouteNames.login,
      debugLogDiagnostics: AppConfig.debugMode,
      redirect: (context, state) {
        final isLoggedIn = appState.isLoggedIn;
        final isLoginRoute = state.matchedLocation == RouteNames.login;
        final isRoleSelectorRoute = state.matchedLocation == RouteNames.roleSelector;
        
        if (!isLoggedIn && !isLoginRoute && !isRoleSelectorRoute) {
          return RouteNames.login;
        }
        
        if (isLoggedIn && isLoginRoute) {
          return _getHomeRoute(appState.currentRole!);
        }
        
        return null;
      },
      routes: [
        // ============================================================
        // AUTH ROUTES
        // ============================================================
        GoRoute(
          path: RouteNames.login,
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: RouteNames.roleSelector,
          name: 'roleSelector',
          builder: (context, state) => const RoleSelectorScreen(),
        ),

        GoRoute(
          path: RouteNames.editProfile,
          name: 'editProfile',
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: RouteNames.helpCenter,
          name: 'helpCenter',
          builder: (context, state) => const HelpCenterScreen(),
        ),
        
        // ============================================================
        // CUSTOMER ROUTES
        // ============================================================
        ..._buildCustomerRoutes(),
        
        // ============================================================
        // ADMIN ROUTES
        // ============================================================
        ..._buildAdminRoutes(),
        
        // ============================================================
        // EMPLOYEE ROUTES
        // ============================================================
        ..._buildEmployeeRoutes(),
        
        // ============================================================
        // SUPER ADMIN ROUTES
        // ============================================================
        ..._buildSuperAdminRoutes(),
      ],
    );
  }
  
  static String _getHomeRoute(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return RouteNames.customerHome;
      case UserRole.admin:
        return RouteNames.adminDashboard;
      case UserRole.employee:
        return RouteNames.employeeTasks;
      case UserRole.superAdmin:
        return RouteNames.superAdminDashboard;
    }
  }
  
  // ============================================================
  // CUSTOMER ROUTE BUILDER
  // ============================================================
  static List<RouteBase> _buildCustomerRoutes() {
    return [
      GoRoute(
        path: RouteNames.customerHome,
        name: 'customerHome',
        builder: (context, state) => const CustomerHomeScreen(),
      ),
      GoRoute(
        path: RouteNames.customerDivisionDetail,
        name: 'customerDivisionDetail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return CustomerDivisionDetailScreen(divisionId: id);
        },
      ),
      GoRoute(
        path: RouteNames.customerServiceDetail,
        name: 'customerServiceDetail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ServiceDetailScreen(serviceId: id);
        },
      ),
      GoRoute(
        path: RouteNames.customerChatRooms,
        name: 'customerChatRooms',
        builder: (context, state) => const CustomerChatRoomsScreen(),
      ),
      GoRoute(
        path: RouteNames.customerChat,
        name: 'customerChat',
        builder: (context, state) {
          final roomId = int.parse(state.pathParameters['roomId']!);
          return CustomerChatScreen(roomId: roomId);
        },
      ),
      GoRoute(
        path: RouteNames.customerCreateOrder,
        name: 'customerCreateOrder',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return CreateOrderScreen(
            serviceId: extra?['serviceId'],
            divisionId: extra?['divisionId'],
          );
        },
      ),
      GoRoute(
        path: RouteNames.customerUploadPayment,
        name: 'customerUploadPayment',
        builder: (context, state) {
          final orderId = int.parse(state.pathParameters['orderId']!);
          return UploadPaymentScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: RouteNames.customerOrders,
        name: 'customerOrders',
        builder: (context, state) => const CustomerOrdersListScreen(),
      ),
      GoRoute(
        path: RouteNames.customerOrderDetail,
        name: 'customerOrderDetail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return CustomerOrderDetailScreen(orderId: id);
        },
      ),
      GoRoute(
        path: RouteNames.customerWriteReview,
        name: 'customerWriteReview',
        builder: (context, state) {
          final orderId = int.parse(state.pathParameters['orderId']!);
          return WriteReviewScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: RouteNames.customerNotifications,
        name: 'customerNotifications',
        builder: (context, state) => const CustomerNotificationsScreen(),
      ),
      GoRoute(
        path: RouteNames.customerProfile,
        name: 'customerProfile',
        builder: (context, state) => const CustomerProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.customerAddresses,
        builder: (context, state) => const SavedAddressesScreen(),
      ),
    ];
  }
  
  // ============================================================
  // ADMIN ROUTE BUILDER
  // ============================================================
  static List<RouteBase> _buildAdminRoutes() {
    return [
      GoRoute(
        path: RouteNames.adminDashboard,
        name: 'adminDashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: RouteNames.adminOrders,
        name: 'adminOrders',
        builder: (context, state) => const AdminOrdersListScreen(),
      ),
      GoRoute(
        path: RouteNames.adminOrderDetail,
        name: 'adminOrderDetail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return AdminOrderDetailScreen(orderId: id);
        },
      ),
      GoRoute(
        path: RouteNames.adminVerifyPayment,
        name: 'adminVerifyPayment',
        builder: (context, state) {
          final orderId = int.parse(state.pathParameters['orderId']!);
          return VerifyPaymentScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: RouteNames.adminChatRooms,
        name: 'adminChatRooms',
        builder: (context, state) => const AdminChatRoomsScreen(),
      ),
      GoRoute(
        path: RouteNames.adminChat,
        name: 'adminChat',
        builder: (context, state) {
          final roomId = int.parse(state.pathParameters['roomId']!);
          return AdminChatScreen(roomId: roomId);
        },
      ),
      GoRoute(
        path: RouteNames.adminTeam,
        name: 'adminTeam',
        builder: (context, state) => const AdminTeamListScreen(),
      ),
      GoRoute(
        path: RouteNames.adminEmployeeDetail,
        name: 'adminEmployeeDetail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return AdminEmployeeDetailScreen(employeeId: id);
        },
      ),
      GoRoute(
        path: RouteNames.adminReports,
        name: 'adminReports',
        builder: (context, state) => const AdminReportsScreen(),
      ),
      GoRoute(
        path: RouteNames.adminNotifications,
        name: 'adminNotifications',
        builder: (context, state) => const AdminNotificationsScreen(),
      ),
      GoRoute(
        path: RouteNames.adminProfile,
        name: 'adminProfile',
        builder: (context, state) => const AdminProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.adminSettings,
        builder: (context, state) => const AdminSettingsScreen(),
      ),
    ];
  }
  
  // ============================================================
  // EMPLOYEE ROUTE BUILDER
  // ============================================================
  static List<RouteBase> _buildEmployeeRoutes() {
    return [
      GoRoute(
        path: RouteNames.employeeTasks,
        name: 'employeeTasks',
        builder: (context, state) => const EmployeeTasksListScreen(),
      ),
      GoRoute(
        path: RouteNames.employeeTaskDetail,
        name: 'employeeTaskDetail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return EmployeeTaskDetailScreen(orderId: id);
        },
      ),
      GoRoute(
        path: RouteNames.employeeDocumentations,
        name: 'employeeDocumentations',
        builder: (context, state) => const EmployeeDocumentationsListScreen(),
      ),
      GoRoute(
        path: RouteNames.employeeOrderDocumentations,
        name: 'employeeOrderDocumentations',
        builder: (context, state) {
          final orderId = int.parse(state.pathParameters['orderId']!);
          return OrderDocumentationsScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: RouteNames.employeeAddDocumentation,
        name: 'employeeAddDocumentation',
        builder: (context, state) {
          final orderId = int.parse(state.pathParameters['orderId']!);
          return AddDocumentationScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: RouteNames.employeeChatRooms,
        name: 'employeeChatRooms',
        builder: (context, state) => const EmployeeChatRoomsScreen(),
      ),
      GoRoute(
        path: RouteNames.employeeChat,
        name: 'employeeChat',
        builder: (context, state) {
          final roomId = int.parse(state.pathParameters['roomId']!);
          return EmployeeChatScreen(roomId: roomId);
        },
      ),
      GoRoute(
        path: RouteNames.employeeNotifications,
        name: 'employeeNotifications',
        builder: (context, state) => const EmployeeNotificationsScreen(),
      ),
      GoRoute(
        path: RouteNames.employeeProfile,
        name: 'employeeProfile',
        builder: (context, state) => const EmployeeProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.employeeSettings,
        builder: (context, state) => const EmployeeSettingsScreen(),
      ),
    ];
  }
  
  // ============================================================
  // SUPER ADMIN ROUTE BUILDER
  // ============================================================
  static List<RouteBase> _buildSuperAdminRoutes() {
    return [
      GoRoute(
        path: RouteNames.superAdminDashboard,
        name: 'superAdminDashboard',
        builder: (context, state) => const SuperAdminDashboardScreen(),
      ),
      GoRoute(
        path: RouteNames.superAdminDivisions,
        name: 'superAdminDivisions',
        builder: (context, state) => const SuperAdminDivisionsListScreen(),
      ),
      GoRoute(
        path: RouteNames.superAdminDivisionDetail,
        name: 'superAdminDivisionDetail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return SuperAdminDivisionDetailScreen(divisionId: id);
        },
      ),
      GoRoute(
        path: RouteNames.superAdminUserDetail,
        name: 'superAdminUserDetail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return SuperAdminUserDetailScreen(userId: id);
        },
      ),
      GoRoute(
        path: RouteNames.superAdminOrders,
        name: 'superAdminOrders',
        builder: (context, state) => const SuperAdminOrdersListScreen(),
      ),
      GoRoute(
        path: RouteNames.superAdminOrderDetail,
        name: 'superAdminOrderDetail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return SuperAdminOrderDetailScreen(orderId: id);
        },
      ),
      GoRoute(
        path: RouteNames.superAdminReports,
        name: 'superAdminReports',
        builder: (context, state) => const SuperAdminReportsScreen(),
      ),
      GoRoute(
        path: RouteNames.superAdminNotifications,
        name: 'superAdminNotifications',
        builder: (context, state) => const SuperAdminNotificationsScreen(),
      ),
      GoRoute(
        path: RouteNames.superAdminProfile,
        name: 'superAdminProfile',
        builder: (context, state) => const SuperAdminProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.superAdminAppSettings,
        builder: (context, state) => const AppSettingsScreen(),
      ),
      GoRoute(
        path: RouteNames.superAdminUserManagement,
        builder: (context, state) => const UserManagementScreen(),
      ),
    ];
  }
}