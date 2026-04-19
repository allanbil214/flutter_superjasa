import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/user_model.dart';
import '../models/division_model.dart';
import '../models/service_model.dart';
import '../models/order_model.dart';
import '../models/order_item_model.dart';
import '../models/payment_model.dart';
import '../models/chat_room_model.dart';
import '../models/chat_message_model.dart';
import '../models/chat_template_model.dart';
import '../models/bot_response_model.dart';
import '../models/review_model.dart';
import '../models/notification_model.dart';
import '../models/employee_documentation_model.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  // Cached data
  List<UserModel>? _users;
  List<DivisionModel>? _divisions;
  List<ServiceModel>? _services;
  List<OrderModel>? _orders;
  List<OrderItemModel>? _orderItems;
  List<PaymentModel>? _payments;
  List<ChatRoomModel>? _chatRooms;
  List<ChatMessageModel>? _chatMessages;
  List<ChatTemplateModel>? _chatTemplates;
  List<BotResponseModel>? _botResponses;
  List<ReviewModel>? _reviews;
  List<NotificationModel>? _notifications;
  List<EmployeeDocumentationModel>? _documentations;

  // Current logged-in user (for prototype)
  UserModel? _currentUser;
  UserRole? _currentRole;

  // ============================================================
  // LOAD METHODS
  // ============================================================

  Future<List<UserModel>> getUsers({bool forceReload = false}) async {
    if (_users != null && !forceReload) return _users!;
    final data = await _loadJson('users');
    _users = (data['users'] as List).map((e) => UserModel.fromJson(e)).toList();
    return _users!;
  }

  Future<List<DivisionModel>> getDivisions({bool forceReload = false}) async {
    if (_divisions != null && !forceReload) return _divisions!;
    final data = await _loadJson('divisions');
    _divisions = (data['divisions'] as List).map((e) => DivisionModel.fromJson(e)).toList();
    return _divisions!;
  }

  Future<List<ServiceModel>> getServices({bool forceReload = false}) async {
    if (_services != null && !forceReload) return _services!;
    final data = await _loadJson('services');
    _services = (data['services'] as List).map((e) => ServiceModel.fromJson(e)).toList();
    return _services!;
  }

  Future<List<OrderModel>> getOrders({bool forceReload = false}) async {
    if (_orders != null && !forceReload) return _orders!;
    final data = await _loadJson('orders');
    _orders = (data['orders'] as List).map((e) => OrderModel.fromJson(e)).toList();
    return _orders!;
  }

  Future<List<OrderItemModel>> getOrderItems({bool forceReload = false}) async {
    if (_orderItems != null && !forceReload) return _orderItems!;
    final data = await _loadJson('order_items');
    _orderItems = (data['order_items'] as List).map((e) => OrderItemModel.fromJson(e)).toList();
    return _orderItems!;
  }

  Future<List<PaymentModel>> getPayments({bool forceReload = false}) async {
    if (_payments != null && !forceReload) return _payments!;
    final data = await _loadJson('payments');
    _payments = (data['payments'] as List).map((e) => PaymentModel.fromJson(e)).toList();
    return _payments!;
  }

  Future<List<ChatRoomModel>> getChatRooms({bool forceReload = false}) async {
    if (_chatRooms != null && !forceReload) return _chatRooms!;
    final data = await _loadJson('chat_rooms');
    _chatRooms = (data['chat_rooms'] as List).map((e) => ChatRoomModel.fromJson(e)).toList();
    return _chatRooms!;
  }

  Future<List<ChatMessageModel>> getChatMessages({bool forceReload = false}) async {
    if (_chatMessages != null && !forceReload) return _chatMessages!;
    final data = await _loadJson('chat_messages');
    _chatMessages = (data['messages'] as List).map((e) => ChatMessageModel.fromJson(e)).toList();
    return _chatMessages!;
  }

  Future<List<ChatTemplateModel>> getChatTemplates({bool forceReload = false}) async {
    if (_chatTemplates != null && !forceReload) return _chatTemplates!;
    final data = await _loadJson('chat_templates');
    _chatTemplates = (data['templates'] as List).map((e) => ChatTemplateModel.fromJson(e)).toList();
    return _chatTemplates!;
  }

  Future<List<BotResponseModel>> getBotResponses({bool forceReload = false}) async {
    if (_botResponses != null && !forceReload) return _botResponses!;
    final data = await _loadJson('bot_responses');
    _botResponses = (data['responses'] as List).map((e) => BotResponseModel.fromJson(e)).toList();
    return _botResponses!;
  }

  Future<List<ReviewModel>> getReviews({bool forceReload = false}) async {
    if (_reviews != null && !forceReload) return _reviews!;
    final data = await _loadJson('reviews');
    _reviews = (data['reviews'] as List).map((e) => ReviewModel.fromJson(e)).toList();
    return _reviews!;
  }

  Future<List<NotificationModel>> getNotifications({bool forceReload = false}) async {
    if (_notifications != null && !forceReload) return _notifications!;
    final data = await _loadJson('notifications');
    _notifications = (data['notifications'] as List).map((e) => NotificationModel.fromJson(e)).toList();
    return _notifications!;
  }

  Future<List<EmployeeDocumentationModel>> getDocumentations({bool forceReload = false}) async {
    if (_documentations != null && !forceReload) return _documentations!;
    final data = await _loadJson('employee_documentations');
    _documentations = (data['documentations'] as List).map((e) => EmployeeDocumentationModel.fromJson(e)).toList();
    return _documentations!;
  }

  // ============================================================
  // HELPER: Load JSON from assets
  // ============================================================
  Future<Map<String, dynamic>> _loadJson(String filename) async {
    final String jsonString = await rootBundle.loadString('lib/data/mock_data/$filename.json');
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  // ============================================================
  // AUTH METHODS (Mock)
  // ============================================================
  void setCurrentRole(UserRole role) {
    _currentRole = role;
    // Auto-login as first user of that role for prototype
    _setDefaultUserForRole(role);
  }

  void _setDefaultUserForRole(UserRole role) async {
    final users = await getUsers();
    _currentUser = users.firstWhere(
      (u) => u.role == role && u.isActive,
      orElse: () => users.first,
    );
  }

  UserModel? get currentUser => _currentUser;
  UserRole? get currentRole => _currentRole;

  void logout() {
    _currentUser = null;
    _currentRole = null;
  }

  // ============================================================
  // QUERY HELPERS
  // ============================================================

  // Get user by ID
  Future<UserModel?> getUserById(int id) async {
    final users = await getUsers();
    try {
      return users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  // Get division by ID
  Future<DivisionModel?> getDivisionById(int id) async {
    final divisions = await getDivisions();
    try {
      return divisions.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  // Get service by ID
  Future<ServiceModel?> getServiceById(int id) async {
    final services = await getServices();
    try {
      return services.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // Get services by division ID
  Future<List<ServiceModel>> getServicesByDivision(int divisionId) async {
    final services = await getServices();
    return services.where((s) => s.divisionId == divisionId && s.isActive).toList();
  }

  // Get orders by customer ID
  Future<List<OrderModel>> getOrdersByCustomer(int customerId) async {
    final orders = await getOrders();
    return orders.where((o) => o.customerId == customerId).toList();
  }

  // Get orders by division ID
  Future<List<OrderModel>> getOrdersByDivision(int divisionId) async {
    final orders = await getOrders();
    return orders.where((o) => o.divisionId == divisionId).toList();
  }

  // Get orders assigned to employee
  Future<List<OrderModel>> getOrdersByEmployee(int employeeId) async {
    final orders = await getOrders();
    return orders.where((o) => o.assignedTo == employeeId).toList();
  }

  // Get chat room by customer and division
  Future<ChatRoomModel?> getChatRoom(int customerId, int divisionId) async {
    final rooms = await getChatRooms();
    try {
      return rooms.firstWhere((r) => r.customerId == customerId && r.divisionId == divisionId);
    } catch (_) {
      return null;
    }
  }

  // Get messages by room ID
  Future<List<ChatMessageModel>> getMessagesByRoom(int roomId) async {
    final messages = await getChatMessages();
    return messages.where((m) => m.roomId == roomId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  // Get chat rooms by customer
  Future<List<ChatRoomModel>> getChatRoomsByCustomer(int customerId) async {
    final rooms = await getChatRooms();
    return rooms.where((r) => r.customerId == customerId).toList();
  }

  // Get chat rooms by division (for admin)
  Future<List<ChatRoomModel>> getChatRoomsByDivision(int divisionId) async {
    final rooms = await getChatRooms();
    return rooms.where((r) => r.divisionId == divisionId).toList();
  }

  // Get templates for role and division
  Future<List<ChatTemplateModel>> getTemplates({
    required TemplateForRole forRole,
    int? divisionId,
  }) async {
    final templates = await getChatTemplates();
    return templates.where((t) {
      if (!t.isActive) return false;
      if (t.forRole != forRole) return false;
      if (t.divisionId != null && t.divisionId != divisionId) return false;
      return true;
    }).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  // Get bot responses for keyword
  Future<BotResponseModel?> findBotResponse(String message, {int? divisionId}) async {
    final responses = await getBotResponses();
    final messageLower = message.toLowerCase();
    
    // Sort by sort_order to prioritize specific responses
    final sorted = responses.where((r) => r.isActive).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    
    for (final response in sorted) {
      if (messageLower.contains(response.keyword.toLowerCase())) {
        // Prefer division-specific response
        if (response.divisionId == divisionId) {
          return response;
        }
        // Fallback to global response
        if (response.divisionId == null) {
          return response;
        }
      }
    }
    return null;
  }

  // Get payment by order ID
  Future<PaymentModel?> getPaymentByOrder(int orderId) async {
    final payments = await getPayments();
    try {
      return payments.firstWhere((p) => p.orderId == orderId);
    } catch (_) {
      return null;
    }
  }

  // Get reviews by division
  Future<List<ReviewModel>> getReviewsByDivision(int divisionId) async {
    final reviews = await getReviews();
    return reviews.where((r) => r.divisionId == divisionId && r.isPublished).toList();
  }

  // Get reviews by employee
  Future<List<ReviewModel>> getReviewsByEmployee(int employeeId) async {
    final reviews = await getReviews();
    return reviews.where((r) => r.employeeId == employeeId && r.isPublished).toList();
  }

  // Get documentations by order
  Future<List<EmployeeDocumentationModel>> getDocumentationsByOrder(int orderId) async {
    final docs = await getDocumentations();
    return docs.where((d) => d.orderId == orderId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  // Get documentations by stage
  Future<List<EmployeeDocumentationModel>> getDocumentationsByStage(int orderId, DocumentationStage stage) async {
    final docs = await getDocumentationsByOrder(orderId);
    return docs.where((d) => d.stage == stage).toList();
  }

  // Get notifications by user
  Future<List<NotificationModel>> getNotificationsByUser(int userId) async {
    final notifications = await getNotifications();
    return notifications.where((n) => n.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get unread notification count
  Future<int> getUnreadNotificationCount(int userId) async {
    final notifications = await getNotificationsByUser(userId);
    return notifications.where((n) => !n.isRead).length;
  }

  // Get employees by division
  Future<List<UserModel>> getEmployeesByDivision(int divisionId) async {
    final division = await getDivisionById(divisionId);
    if (division == null) return [];
    
    final users = await getUsers();
    return users.where((u) => 
      u.role == UserRole.employee && 
      division.employeeIds.contains(u.id) &&
      u.isActive
    ).toList();
  }

  // Get admins by division
  Future<List<UserModel>> getAdminsByDivision(int divisionId) async {
    final division = await getDivisionById(divisionId);
    if (division == null) return [];
    
    final users = await getUsers();
    return users.where((u) => 
      u.role == UserRole.admin && 
      division.adminIds.contains(u.id) &&
      u.isActive
    ).toList();
  }

  // Get order items by order
  Future<List<OrderItemModel>> getOrderItemsByOrder(int orderId) async {
    final items = await getOrderItems();
    return items.where((i) => i.orderId == orderId).toList();
  }

  // Calculate order total
  Future<double> getOrderTotal(int orderId) async {
    final items = await getOrderItemsByOrder(orderId);

    double total = 0;
    for (final item in items) {
      total += await item.subtotal;
    }

    return total;
  }

  // ============================================================
  // STATISTICS (for dashboards)
  // ============================================================

  Future<Map<String, dynamic>> getDivisionStats(int divisionId) async {
    final orders = await getOrdersByDivision(divisionId);
    final reviews = await getReviewsByDivision(divisionId);
    
    final totalOrders = orders.length;
    final completedOrders = orders.where((o) => o.isCompleted).length;
    final activeOrders = orders.where((o) => o.isActive).length;
    final avgRating = reviews.isEmpty ? 0.0 : 
        reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
    
    final totalRevenue = orders
        .where((o) => o.isCompleted)
        .fold<double>(0, (sum, o) => sum + 0); // Would need payment data
    
    return {
      'total_orders': totalOrders,
      'completed_orders': completedOrders,
      'active_orders': activeOrders,
      'avg_rating': avgRating,
      'total_revenue': totalRevenue,
    };
  }

  // Clear all cached data
  void clearCache() {
    _users = null;
    _divisions = null;
    _services = null;
    _orders = null;
    _orderItems = null;
    _payments = null;
    _chatRooms = null;
    _chatMessages = null;
    _chatTemplates = null;
    _botResponses = null;
    _reviews = null;
    _notifications = null;
    _documentations = null;
  }
}