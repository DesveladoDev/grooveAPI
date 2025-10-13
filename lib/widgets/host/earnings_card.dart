import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salas_beats/providers/stripe_provider.dart';
import 'package:salas_beats/utils/app_routes.dart';

class EarningsCard extends StatelessWidget {
  const EarningsCard({super.key});
  
  @override
  Widget build(BuildContext context) => Consumer<StripeProvider>(
      builder: (context, stripeProvider, child) => Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ganancias del mes',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed(
                        AppRoutes.hostEarnings,
                      ),
                      child: const Text('Ver detalles'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Earnings overview
                if (stripeProvider.hasActiveConnectAccount)
                  _buildEarningsOverview(context, stripeProvider)
                else
                  _buildSetupPrompt(context),
              ],
            ),
          ),
        ),
    );
  
  Widget _buildEarningsOverview(
    BuildContext context,
    StripeProvider stripeProvider,
  ) {
    // Mock data - en producción vendría del provider
    const monthlyEarnings = 0.0;
    const pendingEarnings = 0.0;
    const availableEarnings = 0.0;
    const totalBookings = 0;
    
    return Column(
      children: [
        // Ganancia principal del mes
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ganancias de ${_getCurrentMonthName()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${monthlyEarnings.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    monthlyEarnings > 0 ? Icons.trending_up : Icons.trending_flat,
                    color: Colors.white.withOpacity(0.9),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    monthlyEarnings > 0 
                        ? '+${((monthlyEarnings / 1000) * 100).toStringAsFixed(1)}% vs mes anterior'
                        : 'Aún no hay ganancias este mes',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Desglose de ganancias
        Row(
          children: [
            Expanded(
              child: _buildEarningsBreakdown(
                context,
                title: 'Pendiente',
                amount: pendingEarnings,
                icon: Icons.schedule,
                color: Colors.orange,
                subtitle: 'Se liberará pronto',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildEarningsBreakdown(
                context,
                title: 'Disponible',
                amount: availableEarnings,
                icon: Icons.account_balance_wallet,
                color: Colors.green,
                subtitle: 'Listo para retiro',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Estadísticas adicionales
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(
                context,
                label: 'Reservas',
                value: totalBookings.toString(),
                icon: Icons.calendar_today,
              ),
              _buildStatColumn(
                context,
                label: 'Tarifa promedio',
                value: totalBookings > 0 
                    ? '\$${(monthlyEarnings / totalBookings).toStringAsFixed(0)}'
                    : r'$0',
                icon: Icons.attach_money,
              ),
              _buildStatColumn(
                context,
                label: 'Comisión',
                value: '15%', // Comisión de la plataforma
                icon: Icons.percent,
              ),
            ],
          ),
        ),
        
        // Botones de acción
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: availableEarnings > 0 
                    ? () => _showWithdrawDialog(context, availableEarnings)
                    : null,
                icon: const Icon(Icons.download),
                label: const Text('Retirar fondos'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pushNamed(
                  AppRoutes.hostEarnings,
                ),
                icon: const Icon(Icons.analytics),
                label: const Text('Ver reportes'),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildSetupPrompt(BuildContext context) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance,
            size: 48,
            color: Colors.blue[600],
          ),
          const SizedBox(height: 16),
          Text(
            'Configura tu cuenta de pagos',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Completa la configuración de Stripe para empezar a recibir pagos de tus reservas.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.blue[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed(
              AppRoutes.hostDashboard,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Configurar ahora'),
          ),
        ],
      ),
    );
  
  Widget _buildEarningsBreakdown(
    BuildContext context, {
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  
  Widget _buildStatColumn(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) => Column(
      children: [
        Icon(
          icon,
          color: Colors.grey[600],
          size: 20,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  
  // Métodos auxiliares
  String _getCurrentMonthName() {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    return months[DateTime.now().month - 1];
  }
  
  void _showWithdrawDialog(BuildContext context, double availableAmount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retirar fondos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fondos disponibles: \$${availableAmount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Los fondos se transferirán a tu cuenta bancaria registrada en un plazo de 1-3 días hábiles.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No hay comisiones por retiro',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _processWithdrawal(context, availableAmount);
            },
            child: const Text('Confirmar retiro'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _processWithdrawal(BuildContext context, double amount) async {
    // TODO: Implementar lógica de retiro con Stripe
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Retiro de \$${amount.toStringAsFixed(2)} procesado. '
          'Recibirás los fondos en 1-3 días hábiles.',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}

// Widget compacto para usar en otras pantallas
class CompactEarningsCard extends StatelessWidget {
  const CompactEarningsCard({super.key});
  
  @override
  Widget build(BuildContext context) => Consumer<StripeProvider>(
      builder: (context, stripeProvider, child) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ganancias del mes',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stripeProvider.hasActiveConnectAccount 
                          ? r'$0.00' 
                          : 'Configurar',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                stripeProvider.hasActiveConnectAccount 
                    ? Icons.trending_up 
                    : Icons.settings,
                color: Colors.white,
                size: 32,
              ),
            ],
          ),
        ),
    );
}