import 'package:flutter/foundation.dart';
import 'package:salas_beats/services/admin_service.dart';
import 'package:salas_beats/widgets/admin/booking_list.dart';
import 'package:salas_beats/widgets/admin/recent_activity.dart';
import 'package:salas_beats/widgets/admin/reports_widget.dart';
import 'package:salas_beats/widgets/admin/top_performers.dart';
import 'package:salas_beats/widgets/admin/user_list.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();
  
  // Loading states
  bool _isLoadingDashboard = false;
  bool _isLoadingUsers = false;
  bool _isLoadingBookings = false;
  bool _isLoadingReports = false;
  bool _isLoadingTopPerformers = false;
  bool _isLoadingActivity = false;
  
  // Data
  List<Map<String, dynamic>> _statistics = [];
  List<Map<String, dynamic>> _revenueAnalytics = [];
  List<Map<String, dynamic>> _platformHealth = [];
  List<AdminUser> _users = [];
  List<AdminBooking> _bookings = [];
  List<ReportData> _reports = [];
  List<TopHost> _topHosts = [];
  List<TopListing> _topListings = [];
  List<ActivityItem> _recentActivity = [];
  
  // Filters
  String _userSearchQuery = '';
  String _userTypeFilter = '';
  String _userStatusFilter = '';
  String _bookingSearchQuery = '';
  String _bookingStatusFilter = '';
  
  // Error states
  String? _error;
  
  // Getters
  bool get isLoadingDashboard => _isLoadingDashboard;
  bool get isLoadingUsers => _isLoadingUsers;
  bool get isLoadingBookings => _isLoadingBookings;
  bool get isLoadingReports => _isLoadingReports;
  bool get isLoadingTopPerformers => _isLoadingTopPerformers;
  bool get isLoadingActivity => _isLoadingActivity;
  
  List<Map<String, dynamic>> get statistics => _statistics;
  List<Map<String, dynamic>> get revenueAnalytics => _revenueAnalytics;
  List<Map<String, dynamic>> get platformHealth => _platformHealth;
  List<AdminUser> get users => _users;
  List<AdminBooking> get bookings => _bookings;
  List<ReportData> get reports => _reports;
  List<TopHost> get topHosts => _topHosts;
  List<TopListing> get topListings => _topListings;
  List<ActivityItem> get recentActivity => _recentActivity;
  
  String get userSearchQuery => _userSearchQuery;
  String get userTypeFilter => _userTypeFilter;
  String get userStatusFilter => _userStatusFilter;
  String get bookingSearchQuery => _bookingSearchQuery;
  String get bookingStatusFilter => _bookingStatusFilter;
  
  String? get error => _error;
  
  // Load dashboard data
  Future<void> loadDashboardData() async {
    _isLoadingDashboard = true;
    _error = null;
    notifyListeners();
    
    try {
      final data = await _adminService.getDashboardData();
      _statistics = []; // TODO: Extract statistics from AdminReportModel
      _revenueAnalytics = []; // TODO: Extract revenue analytics from AdminReportModel
      _platformHealth = []; // TODO: Implement platform health data
    } catch (e) {
      _error = 'Error loading dashboard data: $e';
    } finally {
      _isLoadingDashboard = false;
      notifyListeners();
    }
  }
  
  // Load top performers
  Future<void> loadTopPerformers() async {
    _isLoadingTopPerformers = true;
    notifyListeners();
    
    try {
      final hosts = await _adminService.getTopHosts();
      final listings = await _adminService.getTopListings();
      
      _topHosts = hosts.map(TopHost.fromMap).toList();
      _topListings = listings.map(TopListing.fromMap).toList();
    } catch (e) {
      _error = 'Error loading top performers: $e';
    } finally {
      _isLoadingTopPerformers = false;
      notifyListeners();
    }
  }
  
  // Load recent activity
  Future<void> loadRecentActivity() async {
    _isLoadingActivity = true;
    notifyListeners();
    
    try {
      // TODO: Implement getRecentActivity in AdminService
      _recentActivity = [];
    } catch (e) {
      _error = 'Error loading recent activity: $e';
    } finally {
      _isLoadingActivity = false;
      notifyListeners();
    }
  }
  
  // Load users with filters
  Future<void> loadUsers() async {
    _isLoadingUsers = true;
    notifyListeners();
    
    try {
      final usersData = await _adminService.getUsers(
        searchQuery: _userSearchQuery.isEmpty ? null : _userSearchQuery,
        userType: _userTypeFilter.isEmpty ? null : _userTypeFilter,
        status: _userStatusFilter.isEmpty ? null : _userStatusFilter,
      );
      
      _users = usersData.map(AdminUser.fromMap).toList();
    } catch (e) {
      _error = 'Error loading users: $e';
    } finally {
      _isLoadingUsers = false;
      notifyListeners();
    }
  }
  
  // Load bookings with filters
  Future<void> loadBookings() async {
    _isLoadingBookings = true;
    notifyListeners();
    
    try {
      final bookingsData = await _adminService.getBookings(
        searchQuery: _bookingSearchQuery.isEmpty ? null : _bookingSearchQuery,
        status: _bookingStatusFilter.isEmpty ? null : _bookingStatusFilter,
      );
      
      _bookings = bookingsData.map(AdminBooking.fromMap).toList();
    } catch (e) {
      _error = 'Error loading bookings: $e';
    } finally {
      _isLoadingBookings = false;
      notifyListeners();
    }
  }
  
  // Load reports
  Future<void> loadReports() async {
    _isLoadingReports = true;
    notifyListeners();
    
    try {
      final reportsData = await _adminService.getReports();
      _reports = reportsData.map(ReportData.fromMap).toList();
    } catch (e) {
      _error = 'Error loading reports: $e';
    } finally {
      _isLoadingReports = false;
      notifyListeners();
    }
  }
  
  // Generate new report
  Future<bool> generateReport({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final report = await _adminService.generateReport(
        reportType: type,
        period: 'custom',
      );
      
      _reports.insert(0, ReportData.fromMap(report));
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error generating report: $e';
      notifyListeners();
      return false;
    }
  }
  
  // Update user search query
  void updateUserSearchQuery(String query) {
    _userSearchQuery = query;
    notifyListeners();
  }
  
  // Update user type filter
  void updateUserTypeFilter(String type) {
    _userTypeFilter = type;
    notifyListeners();
  }
  
  // Update user status filter
  void updateUserStatusFilter(String status) {
    _userStatusFilter = status;
    notifyListeners();
  }
  
  // Update booking search query
  void updateBookingSearchQuery(String query) {
    _bookingSearchQuery = query;
    notifyListeners();
  }
  
  // Update booking status filter
  void updateBookingStatusFilter(String status) {
    _bookingStatusFilter = status;
    notifyListeners();
  }
  
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Check if current user is admin
  Future<bool> isAdmin() async => _adminService.isAdmin();
  
  // Export data
  Future<bool> exportData(String type) async {
    try {
      await _adminService.exportData(
        type: type,
        startDate: DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        endDate: DateTime.now().toIso8601String(),
        format: 'csv',
      );
      return true;
    } catch (e) {
      _error = 'Error exporting data: $e';
      notifyListeners();
      return false;
    }
  }
}