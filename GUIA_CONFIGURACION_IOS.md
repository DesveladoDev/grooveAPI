# Guía de Configuración para iOS - Salas and Beats

## Estado Actual del Proyecto

✅ **Completado:**
- Archivos de configuración de iOS regenerados
- Bundle identifier configurado: `com.developeros.salasandbeats`
- GoogleService-Info.plist actualizado con el bundle ID correcto
- CocoaPods instalado correctamente
- Dependencias de Flutter actualizadas

## Requisitos Previos para Desarrollo iOS

### 1. Instalación de Xcode
**⚠️ REQUERIDO:** Xcode no está completamente instalado en tu sistema.

**Pasos para instalar Xcode:**
1. Descarga Xcode desde el App Store o desde [developer.apple.com/xcode](https://developer.apple.com/xcode/)
2. Una vez instalado, ejecuta los siguientes comandos:
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```

### 2. Configuración de Simuladores iOS
Después de instalar Xcode:
1. Abre Xcode
2. Ve a **Window > Devices and Simulators**
3. Crea un simulador iOS (recomendado: iPhone 15 con iOS 17+)

## Cómo Probar la Aplicación en iOS

### Opción 1: Usando el Simulador iOS (Recomendado)

1. **Verificar simuladores disponibles:**
   ```bash
   flutter emulators
   ```

2. **Iniciar un simulador iOS:**
   ```bash
   flutter emulators --launch <ios_simulator_id>
   ```

3. **Ejecutar la aplicación:**
   ```bash
   flutter run
   ```
   O específicamente para iOS:
   ```bash
   flutter run -d ios
   ```

### Opción 2: Usando un Dispositivo iOS Físico

1. **Conectar el dispositivo iOS** via USB
2. **Habilitar modo desarrollador** en el dispositivo:
   - Configuración > Privacidad y Seguridad > Modo Desarrollador
3. **Confiar en el certificado** cuando se solicite
4. **Ejecutar la aplicación:**
   ```bash
   flutter run -d <device_id>
   ```

### Opción 3: Compilar para Distribución

Para crear un archivo .ipa para distribución:
```bash
flutter build ios --release
```

## Comandos Útiles para Desarrollo iOS

### Verificar Estado del Entorno
```bash
flutter doctor -v
```

### Limpiar y Reconstruir
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter build ios --no-codesign
```

### Ver Dispositivos Conectados
```bash
flutter devices
```

### Ver Logs en Tiempo Real
```bash
flutter logs
```

## Configuración de Firebase para iOS

✅ **Ya configurado:**
- `GoogleService-Info.plist` está en `ios/Runner/`
- Bundle ID actualizado a `com.developeros.salasandbeats`

## Solución de Problemas Comunes

### Error: "Application not configured for iOS"
- Asegúrate de que Xcode esté completamente instalado
- Ejecuta `flutter clean` y `flutter pub get`
- Verifica que el bundle identifier sea consistente

### Error: "No iOS simulators available"
- Instala Xcode completamente
- Crea un simulador desde Xcode > Window > Devices and Simulators

### Error: "CocoaPods not found"
- Ya resuelto: CocoaPods está instalado via Homebrew

### Error de Certificados/Codesigning
Para desarrollo local, usa:
```bash
flutter run --no-codesign
```

## Próximos Pasos

1. **Instalar Xcode completamente**
2. **Configurar un simulador iOS**
3. **Ejecutar `flutter doctor` para verificar la configuración**
4. **Probar la aplicación con `flutter run`**

## Archivos de Configuración Importantes

- `ios/Runner/Info.plist` - Configuración de la aplicación
- `ios/Runner/GoogleService-Info.plist` - Configuración de Firebase
- `ios/Runner.xcodeproj/project.pbxproj` - Configuración del proyecto Xcode
- `ios/Podfile` - Se generará automáticamente al ejecutar Flutter

## Notas Adicionales

- El proyecto está configurado para usar el mismo package name que Android: `com.developeros.salasandbeats`
- Firebase está configurado para el proyecto `salas-and-beats`
- La aplicación soporta orientaciones portrait y landscape
- CocoaPods está instalado y listo para gestionar dependencias nativas

---

**Última actualización:** $(date)
**Estado:** Listo para desarrollo iOS una vez que Xcode esté instalado