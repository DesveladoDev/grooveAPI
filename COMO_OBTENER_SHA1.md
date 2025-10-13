# 🔑 Cómo Obtener el SHA-1 Fingerprint

## ¿Qué es el SHA-1 Fingerprint?

El SHA-1 fingerprint es una huella digital única de tu keystore de Android que Firebase necesita para verificar que tu app es legítima cuando usa Google Sign-In.

## 📍 Métodos para Obtener SHA-1

### Método 1: Usando Keytool (Requiere Java)

#### Paso 1: Instalar Java
```bash
# Opción A: Homebrew (Recomendado para macOS)
brew install openjdk@11

# Opción B: Descargar desde Oracle
# Ve a: https://www.oracle.com/java/technologies/downloads/
```

#### Paso 2: Obtener SHA-1 para Debug
```bash
# Para desarrollo (debug keystore)
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Busca la línea que dice "SHA1:"
# Ejemplo: SHA1: A1:B2:C3:D4:E5:F6:G7:H8:I9:J0:K1:L2:M3:N4:O5:P6:Q7:R8:S9:T0
```

#### Paso 3: Solo el SHA-1 (comando filtrado)
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1
```

### Método 2: Usando Gradle (Alternativa)

```bash
# Desde la carpeta android/ del proyecto
cd android
./gradlew signingReport

# Busca la sección "debug" y copia el SHA1
```

### Método 3: Usando Android Studio

1. **Abre Android Studio**
2. **Ve a:** View → Tool Windows → Terminal
3. **Ejecuta:**
   ```bash
   ./gradlew signingReport
   ```
4. **Busca la sección "debug"** y copia el SHA1

### Método 4: Usando Flutter (Más Simple)

```bash
# Desde la raíz del proyecto Flutter
flutter build apk --debug

# Luego usar keytool en el keystore generado
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

## 📋 Ubicaciones de Keystore

### Debug Keystore (Desarrollo)
```bash
# macOS/Linux
~/.android/debug.keystore

# Windows
C:\Users\[USERNAME]\.android\debug.keystore
```

### Release Keystore (Producción)
```bash
# Ubicación personalizada donde guardaste tu keystore de release
# Ejemplo: ~/keystores/release-key.keystore
```

## 🎯 Ejemplo de Salida

Cuando ejecutes el comando correctamente, verás algo así:

```
Alias name: androiddebugkey
Creation date: Jan 1, 2024
Entry type: PrivateKeyEntry
Certificate chain length: 1
Certificate[1]:
Owner: C=US, O=Android, CN=Android Debug
Issuer: C=US, O=Android, CN=Android Debug
Serial number: 1
Valid from: Mon Jan 01 00:00:00 UTC 2024 until: Wed Dec 31 23:59:59 UTC 2054
Certificate fingerprints:
	SHA1: A1:B2:C3:D4:E5:F6:G7:H8:I9:J0:K1:L2:M3:N4:O5:P6:Q7:R8:S9:T0
	SHA256: ...
```

**El SHA-1 que necesitas es:** `A1:B2:C3:D4:E5:F6:G7:H8:I9:J0:K1:L2:M3:N4:O5:P6:Q7:R8:S9:T0`

## 🔧 Solución de Problemas

### Error: "Unable to locate a Java Runtime"
```bash
# Instalar Java primero
brew install openjdk@11

# O descargar desde Oracle
```

### Error: "Keystore was tampered with, or password was incorrect"
```bash
# Verificar que uses la contraseña correcta:
# Debug keystore: password = "android"
# Release keystore: tu contraseña personalizada
```

### Error: "keytool: command not found"
```bash
# Java no está en el PATH, usar ruta completa:
/usr/libexec/java_home -v 11 --exec keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

## 📱 Para Diferentes Tipos de Build

### Debug (Desarrollo)
```bash
# Keystore automático de Android
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### Release (Producción)
```bash
# Tu keystore personalizado
keytool -list -v -keystore /ruta/a/tu/release-keystore.jks -alias tu-alias -storepass tu-password -keypass tu-key-password
```

## ✅ Pasos Después de Obtener SHA-1

1. **Copia el SHA-1** (formato: XX:XX:XX:XX:...)
2. **Ve a Firebase Console:** https://console.firebase.google.com/
3. **Selecciona tu proyecto**
4. **Ve a Project Settings > General**
5. **En "Your apps" selecciona Android**
6. **Agrega el SHA-1 fingerprint**
7. **Descarga el nuevo google-services.json**
8. **Reemplaza el archivo en android/app/google-services.json**

## 🚨 Importante

- **Para desarrollo:** Usa el debug keystore
- **Para producción:** Necesitarás crear y usar un release keystore
- **Cada keystore tiene un SHA-1 diferente**
- **Debes registrar ambos SHA-1 en Firebase si planeas publicar la app**

---

**💡 Tip:** Una vez que tengas el SHA-1 y lo registres en Firebase Console, el error de Google Sign-In (código 10) se resolverá completamente.