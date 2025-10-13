import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:salas_beats/models/admin_report_model.dart';
import 'package:salas_beats/services/auth_service.dart';

// Mock DocumentSnapshot class to handle Map data
class _MockDocumentSnapshot implements DocumentSnapshot<Map<String, dynamic>> {
  
  _MockDocumentSnapshot(this._data);
  final Map<String, dynamic> _data;
  
  @override
  String get id => (_data['id'] as String?) ?? '';
  
  @override
  Map<String, dynamic>? data() => _data;
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Service class for handling administrative operations
/// 
/// This service provides functionality for:
/// - Dashboard data retrieval and analytics
/// - User management operations
/// - Data export capabilities
/// - Administrative reporting
/// 
/// All methods require admin privileges and will throw exceptions
/// if the current user doesn't have sufficient permissions.
class AdminService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();

  /// Retrieves comprehensive dashboard data for admin analytics
  /// 
  /// [period] - Time period for the report (e.g., 'week', 'month', 'year')
  /// [startDate] - Start date for custom date range (ISO 8601 format)
  /// [endDate] - End date for custom date range (ISO 8601 format)
  /// 
  /// Returns [AdminReportModel] containing metrics, charts, and analytics data
  /// 
  /// Throws [Exception] if user lacks admin privileges or data retrieval fails
  Future<AdminReportModel> getDashboardData({
    String? period,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final callable = _functions.httpsCallable('generateDashboardData');
      
      final result = await callable.call({
        if (period != null) 'period': period,
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
      });

      if (result.data['success'] == true) {
        final dashboardData = result.data['dashboard'] as Map<String, dynamic>;
        // Create a mock DocumentSnapshot-like object with the data
        final mockDoc = _MockDocumentSnapshot(dashboardData);
        return AdminReportModel.fromFirestore(mockDoc);
      } else {
        throw Exception('Failed to get dashboard data');
      }
    } catch (e) {
      throw Exception('Error getting dashboard data: $e');
    }
  }

  /// Verifies if the current authenticated user has admin privileges
  /// 
  /// Returns [true] if user is an admin, [false] otherwise
  /// 
  /// This method should be called before performing any admin operations
  Future<bool> isAdmin() async => _authService.isAdmin();

  /// Exports administrative data in the specified format
  /// 
  /// [type] - Type of data to export (e.g., 'bookings', 'users', 'listings')
  /// [startDate] - Start date for data range (ISO 8601 format)
  /// [endDate] - End date for data range (ISO 8601 format)
  /// [format] - Export format ('csv', 'xlsx', 'pdf')
  /// 
  /// Returns download URL for the exported file
  /// 
  /// Throws [ArgumentError] if parameters are invalid
  /// Throws [Exception] if export operation fails
  Future<String> exportData({
    required String type,
    required String startDate,
    required String endDate,
    required String format,
  }) async {
    try {
      final callable = _functions.httpsCallable('exportBookingData');
      
      final result = await callable.call({
        'type': type,
        'startDate': startDate,
        'endDate': endDate,
        'format': format,
      });

      if (result.data['success'] == true) {
        return result.data['downloadUrl'] as String;
      } else {
        throw Exception('Failed to export data');
      }
    } catch (e) {
      throw Exception('Error exporting data: $e');
    }
  }

  // Generate reports
  Future<Map<String, dynamic>> generateReport({
    required String reportType,
    required String period,
  }) async {
    try {
      final callable = _functions.httpsCallable('generateReports');
      
      final result = await callable.call({
        'reportType': reportType,
        'period': period,
      });

      if (result.data['success'] == true) {
        return result.data['report'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to generate report');
      }
    } catch (e) {
      throw Exception('Error generating report: $e');
    }
  }

  // Manage users
  Future<bool> manageUser({
    required String userId,
    required String action,
    String? reason,
  }) async {
    try {
      final callable = _functions.httpsCallable('manageUsers');
      
      final result = await callable.call({
        'userId': userId,
        'action': action,
        if (reason != null) 'reason': reason,
      });

      return result.data['success'] == true;
    } catch (e) {
      throw Exception('Error managing user: $e');
    }
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      // This would typically call a Cloud Function
      // For now, return mock data
      return {
        'totalUsers': 1250,
        'activeUsers': 890,
        'newUsersThisMonth': 45,
        'totalHosts': 156,
        'verifiedHosts': 134,
        'pendingVerifications': 22,
      };
    } catch (e) {
      throw Exception('Error getting user statistics: $e');
    }
  }

