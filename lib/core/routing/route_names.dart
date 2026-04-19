class RouteNames {
  // Auth
  static const String login = '/login';
  static const String roleSelector = '/role-selector';
  
  // ============================================================
  // CUSTOMER ROUTES
  // ============================================================
  static const String customerHome = '/customer/home';
  static const String customerDivisionDetail = '/customer/division/:id';
  static const String customerServiceDetail = '/customer/service/:id';
  static const String customerChat = '/customer/chat/:roomId';
  static const String customerChatRooms = '/customer/chat-rooms';
  static const String customerCreateOrder = '/customer/create-order';
  static const String customerUploadPayment = '/customer/upload-payment/:orderId';
  static const String customerOrders = '/customer/orders';
  static const String customerOrderDetail = '/customer/orders/:id';
  static const String customerWriteReview = '/customer/write-review/:orderId';
  static const String customerNotifications = '/customer/notifications';
  static const String customerProfile = '/customer/profile';
  
  // ============================================================
  // ADMIN ROUTES
  // ============================================================
  static const String adminDashboard = '/admin/dashboard';
  static const String adminOrders = '/admin/orders';
  static const String adminOrderDetail = '/admin/orders/:id';
  static const String adminVerifyPayment = '/admin/verify-payment/:orderId';
  static const String adminChatRooms = '/admin/chat-rooms';
  static const String adminChat = '/admin/chat/:roomId';
  static const String adminTeam = '/admin/team';
  static const String adminEmployeeDetail = '/admin/team/:id';
  static const String adminReports = '/admin/reports';
  static const String adminNotifications = '/admin/notifications';
  static const String adminProfile = '/admin/profile';
  
  // ============================================================
  // EMPLOYEE ROUTES
  // ============================================================
  static const String employeeTasks = '/employee/tasks';
  static const String employeeTaskDetail = '/employee/tasks/:id';
  static const String employeeDocumentations = '/employee/documentations';
  static const String employeeOrderDocumentations = '/employee/documentations/:orderId';
  static const String employeeAddDocumentation = '/employee/add-documentation/:orderId';
  static const String employeeChatRooms = '/employee/chat-rooms';
  static const String employeeChat = '/employee/chat/:roomId';
  static const String employeeNotifications = '/employee/notifications';
  static const String employeeProfile = '/employee/profile';
  
  // ============================================================
  // SUPER ADMIN ROUTES
  // ============================================================
  static const String superAdminDashboard = '/super-admin/dashboard';
  static const String superAdminDivisions = '/super-admin/divisions';
  static const String superAdminDivisionDetail = '/super-admin/divisions/:id';
  static const String superAdminUserDetail = '/super-admin/users/:id';
  static const String superAdminOrders = '/super-admin/orders';
  static const String superAdminOrderDetail = '/super-admin/orders/:id';
  static const String superAdminReports = '/super-admin/reports';
  static const String superAdminNotifications = '/super-admin/notifications';
  static const String superAdminProfile = '/super-admin/profile';
  
  // Helper to replace path params
  static String customerDivisionDetailPath(int id) => '/customer/division/$id';
  static String customerServiceDetailPath(int id) => '/customer/service/$id';
  static String customerChatPath(int roomId) => '/customer/chat/$roomId';
  static String customerUploadPaymentPath(int orderId) => '/customer/upload-payment/$orderId';
  static String customerOrderDetailPath(int id) => '/customer/orders/$id';
  static String customerWriteReviewPath(int orderId) => '/customer/write-review/$orderId';
  
  static String adminOrderDetailPath(int id) => '/admin/orders/$id';
  static String adminVerifyPaymentPath(int orderId) => '/admin/verify-payment/$orderId';
  static String adminChatPath(int roomId) => '/admin/chat/$roomId';
  static String adminEmployeeDetailPath(int id) => '/admin/team/$id';
  
  static String employeeTaskDetailPath(int id) => '/employee/tasks/$id';
  static String employeeOrderDocumentationsPath(int orderId) => '/employee/documentations/$orderId';
  static String employeeAddDocumentationPath(int orderId) => '/employee/add-documentation/$orderId';
  static String employeeChatPath(int roomId) => '/employee/chat/$roomId';
  
  static String superAdminDivisionDetailPath(int id) => '/super-admin/divisions/$id';
  static String superAdminUserDetailPath(int id) => '/super-admin/users/$id';
  static String superAdminOrderDetailPath(int id) => '/super-admin/orders/$id';
}