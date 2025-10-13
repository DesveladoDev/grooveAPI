import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ReportsWidget extends StatelessWidget {

  const ReportsWidget({
    required this.reports, super.key,
    this.onGenerateReport,
    this.onDownloadReport,
    this.onViewReport,
    this.isLoading = false,
  });
  final List<ReportData> reports;
  final Function(ReportType)? onGenerateReport;
  final Function(ReportData)? onDownloadReport;
  final Function(ReportData)? onViewReport;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reportes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (onGenerateReport != null)
                  ElevatedButton.icon(
                    onPressed: () => _showGenerateReportDialog(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Generar Reporte'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Quick Report Actions
            Row(
              children: [
                Expanded(
                  child: QuickReportCard(
                    title: 'Ingresos Mensuales',
                    icon: Icons.trending_up,
                    color: Colors.green,
                    onTap: onGenerateReport != null
                        ? () => onGenerateReport!(ReportType.monthlyRevenue)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: QuickReportCard(
                    title: 'Reservas por Período',
                    icon: Icons.calendar_today,
                    color: Colors.blue,
                    onTap: onGenerateReport != null
                        ? () => onGenerateReport!(ReportType.bookingsByPeriod)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: QuickReportCard(
                    title: 'Rendimiento Anfitriones',
                    icon: Icons.people,
                    color: Colors.purple,
                    onTap: onGenerateReport != null
                        ? () => onGenerateReport!(ReportType.hostPerformance)
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Reports List
            const Text(
              'Reportes Generados',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (reports.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay reportes generados',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Genera tu primer reporte usando los botones de arriba',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reports.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  color: Colors.grey,
                ),
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return ReportTile(
                    report: report,
                    onView: onViewReport != null ? () => onViewReport!(report) : null,
                    onDownload: onDownloadReport != null ? () => onDownloadReport!(report) : null,
                  );
                },
              ),
          ],
        ),
      ),
    );

  void _showGenerateReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generar Reporte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ReportType.values.map((type) => ListTile(
              leading: Icon(_getReportTypeIcon(type)),
              title: Text(_getReportTypeTitle(type)),
              subtitle: Text(_getReportTypeDescription(type)),
              onTap: () {
                Navigator.of(context).pop();
                onGenerateReport?.call(type);
              },
            ),).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  IconData _getReportTypeIcon(ReportType type) {
    switch (type) {
      case ReportType.monthlyRevenue:
        return Icons.trending_up;
      case ReportType.bookingsByPeriod:
        return Icons.calendar_today;
      case ReportType.hostPerformance:
        return Icons.people;
      case ReportType.platformAnalytics:
        return Icons.analytics;
    }
  }

  String _getReportTypeTitle(ReportType type) {
    switch (type) {
      case ReportType.monthlyRevenue:
        return 'Ingresos Mensuales';
      case ReportType.bookingsByPeriod:
        return 'Reservas por Período';
      case ReportType.hostPerformance:
        return 'Rendimiento de Anfitriones';
      case ReportType.platformAnalytics:
        return 'Analíticas de Plataforma';
    }
  }

  String _getReportTypeDescription(ReportType type) {
    switch (type) {
      case ReportType.monthlyRevenue:
        return 'Ingresos y comisiones por mes';
      case ReportType.bookingsByPeriod:
        return 'Estadísticas de reservas por período';
      case ReportType.hostPerformance:
        return 'Métricas de rendimiento de anfitriones';
      case ReportType.platformAnalytics:
        return 'Analíticas generales de la plataforma';
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<ReportData>('reports', reports));
    properties.add(ObjectFlagProperty<Function(ReportType p1)?>.has('onGenerateReport', onGenerateReport));
    properties.add(ObjectFlagProperty<Function(ReportData p1)?>.has('onDownloadReport', onDownloadReport));
    properties.add(ObjectFlagProperty<Function(ReportData p1)?>.has('onViewReport', onViewReport));
    properties.add(DiagnosticsProperty<bool>('isLoading', isLoading));
  }
}

class QuickReportCard extends StatelessWidget {

  const QuickReportCard({
    required this.title, required this.icon, required this.color, super.key,
    this.onTap,
  });
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
    properties.add(DiagnosticsProperty<IconData>('icon', icon));
    properties.add(ColorProperty('color', color));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
  }
}

class ReportTile extends StatelessWidget {

  const ReportTile({
    required this.report, super.key,
    this.onView,
    this.onDownload,
  });
  final ReportData report;
  final VoidCallback? onView;
  final VoidCallback? onDownload;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          // Report Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getReportTypeColor(report.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getReportTypeIcon(report.type),
              color: _getReportTypeColor(report.type),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // Report Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Período: ${_formatDateRange(report.startDate, report.endDate)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    ReportStatusChip(status: report.status),
                    const SizedBox(width: 8),
                    Text(
                      'Generado ${_formatDate(report.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onView != null)
                IconButton(
                  onPressed: onView,
                  icon: const Icon(Icons.visibility),
                  tooltip: 'Ver reporte',
                  iconSize: 20,
                ),
              if (onDownload != null && report.status == ReportStatus.completed)
                IconButton(
                  onPressed: onDownload,
                  icon: const Icon(Icons.download),
                  tooltip: 'Descargar reporte',
                  iconSize: 20,
                ),
            ],
          ),
        ],
      ),
    );

  IconData _getReportTypeIcon(ReportType type) {
    switch (type) {
      case ReportType.monthlyRevenue:
        return Icons.trending_up;
      case ReportType.bookingsByPeriod:
        return Icons.calendar_today;
      case ReportType.hostPerformance:
        return Icons.people;
      case ReportType.platformAnalytics:
        return Icons.analytics;
    }
  }

  Color _getReportTypeColor(ReportType type) {
    switch (type) {
      case ReportType.monthlyRevenue:
        return Colors.green;
      case ReportType.bookingsByPeriod:
        return Colors.blue;
      case ReportType.hostPerformance:
        return Colors.purple;
      case ReportType.platformAnalytics:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  String _formatDateRange(DateTime start, DateTime end) => '${_formatDate(start)} - ${_formatDate(end)}';

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ReportData>('report', report));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onView', onView));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onDownload', onDownload));
  }
}