  // Get booking statistics
  Future<Map<String, dynamic>> getBookingStatistics() async {
    try {
      // This would typically call a Cloud Function
      // For now, return mock data
      return {
        'totalBookings': 2340,
        'confirmedBookings': 1890,
        'completedBookings': 1650,
        'cancelledBookings': 234,
        'pendingBookings': 156,
        'averageBookingValue': 85.50,
        'totalRevenue': 198750.00,
        'commissionsEarned': 29812.50,
      };
    } catch (e) {
      throw Exception('Error getting booking statistics: $e');
    }
  }

  // Get revenue analytics
  Future<Map<String, dynamic>> getRevenueAnalytics({
    required String period,
  }) async {
    try {
      // This would typically call a Cloud Function
      // For now, return mock data
      return {
        'totalRevenue': 198750.00,
        'commissionsEarned': 29812.50,
        'hostEarnings': 168937.50,
        'averageDailyRevenue': 6625.00,
        'revenueGrowth': 12.5,
        'topEarningHosts': [
          {
            'hostId': 'host1',
            'name': 'María González',
            'earnings': 15420.00,
            'bookings': 89,
          },
          {
            'hostId': 'host2',
            'name': 'Carlos Rodríguez',
            'earnings': 12350.00,
            'bookings': 76,
          },
        ],
        'monthlyRevenue': [
          {'month': 'Enero', 'revenue': 15420.00},
          {'month': 'Febrero', 'revenue': 18350.00},
          {'month': 'Marzo', 'revenue': 22100.00},
          {'month': 'Abril', 'revenue': 19850.00},
          {'month': 'Mayo', 'revenue': 25600.00},
          {'month': 'Junio', 'revenue': 28750.00},
        ],
      };
    } catch (e) {
      throw Exception('Error getting revenue analytics: $e');
    }
  }

  // Get platform health metrics
  Future<Map<String, dynamic>> getPlatformHealth() async {
    try {
      // This would typically call a Cloud Function or monitoring service
      // For now, return mock data
      return {
        'uptime': 99.8,
        'averageResponseTime': 245, // milliseconds
        'errorRate': 0.2, // percentage
        'activeConnections': 1250,
        'serverLoad': 65.5, // percentage
        'databaseConnections': 45,
        'cacheHitRate': 94.2, // percentage
        'lastIncident': '2024-01-15T10:30:00Z',
        'systemStatus': 'healthy',
      };
    } catch (e) {
      throw Exception('Error getting platform health: $e');
    }
  }

  // Search users
  Future<List<Map<String, dynamic>>> searchUsers({
    required String query,
    int limit = 20,
  }) async {
    try {
      // This would typically call a Cloud Function
      // For now, return mock data
      return [
        {
          'id': 'user1',
          'name': 'María González',
          'email': 'maria@example.com',
          'role': 'host',
          'status': 'active',
          'joinDate': '2023-06-15',
          'lastActive': '2024-01-20',
        },
        {
          'id': 'user2',
          'name': 'Carlos Rodríguez',
          'email': 'carlos@example.com',
          'role': 'user',
          'status': 'active',
          'joinDate': '2023-08-22',
          'lastActive': '2024-01-19',
        },
      ];
    } catch (e) {
      throw Exception('Error searching users: $e');
    }
  }

  // Get recent activities
  Future<List<Map<String, dynamic>>> getRecentActivities({
    int limit = 50,
  }) async {
    try {
      // This would typically call a Cloud Function
      // For now, return mock data
      return [
        {
          'id': 'activity1',
          'type': 'booking_created',
          'description': 'Nueva reserva creada por Juan Pérez',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
          'userId': 'user123',
          'metadata': {
            'bookingId': 'booking456',
            'amount': 120.00,
          },
        },
        {
          'id': 'activity2',
          'type': 'host_verified',
          'description': 'Anfitrión María González verificado',
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
          'userId': 'host789',
          'metadata': {
            'hostId': 'host789',
          },
        },
        {
          'id': 'activity3',
          'type': 'payment_completed',
          'description': 'Pago completado para reserva #1234',
          'timestamp': DateTime.now().subtract(const Duration(hours: 4)),
          'userId': 'user456',
          'metadata': {
            'bookingId': 'booking1234',
            'amount': 85.50,
          },
        },
      ];
    } catch (e) {
      throw Exception('Error getting recent activities: $e');
    }
  }

  // Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Get user's custom claims
      final idTokenResult = await user.getIdTokenResult();
      final claims = idTokenResult.claims;
      
      return claims?['role'] == 'admin';
    } catch (e) {
      return false;
    }
  }

  // Get top performing hosts
  Future<List<Map<String, dynamic>>> getTopHosts() async {
    try {
      // TODO: Replace with actual Firestore query
      await Future.delayed(const Duration(milliseconds: 500));
      return _getMockTopHosts();
    } catch (e) {
      print('Error getting top hosts: $e');
      return [];
    }
  }

  // Get top performing listings
  Future<List<Map<String, dynamic>>> getTopListings() async {
    try {
      // TODO: Replace with actual Firestore query
      await Future.delayed(const Duration(milliseconds: 500));
      return _getMockTopListings();
    } catch (e) {
      print('Error getting top listings: $e');
      return [];
    }
  }

  // Get users with search and filtering
  Future<List<Map<String, dynamic>>> getUsers({
    String? searchQuery,
    String? userType,
    String? status,
  }) async {
    try {
      // TODO: Replace with actual Firestore query with filters
      await Future.delayed(const Duration(milliseconds: 800));
      var users = _getMockUsers();
      
      // Apply filters
      if (searchQuery?.isNotEmpty ?? false) {
        users = users.where((user) {
          final name = user['name'].toString().toLowerCase();
          final email = user['email'].toString().toLowerCase();
          final query = searchQuery!.toLowerCase();
          return name.contains(query) || email.contains(query);
        }).toList();
      }
      
      if (userType?.isNotEmpty ?? false) {
        users = users.where((user) => user['type'] == userType).toList();
      }
      
      if (status?.isNotEmpty ?? false) {
        users = users.where((user) => user['status'] == status).toList();
      }
      
      return users;
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  // Get bookings with search and filtering
  Future<List<Map<String, dynamic>>> getBookings({
    String? searchQuery,
    String? status,
  }) async {
    try {
      // TODO: Replace with actual Firestore query with filters
      await Future.delayed(const Duration(milliseconds: 800));
      var bookings = _getMockBookings();
      
      // Apply filters
      if (searchQuery?.isNotEmpty ?? false) {
        bookings = bookings.where((booking) {
          final listingTitle = booking['listingTitle'].toString().toLowerCase();
          final guestName = booking['guestName'].toString().toLowerCase();
          final query = searchQuery!.toLowerCase();
          return listingTitle.contains(query) || guestName.contains(query);
        }).toList();
      }
      
      if (status?.isNotEmpty ?? false) {
        bookings = bookings.where((booking) => booking['status'] == status).toList();
      }
      
      return bookings;
    } catch (e) {
      print('Error getting bookings: $e');
      return [];
    }
  }

  // Get reports
  Future<List<Map<String, dynamic>>> getReports() async {
    try {
      // TODO: Replace with actual Firestore query
      await Future.delayed(const Duration(milliseconds: 600));
      return _getMockReports();
    } catch (e) {
      print('Error getting reports: $e');
      return [];
    }
  }



  // Mock data for testing
  static List<Map<String, dynamic>> _getMockStatistics() => [
      {
        'title': 'Total Usuarios',
        'value': '1,234',
        'subtitle': '+12% vs mes anterior',
        'icon': Icons.people,
        'color': Colors.blue,
      },
      {
        'title': 'Reservas Activas',
        'value': '89',
        'subtitle': '+5% vs semana anterior',
        'icon': Icons.event,
        'color': Colors.green,
      },
      {
        'title': 'Ingresos del Mes',
        'value': r'$45,678',
        'subtitle': '+18% vs mes anterior',
        'icon': Icons.attach_money,
        'color': Colors.orange,
      },
      {
        'title': 'Anfitriones Activos',
        'value': '156',
        'subtitle': '+8% vs mes anterior',
        'icon': Icons.home,
        'color': Colors.purple,
      },
    ];

  // Mock data for top performers
  static List<Map<String, dynamic>> _getMockTopHosts() => [
      {
        'id': '1',
        'name': 'María González',
        'earnings': 5420.0,
        'bookings': 23,
        'rating': 4.9,
      },
      {
        'id': '2',
        'name': 'Carlos Rodríguez',
        'earnings': 4890.0,
        'bookings': 19,
        'rating': 4.8,
      },
      {
        'id': '3',
        'name': 'Ana Martínez',
        'earnings': 4320.0,
        'bookings': 17,
        'rating': 4.7,
      },
    ];

  static List<Map<String, dynamic>> _getMockTopListings() => [
      {
        'id': '1',
        'title': 'Estudio Moderno en Zona Rosa',
        'revenue': 8900.0,
        'bookings': 34,
        'occupancyRate': 85.0,
      },
      {
        'id': '2',
        'title': 'Apartamento Completo Centro',
        'revenue': 7650.0,
        'bookings': 28,
        'occupancyRate': 78.0,
      },
      {
        'id': '3',
        'title': 'Casa Familiar con Jardín',
        'revenue': 6890.0,
        'bookings': 22,
        'occupancyRate': 72.0,
      },
    ];

  // Mock data for users
  static List<Map<String, dynamic>> _getMockUsers() => [
      {
        'id': '1',
        'name': 'Juan Pérez',
        'email': 'juan.perez@email.com',
        'type': 'guest',
        'status': 'active',
        'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'bookingsCount': 5,
        'totalSpent': 1250.0,
      },
      {
        'id': '2',
        'name': 'María González',
        'email': 'maria.gonzalez@email.com',
        'type': 'host',
        'status': 'active',
        'createdAt': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
        'bookingsCount': 23,
        'totalEarned': 5420.0,
      },
      {
        'id': '3',
        'name': 'Admin User',
        'email': 'admin@salasandbeats.com',
        'type': 'admin',
        'status': 'active',
        'createdAt': DateTime.now().subtract(const Duration(days: 365)).toIso8601String(),
        'bookingsCount': 0,
      },
    ];

  // Mock data for bookings
  static List<Map<String, dynamic>> _getMockBookings() => [
      {
        'id': '1',
        'listingId': '1',
        'listingTitle': 'Estudio Moderno en Zona Rosa',
        'guestId': '1',
        'guestName': 'Juan Pérez',
        'hostId': '2',
        'hostName': 'María González',
        'checkIn': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
        'checkOut': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        'guests': 2,
        'totalAmount': 450.0,
        'hostEarnings': 382.5,
        'platformFee': 67.5,
        'status': 'confirmed',
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'id': '2',
        'listingId': '2',
        'listingTitle': 'Apartamento Completo Centro',
        'guestId': '3',
        'guestName': 'Carlos Rodríguez',
        'hostId': '4',
        'hostName': 'Ana Martínez',
        'checkIn': DateTime.now().add(const Duration(days: 10)).toIso8601String(),
        'checkOut': DateTime.now().add(const Duration(days: 12)).toIso8601String(),
        'guests': 4,
        'totalAmount': 680.0,
        'hostEarnings': 578.0,
        'platformFee': 102.0,
        'status': 'pending',
        'createdAt': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      },
    ];

  // Mock data for reports
  static List<Map<String, dynamic>> _getMockReports() => [
      {
        'id': '1',
        'title': 'Reporte de Ingresos - Enero 2024',
        'type': 'monthlyRevenue',
        'startDate': DateTime(2024).toIso8601String(),
        'endDate': DateTime(2024, 1, 31).toIso8601String(),
        'status': 'completed',
        'createdAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'downloadUrl': 'https://example.com/reports/revenue-jan-2024.pdf',
      },
      {
        'id': '2',
        'title': 'Análisis de Reservas - Diciembre 2023',
        'type': 'bookingsByPeriod',
        'startDate': DateTime(2023, 12).toIso8601String(),
        'endDate': DateTime(2023, 12, 31).toIso8601String(),
        'status': 'completed',
        'createdAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'downloadUrl': 'https://example.com/reports/bookings-dec-2023.pdf',
      },
      {
        'id': '3',
        'title': 'Rendimiento de Anfitriones - Q4 2023',
        'type': 'hostPerformance',
        'startDate': DateTime(2023, 10).toIso8601String(),
        'endDate': DateTime(2023, 12, 31).toIso8601String(),
        'status': 'generating',
        'createdAt': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
      },
    ];
}