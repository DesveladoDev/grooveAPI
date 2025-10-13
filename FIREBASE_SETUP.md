# Configuración de Firebase - Guía Completa de Setup

> **Proyecto**: Salas and Beats  
> **Versión Firebase**: 10.x  
> **Flutter**: >=3.10.0  
> **Última actualización**: Enero 2025

## ✅ Estado Actual de Configuración

### 1. Archivos de Configuración

#### Android
- **Archivo creado**: `android/app/google-services.json` ✅
- **Estado**: Placeholder creado, necesita archivo real de Firebase Console
- **Prioridad**: 🟠 **ALTO** - Reemplazar con configuración real

#### iOS
- **Archivo creado**: `ios/Runner/GoogleService-Info.plist` ✅
- **Estado**: Placeholder creado, necesita archivo real de Firebase Console
- **Prioridad**: 🟠 **ALTO** - Reemplazar con configuración real

#### Web
- **Estado**: Firebase SDK configurado en `web/index.html` ✅
- **Versión**: Firebase v10.12.0 (compatible)
- **Scripts**: Todos los servicios necesarios incluidos

### 2. Configuración de Código

#### Firebase Options
- **Problema**: `main.dart` usaba inicialización sin opciones específicas de plataforma
- **Estado**: ✅ **CORREGIDO** - Creado `firebase_options.dart` y actualizado `main.dart`
- **Resultado**: Inicialización multiplataforma funcional

#### Valores Placeholder
- **Problema**: `main_simple.dart` y `firebase_options.dart` contienen valores de ejemplo
- **Impacto**: Conexión a Firebase fallará con valores ficticios
- **Prioridad**: 🟠 **ALTO** - Debe actualizarse antes del despliegue

### 3. Dependencias de Firebase
- **Estado**: ✅ **CORRECTO** - Versiones actualizadas en `pubspec.yaml`
- **Versiones instaladas**:
  - `firebase_core: ^4.1.0`
  - `firebase_auth: ^6.0.2`
  - `cloud_firestore: ^6.0.1`
  - `firebase_storage: ^13.0.1`
  - `firebase_messaging: ^16.0.1`
  - `firebase_analytics: ^12.0.1`
  - `firebase_crashlytics: ^5.0.1`

## ✅ Soluciones Implementadas

### 1. Archivo firebase_options.dart
- ✅ Creado archivo de configuración centralizado
- ✅ Soporte para múltiples plataformas (Web, Android, iOS, macOS)
- ✅ Actualizado main.dart para usar configuración correcta

### 2. Estructura de Configuración
- ✅ Configuración preparada para todos los entornos
- ✅ Manejo de errores mejorado

## 🔧 Pasos para Completar la Configuración

### 1. Configurar Proyecto en Firebase Console

