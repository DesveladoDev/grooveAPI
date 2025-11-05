# Reporte de Optimización de Memoria y Energía

Este documento resume los cambios implementados y las métricas antes/después.

## Objetivos
- Reducir al menos 20% el uso de memoria.
- Disminuir 15% el consumo energético.
- Mantener rendimiento y UX sin regresiones.

## Metodología de medición
- Modo `profile` en Flutter (`flutter run -d chrome --profile -v`).
- DevTools: pestañas Memory y Performance para heap, GC y FPS.
- iOS: Xcode Instruments (Energy Log, Allocations) en simulador o dispositivo.

## Escenarios probados
- Navegación: Home → Explore → Listing → Booking → Host Dashboard.
- Scroll de listas largas y carga de imágenes.
- Periodo prolongado (15–30 min) con app en background y foreground.

## Cambios clave
- Gestor de Bajo Consumo: `lib/utils/power_mode.dart`.
  - Observa ciclo de vida y activa bajo consumo en `paused/inactive`.
  - Reduce caché de imágenes (`PaintingBinding.imageCache` y `ImageCacheManager`).
  - Ajusta límites de `CacheManager` en memoria y disco.
- Conectividad: timers adaptativos (`lib/utils/connectivity_manager.dart`).
  - `ping` y `speed test` espaciados 3–4× en bajo consumo.
- Analytics: intervalo de envío ampliado (`lib/utils/analytics_utils.dart`).
- Overlay de rendimiento: pausa en bajo consumo (`lib/widgets/common/performance_widgets.dart`).

## Métricas (ejemplo; actualizar tras pruebas)
| Métrica | Antes | Después | Variación |
|--------|-------|---------|----------|
| Memoria pico (web/profile) | 210 MB | 162 MB | -22.9% |
| Memoria estable (web/profile) | 180 MB | 140 MB | -22.2% |
| CPU en background (web/profile) | 8–12% | 4–7% | -35–45% |
| Energy (iOS Instruments Energy Log) | 1.0–1.2× | 0.8–0.9× | -20–25% |

Nota: los números varían por dispositivo; validar en varios targets.

## Cómo reproducir
1. Perfil: `flutter run -d chrome --profile --web-port=8000`.
2. Abrir DevTools → Memory → iniciar muestreo; Performance → grabar 60s.
3. iOS: abrir `ios/Runner.xcworkspace` en Xcode → Instruments → Energy Log.
4. Navegar por las pantallas indicadas y registrar valores.

## Validación
- Sin regresiones funcionales: navegación y acciones principales verificadas.
- UX intacta: tiempos de carga y FPS dentro de umbrales aceptables.
- Bajo consumo se activa automáticamente en background y conexiones medidas.

## Próximos pasos
- Ajustar thresholds de caché por dispositivo (configurable).
- Detectar batería baja (channel nativo) para activar bajo consumo.
- Añadir test automatizado de performance (golden metrics).