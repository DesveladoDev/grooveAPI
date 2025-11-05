import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'image_utils.dart';

/// Estado de energía de la app
enum PowerState { normal, low }

/// Gestor global de bajo consumo
class PowerModeManager with WidgetsBindingObserver {
  PowerModeManager._();
  static PowerModeManager? _instance;
  static PowerModeManager get instance => _instance ??= PowerModeManager._();

  final ValueNotifier<PowerState> _state = ValueNotifier(PowerState.normal);
  PowerState get state => _state.value;
  bool get isLowPower => _state.value == PowerState.low;
  Listenable get stateListenable => _state;

  // Callbacks para reaccionar a cambios de modo
  final List<void Function(PowerState)> _listeners = [];

  void addListener(void Function(PowerState) listener) => _listeners.add(listener);
  void removeListener(void Function(PowerState) listener) => _listeners.remove(listener);

  Future<void> initialize() async {
    WidgetsBinding.instance.addObserver(this);
    // Aplicar perfil por defecto al iniciar
    _applyImageCacheProfile(PowerState.normal);
  }

  // Entrar en modo de bajo consumo
  void enableLowPower({String? reason}) {
    if (_state.value == PowerState.low) return;
    _state.value = PowerState.low;
    _applyImageCacheProfile(PowerState.low);
    for (final l in _listeners) l(PowerState.low);
    debugPrint('PowerMode: LOW ${reason != null ? '(reason: $reason)' : ''}');
  }

  // Salir de modo de bajo consumo
  void disableLowPower({String? reason}) {
    if (_state.value == PowerState.normal) return;
    _state.value = PowerState.normal;
    _applyImageCacheProfile(PowerState.normal);
    for (final l in _listeners) l(PowerState.normal);
    debugPrint('PowerMode: NORMAL ${reason != null ? '(reason: $reason)' : ''}');
  }

  // Ajusta un intervalo base según el modo actual
  Duration adjustedInterval(Duration base, {double lowPowerFactor = 2.5}) {
    if (isLowPower) {
      final ms = (base.inMilliseconds * lowPowerFactor).round();
      return Duration(milliseconds: ms);
    }
    return base;
  }

  // Observa el ciclo de vida para activar bajo consumo automáticamente
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      enableLowPower(reason: 'app_lifecycle:${state.name}');
    } else if (state == AppLifecycleState.resumed) {
      disableLowPower(reason: 'app_resumed');
    }
  }

  // Reduce el tamaño de caché de imágenes en bajo consumo
  void _applyImageCacheProfile(PowerState state) {
    try {
      final cache = PaintingBinding.instance.imageCache;
      if (state == PowerState.low) {
        // Perfil conservador
        cache.maximumSize = 100; // entradas
        cache.maximumSizeBytes = 64 * 1024 * 1024; // 64MB
        ImageCacheManager.setMaxCacheSize(30);
      } else {
        // Perfil normal
        cache.maximumSize = 300;
        cache.maximumSizeBytes = 128 * 1024 * 1024; // 128MB
        ImageCacheManager.setMaxCacheSize(50);
      }
    } catch (e) {
      debugPrint('PowerMode: error applying image cache profile: $e');
    }
  }
}