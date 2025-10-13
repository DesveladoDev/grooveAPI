import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:salas_beats/widgets/common/custom_button.dart';

class PaymentMethodSelector extends StatefulWidget {
  
  const PaymentMethodSelector({
    required this.onPaymentMethodSelected, super.key,
    this.selectedPaymentMethodId,
    this.showAddButton = true,
  });
  final String? selectedPaymentMethodId;
  final ValueChanged<String?> onPaymentMethodSelected;
  final bool showAddButton;
  
  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('selectedPaymentMethodId', selectedPaymentMethodId));
    properties.add(ObjectFlagProperty<ValueChanged<String?>>.has('onPaymentMethodSelected', onPaymentMethodSelected));
    properties.add(DiagnosticsProperty<bool>('showAddButton', showAddButton));
  }
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  List<PaymentMethod> _paymentMethods = [];
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_paymentMethods.isEmpty) {
      return _buildEmptyState();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lista de métodos de pago
        ..._paymentMethods.map(_buildPaymentMethodTile),
        
        // Botón para agregar nuevo método
        if (widget.showAddButton) ...[
          const SizedBox(height: 16),
          _buildAddPaymentMethodButton(),
        ],
      ],
    );
  }
  
  Widget _buildPaymentMethodTile(PaymentMethod method) {
    final isSelected = widget.selectedPaymentMethodId == method.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => widget.onPaymentMethodSelected(method.id),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected 
                  ? Theme.of(context).primaryColor 
                  : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isSelected 
                ? Theme.of(context).primaryColor.withOpacity(0.05)
                : Colors.white,
          ),
          child: Row(
            children: [
              // Icono del método de pago
              _buildPaymentMethodIcon(method),
              const SizedBox(width: 16),
              
              // Información del método
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getPaymentMethodDisplayName(method),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getPaymentMethodDescription(method),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    if (method.isDefault) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Predeterminado',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Radio button
              Radio<String>(
                value: method.id,
                groupValue: widget.selectedPaymentMethodId,
                onChanged: (value) => widget.onPaymentMethodSelected(value),
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPaymentMethodIcon(PaymentMethod method) {
    IconData iconData;
    Color iconColor;
    
    switch (method.type) {
      case PaymentMethodType.card:
        iconData = _getCardIcon(method.cardBrand);
        iconColor = _getCardColor(method.cardBrand);
        break;
      case PaymentMethodType.paypal:
        iconData = Icons.paypal;
        iconColor = Colors.blue[600]!;
        break;
      case PaymentMethodType.applePay:
        iconData = Icons.apple;
        iconColor = Colors.black;
        break;
      case PaymentMethodType.googlePay:
        iconData = Icons.account_balance_wallet;
        iconColor = Colors.blue[600]!;
        break;
      default:
        iconData = Icons.payment;
        iconColor = Colors.grey[600]!;
    }
    
    return Container(
      width: 48,
      height: 32,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }
  
  Widget _buildEmptyState() => Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.payment,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay métodos de pago',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega un método de pago para continuar con tu reserva',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Agregar método de pago',
              onPressed: _showAddPaymentMethodDialog,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  
  Widget _buildAddPaymentMethodButton() => CustomButton(
      text: 'Agregar nuevo método de pago',
      onPressed: _showAddPaymentMethodDialog,
      isOutlined: true,
      icon: const Icon(Icons.add),
    );
  
  // Métodos de funcionalidad
  Future<void> _loadPaymentMethods() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // TODO: Implementar carga real desde el servicio de pagos
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Datos mock
      _paymentMethods = [
        PaymentMethod(
          id: 'pm_1',
          type: PaymentMethodType.card,
          cardBrand: CardBrand.visa,
          last4: '4242',
          expiryMonth: 12,
          expiryYear: 2025,
          isDefault: true,
        ),
        PaymentMethod(
          id: 'pm_2',
          type: PaymentMethodType.card,
          cardBrand: CardBrand.mastercard,
          last4: '5555',
          expiryMonth: 8,
          expiryYear: 2024,
        ),
      ];
      
      // Seleccionar el método predeterminado si no hay ninguno seleccionado
      if (widget.selectedPaymentMethodId == null && _paymentMethods.isNotEmpty) {
        final defaultMethod = _paymentMethods.firstWhere(
          (method) => method.isDefault,
          orElse: () => _paymentMethods.first,
        );
        widget.onPaymentMethodSelected(defaultMethod.id);
      }
      
    } catch (e) {
      // Manejar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar métodos de pago: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _showAddPaymentMethodDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddPaymentMethodSheet(),
    ).then((result) {
      if (result == true) {
        _loadPaymentMethods();
      }
    });
  }
  
  String _getPaymentMethodDisplayName(PaymentMethod method) {
    switch (method.type) {
      case PaymentMethodType.card:
        return '${_getCardBrandName(method.cardBrand)} •••• ${method.last4}';
      case PaymentMethodType.paypal:
        return 'PayPal';
      case PaymentMethodType.applePay:
        return 'Apple Pay';
      case PaymentMethodType.googlePay:
        return 'Google Pay';
      default:
        return 'Método de pago';
    }
  }
  
  String _getPaymentMethodDescription(PaymentMethod method) {
    switch (method.type) {
      case PaymentMethodType.card:
        return 'Vence ${method.expiryMonth.toString().padLeft(2, '0')}/${method.expiryYear}';
      case PaymentMethodType.paypal:
        return 'Cuenta de PayPal';
      case PaymentMethodType.applePay:
        return 'Pago con Touch ID o Face ID';
      case PaymentMethodType.googlePay:
        return 'Pago rápido y seguro';
      default:
        return '';
    }
  }
  
  IconData _getCardIcon(CardBrand? brand) {
    switch (brand) {
      case CardBrand.visa:
        return Icons.credit_card;
      case CardBrand.mastercard:
        return Icons.credit_card;
      case CardBrand.amex:
        return Icons.credit_card;
      case CardBrand.discover:
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }
  
  Color _getCardColor(CardBrand? brand) {
    switch (brand) {
      case CardBrand.visa:
        return Colors.blue[600]!;
      case CardBrand.mastercard:
        return Colors.red[600]!;
      case CardBrand.amex:
        return Colors.green[600]!;
      case CardBrand.discover:
        return Colors.orange[600]!;
      default:
        return Colors.grey[600]!;
    }
  }
  
  String _getCardBrandName(CardBrand? brand) {
    switch (brand) {
      case CardBrand.visa:
        return 'Visa';
      case CardBrand.mastercard:
        return 'Mastercard';
      case CardBrand.amex:
        return 'American Express';
      case CardBrand.discover:
        return 'Discover';
      default:
        return 'Tarjeta';
    }
  }
}

// Modelos de datos
class PaymentMethod {
  
  PaymentMethod({
    required this.id,
    required this.type,
    this.cardBrand,
    this.last4,
    this.expiryMonth,
    this.expiryYear,
    this.isDefault = false,
    this.nickname,
  });
  final String id;
  final PaymentMethodType type;
  final CardBrand? cardBrand;
  final String? last4;
  final int? expiryMonth;
  final int? expiryYear;
  final bool isDefault;
  final String? nickname;
}

enum PaymentMethodType {
  card,
  paypal,
  applePay,
  googlePay,
}

enum CardBrand {
  visa,
  mastercard,
  amex,
  discover,
  unknown,
}

// Widget para agregar nuevo método de pago
class AddPaymentMethodSheet extends StatefulWidget {
  const AddPaymentMethodSheet({super.key});
  
  @override
  State<AddPaymentMethodSheet> createState() => _AddPaymentMethodSheetState();
}

class _AddPaymentMethodSheetState extends State<AddPaymentMethodSheet> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  
  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Agregar tarjeta',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Formulario
          Form(
            key: _formKey,
            child: Column(
              children: [
                // Número de tarjeta
                TextFormField(
                  controller: _cardNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Número de tarjeta',
                    hintText: '1234 5678 9012 3456',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa el número de tarjeta';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Fecha de expiración y CVV
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expiryController,
                        decoration: const InputDecoration(
                          labelText: 'MM/AA',
                          hintText: '12/25',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Fecha requerida';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _cvvController,
                        decoration: const InputDecoration(
                          labelText: 'CVV',
                          hintText: '123',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'CVV requerido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Nombre en la tarjeta
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre en la tarjeta',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa el nombre en la tarjeta';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Botón de guardar
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Agregar tarjeta',
                    onPressed: _isLoading ? null : _savePaymentMethod,
                    isLoading: _isLoading,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  
  Future<void> _savePaymentMethod() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // TODO: Implementar guardado real del método de pago
      await Future.delayed(const Duration(seconds: 2));
      
      Navigator.of(context).pop(true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Método de pago agregado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al agregar método de pago: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}