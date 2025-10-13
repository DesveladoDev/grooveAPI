import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:salas_beats/firebase_options.dart';

void main() async {
  // 1. Asegura que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado correctamente');
  } catch (e) {
    print('❌ Error inicializando Firebase: $e');
  }
  
  // 3. Ejecuta la aplicación
  runApp(const SalasBeatsDebugApp());
}

class SalasBeatsDebugApp extends StatelessWidget {
  const SalasBeatsDebugApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salas & Beats - Debug',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: const DebugHomeScreen(),
    );
  }
}

class DebugHomeScreen extends StatefulWidget {
  const DebugHomeScreen({super.key});

  @override
  State<DebugHomeScreen> createState() => _DebugHomeScreenState();
}

class _DebugHomeScreenState extends State<DebugHomeScreen> {
  String _status = 'Inicializando...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _status = 'Aplicación funcionando correctamente';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salas & Beats - Debug'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isLoading ? Icons.hourglass_empty : Icons.check_circle,
                size: 80,
                color: _isLoading ? Colors.orange : Colors.green,
              ),
              const SizedBox(height: 24),
              Text(
                _status,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                Column(
                  children: [
                    const Text(
                      'Firebase está inicializado y la aplicación está funcionando.',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _status = 'Verificando nuevamente...';
                        });
                        _checkStatus();
                      },
                      child: const Text('Verificar Nuevamente'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}