import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class CustomErrorWidget extends StatelessWidget {

  const CustomErrorWidget({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.onRetry,
    this.retryButtonText,
    this.customAction,
    this.showDetails = false,
    this.errorDetails,
  });

  // Constructor para errores de red
  const CustomErrorWidget.network({
    super.key,
    this.onRetry,
    this.retryButtonText = 'Reintentar',
    this.customAction,
    this.showDetails = false,
    this.errorDetails,
  }) : title = 'Error de conexión',
       message = 'No se pudo conectar al servidor. Verifica tu conexión a internet.',
       icon = Icons.wifi_off;

  // Constructor para errores de servidor
  const CustomErrorWidget.server({
    super.key,
    this.onRetry,
    this.retryButtonText = 'Reintentar',
    this.customAction,
    this.showDetails = false,
    this.errorDetails,
  }) : title = 'Error del servidor',
       message = 'Ocurrió un problema en el servidor. Inténtalo de nuevo más tarde.',
       icon = Icons.error_outline;

  // Constructor para errores de autenticación
  const CustomErrorWidget.auth({
    super.key,
    this.onRetry,
    this.retryButtonText = 'Iniciar sesión',
    this.customAction,
    this.showDetails = false,
    this.errorDetails,
  }) : title = 'Sesión expirada',
       message = 'Tu sesión ha expirado. Inicia sesión nuevamente.',
       icon = Icons.lock_outline;

  // Constructor para errores de permisos
  const CustomErrorWidget.permission({
    super.key,
    this.onRetry,
    this.retryButtonText = 'Configurar',
    this.customAction,
    this.showDetails = false,
    this.errorDetails,
  }) : title = 'Permisos requeridos',
       message = 'Esta función requiere permisos adicionales para funcionar.',
       icon = Icons.security;

  // Constructor para contenido no encontrado
  const CustomErrorWidget.notFound({
    super.key,
    this.onRetry,
    this.retryButtonText = 'Volver',
    this.customAction,
    this.showDetails = false,
    this.errorDetails,
  }) : title = 'Contenido no encontrado',
       message = 'El contenido que buscas no existe o ha sido eliminado.',
       icon = Icons.search_off;

  // Constructor genérico
  const CustomErrorWidget.generic({
    super.key,
    this.title = 'Algo salió mal',
    this.message = 'Ocurrió un error inesperado. Inténtalo de nuevo.',
    this.icon = Icons.error_outline,
    this.onRetry,
    this.retryButtonText = 'Reintentar',
    this.customAction,
    this.showDetails = false,
    this.errorDetails,
  });
  final String? title;
  final String? message;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String? retryButtonText;
  final Widget? customAction;
  final bool showDetails;
  final String? errorDetails;

  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de error
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Título del error
            if (title != null)
              Text(
                title!,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
            
            const SizedBox(height: 12),
            
            // Mensaje del error
            if (message != null)
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            
            const SizedBox(height: 24),
            
            // Botones de acción
            _buildActionButtons(context),
            
            // Detalles del error (expandible)
            if (showDetails && errorDetails != null) ...[
              const SizedBox(height: 16),
              _buildErrorDetails(context),
            ],
          ],
        ),
      ),
    );

  Widget _buildActionButtons(BuildContext context) {
    final buttons = <Widget>[];
    
    // Botón de reintentar
    if (onRetry != null) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: Text(retryButtonText ?? 'Reintentar'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
        ),
      );
    }
    
    // Acción personalizada
    if (customAction != null) {
      if (buttons.isNotEmpty) {
        buttons.add(const SizedBox(width: 12));
      }
      buttons.add(customAction!);
    }
    
    // Si no hay botones, mostrar uno por defecto
    if (buttons.isEmpty) {
      buttons.add(
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      );
    }
    
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: buttons,
    );
  }

  Widget _buildErrorDetails(BuildContext context) => ExpansionTile(
      title: const Text(
        'Detalles técnicos',
        style: TextStyle(fontSize: 14),
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: SelectableText(
            errorDetails!,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
    properties.add(StringProperty('message', message));
    properties.add(DiagnosticsProperty<IconData?>('icon', icon));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onRetry', onRetry));
    properties.add(StringProperty('retryButtonText', retryButtonText));
    properties.add(DiagnosticsProperty<bool>('showDetails', showDetails));
    properties.add(StringProperty('errorDetails', errorDetails));
  }
}

// Widget de error para uso en listas o grids
class CompactErrorWidget extends StatelessWidget {

  const CompactErrorWidget({
    required this.message, super.key,
    this.onRetry,
    this.icon,
  });
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.error_outline,
            size: 32,
            color: Colors.red[400],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Reintentar'),
            ),
          ],
        ],
      ),
    );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('message', message));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onRetry', onRetry));
    properties.add(DiagnosticsProperty<IconData?>('icon', icon));
  }
}

// Widget de error para uso en AppBar o SnackBar
class InlineErrorWidget extends StatelessWidget {

  const InlineErrorWidget({
    required this.message, super.key,
    this.onDismiss,
    this.onRetry,
  });
  final String message;
  final VoidCallback? onDismiss;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.red[50],
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 20,
            color: Colors.red[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red[800],
                fontSize: 14,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('message', message));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onDismiss', onDismiss));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onRetry', onRetry));
  }
}