#### Paso 1.1: Crear/Verificar Proyecto
1. Ir a [Firebase Console](https://console.firebase.google.com/)
2. Crear nuevo proyecto o seleccionar `salas-and-beats`
3. Configurar nombre del proyecto: **"Salas and Beats"
4. Habilitar Google Analytics (recomendado)
5. Seleccionar región: **us-central1** (recomendado para Latinoamérica)

#### Paso 1.2: Habilitar Servicios Firebase
**Servicios REQUERIDOS** (en orden de prioridad):
1. **Authentication** - Sistema de usuarios
   - Métodos: Email/Password, Google Sign-In
2. **Firestore Database** - Base de datos principal
   - Modo: Producción (con reglas de seguridad)
3. **Storage** - Almacenamiento de archivos
   - Reglas de seguridad configuradas
4. **Cloud Messaging** - Notificaciones push
5. **Analytics** - Métricas de uso
6. **Crashlytics** - Reporte de errores

**Servicios OPCIONALES**:
- **Performance Monitoring** - Métricas de rendimiento
- **Remote Config** - Configuración remota
- **App Check** - Protección contra abuso

### 2. Configurar Aplicaciones por Plataforma

#### 2.1 Configuración Android
1. **En Firebase Console**:
   - Ir a `Project Settings` > `General`
   - Scroll hasta "Your apps"
   - Click "Add app" > Seleccionar Android

2. **Configurar App Android**:
   - **Package name**: `com.salasbeats.app` (verificar en `android/app/build.gradle`)
   - **App nickname**: "Salas and Beats Android"
   - **SHA-1**: Obtener con `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey`

3. **Descargar y colocar archivo**:
   ```bash
   # Descargar google-services.json desde Firebase Console
   # Colocar en: android/app/google-services.json
   ```

4. **Verificar configuración en `android/app/build.gradle`**:
   ```gradle
   // Debe estar presente:
   apply plugin: 'com.google.gms.google-services'
   ```

#### 2.2 Configuración iOS
1. **En Firebase Console**:
   - Click "Add app" > Seleccionar iOS
   - **Bundle ID**: `com.salasbeats.app` (verificar en `ios/Runner.xcodeproj`)
   - **App nickname**: "Salas and Beats iOS"

2. **Descargar y colocar archivo**:
   ```bash
   # Descargar GoogleService-Info.plist desde Firebase Console
   # Colocar en: ios/Runner/GoogleService-Info.plist
   ```

3. **Configurar en Xcode**:
   - Abrir `ios/Runner.xcworkspace`
   - Arrastrar `GoogleService-Info.plist` al proyecto
   - Asegurar que esté en el target "Runner"

#### 2.3 Configuración Web
1. **En Firebase Console**:
   - Click "Add app" > Seleccionar Web
   - **App nickname**: "Salas and Beats Web"
   - **Hosting**: Seleccionar si planeas usar Firebase Hosting

2. **Copiar configuración** y actualizar `lib/firebase_options.dart`

3. **Actualizar `web/index.html`** (ver sección 4)

### 3. Actualizar firebase_options.dart

#### 3.1 Obtener Configuración Real
1. En Firebase Console > Project Settings > General
2. Scroll hasta "Your apps" > Seleccionar app Web
3. Click en "Config" para ver la configuración

#### 3.2 Reemplazar Valores Placeholder
Editar `lib/firebase_options.dart` y reemplazar:

```dart
// ❌ VALORES ACTUALES (placeholder):
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyBXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',     // ← CAMBIAR
  appId: '1:123456789:web:abcdefghijklmnop',          // ← CAMBIAR
  messagingSenderId: '123456789',                     // ← CAMBIAR
  projectId: 'salas-and-beats',                       // ← VERIFICAR
  authDomain: 'salas-and-beats.firebaseapp.com',     // ← VERIFICAR
  storageBucket: 'salas-and-beats.appspot.com',      // ← VERIFICAR
  measurementId: 'G-XXXXXXXXXX',                      // ← CAMBIAR
);

// ✅ REEMPLAZAR CON VALORES REALES DE FIREBASE CONSOLE
```

#### 3.3 Configuraciones por Plataforma
- **Android**: Actualizar `android` FirebaseOptions
- **iOS**: Actualizar `ios` FirebaseOptions  
- **macOS**: Actualizar `macos` FirebaseOptions (si aplica)

> ⚠️ **IMPORTANTE**: Cada plataforma tiene diferentes `appId` y `apiKey`

### 4. Configurar Web (index.html)

#### 4.1 Agregar Firebase SDK
Editar `web/index.html` y agregar antes de `</body>`:

```html
<!-- Firebase SDK v10.x (Compatible con Flutter Web) -->
<script src="https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.12.0/firebase-firestore-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.12.0/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.12.0/firebase-storage-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.12.0/firebase-analytics-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.12.0/firebase-performance-compat.js"></script>
```

#### 4.2 Verificar Compatibilidad
- ✅ Usar versión **10.12.0** (compatible con firebase_core ^4.1.0)
- ✅ Usar scripts **-compat** para compatibilidad con Flutter Web
- ❌ NO usar versión 11.x (incompatible con versiones actuales)

#### 4.3 Configuración Adicional Web
Si usas Firebase Hosting, agregar también:

```html
<!-- Firebase Hosting -->
<script src="https://www.gstatic.com/firebasejs/10.12.0/firebase-hosting-compat.js"></script>
```

### 5. Verificar y Probar Configuración

#### 5.1 Limpiar y Reconstruir
```bash
# Limpiar caché y dependencias
flutter clean
flutter pub get

# Verificar que no hay errores de dependencias
flutter doctor
flutter analyze
```

#### 5.2 Probar por Plataforma
```bash
# Probar Android (requiere google-services.json)
flutter run -d android

# Probar iOS (requiere GoogleService-Info.plist)
flutter run -d ios

# Probar Web (requiere Firebase SDK en index.html)
flutter run -d web-server --web-port 8080
```

#### 5.3 Verificar Conexión Firebase
1. **Logs de inicialización**: Buscar "Firebase initialized" en logs
2. **Firebase Console**: Verificar que aparezcan eventos en Analytics
3. **Crashlytics**: Forzar un crash de prueba
4. **Authentication**: Probar registro/login de usuario

#### 5.4 Comandos de Diagnóstico
```bash
# Verificar configuración Firebase
firebase projects:list
firebase use --add  # Seleccionar proyecto

# Verificar reglas de Firestore
firebase firestore:rules:get

# Probar con emuladores locales
firebase emulators:start
```

### 6. Configurar Variables de Entorno

Crear archivo `.env` basado en `.env.example`:

```bash
cp .env.example .env
# Editar .env con valores reales
```

## 🔍 Checklist de Verificación

### ✅ Archivos Completados
- ✅ `lib/firebase_options.dart` - Estructura creada
- ✅ `lib/main.dart` - Inicialización actualizada
- ✅ `pubspec.yaml` - Dependencias Firebase actualizadas
- ✅ `firebase.json` - Configuración de servicios
- ✅ `firestore.rules` - Reglas de seguridad
- ✅ `.firebaserc` - Configuración de proyectos

### 🔄 Archivos a Actualizar
- 🔄 `android/app/google-services.json` - **Reemplazar placeholder con archivo real**
- 🔄 `ios/Runner/GoogleService-Info.plist` - **Reemplazar placeholder con archivo real**
- ✅ `.env` - Variables de entorno creadas

### 🔄 Configuraciones a Actualizar
- 🔄 `lib/firebase_options.dart` - Reemplazar valores placeholder
- ✅ `web/index.html` - Firebase SDK v10.12.0 configurado
- ✅ `android/app/build.gradle` - Plugin Google Services configurado
- 🔄 `ios/Runner.xcodeproj` - Agregar GoogleService-Info.plist real al proyecto

### 🧪 Pruebas Requeridas
- 🔄 Conexión Firebase en Android (pendiente archivo real)
- 🔄 Conexión Firebase en iOS (pendiente archivo real)
- ✅ Conexión Firebase en Web (configurado)
- 🔄 Autenticación de usuarios
- 🔄 Lectura/escritura Firestore
- 🔄 Subida de archivos a Storage

## 🚨 Consideraciones Importantes

### 🔒 Seguridad
1. **Archivos sensibles**: ✅ Ya configurados en `.gitignore`:
   ```gitignore
   # Firebase config files (líneas 97-98, 102-106, 135-136)
   android/app/google-services.json
   ios/Runner/GoogleService-Info.plist
   .env
   .env.local
   .env.development
   .env.test
   .env.production
   ```
2. **Claves API**: Nunca hardcodear en código fuente
3. **Reglas Firestore**: Revisar y actualizar regularmente
4. **Autenticación**: Implementar validación robusta

### 🌍 Entornos
- **Desarrollo**: `salas-and-beats-dev`
- **Staging**: `salas-and-beats-staging`  
- **Producción**: `salas-and-beats`
- **Configurar en `.firebaserc`** para cambio fácil entre entornos

### 🧪 Testing y Desarrollo
- **Emuladores locales**: Usar para desarrollo sin costos
- **Firebase Local Emulator Suite**: Incluye Auth, Firestore, Storage
- **Datos de prueba**: No usar datos reales en desarrollo

### 📊 Monitoreo
- **Crashlytics**: Configurar alertas de errores críticos
- **Performance**: Monitorear tiempos de carga
- **Analytics**: Configurar eventos personalizados
- **Quotas**: Monitorear límites de Firestore y Storage

### 💰 Costos
- **Firestore**: Cobro por lectura/escritura/eliminación
- **Storage**: Cobro por almacenamiento y transferencia
- **Authentication**: Gratuito hasta cierto límite
- **Hosting**: Generoso plan gratuito

## 📞 Comandos de Referencia

### 🛠️ Setup Inicial
```bash
# Instalar Firebase CLI (requiere Node.js)
npm install -g firebase-tools@latest

# Verificar instalación
firebase --version

# Login a Firebase
firebase login

# Verificar proyectos disponibles
firebase projects:list
```

### 🏗️ Configuración Proyecto
```bash
# Inicializar Firebase en proyecto existente
firebase init

# Seleccionar proyecto específico
firebase use salas-and-beats

# Agregar alias para entornos
firebase use --add
```

### 🧪 Desarrollo Local
```bash
# Iniciar todos los emuladores
firebase emulators:start

# Iniciar emuladores específicos
firebase emulators:start --only firestore,auth

# Ejecutar con datos de prueba
firebase emulators:exec --import=./test-data "flutter test"
```

### 🚀 Despliegue
```bash
# Deploy completo
firebase deploy

# Deploy específico
firebase deploy --only firestore:rules
firebase deploy --only storage:rules
firebase deploy --only functions
firebase deploy --only hosting
```

### 🔍 Diagnóstico
```bash
# Ver logs de Cloud Functions
firebase functions:log

# Verificar reglas de Firestore
firebase firestore:rules:get

# Verificar configuración actual
firebase projects:list
firebase use
```

### 📱 Flutter + Firebase
```bash
# Generar firebase_options.dart automáticamente
flutterfire configure

# Limpiar y reconstruir
flutter clean && flutter pub get

# Ejecutar con perfil específico
flutter run --flavor development
flutter run --flavor production
```

---

## 🆘 Solución de Problemas Comunes

### Error: "google-services.json not found"
```bash
# Verificar ubicación del archivo
ls -la android/app/google-services.json

# Si no existe, descargar desde Firebase Console
# Project Settings > General > Your apps > Android
```

### Error: "Firebase not initialized"
```dart
// Verificar en main.dart:
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### Error: "Permission denied" en Firestore
```bash
# Verificar reglas en Firebase Console
# Firestore Database > Rules

# O verificar localmente
firebase firestore:rules:get
```

### Error de versiones incompatibles
```bash
# Actualizar dependencias
flutter pub upgrade

# Verificar compatibilidad
flutter doctor
```