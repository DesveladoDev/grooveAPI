import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/advanced_analytics_service.dart';
import '../../services/business_intelligence_service.dart';

/// Real-time metrics widget for displaying live analytics data
class RealTimeMetricsWidget extends StatefulWidget {
  final Duration refreshInterval;
  final VoidCallback? onRefresh;

  const RealTimeMetricsWidget({
    super.key,
    this.refreshInterval = const Duration(seconds: 30),
    this.onRefresh,
  });

  @override
  State<RealTimeMetricsWidget> createState() => _RealTimeMetricsWidgetState();
}

class _RealTimeMetricsWidgetState extends State<RealTimeMetricsWidget> {
  late Stream<RealTimeMetrics> _metricsStream;

  @override
  void initState() {
    super.initState();
    _metricsStream = _createMetricsStream();
  }

  Stream<RealTimeMetrics> _createMetricsStream() async* {
    while (true) {
      yield RealTimeMetrics.mock();
      await Future.delayed(widget.refreshInterval);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RealTimeMetrics>(
      stream: _metricsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final metrics = snapshot.data!;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Real-time Metrics',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: widget.onRefresh,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        'Active Users',
                        '${metrics.activeUsers}',
                        Icons.people,
                        Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _buildMetricTile(
                        'Live Bookings',
                        '${metrics.liveBookings}',
                        Icons.calendar_today,
                        Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _buildMetricTile(
                        'Revenue/Hour',
                        '\$${metrics.revenuePerHour.toStringAsFixed(0)}',
                        Icons.attach_money,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Conversion funnel visualization widget
class ConversionFunnelWidget extends StatelessWidget {
  final List<FunnelStep> steps;
  final String title;

  const ConversionFunnelWidget({
    super.key,
    required this.steps,
    this.title = 'Conversion Funnel',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isLast = index == steps.length - 1;
              
              return Column(
                children: [
                  _buildFunnelStep(context, step, index),
                  if (!isLast) _buildFunnelConnector(context, step, steps[index + 1]),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFunnelStep(BuildContext context, FunnelStep step, int index) {
    final conversionRate = step.conversionRate;
    final color = _getStepColor(conversionRate);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Text(
              '${index + 1}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${step.users} users',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(conversionRate * 100).toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                'conversion',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFunnelConnector(BuildContext context, FunnelStep currentStep, FunnelStep nextStep) {
    final dropOffRate = 1 - (nextStep.users / currentStep.users);
    final dropOffUsers = currentStep.users - nextStep.users;
    
    return Container(
      height: 40,
      child: Row(
        children: [
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_downward,
                  color: Colors.grey[600],
                  size: 16,
                ),
                Text(
                  '${dropOffUsers} dropped (${(dropOffRate * 100).toStringAsFixed(1)}%)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStepColor(double conversionRate) {
    if (conversionRate >= 0.7) return Colors.green;
    if (conversionRate >= 0.5) return Colors.orange;
    return Colors.red;
  }
}

/// Revenue chart widget with customizable time periods
class RevenueChartWidget extends StatefulWidget {
  final String title;
  final List<RevenueDataPoint> data;
  final Duration period;

  const RevenueChartWidget({
    super.key,
    this.title = 'Revenue Trend',
    required this.data,
    this.period = const Duration(days: 30),
  });

  @override
  State<RevenueChartWidget> createState() => _RevenueChartWidgetState();
}

class _RevenueChartWidgetState extends State<RevenueChartWidget> {
  String _selectedPeriod = '30D';

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                _buildPeriodSelector(),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: _buildTitlesData(),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _convertDataToSpots(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildRevenueStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: '7D', label: Text('7D')),
        ButtonSegment(value: '30D', label: Text('30D')),
        ButtonSegment(value: '90D', label: Text('90D')),
      ],
      selected: {_selectedPeriod},
      onSelectionChanged: (Set<String> selection) {
        setState(() {
          _selectedPeriod = selection.first;
        });
      },
    );
  }

  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index >= 0 && index < widget.data.length) {
              final date = widget.data[index].date;
              return Text(
                '${date.day}/${date.month}',
                style: const TextStyle(fontSize: 10),
              );
            }
            return const Text('');
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            return Text('\$${(value / 1000).toStringAsFixed(0)}k');
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  List<FlSpot> _convertDataToSpots() {
    return widget.data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.revenue);
    }).toList();
  }

  Widget _buildRevenueStats() {
    final totalRevenue = widget.data.fold<double>(0, (sum, point) => sum + point.revenue);
    final averageRevenue = totalRevenue / widget.data.length;
    final maxRevenue = widget.data.map((p) => p.revenue).reduce((a, b) => a > b ? a : b);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('Total', '\$${totalRevenue.toStringAsFixed(0)}', Colors.green),
        _buildStatItem('Average', '\$${averageRevenue.toStringAsFixed(0)}', Colors.blue),
        _buildStatItem('Peak', '\$${maxRevenue.toStringAsFixed(0)}', Colors.orange),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// User behavior heatmap widget
class UserBehaviorHeatmapWidget extends StatelessWidget {
  final List<HeatmapData> data;
  final String title;

  const UserBehaviorHeatmapWidget({
    super.key,
    required this.data,
    this.title = 'User Activity Heatmap',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildHeatmap(context),
            const SizedBox(height: 16),
            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmap(BuildContext context) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const hours = ['00', '06', '12', '18'];
    
    return Column(
      children: [
        // Hour labels
        Row(
          children: [
            const SizedBox(width: 40),
            ...hours.map((hour) => Expanded(
              child: Text(
                hour,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )),
          ],
        ),
        const SizedBox(height: 8),
        // Heatmap grid
        ...days.asMap().entries.map((dayEntry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    dayEntry.value,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                ...List.generate(24, (hour) {
                  final intensity = _getIntensity(dayEntry.key, hour);
                  return Expanded(
                    child: Container(
                      height: 20,
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: _getHeatmapColor(intensity),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Less',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(width: 8),
        ...List.generate(5, (index) {
          return Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: _getHeatmapColor(index / 4),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
        const SizedBox(width: 8),
        Text(
          'More',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  double _getIntensity(int day, int hour) {
    // Mock data - in real app, this would come from actual analytics
    if (day >= 5) return 0.8; // Weekend activity
    if (hour >= 9 && hour <= 17) return 0.6; // Business hours
    if (hour >= 18 && hour <= 22) return 0.9; // Evening peak
    return 0.2; // Low activity
  }

  Color _getHeatmapColor(double intensity) {
    final colors = [
      Colors.grey[200]!,
      Colors.blue[100]!,
      Colors.blue[300]!,
      Colors.blue[500]!,
      Colors.blue[700]!,
    ];
    final index = (intensity * (colors.length - 1)).round();
    return colors[index.clamp(0, colors.length - 1)];
  }
}

/// Performance metrics widget
class PerformanceMetricsWidget extends StatelessWidget {
  final List<PerformanceMetric> metrics;
  final String title;

  const PerformanceMetricsWidget({
    super.key,
    required this.metrics,
    this.title = 'Performance Metrics',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...metrics.map((metric) => _buildMetricItem(context, metric)),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(BuildContext context, PerformanceMetric metric) {
    final color = _getMetricColor(metric.score);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                metric.name,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Row(
                children: [
                  Text(
                    metric.value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _getMetricIcon(metric.score),
                    color: color,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: metric.score,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Color _getMetricColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  IconData _getMetricIcon(double score) {
    if (score >= 0.8) return Icons.check_circle;
    if (score >= 0.6) return Icons.warning;
    return Icons.error;
  }
}

// ============================================================================
// DATA MODELS
// ============================================================================

class RealTimeMetrics {
  final int activeUsers;
  final int liveBookings;
  final double revenuePerHour;
  final DateTime timestamp;

  RealTimeMetrics({
    required this.activeUsers,
    required this.liveBookings,
    required this.revenuePerHour,
    required this.timestamp,
  });

  factory RealTimeMetrics.mock() {
    return RealTimeMetrics(
      activeUsers: 156 + (DateTime.now().second % 20),
      liveBookings: 8 + (DateTime.now().second % 5),
      revenuePerHour: 1200 + (DateTime.now().second * 10),
      timestamp: DateTime.now(),
    );
  }
}

class FunnelStep {
  final String name;
  final int users;
  final double conversionRate;

  FunnelStep({
    required this.name,
    required this.users,
    required this.conversionRate,
  });
}

class RevenueDataPoint {
  final DateTime date;
  final double revenue;

  RevenueDataPoint({
    required this.date,
    required this.revenue,
  });
}

class HeatmapData {
  final int day;
  final int hour;
  final double intensity;

  HeatmapData({
    required this.day,
    required this.hour,
    required this.intensity,
  });
}

class PerformanceMetric {
  final String name;
  final String value;
  final double score;

  PerformanceMetric({
    required this.name,
    required this.value,
    required this.score,
  });
}