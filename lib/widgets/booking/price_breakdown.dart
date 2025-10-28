import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:salas_beats/models/booking.dart';
import 'package:salas_beats/services/booking_service.dart';

class PriceBreakdown extends StatelessWidget {
  
  const PriceBreakdown({
    required this.priceCalculation, super.key,
    this.showTitle = false,
    this.isExpanded = true,
  });
  final PriceCalculation priceCalculation;
  final bool showTitle;
  final bool isExpanded;
  
  @override
  Widget build(BuildContext context) {
    if (isExpanded) {
      return _buildExpandedBreakdown(context);
    } else {
      return _buildCollapsedBreakdown(context);
    }
  }
  
  Widget _buildExpandedBreakdown(BuildContext context) => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showTitle) ...[
              Text(
                'Desglose de precios',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Precio base
            _buildPriceRow(
              context,
              label: 'Precio base (${priceCalculation.totalHours} horas)',
              amount: priceCalculation.basePrice,
            ),
            
            // Descuentos
            if (priceCalculation.breakdown.containsKey('discount') &&
            priceCalculation.breakdown['discount']! > 0) ...[
              const SizedBox(height: 8),
              _buildPriceRow(
                context,
                label: 'Descuento aplicado',
                amount: -priceCalculation.breakdown['discount']!,
                isDiscount: true,
              ),
            ],
            
            // Tarifas adicionales
            if (priceCalculation.breakdown.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...priceCalculation.breakdown.entries.where((entry) => entry.key != 'discount').map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _buildPriceRow(
                    context,
                    label: _formatFeeLabel(entry.key),
                    amount: entry.value,
                  ),
                ),
              ),
            ],
            
            // Subtotal
            const SizedBox(height: 8),
            _buildPriceRow(
              context,
              label: 'Subtotal',
              amount: priceCalculation.totalPrice - priceCalculation.taxes,
              isBold: true,
            ),
            
            // Impuestos
            if (priceCalculation.taxes > 0) ...[
              const SizedBox(height: 8),
              _buildPriceRow(
                context,
                label: 'Impuestos',
                amount: priceCalculation.taxes,
              ),
            ],
            
            // Comisión de la plataforma
            if (priceCalculation.serviceFee > 0) ...[
              const SizedBox(height: 8),
              _buildPriceRow(
                context,
                label: 'Comisión de servicio',
                amount: priceCalculation.serviceFee,
              ),
            ],
            
            const Divider(height: 24),
            
            // Total
            _buildPriceRow(
              context,
              label: 'Total',
              amount: priceCalculation.totalPrice,
              isTotal: true,
            ),
            
            // Información adicional omitida - currency no disponible
            
            // Nota sobre cancelación
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Los precios pueden variar según la política de cancelación y las fechas seleccionadas.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  
  Widget _buildCollapsedBreakdown(BuildContext context) => Card(
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Desglose de precios',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '\$${priceCalculation.totalPrice.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Precio base
                _buildPriceRow(
                  context,
                  label: 'Precio base (${priceCalculation.totalHours} horas)',
                  amount: priceCalculation.basePrice,
                ),
                
                // Descuentos
                if (priceCalculation.breakdown.containsKey('discount') && priceCalculation.breakdown['discount']! > 0) ...[
                  const SizedBox(height: 8),
                  _buildPriceRow(
                    context,
                    label: 'Descuento aplicado',
                    amount: -priceCalculation.breakdown['discount']!,
                    isDiscount: true,
                  ),
                ],
                
                // Tarifas adicionales
                if (priceCalculation.breakdown.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...priceCalculation.breakdown.entries.where((entry) => entry.key != 'discount').map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: _buildPriceRow(
                        context,
                        label: _formatFeeLabel(entry.key),
                        amount: entry.value,
                      ),
                    ),
                  ),
                ],
                
                // Impuestos y comisiones
                if (priceCalculation.taxes > 0) ...[
                  const SizedBox(height: 8),
                  _buildPriceRow(
                    context,
                    label: 'Impuestos',
                    amount: priceCalculation.taxes,
                  ),
                ],
                
                if (priceCalculation.serviceFee > 0) ...[
                  const SizedBox(height: 8),
                  _buildPriceRow(
                    context,
                    label: 'Comisión de servicio',
                    amount: priceCalculation.serviceFee,
                  ),
                ],
                
                const Divider(height: 16),
                
                // Total
                _buildPriceRow(
                  context,
                  label: 'Total',
                  amount: priceCalculation.totalPrice,
                  isTotal: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  
  Widget _buildPriceRow(
    BuildContext context, {
    required String label,
    required double amount,
    bool isTotal = false,
    bool isDiscount = false,
    bool isBold = false,
  }) {
    final textStyle = isTotal
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          )
        : isBold
            ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              )
            : Theme.of(context).textTheme.bodyMedium;
    
    final amountColor = isTotal
        ? Theme.of(context).primaryColor
        : isDiscount
            ? Colors.green[600]
            : null;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: textStyle,
          ),
        ),
        Text(
          '${amount < 0 ? '-' : ''}\$${amount.abs().toStringAsFixed(2)}',
          style: textStyle?.copyWith(
            color: amountColor,
            fontWeight: isTotal ? FontWeight.bold : textStyle.fontWeight,
          ),
        ),
      ],
    );
  }
  
  String _formatFeeLabel(String feeKey) {
    switch (feeKey) {
      case 'cleaning_fee':
        return 'Tarifa de limpieza';
      case 'security_deposit':
        return 'Depósito de seguridad';
      case 'equipment_fee':
        return 'Tarifa de equipos';
      case 'late_night_fee':
        return 'Tarifa nocturna';
      case 'weekend_fee':
        return 'Tarifa de fin de semana';
      case 'holiday_fee':
        return 'Tarifa de día festivo';
      case 'peak_hours_fee':
        return 'Tarifa de horas pico';
      default:
        return feeKey.replaceAll('_', ' ').split(' ').map(
          (word) => word.isNotEmpty 
              ? word[0].toUpperCase() + word.substring(1).toLowerCase()
              : word,
        ).join(' ');
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<PriceCalculation>('priceCalculation', priceCalculation));
    properties.add(DiagnosticsProperty<bool>('showTitle', showTitle));
    properties.add(DiagnosticsProperty<bool>('isExpanded', isExpanded));
  }
}

// Widget para mostrar un resumen rápido del precio
class PriceSummary extends StatelessWidget {
  
  const PriceSummary({
    required this.priceCalculation, super.key,
    this.onTap,
  });
  final PriceCalculation priceCalculation;
  final VoidCallback? onTap;
  
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '\$${priceCalculation.totalPrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            if (onTap != null)
              Row(
                children: [
                  Text(
                    'Ver desglose',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
          ],
        ),
      ),
    );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<PriceCalculation>('priceCalculation', priceCalculation));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
  }
}