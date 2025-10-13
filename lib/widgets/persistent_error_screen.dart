import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../services/error_persistence_service.dart';

class PersistentErrorScreen extends StatelessWidget {
  final FlutterErrorDetails? details;

  const PersistentErrorScreen({super.key, this.details});

  static Future<void> show(
    BuildContext? context, {
    required FlutterErrorDetails details,
    GlobalKey<NavigatorState>? navigatorKey,
  }) async {
    // Guardar el error de forma persistente
    await ErrorPersistenceService.save(details);

    // Decidir el navigator para mostrar la pantalla
    final NavigatorState? nav = navigatorKey?.currentState ??
        (context != null ? Navigator.of(context, rootNavigator: true) : null);
    if (nav == null) return;

    // Empujar pantalla en el root navigator
    nav.push(MaterialPageRoute(
      builder: (_) => PersistentErrorScreen(details: details),
      fullscreenDialog: true,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8B0000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5A0000),
        title: const Text('Error en la aplicación'),
        actions: [
          IconButton(
            tooltip: 'Copiar',
            icon: const Icon(Icons.copy),
          onPressed: () async {
              final info = await ErrorPersistenceService.load();
              final text = _composeText(info);
              await Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error copiado al portapapeles')),
              );
            },
          ),
          IconButton(
            tooltip: 'Limpiar',
            icon: const Icon(Icons.delete_forever),
            onPressed: () async {
              await ErrorPersistenceService.clear();
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: FutureBuilder<LastErrorInfo?>(
        future: ErrorPersistenceService.load(),
        builder: (context, snapshot) {
          final info = snapshot.data;
          final text = _composeText(info);
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.yellow,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static String _composeText(LastErrorInfo? info) {
    if (info == null) return 'No hay errores persistidos.';
    final buffer = StringBuffer();
    buffer.writeln('[${info.timestamp.toIso8601String()}]');
    if (info.library != null && info.library!.isNotEmpty) {
      buffer.writeln('library: ${info.library}');
    }
    if (info.context != null && info.context!.isNotEmpty) {
      buffer.writeln('context: ${info.context}');
    }
    buffer.writeln(info.message);
    buffer.writeln(info.stackTrace);
    buffer.writeln('\nMás info: https://docs.flutter.dev/testing/errors');
    return buffer.toString();
  }
}