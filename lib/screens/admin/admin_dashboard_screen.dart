import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salas_beats/models/admin_report_model.dart';
import 'package:salas_beats/providers/auth_provider.dart';
import 'package:salas_beats/services/admin_service.dart';
import 'package:salas_beats/widgets/admin/chart_card.dart';
import 'package:salas_beats/widgets/admin/metrics_card.dart';
import 'package:salas_beats/widgets/admin/recent_activity.dart';
import 'package:salas_beats/widgets/admin/top_performers.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final AdminService _adminService = AdminService();
  
  AdminReportModel? _dashboardData;
  bool _isLoading = true;
  String _selectedPeriod = 'month';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _adminService.getDashboardData(
        period: _selectedPeriod,
      );
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading dashboard: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Panel de Administración',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6C5CE7),
        elevation: 0,
        actions: [
          // Period selector
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: DropdownButton<String>(
              value: _selectedPeriod,
              dropdownColor: const Color(0xFF6C5CE7),
              style: const TextStyle(color: Colors.white),
              underline: Container(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              items: const [
                DropdownMenuItem(value: 'week', child: Text('Semana')),
                DropdownMenuItem(value: 'month', child: Text('Mes')),
                DropdownMenuItem(value: 'year', child: Text('Año')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPeriod = value);
                  _loadDashboardData();
                }
              },
            ),
          ),
          // User profile
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Text(
                user?.displayName.substring(0, 1).toUpperCase() ?? 'A',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Resumen', icon: Icon(Icons.dashboard)),
            Tab(text: 'Usuarios', icon: Icon(Icons.people)),
            Tab(text: 'Reservas', icon: Icon(Icons.book_online)),
            Tab(text: 'Reportes', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildUsersTab(),
                _buildBookingsTab(),
                _buildReportsTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    if (_dashboardData == null) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Metrics cards
            _buildMetricsGrid(),
            const SizedBox(height: 24),
            
            // Charts section
            Row(
              children: [
                Expanded(
                  child: ChartCard(
                    title: 'Ingresos',
                    chart: _buildRevenueChart(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ChartCard(
                    title: 'Reservas',
                    chart: _buildBookingsChart(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Recent activity and top performers
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: RecentActivity(
                    activities: [],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TopPerformers(
                    hosts: [],
                    listings: [],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    final data = _dashboardData!;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        MetricsCard(
          title: 'Usuarios Totales',
          value: data.newUsers.toString(),
          subtitle: '+${data.newUsers} nuevos',
          icon: Icons.people,
          color: Colors.blue,
        ),
        MetricsCard(
          title: 'Anfitriones',
          value: data.newHosts.toString(),
          subtitle: '${data.newHosts} nuevos',
          icon: Icons.home,
          color: Colors.green,
        ),
        MetricsCard(
          title: 'Reservas',
          value: data.bookingsCount.toString(),
          subtitle: '${data.completedBookings} completadas',
          icon: Icons.book_online,
          color: Colors.orange,
        ),
        MetricsCard(
          title: 'Ingresos',
          value: '\$${(data.platformRevenue / 100).toStringAsFixed(0)}',
          subtitle: '\$${(data.hostFees / 100).toStringAsFixed(0)} comisiones',
          icon: Icons.attach_money,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildRevenueChart() {
    // Sample data - replace with actual data from _dashboardData
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              const FlSpot(0, 3),
              const FlSpot(1, 1),
              const FlSpot(2, 4),
              const FlSpot(3, 2),
              const FlSpot(4, 5),
              const FlSpot(5, 3),
              const FlSpot(6, 4),
            ],
            isCurved: true,
            color: Colors.purple,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.purple.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsChart() {
    final data = _dashboardData!;
    
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            color: Colors.green,
            value: data.bookingsCount.toDouble(),
            title: 'Total',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: Colors.blue,
            value: data.completedBookings.toDouble(),
            title: 'Completadas',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: Colors.red,
            value: data.cancelledBookings.toDouble(),
            title: 'Canceladas',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() => const Center(
      child: Text(
        'Gestión de Usuarios\n(En desarrollo)',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          color: Colors.grey,
        ),
      ),
    );

  Widget _buildBookingsTab() => const Center(
      child: Text(
        'Gestión de Reservas\n(En desarrollo)',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          color: Colors.grey,
        ),
      ),
    );

  Widget _buildReportsTab() => const Center(
      child: Text(
        'Reportes Avanzados\n(En desarrollo)',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          color: Colors.grey,
        ),
      ),
    );
}