class ReportStatusChip extends StatelessWidget {

  const ReportStatusChip({required this.status, super.key});
  final ReportStatus status;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
        ),
      ),
      child: Text(
        _getStatusText(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: _getStatusColor(),
        ),
      ),
    );

  Color _getStatusColor() {
    switch (status) {
      case ReportStatus.generating:
        return Colors.orange;
      case ReportStatus.completed:
        return Colors.green;
      case ReportStatus.failed:
        return Colors.red;
    }
  }

  String _getStatusText() {
    switch (status) {
      case ReportStatus.generating:
        return 'Generando';
      case ReportStatus.completed:
        return 'Completado';
      case ReportStatus.failed:
        return 'Error';
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<ReportStatus>('status', status));
  }
}

class ReportData {

  const ReportData({
    required this.id,
    required this.title,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
    this.downloadUrl,
    this.data,
    this.errorMessage,
  });

  factory ReportData.fromMap(Map<String, dynamic> map) => ReportData(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      type: ReportType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'] as String?,
        orElse: () => ReportType.platformAnalytics,
      ),
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      status: ReportStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'] as String?,
        orElse: () => ReportStatus.generating,
      ),
      createdAt: DateTime.parse(map['createdAt'] as String),
      downloadUrl: map['downloadUrl'] as String?,
      data: map['data'] as Map<String, dynamic>?,
      errorMessage: map['errorMessage'] as String?,
    );
  final String id;
  final String title;
  final ReportType type;
  final DateTime startDate;
  final DateTime endDate;
  final ReportStatus status;
  final DateTime createdAt;
  final String? downloadUrl;
  final Map<String, dynamic>? data;
  final String? errorMessage;

  Map<String, dynamic> toMap() => {
      'id': id,
      'title': title,
      'type': type.toString().split('.').last,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'downloadUrl': downloadUrl,
      'data': data,
      'errorMessage': errorMessage,
    };
}

enum ReportType {
  monthlyRevenue,
  bookingsByPeriod,
  hostPerformance,
  platformAnalytics,
}

enum ReportStatus {
  generating,
  completed,
  failed,
}

class CompactReportsWidget extends StatelessWidget {

  const CompactReportsWidget({
    required this.recentReports, super.key,
    this.onViewAll,
    this.onQuickGenerate,
  });
  final List<ReportData> recentReports;
  final VoidCallback? onViewAll;
  final Function(ReportType)? onQuickGenerate;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Reportes Recientes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('Ver todos'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Quick Actions
          if (onQuickGenerate != null)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onQuickGenerate!(ReportType.monthlyRevenue),
                    icon: const Icon(Icons.trending_up, size: 16),
                    label: const Text('Ingresos', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onQuickGenerate!(ReportType.bookingsByPeriod),
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: const Text('Reservas', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    ),
                  ),
                ),
              ],
            ),
          
          if (onQuickGenerate != null)
            const SizedBox(height: 16),
          
          // Recent Reports
          if (recentReports.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No hay reportes recientes',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...recentReports.take(3).map(
              (report) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _getReportTypeColor(report.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        _getReportTypeIcon(report.type),
                        size: 16,
                        color: _getReportTypeColor(report.type),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _formatDate(report.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ReportStatusChip(status: report.status),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

  IconData _getReportTypeIcon(ReportType type) {
    switch (type) {
      case ReportType.monthlyRevenue:
        return Icons.trending_up;
      case ReportType.bookingsByPeriod:
        return Icons.calendar_today;
      case ReportType.hostPerformance:
        return Icons.people;
      case ReportType.platformAnalytics:
        return Icons.analytics;
    }
  }

  Color _getReportTypeColor(ReportType type) {
    switch (type) {
      case ReportType.monthlyRevenue:
        return Colors.green;
      case ReportType.bookingsByPeriod:
        return Colors.blue;
      case ReportType.hostPerformance:
        return Colors.purple;
      case ReportType.platformAnalytics:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<ReportData>('recentReports', recentReports));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onViewAll', onViewAll));
    properties.add(ObjectFlagProperty<Function(ReportType p1)?>.has('onQuickGenerate', onQuickGenerate));
  }
}